# twolfson.com-scripts changelog
2.1.0 - Repaired broken user provisioning for `ubuntu`

2.0.2 - Updated DNS docs

2.0.1 - Updated provisioner docs

2.0.0 - Moved to Chef as our provisioner

1.14.1 - Added tests for user provisioning

1.14.0 - Moved to periodic `apt-get update`

1.13.1 - Upgraded to `serverspec@2.29.0` to remove custom fork

1.13.0 - Broke down `bin/_bootstrap.sh` into 2 halves for transition and reuse

1.12.0 - Moved `deploy-twolfson.com.sh` from `npm install` to `deploy-install.sh`

1.11.0 - Added NGINX configuration for `twolfsn.com`

1.10.0 - Repaired timezone issue on Digital Ocean

1.9.0 - Patched Logjam vulnerability

1.8.1 - Enabled gzip compression for all files on `drive.twolfson.com`

1.8.0 - Added `drive.twolfson.com` to NGINX

1.7.0 - Consolidated and repaired SSL configuration for twolfson.com

1.6.0 - Added `twolfson.com` deploy script

1.5.0 - Added `twolfson.com` to Supervisor

1.4.0 - Added Supervisor for process management

1.3.3 - Repaired chown's not sticking during Vagrant bootstrap

1.3.2 - Repaired `bootstrap-remote.sh` for non-root user

1.3.1 - Fixed broken Travis CI

1.3.0 - Added provisioning scripts for remote server

1.2.0 - Removed `git` patches for `specinfra` after finding better solutions

1.1.0 - Added Travis CI setup

1.0.0 - Initial release
