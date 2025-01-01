+++
title = "Improving the usability of my blog"
date = 2025-01-01
[taxonomies]
tags=["blog"]
[extra]
thumb = "thumb.jpg"
+++

Another attempt to write more in here!

<!-- more -->

So, I've been thinking about how to improve the usability of my blog. All throughout
2024, I kept coming up with a whole bunch of articles I could write, but I never
got around to actually writing them. Many times the hassle of preparing everything
made me put it off for later.

To remove that excuse, I have come up with a set of scripts to make the process of
creating a new article and publishing it as easy as possible.

### Creating a new post

Now all I have to do is navigate to my blog's directory and run the following command:

```bash
make author
```

This will create a new markdown file in the `content` directory with the current date
and a placeholder title. The file will be opened in my text editor and `zola serve`
is run. All I have to do is start writing!

This script is extremely simple:

```bash
#!/bin/bash

# ensure script is run from the root of the project
if [ ! -d "scripts" ]; then
    print_error "this script must be run from the root of the project"
    exit 1
fi

DATE=$(date +"%Y-%m-%d")
NEW_POST=$DATE-${1:-untitled}

mkdir -p content/"$NEW_POST"
cat > content/"$NEW_POST"/index.md <<EOF
+++
title = "${1:-untitled}"
date = $DATE
[taxonomies]
tags=[]
[extra]
# thumb = "none.jpg"
+++

This is the description of the new post.

<!-- more -->

This is the body of the new post.
EOF

echo "new post created at content/$NEW_POST, starting editor and live preview..."
code .
zola serve
```


### Publishing a post

Once I'm done writing, I can run the following command:

```bash
make publish
```

And the post is published to my blog.

This script is a bit more complicated, and it needs some server-side setup. Let's
look at the code first:

```bash
#!/bin/bash
# shellcheck disable=SC2029

# functions to print status messages
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
print_info() {
    echo -e "${YELLOW}$1${NC}"
}
print_success() {
    echo -e "${GREEN}$1${NC}"
}
print_error() {
    echo -e "${RED}$1${NC}"
}

# ensure script is run from the root of the project
if [ ! -d "scripts" ]; then
    print_error "this script must be run from the root of the project"
    exit 1
fi

# load configuration
if [ -f ".env" ]; then
    set -a
    # shellcheck source=../.env
    source .env
    set +a
else
    print_error ".env file not found"
    exit 1
fi

# validate required variables are set
REQUIRED_VARS=("REMOTE_USER" "REMOTE_HOST" "REMOTE_PATH" "BASE_URL" "REMOTE_WEB_USER" "REMOTE_WEB_GROUP")
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        print_error "$var is not set in .env"
        exit 1
    fi
done

# build the static site
print_info "building the static site..."
rm -rf public
if ! zola build --base-url "$BASE_URL" --output-dir public > /dev/null
then
  print_error "failed to build the site"
  exit 1
fi

# create necessary remote directories and set permissions
print_info "setting up remote directories..."
if ! ssh "$REMOTE_USER"@"$REMOTE_HOST" "sudo mkdir -p $REMOTE_PATH && \
  sudo chown $REMOTE_WEB_USER:$REMOTE_WEB_GROUP $REMOTE_PATH && \
  sudo chmod 775 $REMOTE_PATH"
then
  print_error "failed to set up remote directories"
  exit 1
fi

# deploy files using rsync
print_info "deploying files..."
if ! rsync -qrlvz --no-group --no-times --delete --chmod=D775,F664 \
  public/ \
  "$REMOTE_USER"@"$REMOTE_HOST":"$REMOTE_PATH"/
then
  print_error "failed to sync files"
  exit 1
fi

print_success "deployment completed successfully!"
```

After some fancy color printing functions and configuration checks, it does the following:

1. Builds the static site with `zola build`.
2. Makes sure the blog root directory exists in the server and has the correct permissions.
3. Deploys the files to the server using `rsync`.

Obviously, you need both zola and rsync installed on your machine. This last step has some
quirks to ensure the permissions are set correctly in the server. It avoids setting the group
and time of the files, but it does set the permissions of directories to `775` and files to `664`.

To be able to run this, you need to create an `.env` file in the root of your project
with the following variables:

```bash
REMOTE_USER="your-ssh-user"
REMOTE_HOST="your-ssh-host"
REMOTE_PATH="/var/www/blog"
BASE_URL="https://your-blog-url"
REMOTE_WEB_USER="server-web-user"
REMOTE_WEB_GROUP="server-web-group"
```

You also need `NOPASSWD` sudo permissions on the server for the `REMOTE_USER` to run the
`mkdir`, `chown`, and `chmod` commands. This could be considered a security risk, but
we can limit the commands to only the necessary ones. Add the following line to your
`/etc/sudoers` file by running `sudo visudo`:

```bash
your-ssh-user ALL=(root) NOPASSWD:/usr/bin/mkdir -p /var/www/blog, /usr/bin/chown your-ssh-user\:server-web-user /var/www/blog, /usr/bin/chmod 775 /var/www/blog
```

Remember to replace `your-ssh-user` and `server-web-user` with the correct values.

It is cool that the sudoers file allows specifying the arguments of the commands.

---

That's it! I hope this will make it easier for me to write more often in 2025.
