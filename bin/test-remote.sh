#!/usr/bin/env bash
# Exit on first error
set -e

# If there is target host variable set, then complain and leave
target_host="$1"
if test "$target_host" = ""; then
  echo "Target host was not set. Pass it as an argument to \`$0\`" 1>&2
  echo "Usage: $0 \"name-of-host-in-ssh-config\"" 1>&2
  exit 1
fi

# Set up the backend for serverspec to run via SSH on a remote server
export SSH_CONFIG="$HOME/.ssh/config"
export TARGET_HOST="$target_host"
export SERVERSPEC_BACKEND="ssh"

# Run our tests
. bin/_test.sh
