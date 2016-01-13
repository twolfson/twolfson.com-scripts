#!/usr/bin/env bash
# Exit on first error
set -e

# Define our provisioner
# @depends_on: apt
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
