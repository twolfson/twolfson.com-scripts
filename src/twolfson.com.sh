#!/usr/bin/env bash
# Exit on first error
set -e

# Run our common provisioners
cd src
sudo data_dir="$data_dir" chef-client --local-mode --override-runlist "recipe[twolfson.com]"
cd -

# Define and run our provisioners
# @depends_on: apt_provisioner
node_provisioner() {
  # If we haven't installed node, then set it up
  # https://github.com/nodesource/distributions/tree/96e9b7d40b6aff7ade7bc130d9e18fd140e9f4f8#installation-instructions
  # TODO: Handle out of date scenario
  #   https://github.com/twolfson/twolfson.com-scripts/blob/150de4af2778e577ca3d57dab74b6dd7a0e1a55f/bin/bootstrap.sh#L18-L24
  if ! which node &> /dev/null; then
    curl -sL https://deb.nodesource.com/setup_0.10 | sudo -E bash -
    sudo apt-get install -y "nodejs=0.10.41-1nodesource1~trusty1"
  fi
}
node_provisioner

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
