#!/bin/bash
pushd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" > /dev/null

VERSION_URL=https://net-secondary.web.minecraft-services.net/api/v1.0/download/latest
DOWNLOAD_LINKS=https://net-secondary.web.minecraft-services.net/api/v1.0/download/links
DOWNLOAD_TYPE=serverJar

OLD_VERSION=""

if [ -f version ]; then
   OLD_VERSION=$(< version)
fi

LATEST_VERSION=$(curl "$VERSION_URL" -s | jq -r '.result')

if [ "$OLD_VERSION" == "$LATEST_VERSION" ]; then
  echo No update available \($LATEST_VERSION\)
  popd > /dev/null;
  exit 0
fi

DOWNLOAD_URL=$(curl "$DOWNLOAD_LINKS" -s | jq -r ".result.links | .[] | select(.downloadType == \"$DOWNLOAD_TYPE\") | .downloadUrl")
echo New version $LATEST_VERSION available, downloading from $DOWNLOAD_URL ...
curl -o minecraft_server.jar "$DOWNLOAD_URL"

echo Building container image ...
buildah build -t minecraft_server:latest -t minecraft_server:$LATEST_VERSION
echo $LATEST_VERSION > version

echo Updating running containers ...
podman auto-update

echo Cleaning up old versions ...
podman create --name keep-minecraft minecraft_server:latest
podman image prune -f
podman container prune -f

popd > /dev/null;
echo Complete!
