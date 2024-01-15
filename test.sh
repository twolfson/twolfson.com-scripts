#!/usr/bin/env bash
# Exit on first error
set -e

# If we should lint our files, then run our linter
if test "$SKIP_LINT" != "TRUE"; then
  bin/rubocop
fi
