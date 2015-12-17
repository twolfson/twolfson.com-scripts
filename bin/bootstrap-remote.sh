#!/usr/bin/env bash
# Exit on first error
set -e

# If there is no remote server to bootstrap on, then complain and leave
target_host="$1"
if test "$target_host" = ""; then
  echo "Target host was not set. Please pass it as an argument to \`$0\`" 1>&2
  echo "Usage: $0 \"name-of-host-in-ssh-config\"" 1>&2
  exit 1
fi
branch="$2"
if test "$branch" = ""; then
  branch="master"
fi

# Output future commands
set -x

# Create a local directory for building
if test -d "tmp/build/"; then
  rm -rf tmp/build/
fi
mkdir -p tmp/build/
cd tmp/build/

# Clone our repository for a fresh start
# DEV: This is to prevent using accidentally dirty `data/`
git clone git@github.com:twolfson/twolfson.com-scripts.git
cd twolfson.com-scripts/

# Checkout the requested branch
git checkout "$branch"

# Upload our data, only allow for reads from user and nothing else from anyone
# Expanded -havz is `--human-readable --archive --verbose --compress`
rsync --chmod u=r,g=,o= --human-readable --archive --verbose --compress "data" "$target_host":"data"

# TODO: Pipe in `_bootstrap.sh` to ssh? -- need to figure out data_dir somehow. maybe with a `sed` or if `ssh` has an `env`
