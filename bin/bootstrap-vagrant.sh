#!/usr/bin/env bash
# Exit on first error and output commands
set -e
set -x

# Set up our data directory
data_dir="/vagrant/data"

# TODO: Set up SSL certs creation/install

# Invoke bootstrap.sh in our context
. bootstrap.sh
