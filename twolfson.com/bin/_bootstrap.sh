#!/usr/bin/env bash
# Exit on first error
set -e

# Run our Chef provisioner
cd twolfson.com
sudo data_dir="$data_dir" chef-client --local-mode --override-runlist "recipe[twolfson.com]"
