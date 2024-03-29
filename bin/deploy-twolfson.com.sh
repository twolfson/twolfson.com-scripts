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

# Install its dependencies locally
# DEV: We would prefer to do this remotely but as of Node.js@6, our 512MB RAM server runs out of memory
#   For reference, here was our prior setup https://github.com/twolfson/twolfson.com-scripts/blob/2.10.0/bin/deploy-twolfson.com.sh#L65-L67
bin/deploy-install.sh

# Navigate back to containing folder
cd ../

# Find a timestamp to use for our deploy
timestamp="$(ssh "$target_host" "date --utc +%Y%m%d.%H%M%S.%N")"
# DEV: We could tag our repo, but a server is unlike libraries. It's always running "latest"
#   Caveat: Since this is a public repo, we can tag release, just shouldn't be part of deploy
base_target_dir="/home/ubuntu/twolfson.com"
target_dir="$base_target_dir/$timestamp"
main_target_dir="$base_target_dir/main"

# Generate a folder to upload our server to
# DEV: We use `-p` to avoid "File exists" issues
ssh "$target_host" "mkdir -p $base_target_dir"

# Upload our server files
# Expanded -havz is `--human-readable --archive --verbose --compress`
# DEV: We use trailing slashes to force uploading into non-nested directories
# DEV: `.git` is bulky but we've left it for now for potential future Sentry version reporting
rsync --human-readable --archive --verbose --compress "twolfson.com/" "$target_host":"$target_dir/"

# Replace our existing `main` server with the new one
# DEV: We use `--no-dereference` to prevent creating a symlink in the existing `main` directory
# DEV: We use a local relative target to make the symlink portable
#   ln --symbolic 20151222.073547.761299235 twolfson.com/main
#   twolfson.com/main -> 20151222.073547.761299235
ssh "$target_host" <<EOF
# Exit upon first error and echo commands
set -e
set -x

# Copy over any .env.*.local files from current deployment
if test -d "${main_target_dir}"; then
  cp "${main_target_dir}"/.env*.local "${target_dir}"
fi

# Swap directories
ln --symbolic --force --no-dereference "$target_dir" "$main_target_dir"

# Restart our server
sudo supervisorctl restart twolfson.com-server
EOF

# Notify the user of success
echo "Server restarted. Please manually verify the server is running at https://twolfson.com/"
