#!/usr/bin/env bash
# Exit on first error
set -e

# Define our provisioner
system_provision() {
  # If the timezone isn't as we expect, then update it now
  # https://www.digitalocean.com/community/questions/how-to-change-the-timezone-on-ubuntu-14
  # http://serverfault.com/a/84528
  if test "$(date +"%z")" != "+0000"; then
    sudo chown root:root "$data_dir/etc/timezone"
    sudo chmod u=rw,g=r,o=r "$data_dir/etc/timezone"
    sudo cp --preserve "$data_dir/etc/timezone" /etc/timezone
    sudo dpkg-reconfigure --frontend noninteractive tzdata
  fi
}
