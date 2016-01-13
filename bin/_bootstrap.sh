#!/usr/bin/env bash
# Exit on first error and output commands
set -e
set -x

# Placeholder for `sed` injection of `data_dir`
# DATA_DIR_PLACEHOLDER

# Verify we have a data_dir variable set
if test "$data_dir" = ""; then
  echo "Environment variable \`data_dir\` wasn't set when calling \`bootstrap.sh\`." 1>&2
  echo "Please verify it is set before running it." 1>&2
  echo "Example: \`data_dir=\"/vagrant/data\"; . bin/bootstrap.sh\`" 1>&2
  exit 1
fi

# Load and run our provisioners
# TODO: Add missing tests for apt's update timestamp
. src/apt.sh; apt_provisioner
. src/system.sh; system_provisioner
# TODO: Add missing tests for users provisioner
. src/users.sh; users_provisioner_ubuntu
# TODO: Relocate `ssh_provisioner` to bottom of our queue
. src/ssh.sh; ssh_provisioner_authorized_keys
. src/node.sh; node_provisioner
. src/python.sh; python_provisioner
. src/nginx.sh; nginx_provisioner
users_provisioner_shells

install_supervisord_conf () {
  sudo chown root:root "$data_dir/etc/supervisord.conf"
  sudo chmod u=rw,g=r,o=r "$data_dir/etc/supervisord.conf"
  sudo cp --preserve "$data_dir/etc/supervisord.conf" /etc/supervisord.conf
}

# If supervisor is not installed, then install it
if ! which supervisorctl &> /dev/null; then
  # Install supervisor
  sudo pip install "supervisor==3.2.0"

  # Create folder for log files
  sudo mkdir --mode u=rwx,g=rx,o=rx /var/log/supervisor
  sudo chown root:root /var/log/supervisor
  sudo chmod u=rwx,g=rx,o=rx /var/log/supervisor

  # Copy over supervisord conf
  install_supervisord_conf

  # Add `init` script
  # http://supervisord.org/running.html#running-supervisord-automatically-on-startup
  # http://serverfault.com/a/96500
  sudo chown root:root "$data_dir/etc/init.d/supervisord"
  sudo chmod u=rwx,g=rx,o=rx "$data_dir/etc/init.d/supervisord"
  sudo cp --preserve "$data_dir/etc/init.d/supervisord" /etc/init.d/supervisord
  sudo /etc/init.d/supervisord start
  sudo update-rc.d supervisord defaults
fi

# If we have a new config for supervisor, then update ourselves
if test "$(cat /etc/supervisord.conf 2> /dev/null)" != "$(cat "$data_dir/etc/supervisord.conf")"; then
  # Copy over the new config file
  install_supervisord_conf

  # Load supervisor config changes
  # DEV: We need to access socket as root user
  # DEV: This command might fail if we change anything with `supervisor.d's` config
  #   Be sure to use `/etc/init.d/supervisord restart` in that case
  sudo supervisorctl update
fi

# Update sshd config
# WARNING: THIS WILL LOCK OUT THE ROOT USER
# TODO: Find conditional to handle this
sudo chown root:root "$data_dir/etc/ssh/sshd_config"
sudo chmod u=rw,g=r,o=r "$data_dir/etc/ssh/sshd_config"
sudo cp --preserve "$data_dir/etc/ssh/sshd_config" /etc/ssh/sshd_config

# Reload our SSH server
# http://unix.stackexchange.com/a/127887
sudo service ssh reload
