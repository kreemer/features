#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Ensure extended version is installed
check "devsense"  bash -c "npm list -g | grep devsense-php-ls"

# Report result
reportResults
