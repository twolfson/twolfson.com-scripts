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

- Provisioning is currently done by [Chef][]
    - This is to maximize reuse of common setup
    - For ease of approach to new developers, we typically prefer [bash][]
- Secrets are managed via [SOPS][]
- Services are currently all [Node.js][]/[JavaScript][] based
- Tests are done via [Serverspec][]
    - These are both meant to cover sanity and security

[Chef]: https://www.chef.io/
[bash]: https://www.gnu.org/software/bash/
[SOPS]: https://github.com/mozilla/sops
[Node.js]: https://nodejs.org/
[JavaScript]: https://en.wikipedia.org/wiki/JavaScript
[Serverspec]: http://serverspec.org/

### File structure
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
- Install certbot for LetsEncrypt backed domains
    - Specify each subdomain/subdomain pair individually (e.g. `twolfsn.com` (1,2), `twolfson.com` (3,4)), otherwise LetsEncrypt will use the same file/certificate for all of them
- Bootstrap our server
    - `bin/bootstrap-remote.sh digital-my-server`
- Update `~/.ssh/config` to use `User ubuntu` instead of `User root`
    - During the bootstrap process, we intentionally lock our `root` access via `ssh` for security
- Run our tests on the server
    - `bin/test-remote.sh digital-my-server`

[data/home/ubuntu/.ssh/authorized_keys]: data/home/ubuntu/.ssh/authorized_keys

### Managing PGP data
We use [PGP][] and [SOPS][] for storing our secrets. To add a new PGP key, follow the steps below:

- Find full fingerprint of key we want to export
    - `gpg --fingerprint`
    - Fingerprint will be `740D DBFA...` in `Key fingerprint = 740D DBFA...`
- Extract private key to file
    - `gpg --export-secret-keys --armor {{fingerprint}} > private.rsa`
    - `--armor` exports a human-friendly ASCII format instead of binary
- Upload/import private key to our server
    ```bash
    # Run outside of the server, can also use copy/paste if desired
    ssh my-digital-server "echo \"$(cat "path/to/file.pem")\" | gpg --import -"
    ```

[PGP]: https://en.wikipedia.org/wiki/Pretty_Good_Privacy

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
As mentioned in the high level overview, we use [Serverspec][] for testing. This is a [Ruby][] gem so you will need it installed to run our tests:

```bash
# Install bundler to manage gems for local directory
gem install bundler

# Install dependencies for this repo
bundle install

# Run our tests
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
