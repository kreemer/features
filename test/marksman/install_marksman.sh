#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Ensure extended version is installed
check "marksman"  bash -c "ls /usr/local/bin/marksman"

# Report result
reportResults
