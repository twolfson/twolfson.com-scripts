#!/usr/bin/env bash
# Exit on first error
set -e

# If there is no remote server to build to, then complain and leave
# DEV: We support `TARGET_HOST="my-user@127.0.0.1"` as well but that's inconsistent with `test-remote.sh`
usage_str="Usage: $0 \"name-of-host-in-ssh-config\" --crt \"path/to/domain.crt\" --key \"path/to/domain.key\""
target_host="$1"
shift
if test "$target_host" = "" || test "${target_host:0:1}" = "-"; then
  echo "Target host was not set. Please pass it as an argument to \`$0\`" 1>&2
  echo "$usage_str" 1>&2
  exit 1
fi

# Parse remaining arguments
# http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_03.html
# http://superuser.com/a/541675
while true; do
  case "$1" in
    # DEV: We can dodge `&&` since we are using `set -e`
    --crt) shift; export crt_path="$1"; shift || break;;
    --key) shift; export key_path="$1"; shift || break;;
    *) break;;
  esac
done

# If we don't have a certificate key or bundle, then complain and leave
if test "$key_path" = ""; then
  echo "Certificate key was not set. Please pass it as an argument (\`--key\`) to \`$0\`" 1>&2
  echo "$usage_str" 1>&2
  exit 1
fi
if test "$crt_path" = ""; then
  echo "Certificate bundle was not set. Please pass it as an argument (\`--crt\`) to \`$0\`" 1>&2
  echo "$usage_str" 1>&2
  exit 1
fi

# Output all future commands
set -x

# TODO: Write script to install SSL certs on a server (e.g. rsync, ssh, chmod, chown, mv)
