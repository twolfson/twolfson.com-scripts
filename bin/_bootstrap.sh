#!/usr/bin/env bash
# Exit on first error and output commands
set -e
set -x

# Placeholder for `sed` injection of `data_dir` and `src_dir`
# DATA_DIR_PLACEHOLDER
# SRC_DIR_PLACEHOLDER

# Verify we have a data_dir and src_dir variable set
usage() {
  echo "Example: \`data_dir=\"/vagrant/data\"; src_dir=\"/vagrant/src\"; . bin/bootstrap.sh\`" 1>&2
}
if test "$data_dir" = ""; then
  echo "Environment variable \`data_dir\` wasn't set when calling \`bootstrap.sh\`." 1>&2
  echo "Please verify it is set before running it." 1>&2
  usage
  exit 1
fi
if test "$src_dir" = ""; then
  echo "Environment variable \`src_dir\` wasn't set when calling \`bootstrap.sh\`." 1>&2
  echo "Please verify it is set before running it." 1>&2
  usage
  exit 1
fi

# Load and run our provisioners
# TODO: Add missing tests for apt's update timestamp
# TODO: It feels like we overly broke down our provisioner into too pedantic pieces
#   Reconsider doing something like a `normalize.sh` (which sets up apt, users, supervisor, timezone)
#   Then, maybe one for our node (e.g. require node, custom supervisorctl config, custom nginx configs)
. src/apt.sh; apt_provisioner
. src/system.sh; system_provisioner
# TODO: Add missing tests for users provisioner
. src/users.sh; users_provisioner_ubuntu
. src/ssh.sh; ssh_provisioner_authorized_keys
. src/node.sh; node_provisioner
. src/python.sh; python_provisioner
. src/nginx.sh; nginx_provisioner
users_provisioner_shells
. src/supervisor.sh; supervisor_provisioner
ssh_provisioner_config
