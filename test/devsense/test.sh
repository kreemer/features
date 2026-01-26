#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Definition specific tests
check "binary" which devsense-php-ls

# Report result
reportResults
