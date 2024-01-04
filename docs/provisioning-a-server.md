# Provisioning a server
To provision a new server via [DigitalOcean][], follow the steps below:

1. If we don't have a DigitalOcean SSH key pair yet, then generate one
    - [GitHub has ideal instructions for generating a new key (ideal flags)](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
    - [DigitalOcean documentation for adding new SSH key](https://docs.digitalocean.com/products/droplets/how-to/add-ssh-keys/to-team/)
2. [Create a new DigitalOcean droplet][create-droplet] with the following configuration
    - Region: NYC1 (more realistic lag since I'm in SF, plus middleground for EU)
    - OS: Ubuntu LTS (22.04 x64)
    - Droplet: Regular, $4/mo (512MB CPU, 10GB SSD, 500GB transfer)
        - Context: Repo is ~200MB per deployment, giving us plenty of space still
        - and we've run on 512MB CPU since 2013-12-08 just fine (sometimes requiring `npm` memory workarounds)
    - Authentication method: SSH key from previous step
    - Enable improved metrics and monitoring
    - Hostname: twolfson.com
3. Add SSH public key to [data/home/ubuntu/.ssh/authorized_keys][] so we can `ssh` into the `ubuntu` user
    - DigitalOcean's SSH key will initially be registered to `root` user but we dislike having direct SSH access into a `root` user
4. Once droplet has started, set up a `~/.ssh/config` on your computer to connect to machine

```
# Replace xxx.xxx.xxx.xxx with droplet's public IP
Host digital-twolfson.com
    User root
    HostName xxx.xxx.xxx.xxx
```

5. SSH into our server

```bash
ssh digital-twolfson.com
```

6. Create a Diffie-Hellman parameter for NGINX with HTTPS (SSL)

```bash
# https://weakdh.org/sysadmin.html
openssl dhparam -out dhparam.pem 2048
sudo mv dhparam.pem /etc/ssl/private/dhparam.pem
sudo chown root:root /etc/ssl/private/dhparam.pem
sudo chmod u=r,g=,o= /etc/ssl/private/dhparam.pem # Only user can read this file
```

7. Install certbot for LetsEncrypt backed domains
    - Specify each subdomain/subdomain pair individually (e.g. `twolfsn.com` (1,2), `twolfson.com` (3,4)), otherwise LetsEncrypt will use the same file/certificate for all of them
8. Bootstrap our server (TODO: No longer functional) (TODO: Delete Chef)
    - `bin/bootstrap-remote.sh digital-my-server`
1. Update `~/.ssh/config` to use `User ubuntu` instead of `User root`
    - During the bootstrap process, we intentionally lock our `root` access via `ssh` for security
1. Run our tests on the server
    - `bin/test-remote.sh digital-my-server`

[create-droplet]: https://cloud.digitalocean.com/droplets
[data/home/ubuntu/.ssh/authorized_keys]: ../data/home/ubuntu/.ssh/authorized_keys
