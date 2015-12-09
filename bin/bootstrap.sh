#!/usr/bin/env bash
# Exit on first error and output commands
set -e
set -x

# If we haven't updated apt-get, then update it now
# TODO: Use timestamp to update it on a schedule (e.g. 1 day)
# TODO: Maybe build a function like `update_apt_get` used by other functions?
if ! test -f .updated-apt-get; then
  sudo apt-get update
  touch .updated-apt-get
fi

# If we haven't installed note, then set it up
# https://github.com/nodesource/distributions/tree/96e9b7d40b6aff7ade7bc130d9e18fd140e9f4f8#installation-instructions
# TODO: Upgrade to newer version of node
if ! which node &> /dev/null; then
  curl -sL https://deb.nodesource.com/setup_0.10 | sudo -E bash -
  sudo apt-get install -y nodejs==0.10.41-1nodesource1~trusty1
fi
