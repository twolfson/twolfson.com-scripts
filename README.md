# twolfson.com-scripts [![Build status](https://travis-ci.org/twolfson/twolfson.com-scripts.png?branch=master)](https://travis-ci.org/twolfson/twolfson.com-scripts)

Runbooks and scripts used for bootstrapping and deploying services for `twolfson.com` and its subdomains.

This was created to provide a dotfiles-like setup that documents my personal server setup.

## Breaking changes in 3.0.0
We've dropped Vagrant, Chef, and scripted bootstrapping support.

We're keeping Serverspec to ensure server integrity and have moved to runbooks for documenting setup.

We don't touch this server often, but whenever we want to, we find iteration slow and difficult.

i.e. Versioning is too brittle, commands change upon upgrading, deploying/testing requires a feedback loop.

We believe this means we've overinvested in automation, and instead believe divesting will lead to faster results.

For more reading, please see: https://twolfson.com/2022-07-30-startup-time-investing-operational-processes

## Getting Started
To get a server running or verifying server integrity, we have documented runbooks for each of those tasks.

There are common dependencies needed to check your work. Please install the following:

- Ruby @ 2.7, https://www.ruby-lang.org/en/documentation/installation/
- Bundler @ 2.4.22, https://rubygems.org/gems/bundler

For those on Ubuntu, this will look like:

```bash
sudo apt-get install ruby==1:2.7+1
sudo gem install bundler -v 2.4.22
```

Once all dependencies are installed, follow the steps below:

```bash
# Clone our repository
git clone https://github.com/twolfson/twolfson.com-scripts
cd twolfson.com-scripts

# Install our dependencies
bundle install

# Follow relevant documentation
```

## Documentation
As a high level overview of our setup, we use the following:

**Operations:**

- [Digital Ocean][] for hosting our servers and DNS management
- [Google Apps][] for email management
- [Supervisor][] for process management
- Metrics
    - Currently, we only have Digital Ocean for metrics
- Monitoring
    - We use [UptimeRobot][] and [VisualPing][]
    - In-service error reporting depends on the service

[Digital Ocean]: http://digitalocean.com/
[Google Apps]: https://apps.google.com/
[Supervisor]: https://github.com/Supervisor/supervisor
[UptimeRobot]: https://uptimerobot.com/
[VisualPing]: https://visualping.io/

**Development:**

- Provisioning is done by hand and maintained via runbooks (documented in README)
- Deployments are scripted in [bash][]
    - We prefer this for ease of approach to new developers
- Secrets are managed via environment variables
- Services are currently all [Node.js][]/[JavaScript][] based
- Tests are done via [Serverspec][]
    - These are both meant to cover sanity and security

[bash]: https://www.gnu.org/software/bash/
[Node.js]: https://nodejs.org/
[JavaScript]: https://en.wikipedia.org/wiki/JavaScript
[Serverspec]: http://serverspec.org/

### File structure
TODO: Update after scripts updated

This repository has the following file structure:

- `.bundle/` - Configuration for Bundler (used for managing Ruby gems)
- `bin/` - Contains our executable files (e.g. deployment scripts)
- `data/` - Contains static files used during provisioning
    - This starts at `/` as if it were the root of a file system
    - For multiple environment projects, it's good to have a `data/{{env}}` for each setup (e.g. `data/development`, `data/production`)
- `src/` - Container for our bootstrapping scripts
- `test/` - Container for our test files
- `CHANGELOG.md` - CHANGELOG of what has changed during each release of this repository
- `README.md` - Documentation for this repository
- `SECURITY.md` - Documentation for security considerations in this repository
- `Vagrantfile` - Configuration for Vagrant

### Provisioning a new server
TODO: Possibly move to a new folder, pull in GitHub issues

To provision a new server via [Digital Ocean][], follow the steps below:

- If we don't have a Digital Ocean SSH key pair yet, then generate one
    - https://help.github.com/articles/generating-ssh-keys/
- Create a new Ubuntu based droplet with our SSH key (14.04 x64)
- Add public key to [data/home/ubuntu/.ssh/authorized_keys][] so we can `ssh` into the `ubuntu` user
    - Digital Ocean's SSH key will initially be registered to `root` user but we dislike having direct SSH access into a `root` user
- Once droplet has started, set up our `~/.ssh/config` on the local machine

```
# Replace `digital-my-server` with a better name
# Replace 127.0.0.1 with droplet's public IP
Host digital-my-server
    User root
    HostName 127.0.0.1
```

- SSH into our server and set up basic provisions
    - `ssh digital-my-server`
    - Create a Diffie-Hellman parameter for NGINX with HTTPS (SSL)
        ```bash
        # DEV: We could use `/etc/letsencrypt/ssl-dhparams.pem` for this but are opting out for easier testing
        # https://weakdh.org/sysadmin.html
        openssl dhparam -out dhparam.pem 2048
        sudo mv dhparam.pem /etc/ssl/private/dhparam.pem
        sudo chown root:root /etc/ssl/private/dhparam.pem
        sudo chmod u=r,g=,o= /etc/ssl/private/dhparam.pem # Only user can read this file
        ```
    - Upload/import PGP privte key for SOPS, see [Managing PGP data](#managing-pgp-data)
        - TODO: Drop SOPS mention
- Install certbot for LetsEncrypt backed domains
    - Specify each subdomain/subdomain pair individually (e.g. `twolfsn.com` (1,2), `twolfson.com` (3,4)), otherwise LetsEncrypt will use the same file/certificate for all of them
- Bootstrap our server
    - `bin/bootstrap-remote.sh digital-my-server`
- Update `~/.ssh/config` to use `User ubuntu` instead of `User root`
    - During the bootstrap process, we intentionally lock our `root` access via `ssh` for security
- Run our tests on the server
    - `bin/test-remote.sh digital-my-server`

[data/home/ubuntu/.ssh/authorized_keys]: data/home/ubuntu/.ssh/authorized_keys

### Managing secrets
Secrets are maintained on each server by hand. To add/edit/remove a secret, modify the relevant section in `/etc/supervisor.conf`

### Updating a server configuration
We reuse our provisioning script for managing server state. As a result, we can reuse it for updates:

```bash
bin/bootstrap-remote.sh digital-my-server

# If we need to use a non-master ref, then pass it as a second parameter
# bin/bootstrap-remote.com.sh digital-my-server dev/new.feature
```

If you'd like to run a dry run, Chef has `--why-run` which explains everything it's doing. It's unclear if it fully stops running actions though

This can be enabled by directly editing `bin/_bootstrap.sh`

### Deploying a service
To deploy a service, use its respective `bin/deploy-*.sh` script. Here's an example with `twolfson.com`:

```bash
bin/deploy-twolfson.com.sh digital-my-server

# If we need to deploy a non-master ref, then pass as a second parameter
# bin/deploy-twolfson.com.sh digital-my-server dev/new.feature
```

### Testing
TODO: Update notes

As mentioned in the high level overview, we use [Serverspec][] for testing. This is a [Ruby][] gem so you will need it installed to run our tests:

```bash
./test.sh
```

To make iterating on our test suite faster, we have set up `SKIP_LINT` and `SKIP_PROVISION` environment variables. This skips running linting and `vagrant provision` in our tests:

```bash
# Skip both linting and provisioning
SKIP_LINT=TRUE SKIP_PROVISION=TRUE ./test.sh
```

[Ruby]: https://www.ruby-lang.org/en/

### Validating production
To run our test suite against a production machine, we can use the `bin/test-remote.sh` script.

```bash
# Before running our tests, please add the remote server to ~/.ssh/config
# For example:
# Host my-server
#     User ubuntu
#     HostName 127.0.0.1
TARGET_HOST="{{name-of-host-in-ssh-config}}" bin/test-remote.sh
```

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Testing information can be found in the [Testing section](#testing).

## Donating
Support this project and [others by twolfson][twolfson-projects] via [donations][twolfson-support-me].

<http://twolfson.com/support-me>

[twolfson-projects]: http://twolfson.com/projects
[twolfson-support-me]: http://twolfson.com/support-me

## Unlicense
As of Dec 08 2015, Todd Wolfson has released this repository and its contents to the public domain.

It has been released under the [UNLICENSE][].

[UNLICENSE]: UNLICENSE
