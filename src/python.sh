#!/usr/bin/env bash
# Exit on first error
set -e

# Define our provisioner
# @depends_on: apt
python_provisioner() {
  # If pip isn't installed, then install it
  if ! which pip &> /dev/null; then
    sudo apt-get install -y "python-setuptools=3.3-1ubuntu2" "python-pip=1.5.4-1ubuntu3"
  fi

  # If pip is out of date, then upgrade it
  if ! pip --version | grep "pip 7.1.2" &> /dev/null; then
    sudo pip install "pip==7.1.2"
    source ~/.bashrc
  fi
}
