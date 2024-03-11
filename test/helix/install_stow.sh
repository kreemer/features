#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Ensure extended version is installed
check "installed"  bash -c "hx -V | grep helix"

# Report result
reportResults
