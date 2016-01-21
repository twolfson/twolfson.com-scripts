#!/usr/bin/env bash
# Exit on first error and output commands
set -e
set -x

# Find the last git tag
last_git_tag="$(git tag | sort -V | tail -n 1)"
if test "$last_git_tag" = ""; then
  echo "Expected \`last_git_tag\` to be defined but it was not" 1>&2
  exit 1
fi

# Checkout our last tag
git checkout "$last_git_tag"

# Run our provisioner
bin/bootstrap-travis-ci.sh

# Return to the past commit
git checkout -
