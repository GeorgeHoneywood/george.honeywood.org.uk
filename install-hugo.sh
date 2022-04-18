#!/bin/bash

# this script could be reduced to a single line:
# > go install --tags extended "github.com/gohugoio/hugo@latest"
# I had fun writing it at least :)

function show_help () {
    echo "Installs a version of hugo, defaulting to latest"
    echo "Usage: ./install-hugo.sh [version] [--help]"
    echo "Find versions here: https://github.com/gohugoio/hugo/releases"
    exit 1
}

ARG="$1"
if [[ "$ARG" == "--help" ]]; then
    show_help
fi

VERSION=$ARG
if [[ "$VERSION" == "" ]]; then
    VERSION="latest"
    echo "Defaulting to latest version: $(go list -f '{{.Version}}' -m github.com/gohugoio/hugo@latest)"
    # could also get latest version from github, like so (but requires jq and curl):
    # > curl -s https://api.github.com/repos/gohugoio/hugo/releases/latest | jq -r '.tag_name'
elif [[ "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "User specified version: $VERSION"
else
    echo "Invalid version specified: $VERSION"
    show_help
fi

echo "Installing hugo@$VERSION..."
go install --tags extended "github.com/gohugoio/hugo@${VERSION}"

if [[ $? != 0 ]]; then
    echo "Failed to install hugo@$VERSION"
    exit 1
else
    echo "Installed $(hugo version)!"
fi
