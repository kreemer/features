#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Ensure extended version is installed
check "chrome"  bash -c "ls /opt/chrome"
check "chromedriver"  bash -c "ls /usr/local/bin/chromedriver"

# Report result
reportResults
