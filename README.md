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
TODO: Document me

- Servers are running on Digital Ocean
- DNS is being managed by AWS
- Tests are done via [testinfra][]
    - These are both meant to cover sanity and security
    - TODO: Write tests
    - TODO: Add Travis CI
- Monitoring
    - Only Digital Ocean for metrics
    - In-service error reporting depends on the service
        - TODO: We should standardize-ish...

[testinfra]: https://github.com/philpep/testinfra

### Testing
TODO: Document gem install bundle, bundle install, ./test.sh
TODO: Prob include some explanation for Ruby novices
TODO: Document SKIP_PROVISION?

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint via `npm run lint` and test via `npm test`.

// TODO: Update test notes

## Donating
Support this project and [others by twolfson][gratipay] via [gratipay][].

[![Support via Gratipay][gratipay-badge]][gratipay]

[gratipay-badge]: https://cdn.rawgit.com/gratipay/gratipay-badge/2.x.x/dist/gratipay.png
[gratipay]: https://www.gratipay.com/twolfson/

## Unlicense
As of Dec 08 2015, Todd Wolfson has released this repository and its contents to the public domain.

It has been released under the [UNLICENSE][].

[UNLICENSE]: UNLICENSE
