#!/usr/bin/env bash
# Exit on first error
set -e

# Define our provisioner
# @depends_on: users_provisioner # For ubuntu user
ssh_provisioner_authorized_keys() {
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
}
