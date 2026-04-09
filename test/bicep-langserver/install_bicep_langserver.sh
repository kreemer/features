#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Ensure extended version is installed
check "bicep-langserver"  bash -c "ls /usr/local/bin/bicep-langserver"

# Report result
reportResults
