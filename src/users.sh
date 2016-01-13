#!/usr/bin/env bash
# Exit on first error
set -e

# Define our provisioner
users_provisioner() {
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
}
