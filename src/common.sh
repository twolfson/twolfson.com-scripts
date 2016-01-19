#!/usr/bin/env bash
# Exit on first error
set -e

# @depends_on: python
supervisor_provisioner() {
  # TODO: Relocate this to `twolfson.com.sh`
  #   or more accurately: use a template for `supervisord.conf`
  #   and don't run any `twolfson.com` services by default (e.g. use `if twolfson.com` for conf blocks)
  _install_supervisord_conf () {
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
    _install_supervisord_conf

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
    _install_supervisord_conf

    # Load supervisor config changes
    # DEV: We need to access socket as root user
    # DEV: This command might fail if we change anything with `supervisor.d's` config
    #   Be sure to use `/etc/init.d/supervisord restart` in that case
    sudo supervisorctl update
  fi
}
supervisor_provisioner
