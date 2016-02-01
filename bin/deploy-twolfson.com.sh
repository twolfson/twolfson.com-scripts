#!/usr/bin/env bash
# Exit on first error
set -e

# Define a usage function
echo_usage() {
  echo "Usage: $0 \"name-of-host-in-ssh-config\" <branch>" 1>&2
}

# If there is no remote server to bootstrap on, then complain and leave
target_host="$1"
shift
if test "$target_host" = "" || test "${target_host:0:1}" = "-"; then
  echo "Target host was not set. Please pass it as an argument to \`$0\`" 1>&2
  echo_usage
  exit 1
fi
branch="$1"
git_depth_flag=""
if test "$branch" = "" || test "${branch:0:1}" = "-"; then
  branch="master"
  git_depth_flag="--depth 1"
else
  shift
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
git clone $git_depth_flag git@github.com:twolfson/twolfson.com.git
cd twolfson.com/

# Checkout the requested branch
git checkout "$branch"

# Navigate back to containing folder
cd ../

# Find a timestamp to use for our deploy
timestamp="$(ssh "$target_host" "date --utc +%Y%m%d.%H%M%S.%N")"
# TODO: Consider tagging repository
base_target_dir="/home/ubuntu/twolfson.com"
target_dir="$base_target_dir/$timestamp"
main_target_dir="$base_target_dir/main"

# Generate a folder to upload our server to
# DEV: We use `-p` to avoid "File exists" issues
ssh "$target_host" "mkdir -p $base_target_dir"

# Upload our server files
# TODO: Consider deleting `.git`
# Expanded -havz is `--human-readable --archive --verbose --compress`
# DEV: We use trailing slashes to force uploading into non-nested directories
rsync --human-readable --archive --verbose --compress "twolfson.com/" "$target_host":"$target_dir/"

# On the remote server, install our dependencies
# DEV: We perform this on the server to prevent inconsistencies between development and production
ssh -A "$target_host" "cd $target_dir && bin/deploy-install.sh"

# Replace our existing `main` server with the new one
# DEV: We use `--no-dereference` to prevent creating a symlink in the existing `main` directory
# DEV: We use a local relative target to make the symlink portable
#   ln --symbolic 20151222.073547.761299235 twolfson.com/main
#   twolfson.com/main -> 20151222.073547.761299235
# TODO: Add health check (verify server is running) and load balance before swap
ssh "$target_host" <<EOF
# Exit upon first error and echo commands
set -e
set -x

# Swap directories
ln --symbolic --force --no-dereference "$target_dir" "$main_target_dir"

# Restart our server
sudo supervisorctl restart twolfson.com-server
EOF

# Notify the user of success
echo "Server restarted. Please manually verify the server is running at http://twolfson.com/"
