#!/usr/bin/env bash
# Exit on first error and output commands
set -e
set -x

# If we haven't updated apt-get, then update it now
# TODO: Use timestamp to update it on a schedule (e.g. 1 day)
#   https://github.com/twolfson/twolfson.com-scripts/blob/150de4af2778e577ca3d57dab74b6dd7a0e1a55f/bin/bootstrap.sh#L6-L14
# TODO: Maybe build a function like `update_apt_get` used by other functions?
if ! test -f .updated-apt-get; then
  sudo apt-get update
  touch .updated-apt-get
fi

# If we haven't installed node, then set it up
# https://github.com/nodesource/distributions/tree/96e9b7d40b6aff7ade7bc130d9e18fd140e9f4f8#installation-instructions
# TODO: Handle out of date scenario
#   https://github.com/twolfson/twolfson.com-scripts/blob/150de4af2778e577ca3d57dab74b6dd7a0e1a55f/bin/bootstrap.sh#L18-L24
if ! which node &> /dev/null; then
  curl -sL https://deb.nodesource.com/setup_0.10 | sudo -E bash -
  sudo apt-get install -y "nodejs=0.10.41-1nodesource1~trusty1"
fi

# If NGINX isn't installed, then set it up
# TOOD: Thinking about `apt-get` function to handle installs/updates
if ! which nginx &> /dev/null; then
  sudo apt-get install -y nginx=1.4.6-1ubuntu3.3
fi

# If there are no NGINX configuration files, then install them
# TODO: Handle updates for conf.d
#   Thinking about 3 functions to copy files, update ownership, update permissions
# TODO: Set up data files for NGINX (both conf.d, SSL certs)
#   Set up SSL certs via a `bootstrap-vagrant.sh` script
# TODO: Set up process manager and init.d for said process manager
