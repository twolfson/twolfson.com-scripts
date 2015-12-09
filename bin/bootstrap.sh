#!/usr/bin/env bash
# Exit on first error and output commands
set -e
set -x

# Collect current timestmap in seconds (e.g. 1449635654)
timestamp="$(date +%s)"

# If we haven't updated apt-get or it's been a day since our last apt-get update, then update it now
# TODO: Maybe build a function like `update_apt_get` used by other functions?
if (! test -f .updated-apt-get) || test "$timestamp" -ge "$(($(cat .updated-apt-get) + (60 * 60 * 24)))"; then
  sudo apt-get update
  echo -n "$timestamp" > .updated-apt-get
fi

# If we haven't installed node or it's out of date, then set it up
# https://github.com/nodesource/distributions/tree/96e9b7d40b6aff7ade7bc130d9e18fd140e9f4f8#installation-instructions
node_version="0.10.41-1nodesource1~trusty1"
if ! ls /var/lib/apt/lists/deb.nodesource.com* &> /dev/null; then
  curl -sL https://deb.nodesource.com/setup_0.10 | sudo -E bash -
fi
if ! dpkg --list | grep nodejs | grep "$node_version"; then
  sudo apt-get install -y "nodejs=0.10.41-1nodesource1~trusty1"
fi
