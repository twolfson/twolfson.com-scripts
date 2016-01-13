#!/usr/bin/env bash
# Exit on first error
set -e

# Define our provisioner
apt_provision() {
  # If we haven't updated apt-get, then update it now
  # TODO: Use timestamp to update it on a schedule (e.g. 1 day)
  #   https://github.com/twolfson/twolfson.com-scripts/blob/150de4af2778e577ca3d57dab74b6dd7a0e1a55f/bin/bootstrap.sh#L6-L14
  # TODO: Maybe build a function like `update_apt_get` used by other functions?
  if ! test -f .updated-apt-get; then
    sudo apt-get update
    touch .updated-apt-get
  fi
}
