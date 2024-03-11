#!/usr/bin/env bash

VERSION="${VERSION:-"latest"}"

USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"

set -e

# Clean up
rm -rf /var/lib/apt/lists/*

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


# Insall Hugo if it's missing
if ! stow -V &> /dev/null ; then
	  echo "Installing Helix..."
		apt_get_update
	  apt-get -y install --no-install-recommends software-properties-common

    add-apt-repository ppa:maveonair/helix-editor
    apt-get update -y
    apt-get -y install --no-install-recommends helix
fi

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
