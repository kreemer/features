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


# Insall JDTLS if it's missing
if ! which jdtls &> /dev/null ; then
	  echo "Installing jdtls..."
		apt_get_update
    apt-get -y install --no-install-recommends jq curl tar xz-utils ca-certificates libicu-dev

    if [[ "$VERSION" == "latest" || -z "$VERSION" ]]; then
      echo "Using last known published version..."
      VERSION="1.60.0"
    fi

    DOWNLOAD_FILE=$(curl -s -L "https://download.eclipse.org/jdtls/milestones/${VERSION}/latest.txt")

    if [ -z "$DOWNLOAD_FILE" ]; then
        echo "Error: Unable to find download URL for version $VERSION"
        exit 1
    fi

    echo "Downloading jdtls from: https://download.eclipse.org/jdtls/milestones/${VERSION}/${DOWNLOAD_FILE}"

    mkdir -p "/tmp/jdtls"
    curl -s -L -o "/tmp/jdtls/${DOWNLOAD_FILE}" "https://download.eclipse.org/jdtls/milestones/${VERSION}/${DOWNLOAD_FILE}"
    cd /tmp/jdtls
    tar xvfz "/tmp/jdtls/${DOWNLOAD_FILE}" 
    rm "/tmp/jdtls/${DOWNLOAD_FILE}"
    mv "/tmp/jdtls" /opt

    ln -s /opt/jdtls/bin/jdtls /usr/local/bin/jdtls
fi

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
