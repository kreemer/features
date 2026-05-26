#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Ensure extended version is installed
check "jdtls" bash -c "ls /opt/jdtls/bin/jdtls"

# Report result
reportResults
