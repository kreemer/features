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
if ! bicep-langserver --version &> /dev/null ; then
	  echo "Installing bicep-langserver..."
		apt_get_update
    apt-get -y install --no-install-recommends jq curl tar xz-utils ca-certificates libicu-dev unzip

    curl -L https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
    chmod +x /tmp/dotnet-install.sh
    /tmp/dotnet-install.sh -InstallDir /opt/dotnet
    ln -s /opt/dotnet/dotnet /usr/local/bin/dotnet

    if [[ "$VERSION" == "latest" || -z "$VERSION" ]]; then
      echo "Fetching latest version..."
      VERSION=$(curl -s -L -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "https://api.github.com/repos/Azure/bicep/releases/latest" | jq -r .tag_name)
    fi

    IDENTIFIER="bicep-langserver.zip"

    DOWNLOAD_URL=$(curl -s -L -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "https://api.github.com/repos/Azure/bicep/releases/tags/${VERSION}" | \
       jq -r '.assets | map(select(.name=="'"$IDENTIFIER"'"))[0].browser_download_url')

    if [ -z "$DOWNLOAD_URL" ]; then
        echo "Error: Unable to find download URL for $IDENTIFIER and version $VERSION"
        exit 1
    fi

    echo "Downloading bicep-langserver from: ${DOWNLOAD_URL}"

    mkdir -p "/tmp/bicep-langserver"
    curl -s -L -o "/tmp/bicep-langserver/${IDENTIFIER}" "${DOWNLOAD_URL}"
    unzip "/tmp/bicep-langserver/${IDENTIFIER}"
    rm "/tmp/bicep-langserver/${IDENTIFIER}"
    mv "/tmp/bicep-langserver" /opt

    echo "#!/usr/bin/env bash\n\nexec dotnet /opt/bicep-langserver/Bicep.LangServer.dll" > /usr/local/bin/bicep-langserver
    chmod +x /usr/local/bin/bicep-langserver
fi

# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"
