#!/usr/bin/env bash
# Exit on first error
set -e

# Run our Chef provisioner
cd src
sudo data_dir="$data_dir" chef-client --local-mode --override-runlist "recipe[twolfson.com]"
cd -

# @depends_on: nginx_provisioner_common
nginx_provisioner_twolfson_com() {
  # If there are no NGINX configuration files, then install them
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
nginx_provisioner_twolfson_com
