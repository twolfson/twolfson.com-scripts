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

# Run our provisioner script
. src/twolfson.com.sh
