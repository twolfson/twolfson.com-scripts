#!/usr/bin/env bash
# Exit on first error and output commands
set -e
set -x

# Set up our data directory
# https://docs.travis-ci.com/user/environment-variables/#Default-Environment-Variables
if test "$TRAVIS_BUILD_DIR" = ""; then
  echo "Expected \`TRAVIS_BUILD_DIR\` environment variable to be set but it was not. Something is seriously wrong." 1&>2
  exit 1
fi
base_dir="$TRAVIS_BUILD_DIR"
data_dir="$base_dir/data"
src_dir="$base_dir/src"

# If we haven't set up SSL certificates, then generate and install them
if ! test -f /etc/ssl/certs/twolfson.com.crt; then
  # Create our certificates
  # https://www.digitalocean.com/community/tutorials/openssl-essentials-working-with-ssl-certificates-private-keys-and-csrs#generate-a-self-signed-certificate
  # https://www.openssl.org/docs/manmaster/apps/req.html#EXAMPLES
  #   Country Name (2 letter code) [AU]:
  #   State or Province Name (full name) [Some-State]:
  #   Locality Name (eg, city) []:
  #   Organization Name (eg, company) [Internet Widgits Pty Ltd]:
  #   Organizational Unit Name (eg, section) []:
  #   Common Name (e.g. server FQDN or YOUR name) []:
  #   Email Address []:
  openssl_subj="/C=US/ST=Illinois/L=Chicago/O=twolfson/CN=twolfson.com/emailAddress=todd@twolfson.com"
  openssl req \
    -newkey rsa:2048 -nodes -keyout twolfson.com.key \
    -x509 -days 365 -out twolfson.com.crt \
    -subj "$openssl_subj"

  # Install our certificates
  sudo mv twolfson.com.crt /etc/ssl/certs/twolfson.com.crt
  sudo chown root:root /etc/ssl/certs/twolfson.com.crt
  sudo chmod a=rwx /etc/ssl/certs/twolfson.com.crt # Anyone can do all the things

  sudo mv twolfson.com.key /etc/ssl/private/twolfson.com.key
  sudo chown root:root /etc/ssl/private/twolfson.com.key
  sudo chmod u=r,g=,o= /etc/ssl/private/twolfson.com.key # Only user can read this file
fi

# If we haven't set up a Diffie-Hellman group, then create and install it
# https://weakdh.org/sysadmin.html
if ! test -f /etc/ssl/private/dhparam.pem; then
  openssl dhparam -out dhparam.pem 2048
  sudo mv dhparam.pem /etc/ssl/private/dhparam.pem
  sudo chown root:root /etc/ssl/private/dhparam.pem
  sudo chmod u=r,g=,o= /etc/ssl/private/dhparam.pem # Only user can read this file
fi

# Invoke bootstrap.sh in our context
cd "$base_dir"
. bin/_bootstrap.sh
