#!/usr/bin/env bash

VERSION="${VERSION:-"latest"}"

USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Ensure that login shells get the correct path if the user updated the PATH using ENV.
rm -f /etc/profile.d/00-restore-env.sh
echo "export PATH=${PATH//$(sh -lc 'echo $PATH')/\$PATH}" > /etc/profile.d/00-restore-env.sh
chmod +x /etc/profile.d/00-restore-env.sh

apt_get_update()
{
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}


# Insall Marksman if it's missing
if ! ./marksman-linux-x64 --version &> /dev/null ; then
	  echo "Installing Marksman..."
		apt_get_update
	  apt-get -y install --no-install-recommends jq curl tar xz-utils

    if [[ "$VERSION" == "latest" || -z "$VERSION" ]]; then
      echo "Fetching latest version..."
      
      update-ca-certificates
      curl -v -L -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "https://api.github.com/repos/artempyanykh/marksman/releases/latest"
      
      VERSION=$(curl -s -L -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "https://api.github.com/repos/artempyanykh/marksman/releases/latest" | jq -r .tag_name)
    fi

    IDENTIFIER="marksman-linux-x64"

    DOWNLOAD_URL=$(curl -s -L -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "https://api.github.com/repos/artempyanykh/marksman/releases/tags/${VERSION}" | \
       jq -r '.assets | map(select(.name=="'"$IDENTIFIER"'"))[0].browser_download_url')

    if [ -z "$DOWNLOAD_URL" ]; then
        echo "Error: Unable to find download URL for $IDENTIFIER and version $VERSION"
        exit 1
    fi

    echo "Downloading marksman from: ${DOWNLOAD_URL}"

    curl -s -L -o "/tmp/${IDENTIFIER}" "${DOWNLOAD_URL}"
    mv "/tmp/${IDENTIFIER}" /usr/local/bin/marksman
    chmod +x /usr/local/bin/marksman
fi

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
