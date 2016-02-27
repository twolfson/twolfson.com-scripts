#!/usr/bin/env bash
# Exit on first error and output commands
set -e
set -x

# Find the last git tag
last_git_tag="$(git tag | sort -V | tail -n 1)"

# If the current commit is the same as our last tag, then find the previous one
# DEV: This occurs during `tag` on a release
current_commit="$(git rev-parse HEAD)"
last_git_tag_commit="$(git rev-parse "$last_git_tag")"
if test "$current_commit" = "$last_git_tag_commit"; then
  last_git_tag="$(git tag | sort -V | grep --invert-match "$last_git_tag" | tail -n 1)"
fi

# Verify we have a tag still
if test "$last_git_tag" = ""; then
  echo "Expected \`last_git_tag\` to be defined but it was not" 1>&2
  exit 1
fi

# Checkout our last tag
git checkout "$last_git_tag"

# Always return to the previous revision, even when the past Bootstrap fails
trap "{ git checkout -; }" EXIT

# Run our provisioner
bin/bootstrap-travis-ci.sh

# Return to the past commit
# DEV: We will return to the past commit via `trap`
