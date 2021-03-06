#!/usr/bin/env bash
# Exit on first error
set -e

# Define our usage
usage() {
  echo "Usage: $0 \"name-of-host-in-ssh-config\" <branch>" 1>&2
}

# If there is no remote server to bootstrap on, then complain and leave
target_host="$1"
if test "$target_host" = ""; then
  echo "Target host was not set. Please pass it as an argument to \`$0\`" 1>&2
  usage
  exit 1
fi
branch="$2"
if test "$branch" = ""; then
  # If we're on master, then assume `master`
  # * dev/more.cleanup -> dev/more.cleanup
  current_branch="$(git branch | grep '^*' | cut -f 2 -d ' ')"
  if test "$current_branch" = "master"; then
    branch="master"
  # Otherwise, require branch to be specified
  else
    # DEV: We could set to `master` by default but for sanity, let's always require it
    echo "Branch was not set and not on \`master\` branch. Please pass it as an argument to \`$0\` or move to \`master\` branch" 1>&2
    echo "e.g. $current_branch" 1>&2
    usage
    exit 1
  fi
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
base_target_dir="$(ssh "$target_host" "pwd")"
target_data_dir="$base_target_dir/data"
target_src_dir="$base_target_dir/src"
rsync --chmod u=rw,g=,o= --human-readable --archive --verbose --compress "data" "$target_host":"$base_target_data_dir"
rsync --chmod u=rw,g=,o= --human-readable --archive --verbose --compress "src" "$target_host":"$base_target_src_dir"

# Remove our sensitive files from the remote server on exit
# http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_12_02.html
# DEV: This will always run whether bootstrap succeeds/fails
trap "{ ssh \"$target_host\" \"rm -rf \\\"$target_data_dir\\\"; rm -rf \\\"$target_src_dir\\\"\"; }" EXIT

# Run our bootstrap on the remote server
# DEV: We need to escape our target directory for the second sed
#   "/a/b" -> "\/a\/b"
escaped_target_data_dir="$(echo -n "$target_data_dir" | sed "s/\\//\\\\\//g")"
escaped_target_src_dir="$(echo -n "$target_src_dir" | sed "s/\\//\\\\\//g")"
cat bin/_bootstrap.sh |
  sed "s/# DATA_DIR_PLACEHOLDER/export data_dir=\"$escaped_target_data_dir\"/" |
  sed "s/# SRC_DIR_PLACEHOLDER/export src_dir=\"$escaped_target_src_dir\"/" |
  ssh "$target_host"
