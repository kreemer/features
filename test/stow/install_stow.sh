#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Ensure extended version is installed
check "installed"  bash -c "stow -V | grep stow"

# Report result
reportResults
