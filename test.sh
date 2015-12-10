#!/usr/bin/env bash
# Exit on first error
set -e

# Run our rspec tests
--color
--format documentation
bin/rspec "spec/*_spec.rb"
