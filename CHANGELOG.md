# twolfson.com-scripts changelog
2.28.1 - Added ignores for new `bin/bundle` to fix Travis CI issues

2.28.0 - Upgraded to Node.js@6.11.5 to fix Travis CI issues

2.27.0 - Added allowed "aj" user for Travis CI

2.26.0 - Upgraded to Node.js@6.11.4 to fix Travis CI issues

2.25.0 - Upgraded to Node.js@6.11.3 to fix Travis CI issues

2.24.0 - Upgraded to Node.js@6.11.2 to fix Travis CI issues

2.23.1 - Fixed up one-off issues to remove deprecated flag from Travis CI

2.23.0 - Upgraded to Node.js@6.11.1 and NGINX patch version to fix Travis CI issues

2.22.0 - Added allowed "packer" user for Travis CI

2.21.0 - Upgraded to Node.js@6.11.0 to fix Travis CI issues

2.20.0 - Upgraded to Node.js@6.10.3 to fix Travis CI issues

2.19.0 - Upgraded to Node.js@6.10.2 to fix Travis CI issues

2.18.0 - Fixed apt version for Node.js to fix Travis CI issues

2.17.0 - Upgraded to Node.js@6.10.1 to fix Travis CI issues

2.16.0 - Upgraded to Node.js@6.10.0 to fix Travis CI issues

2.15.0 - Upgraded to Node.js@6.9.5 to fix Travis CI issues

2.14.0 - Upgraded to Node.js@6.9.4 to fix Travis CI issues

2.13.0 - Upgraded to Node.js@6.9.3 to fix Travis CI issues

2.12.0 - Upgraded to Node.js@6.9.2 to fix Travis CI issues

2.11.1 - Added new Travis CI user based on nightly build

2.11.0 - Moved to installing dependencies locally for `bin/deploy-twolfson.com.sh` to resolve memory issues introduced by Node.js@6

2.10.0 - Removed Node.js upgrade check

2.9.0 - Upgraded to Node.js@6.9.1 due to Node.js@0.10 out of maintenance

2.8.1 - Upgraded to `nginx=1.4.6-1ubuntu3.7` to fix Travis CI issues

2.8.0 - Upgraded to `nginx=1.4.6-1ubuntu3.6` to fix Travis CI issues

2.7.1 - Fixed Travis CI users more thoroughly

2.7.0 - Upgraded to Node.js@0.10.48, sops@0.14, and OpenSSH@1:6.6p1-2ubuntu2.8 as well as fixed `sudo` in Travis CI

2.6.4 - Upgraded to `nginx=1.4.6-1ubuntu3.5` and added Travis CI user to fix provisioning

2.6.3 - Upgraded to OpenSSH@1:6.6p1-2ubuntu2.7 and Node.js@0.10.45 for security

2.6.2 - Allow failure during bootstrap of last tag in Travis CI since it's not the test's focus

2.6.1 - Updated apt versions and Travis CI users

2.6.0 - Upgraded to OpenSSH@2.6 to patch PatrolServer errors

2.5.0 - Moved to SOPS for managing secrets for twolfson.com

2.4.1 - Repaired diff test in Travis CI for `git tag` releases

2.4.0 - Added `data_file` resource. Fixes #8

2.3.1 - Added test for provisioning last tag to prevent missing deletions

2.3.0 - Added linting via RuboCop. Fixes #7

2.2.0 - Added upgrade for `openssh-server` to patch vulnerability

2.1.2 - Added assertion to prevent future SSH lockouts

2.1.1 - Added notes for origins of sensitive remote data

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
