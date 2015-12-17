#!/usr/bin/env bash
# Exit on first error
set -e

# If there is no remote server to build to, then complain and leave
usage_str="Usage: SOURCE_KEY=\"my-domain.key\" SOURCE_CRT=\"my-domain.crt\" TARGET_HOST=\"my-server-from-ssh-config\" bin/install-ssl-certificates-remote.sh"
if test "$TARGET_HOST" = ""; then
  # DEV: We support `TARGET_HOST="my-user@127.0.0.1"` as well but that's inconsistent with `test-remote.sh`
  echo "Environment variable \`TARGET_HOST\` was not set. Please set it before running \`install-ssl-certificates-remote.sh\`" 1>&2
  echo "$usage_str" 1>&2
  exit 1
fi

# If we don't have a certificate key or bundle

# Output all future commands
set -x

#
# TODO: Write script to install SSL certs on a server (e.g. rsync, ssh, chmod, chown, mv)
