#!/usr/bin/env bash
# Exit on first error
set -e

# If there is no remote server to build to, then complain and leave
# DEV: We support `TARGET_HOST="my-user@127.0.0.1"` as well but that's inconsistent with `test-remote.sh`
usage_str="Usage: $0 \"name-of-host-in-ssh-config\" --crt \"path/to/domain.crt\" --key \"path/to/domain.key\""
target_host="$1"
# shift
# if test "$target_host" = ""; then
#   echo "Environment variable \`TARGET_HOST\` was not set. Please set it before running \`$0\`" 1>&2
#   echo "$usage_str" 1>&2
#   exit 1
# fi

# If we don't have a certificate key or bundle
# http://superuser.com/a/541673
while getopts crt:key: OPT; do
  echo "$OPT"
  echo "$OPTARG"
done

# Output all future commands
set -x

#
# TODO: Write script to install SSL certs on a server (e.g. rsync, ssh, chmod, chown, mv)
