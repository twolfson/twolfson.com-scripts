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

# If we haven't updated apt-get, then update it now
# TODO: Use timestamp to update it on a schedule (e.g. 1 day)
#   https://github.com/twolfson/twolfson.com-scripts/blob/150de4af2778e577ca3d57dab74b6dd7a0e1a55f/bin/bootstrap.sh#L6-L14
# TODO: Maybe build a function like `update_apt_get` used by other functions?
if ! test -f .updated-apt-get; then
  sudo apt-get update
  touch .updated-apt-get
fi

# If the timezone isn't as we expect, then update it now
# https://www.digitalocean.com/community/questions/how-to-change-the-timezone-on-ubuntu-14
# http://serverfault.com/a/84528
if test "$(date +"%z")" != "+0000"; then
  sudo chown root:root "$data_dir/etc/timezone"
  sudo chmod u=rw,g=r,o=r "$data_dir/etc/timezone"
  sudo cp --preserve "$data_dir/etc/timezone" /etc/timezone
  sudo dpkg-reconfigure --frontend noninteractive tzdata
fi

# If there is no ubuntu user, then create them
# DEV: Digital Ocean's Ubuntu images provision us as the root user so we must create an ubuntu user
# https://github.com/mizzy/specinfra/blob/v2.47.0/lib/specinfra/command/base/user.rb#L3-L5
# https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-14-04
# https://www.digitalocean.com/community/tutorials/how-to-edit-the-sudoers-file-on-ubuntu-and-centos
if ! id ubuntu &> /dev/null; then
  # Create password-less `ubuntu` user with metadata "Ubuntu"
  adduser ubuntu --disabled-password --gecos "Ubuntu"

  # Add ubuntu user to sudo group (sudoers will be performed later)
  gpasswd -a ubuntu sudo

  # Create a folder for SSH configuration
  mkdir --mode u=rwx,g=,o= /home/ubuntu/.ssh
  chown ubuntu:ubuntu /home/ubuntu/.ssh
  chmod u=rwx,g=,o= /home/ubuntu/.ssh
fi

# if there is no sudoers set up for the `ubuntu` user, then set it up
# DEV: We keep this separate from `gpasswd` to run this for Travis CI
if ! test -f /etc/sudoers.d/ubuntu; then
  sudo chown root:root "$data_dir/etc/sudoers.d/ubuntu"
  sudo chmod u=r,g=,o= "$data_dir/etc/sudoers.d/ubuntu"
  sudo cp --preserve "$data_dir/etc/sudoers.d/ubuntu" /etc/sudoers.d/ubuntu
fi

# Update authorized keys
# DEV: This won't brick Vagrant since it uses a `vagrant` user for ssh
sudo chown ubuntu:ubuntu "$data_dir/home/ubuntu/.ssh/authorized_keys"
sudo chmod u=rw,g=,o= "$data_dir/home/ubuntu/.ssh/authorized_keys"
sudo cp --preserve "$data_dir/home/ubuntu/.ssh/authorized_keys" /home/ubuntu/.ssh/authorized_keys
# WARNING: THIS WILL LOCK OUT THE ROOT USER
sudo chmod u=rwx,g=,o= "/root/.ssh"
sudo chown root:root "$data_dir/root/.ssh/authorized_keys"
sudo chmod u=rw,g=,o= "$data_dir/root/.ssh/authorized_keys"
sudo cp --preserve "$data_dir/root/.ssh/authorized_keys" /root/.ssh/authorized_keys

# If we haven't installed node, then set it up
# https://github.com/nodesource/distributions/tree/96e9b7d40b6aff7ade7bc130d9e18fd140e9f4f8#installation-instructions
# TODO: Handle out of date scenario
#   https://github.com/twolfson/twolfson.com-scripts/blob/150de4af2778e577ca3d57dab74b6dd7a0e1a55f/bin/bootstrap.sh#L18-L24
if ! which node &> /dev/null; then
  curl -sL https://deb.nodesource.com/setup_0.10 | sudo -E bash -
  sudo apt-get install -y "nodejs=0.10.41-1nodesource1~trusty1"
fi

# If pip isn't installed, then install it
if ! which pip &> /dev/null; then
  sudo apt-get install -y "python-setuptools=3.3-1ubuntu2" "python-pip=1.5.4-1ubuntu3"
fi

# If pip is out of date, then upgrade it
if ! pip --version | grep "pip 7.1.2" &> /dev/null; then
  sudo pip install "pip==7.1.2"
  source ~/.bashrc
fi

# If NGINX isn't installed, then set it up
# TODO: Thinking about `apt-get` function to handle installs/updates
if ! which nginx &> /dev/null; then
  sudo apt-get install -y nginx=1.4.6-1ubuntu3.3
fi

# If there are no NGINX configuration files, then install them
if test "$(cat /etc/nginx/conf.d/twolfson.com.conf 2> /dev/null)" != "$(cat "$data_dir/etc/nginx/conf.d/twolfson.com.conf")" ||
    test "$(cat /etc/nginx/conf.d/drive.twolfson.com.conf 2> /dev/null)" != "$(cat "$data_dir/etc/nginx/conf.d/drive.twolfson.com.conf")" ||
    test "$(cat /etc/nginx/nginx.conf 2> /dev/null)" != "$(cat "$data_dir/etc/nginx/nginx.conf")"; then
  # Install our configurations
  sudo chown root:root "$data_dir/etc/nginx/conf.d/twolfson.com.conf"
  sudo chmod u=rw,g=r,o=r "$data_dir/etc/nginx/conf.d/twolfson.com.conf"
  sudo cp --preserve "$data_dir/etc/nginx/conf.d/twolfson.com.conf" /etc/nginx/conf.d/twolfson.com.conf
  sudo chown root:root "$data_dir/etc/nginx/conf.d/drive.twolfson.com.conf"
  sudo chmod u=rw,g=r,o=r "$data_dir/etc/nginx/conf.d/drive.twolfson.com.conf"
  sudo cp --preserve "$data_dir/etc/nginx/conf.d/drive.twolfson.com.conf" /etc/nginx/conf.d/drive.twolfson.com.conf
  sudo chown root:root "$data_dir/etc/nginx/nginx.conf"
  sudo chmod u=rw,g=r,o=r "$data_dir/etc/nginx/nginx.conf"
  sudo cp --preserve "$data_dir/etc/nginx/nginx.conf" /etc/nginx/nginx.conf

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

# If there is no folder for drive.twolfson.com, then create one
if ! test -d /var/www; then
  sudo mkdir --mode u=rwx,g=rx,o=rx /var/www
  sudo chown root:root /var/www
  sudo chmod u=rwx,g=rx,o=rx /var/www
fi
if ! test -d /var/www/drive.twolfson.com; then
  sudo mkdir --mode u=rwx,g=rx,o=rx /var/www/drive.twolfson.com
  sudo chown ubuntu:ubuntu /var/www/drive.twolfson.com
  sudo chmod u=rwx,g=rx,o=rx /var/www/drive.twolfson.com
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
