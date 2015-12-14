# twolfson.com-scripts [![Build status](https://travis-ci.org/twolfson/twolfson.com-scripts.png?branch=master)](https://travis-ci.org/twolfson/twolfson.com-scripts)

Scripts used for bootstrapping and deploying services for `twolfson.com` and its subdomains.

This was created to provide a dotfiles-like setup that documents my personal server setup.

TODO: Clean up TODO's into GitHub issues

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

### Testing
TODO: Document gem install bundle, bundle install, ./test.sh
TODO: Prob include some explanation for Ruby novices
TODO: Document SKIP_PROVISION?

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
