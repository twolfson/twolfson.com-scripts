# Provisioning a server
To provision a new server via [Digital Ocean][], follow the steps below:

1. If we don't have a Digital Ocean SSH key pair yet, then generate one
    - [GitHub has ideal instructions for generating a new key (ideal flags)](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
    - [Digital Ocean documentation for adding new SSH key](https://docs.digitalocean.com/products/droplets/how-to/add-ssh-keys/to-team/)
2. [Create a new Digital Ocean droplet][create-droplet] with the following configuration
    - Region: NYC1 (more realistic lag since I'm in SF, plus middleground for EU)
    - OS: Ubuntu LTS (22.04 x64)
    - Droplet: Regular, $4/mo (512MB CPU, 10GB SSD, 500GB transfer)
        - Context: Repo is ~200MB per deployment, giving us plenty of space still
        - and we've run on 512MB CPU since 2016-01-19 just fine
    - Authentication method: SSH key from previous step
    - Enable improved metrics and monitoring
    - Hostname: twolfson.com
3. Add public key to [data/home/ubuntu/.ssh/authorized_keys][] so we can `ssh` into the `ubuntu` user
    - Digital Ocean's SSH key will initially be registered to `root` user but we dislike having direct SSH access into a `root` user
4. Once droplet has started, set up our `~/.ssh/config` on the local machine

```
# Replace xxx.xxx.xxx.xxx with droplet's public IP
Host digital-twolfson.com
    User root
    HostName xxx.xxx.xxx.xxx
```

5. SSH into our server and set up basic provisions
    1 `ssh digital-twolfson.com`
    2. Create a Diffie-Hellman parameter for NGINX with HTTPS (SSL)
        ```bash
        # DEV: We could use `/etc/letsencrypt/ssl-dhparams.pem` for this but are opting out for easier testing
        # https://weakdh.org/sysadmin.html
        openssl dhparam -out dhparam.pem 2048
        sudo mv dhparam.pem /etc/ssl/private/dhparam.pem
        sudo chown root:root /etc/ssl/private/dhparam.pem
        sudo chmod u=r,g=,o= /etc/ssl/private/dhparam.pem # Only user can read this file
        ```
6. Install certbot for LetsEncrypt backed domains
    - Specify each subdomain/subdomain pair individually (e.g. `twolfsn.com` (1,2), `twolfson.com` (3,4)), otherwise LetsEncrypt will use the same file/certificate for all of them
7. Bootstrap our server (TODO: No longer functional) (TODO: Delete Chef)
    - `bin/bootstrap-remote.sh digital-my-server`
8. Update `~/.ssh/config` to use `User ubuntu` instead of `User root`
    - During the bootstrap process, we intentionally lock our `root` access via `ssh` for security
9. Run our tests on the server
    - `bin/test-remote.sh digital-my-server`

[create-droplet]: https://cloud.digitalocean.com/droplets
[data/home/ubuntu/.ssh/authorized_keys]: ../data/home/ubuntu/.ssh/authorized_keys
