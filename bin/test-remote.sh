#!/usr/bin/env bash
# Exit on first error
set -e

# If there is no `TARGET_HOST` environment variable set, then complain and leave
if test "$TARGET_HOST" = ""; then
  echo "Environment variable \`TARGET_HOST\` was not set. Please set it before running \`test-remote.sh\`" 1>&2
  exit 1
fi

# Set up the backend for serverspec to run via SSH on a remote server
export SSH_CONFIG="$HOME/.ssh/config"
export SERVERSPEC_BACKEND="ssh"

# Run our tests
. bin/_test.sh
