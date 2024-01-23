# twolfson.com-scripts [![Build status](https://travis-ci.org/twolfson/twolfson.com-scripts.png?branch=master)](https://travis-ci.org/twolfson/twolfson.com-scripts)

Runbooks and scripts used for bootstrapping and deploying services for `twolfson.com` and its subdomains.

This was created to provide a dotfiles-like setup that documents my personal server setup.

## Breaking changes in 3.0.0
We've dropped Vagrant, Chef, and scripted bootstrapping. [See previous version here](https://github.com/twolfson/twolfson.com-scripts/tree/2.44.0).

As the replacement, we've moved to runbooks, which are easier to maintain over sparse iteration cycles.

i.e. There was always a slow "how did that work again?" period, iterating required deployments (slow), and cascades of changes from minor upgrades became even slower due to this feedback loop.

In short, we overinvested in automation, and believe divesting will lead to faster results.

For more reading, please see: https://twolfson.com/2022-07-30-startup-time-investing-operational-processes

## Getting Started
To provision a server, deploy a service, or validate integrity, we have runbooks for each of those tasks.

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

- [Provisioning a server](docs/provisioning-a-server.md)
- [Deploying a service](#deploying-a-service)
- [Validate server integrity](#validating-server-integrity)
- Additional actions documented below

## Documentation
As a high level overview of our setup, we use the following:

**Operations:**

- [DigitalOcean][] for hosting our servers and DNS management
- [Google Apps][] for email management
- [Supervisor][] for process management
- Metrics
    - Currently, we only have DigitalOcean for metrics
- Monitoring
    - We use [UptimeRobot][] and [VisualPing][]
    - In-service error reporting depends on the service

[DigitalOcean]: https://digitalocean.com/
[Google Apps]: https://apps.google.com/
[Supervisor]: https://github.com/Supervisor/supervisor
[UptimeRobot]: https://uptimerobot.com/
[VisualPing]: https://visualping.io/

**Development:**

- Provisioning is done by hand and maintained via runbooks
- Deployments are scripted in [bash][]
    - We prefer this since it's consisently available in most environments
- Secrets are managed via environment variables
- Services are currently all [Node.js][]/[JavaScript][] based
- Integrity checks are done via [Serverspec][]
    - These are both meant to cover sanity and security

[bash]: https://www.gnu.org/software/bash/
[Node.js]: https://nodejs.org/
[JavaScript]: https://en.wikipedia.org/wiki/JavaScript
[Serverspec]: https://serverspec.org/

### File structure
This repository has the following file structure:

- `.bundle/` - Configuration for Bundler (used for managing Ruby gems)
- `bin/` - Contains our executable files (e.g. deployment scripts)
- `data/` - Contains static files used during provisioning
    - This starts at `/` as if it were the root of a file system
    - For multiple environment projects, it's good to have a `data/{{env}}` for each setup (e.g. `data/development`, `data/production`)
- `src/` - Container for our bootstrapping scripts
- `spec/` - Container for our test files
    - `serverspec/` - Files for validating machines via Serverspec
- `CHANGELOG.md` - CHANGELOG of what has changed during each release of this repository
- `README.md` - Documentation for this repository
- `SECURITY.md` - Documentation for security considerations in this repository

### Provisioning a new server
See [docs/provisioning-a-server.md](docs/provisioning-a-server.md)

### Managing secrets
Secrets are maintained on each server by hand. To add/edit/remove a secret, modify the relevant section in `/etc/supervisor.conf`

### Updating a server configuration
We use our runbook provisioning setup as a "good enough" approximation of the server's state.

As a result, SSH into the machine to make changes, then when done update the files in this repo and its docs.

### Deploying a service
To deploy a service, use its respective `bin/deploy-*.sh` script. Here's an example with `twolfson.com`:

```bash
# `digital-twolfson.com` should be configured in `~/.ssh/config` as per provisioning notes
bin/deploy-twolfson.com.sh digital-twolfson.com

# If we need to deploy a non-master ref, then pass as a second parameter
# bin/deploy-twolfson.com.sh digital-my-server dev/new.feature
```

### Testing
Our test suite can be run via:

```bash
./test.sh
```

To make iterating on our test suite faster, we have set up `SKIP_LINT` environment variables. This skips running linting in our tests:

```bash
# Skip linting
SKIP_LINT=TRUE ./test.sh
```

### Validating server integrity
To run Serverspec against a server, we can use the `bin/validate-remote.sh` script.

```bash
# `digital-twolfson.com` should be configured in `~/.ssh/config` as per provisioning notes
bin/test-remote.sh digital-twolfson.com
```

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Testing information can be found in the [Testing section](#testing).

## Donating
Support this project and [others by twolfson][twolfson-projects] via [donations][twolfson-support-me].

<https://twolfson.com/support-me>

[twolfson-projects]: https://twolfson.com/projects
[twolfson-support-me]: https://twolfson.com/support-me

## Unlicense
As of Dec 08 2015, Todd Wolfson has released this repository and its contents to the public domain.

It has been released under the [UNLICENSE][].

[UNLICENSE]: UNLICENSE
