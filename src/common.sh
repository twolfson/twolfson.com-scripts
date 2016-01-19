#!/usr/bin/env bash
# Exit on first error
set -e

# @depends_on: ssh_provisioner_authorized_keys # To prevent locking out root without ubuntu user being setup
users_provisioner_shells() {
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
}
users_provisioner_shells

# @depends_on: ssh_provisioner_authorized_keys # To prevent locking out root and ubuntu user concurrently
ssh_provisioner_config() {
  # Update sshd config
  # WARNING: THIS WILL LOCK OUT THE ROOT USER
  # TODO: Find conditional to handle this
  sudo chown root:root "$data_dir/etc/ssh/sshd_config"
  sudo chmod u=rw,g=r,o=r "$data_dir/etc/ssh/sshd_config"
  sudo cp --preserve "$data_dir/etc/ssh/sshd_config" /etc/ssh/sshd_config

  # Reload our SSH server
  # http://unix.stackexchange.com/a/127887
  sudo service ssh reload
}
ssh_provisioner_config

# @depends_on: apt_provisioner
nginx_provisioner_common() {
  # If NGINX isn't installed, then set it up
  # TODO: Thinking about `apt-get` function to handle installs/updates
  if ! which nginx &> /dev/null; then
    sudo apt-get install -y "nginx=1.4.6-1ubuntu3.3"
  fi

  # If there are default NGINX configuration files, then remove them
  if test "$(ls /etc/nginx/sites-enabled)" != ""; then
    # Remove the configurations
    sudo rm /etc/nginx/sites-enabled/*

    # Reload the NGINX server
    sudo /etc/init.d/nginx reload
  fi
}
nginx_provisioner_common

# @depends_on: apt
python_provisioner() {
  # If pip isn't installed, then install it
  if ! which pip &> /dev/null; then
    sudo apt-get install -y "python-setuptools=3.3-1ubuntu2" "python-pip=1.5.4-1ubuntu3"
  fi

  # If pip is out of date, then upgrade it
  if ! pip --version | grep "pip 7.1.2" &> /dev/null; then
    sudo pip install "pip==7.1.2"
    source ~/.bashrc
  fi
}
python_provisioner

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
