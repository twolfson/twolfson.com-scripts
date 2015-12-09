#!/usr/bin/env bash
# Exit on first error and output commands
set -e
set -x

# Temporarily set up data directory inline
# TODO: Set up data directory for production (set this one inside of `bootstrap-vagrant.sh`)
#   Then, invoke `bootstrap.sh` (or maybe rename to `_bootstrap.sh` via a `. bootstrap.sh` so it's in the same shell -- or maybe us an export)
data_dir="/vagrant/data"

# Verify we have a data_dir variable set
if test "$data_dir" = ""; then
  echo "Environment variable \`data_dir\` wasn't set when calling \`bootstrap.sh\`." 1>&2
  echo "Please verify it is set before running it." 1>&2
  echo "Example: \`data_dir=\"/vagrant/data\"; . bin/bootstrap.sh\`" 1>&2
  exit 1
fi

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
# TODO: Thinking about `apt-get` function to handle installs/updates
if ! which nginx &> /dev/null; then
  sudo apt-get install -y nginx=1.4.6-1ubuntu3.3
fi

# If there are no NGINX configuration files, then install them
# TODO: Handle updates for conf.d
#   Thinking about 3 functions to copy files, update ownership, update permissions
# TODO: Set up SSL certs via a `bootstrap-vagrant.sh` script
# TODO: Move all cp, chown, chmod logic into an `if` so we can handle nginx reload gracefully
# TODO: Write script to install SSL certs on a server (e.g. rsync, ssh, chmod, chown, mv)
# TODO: Set up process manager and init.d for said process manager
if ! test -f /etc/nginx/conf.d/twolfson.com.conf; then
  # Install our configuration
  cp "$data_dir/etc/nginx/conf.d/twolfson.com.conf" /etc/nginx/conf.d/twolfson.com.conf
  sudo chown root:root /etc/nginx/conf.d/twolfson.com.conf
  sudo chmod chmod u=rw,g=r,o=r /etc/nginx/conf.d/twolfson.com.conf

  # Reload the NGINX server
  sudo /etc/init.d/nginx reload
fi
