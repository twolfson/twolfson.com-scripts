# Provisioning a server
To provision a new server via [Digital Ocean][], follow the steps below:

1. If we don't have a Digital Ocean SSH key pair yet, then generate one
    - https://help.github.com/articles/generating-ssh-keys/
2. Create a new Ubuntu based droplet with our SSH key (14.04 x64)
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

[data/home/ubuntu/.ssh/authorized_keys]: ../data/home/ubuntu/.ssh/authorized_keys
