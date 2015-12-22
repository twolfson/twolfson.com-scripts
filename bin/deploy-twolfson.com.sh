#!/usr/bin/env bash
# Exit on first error
set -e

# If there is no remote server to bootstrap on, then complain and leave
target_host="$1"
if test "$target_host" = ""; then
  echo "Target host was not set. Please pass it as an argument to \`$0\`" 1>&2
  echo "Usage: $0 \"name-of-host-in-ssh-config\" <branch>" 1>&2
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
git clone git@github.com:twolfson/twolfson.com.git
cd twolfson.com/

# Checkout the requested branch
git checkout "$branch"

# Navigate back to containing folder
cd ../

# Find a timestamp to use for our deploy
timestamp="$(ssh "date --utc +%Y%m%d.%H%M%S.%N")"
# TODO: Consider tagging repository
base_target_dir="/home/ubuntu/twolfson.com"
target_dir="$base_target_dir/$timestamp"
main_target_dir="$base_target_dir/main"

# Generate a folder to upload our server to
ssh "mkdir $base_target_dir"

# Upload our server files
# TODO: Consider deleting `.git`
# Expanded -havz is `--human-readable --archive --verbose --compress`
rsync --human-readable --archive --verbose --compress "twolfson.com" "$target_host":"$target_dir"
