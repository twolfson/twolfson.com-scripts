#!/usr/bin/env bash
# Exit on first error
set -e

# If the Vagrant machine is offline, then complain and leave
if ! vagrant status | grep -E "default\s+running" &> /dev/null; then
  echo "Our \`vagrant\` machine isn't running. Please start it up via \`vagrant up\`." 1>&2
  exit 1
fi

# If we should provision our Vagrant box, then provision it
if test "$SKIP_PROVISION" != "TRUE"; then
  vagrant provision
fi

# Export the `ssh-config` for our Vagrant server
export SSH_CONFIG=".vagrant/ssh-config"
export TARGET_HOST="default"
vagrant ssh-config > "$SSH_CONFIG"

# Set up the backend for serverspec to run inside Vagrant
export SERVERSPEC_BACKEND="ssh"

# Run our tests
. bin/_test.sh
