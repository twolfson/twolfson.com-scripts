#!/usr/bin/env bash
# Exit on first error
set -e

# Run our rspec tests (depends on SSH_CONFIG, TARGET_HOST)
sudo --preserve-env bundle exec rspec --color test/*.rb
