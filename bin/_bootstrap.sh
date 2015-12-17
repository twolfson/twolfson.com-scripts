#!/usr/bin/env bash
# Exit on first error and output commands
set -e
set -x

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

# TODO: Verify an ubuntu user exists and we are them
#   Otherwise, create the user with auth keys
exit 1

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
# TODO: Move all cp, chown, chmod logic into an `if` so we can handle nginx reload gracefully
# TODO: Write script to install SSL certs on a server (e.g. rsync, ssh, chmod, chown, mv)
# TODO: Set up process manager and init.d for said process manager
if ! test -f /etc/nginx/conf.d/twolfson.com.conf; then
  # Install our configuration
  sudo cp "$data_dir/etc/nginx/conf.d/twolfson.com.conf" /etc/nginx/conf.d/twolfson.com.conf
  sudo chown root:root /etc/nginx/conf.d/twolfson.com.conf
  sudo chmod u=rw,g=r,o=r /etc/nginx/conf.d/twolfson.com.conf

  # Reload the NGINX server
  sudo /etc/init.d/nginx reload
fi

# If there are default NGINX configuration files, then remove them
if test "$(ls /etc/nginx/sites-enabled)" != ""; then
  # Remove the configurations
  sudo rm /etc/nginx/sites-enabled/*

  # Reload the NGINX server
  sudo /etc/init.d/nginx reload
fi

# If the root user has a non-nologin login shell, update it
# https://github.com/mizzy/specinfra/blob/v2.44.7/lib/specinfra/command/base/user.rb#L53-L55
# https://github.com/mizzy/specinfra/blob/v2.44.7/lib/specinfra/command/base/user.rb#L61-L63
if test "$(getent passwd root | cut -f 7 -d ":")" != "/usr/sbin/nologin"; then
  sudo usermod --shell /usr/sbin/nologin root
fi

# If the sync user has a non-nologin login shell, update it
# DEV: The sync user exists to run `sync` on a server without needing to use a shell
#   However, we are going to be paranoid and remove it
# http://www.unix.com/fedora/167621-user-sync-shutdown.html
if test "$(getent passwd sync | cut -f 7 -d ":")" != "/usr/sbin/nologin"; then
  sudo usermod --shell /usr/sbin/nologin sync
fi

# Update sshd config
# TODO: Find conditional to handle this
sudo cp "$data_dir/etc/ssh/sshd_config" /etc/ssh/sshd_config
sudo chown root:root /etc/ssh/sshd_config
sudo chmod u=rw,g=r,o=r /etc/ssh/sshd_config

# Reload our SSH server
# http://unix.stackexchange.com/a/127887
sudo service ssh reload
