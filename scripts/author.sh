#!/bin/bash

# ensure script is run from the root of the project
if [ ! -d "scripts" ]; then
    print_error "this script must be run from the root of the project"
    exit 1
fi

DATE=$(date +"%Y-%m-%d")
NEW_POST=$(date +"%Y-%m-%d")-${1:-untitled}

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
