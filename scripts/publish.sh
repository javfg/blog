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
