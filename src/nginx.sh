#!/usr/bin/env bash
# Exit on first error
set -e

# Define our provisioner
# @depends_on: apt
python_provisioner() {
  # If NGINX isn't installed, then set it up
  # TODO: Thinking about `apt-get` function to handle installs/updates
  if ! which nginx &> /dev/null; then
    sudo apt-get install -y "nginx=1.4.6-1ubuntu3.3"
  fi

  # If there are no NGINX configuration files, then install them
  # TODO: Consider breaking out to another location, like `twolfson.com.sh` and `drive.twolfson.com.sh`
  #   but that might be overkill
  if test "$(cat /etc/nginx/conf.d/twolfson.com.conf 2> /dev/null)" != "$(cat "$data_dir/etc/nginx/conf.d/twolfson.com.conf")" ||
      test "$(cat /etc/nginx/conf.d/drive.twolfson.com.conf 2> /dev/null)" != "$(cat "$data_dir/etc/nginx/conf.d/drive.twolfson.com.conf")" ||
      test "$(cat /etc/nginx/conf.d/twolfsn.com.conf 2> /dev/null)" != "$(cat "$data_dir/etc/nginx/conf.d/twolfsn.com.conf")" ||
      test "$(cat /etc/nginx/nginx.conf 2> /dev/null)" != "$(cat "$data_dir/etc/nginx/nginx.conf")"; then
    # Install our configurations
    sudo chown root:root "$data_dir/etc/nginx/conf.d/twolfson.com.conf"
    sudo chmod u=rw,g=r,o=r "$data_dir/etc/nginx/conf.d/twolfson.com.conf"
    sudo cp --preserve "$data_dir/etc/nginx/conf.d/twolfson.com.conf" /etc/nginx/conf.d/twolfson.com.conf
    sudo chown root:root "$data_dir/etc/nginx/conf.d/drive.twolfson.com.conf"
    sudo chmod u=rw,g=r,o=r "$data_dir/etc/nginx/conf.d/drive.twolfson.com.conf"
    sudo cp --preserve "$data_dir/etc/nginx/conf.d/drive.twolfson.com.conf" /etc/nginx/conf.d/drive.twolfson.com.conf
    sudo chown root:root "$data_dir/etc/nginx/conf.d/twolfsn.com.conf"
    sudo chmod u=rw,g=r,o=r "$data_dir/etc/nginx/conf.d/twolfsn.com.conf"
    sudo cp --preserve "$data_dir/etc/nginx/conf.d/twolfsn.com.conf" /etc/nginx/conf.d/twolfsn.com.conf
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
}
