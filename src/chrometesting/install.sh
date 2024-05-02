#!/usr/bin/env bash

VERSION="${VERSION:-"Stable"}"

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

if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
    echo "Running apt-get update..."
    apt-get update -y
fi

apt-get install -y curl wget unzip xvfb jq ca-certificates fonts-liberation lsb-release xdg-utils libnss3 libasound2-dev


cd /tmp
CHROME_URL=$(curl -s "https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json" | jq '.channels.Stable.downloads.chrome' | jq '.[] | select(.platform=="linux64") | .url' -r)
CHROMEDRIVER_URL=$(curl -s "https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions-with-downloads.json" | jq '.channels.Stable.downloads.chromedriver' | jq '.[] | select(.platform=="linux64") | .url' -r)

wget $CHROME_URL
unzip chrome-linux64.zip
mv chrome-linux64 /opt/chrome
chmod +x /opt/chrome/chrome
ln -s /opt/chrome/chrome /usr/local/bin/chrome

wget $CHROMEDRIVER_URL
unzip chromedriver-linux64.zip
mv chromedriver-linux64/chromedriver /usr/local/bin/chromedriver

# Clean up
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/chrome-linux64.zip
rm -rf /tmp/chromedriver-linux64.zip
rm -rf /tmp/chromedriver-linux64

echo "Done!"
