#!/usr/bin/env bash
# Exit on first error
set -e

# Set up the backend for serverspec to run locally
export SERVERSPEC_BACKEND="exec"

# Run our tests
sudo --preserve-env bin/_test.sh
