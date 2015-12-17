# twolfson.com-scripts [![Build status](https://travis-ci.org/twolfson/twolfson.com-scripts.png?branch=master)](https://travis-ci.org/twolfson/twolfson.com-scripts)

Scripts used for bootstrapping and deploying services for `twolfson.com` and its subdomains.

This was created to provide a dotfiles-like setup that documents my personal server setup.

## Getting Started
To get a local server running, we have created a [Vagrant][] setup.

If you don't have Vagrant installed, then please follow the instructions at <http://www.vagrantup.com/>.

[Vagrant]: http://www.vagrantup.com/

Once Vagrant is installed, follow the steps below:

```bash
# Clone our repository
git clone https://github.com/twolfson/twolfson.com-scripts

# Start up a Vagrant instance
vagrant up

# SSH into the machine and poke around
vagrant ssh
```

## Documentation
As a high level overview of our setup, we use the following:

**Operations:**

- [Digital Ocean][] for hosting our servers
- [AWS][] for DNS management via [Route 53][]
- [Google Apps][] for email management
- Metrics
    - Currently, we only have Digital Ocean for metrics
- Monitoring
    - We use [UptimeRobot][] and [VisualPing][]
    - In-service error reporting depends on the service

[Digital Ocean]: http://digitalocean.com/
[AWS]: https://aws.amazon.com/
[Route 53]: https://aws.amazon.com/route53/
[Google Apps]: https://apps.google.com/
[UptimeRobot]: https://uptimerobot.com/
[VisualPing]: https://visualping.io/

**Development:**

- Provisioning is currently done by [bash][]
    - This is to maximize ease of approach for new developers
- Services are currently all [Node.js][]/[JavaScript][] based
- Tests are done via [Serverspec][]
    - These are both meant to cover sanity and security

[bash]: https://www.gnu.org/software/bash/
[Node.js]: https://nodejs.org/
[JavaScript]: https://en.wikipedia.org/wiki/JavaScript
[Serverspec]: http://serverspec.org/

### File structure
This repository has the following file structure:

- `.bundle/` - Configuration for Bundler (used for managing Ruby gems)
- `bin/` - Contains our executable files (e.g. bootstraping scripts)
- `data/` - Contains static files used during provisioning
    - This starts at `/` as if it were the root of a file system
    - For multiple environment projects, it's good to have a `data/{{env}}` for each setup (e.g. `data/development`, `data/production`)
- `test/` - Container for our test files
- `CHANGELOG.md` - CHANGELOG of what has changed during each release of this repository
- `README.md` - Documentation for this repository
- `SECURITY.md` - Documentation for security considerations in this repository
- `Vagrantfile` - Configuration for Vagrant

### Testing
As mentioned in the high level overview, we use [Serverspec][] for testing. This is a [Ruby][] gem so you will need it installed to run our tests:

```bash
# Install bundler to manage gems for local directory
gem install bundler

# Install dependencies for this repo
bundle install

# Run our tests
./test.sh
```

To make iterating on our test suite faster, we have set up a `SKIP_PROVISION` environment variable. This skips running `vagrant provision` in our tests:

```bash
SKIP_PROVISION=TRUE ./test.sh
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
Support this project and [others by twolfson][gratipay] via [gratipay][].

[![Support via Gratipay][gratipay-badge]][gratipay]

[gratipay-badge]: https://cdn.rawgit.com/gratipay/gratipay-badge/2.x.x/dist/gratipay.png
[gratipay]: https://www.gratipay.com/twolfson/

## Unlicense
As of Dec 08 2015, Todd Wolfson has released this repository and its contents to the public domain.

It has been released under the [UNLICENSE][].

[UNLICENSE]: UNLICENSE
