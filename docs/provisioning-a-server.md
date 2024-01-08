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
    User ubuntu
    HostName xxx.xxx.xxx.xxx
```

5. SSH into our server as `root` user to set up `ubuntu` one

```bash
ssh root@digital-twolfson.com
```

6. Run the following provisioning commands

```bash
# Update apt cache
sudo apt-get update

# Sanity check timezone is configured as UTC
# DEV: This was a legacy Ubuntu 14 issue, resolved in 22, https://www.digitalocean.com/community/questions/how-to-change-the-timezone-on-ubuntu-14
#   https://serverfault.com/a/84528
# Feel free to double check via: `cat /etc/timezone` and `cat /etc/localtime`
sudo dpkg-reconfigure --frontend noninteractive tzdata

# Create an `ubuntu` user as DigitalOcean's Ubuntu images only provide `root`
# DEV: GECOS is a comment field in /etc/passwd, https://en.wikipedia.org/wiki/Gecos_field
adduser ubuntu --disabled-password --gecos "Ubuntu" \
    --home /home/ubuntu --shell /bin/bash
# Can check user existence and groups via `id ubuntu`

# Adjust home folder permissions for easier third party execution
sudo chown -R ubuntu:ubuntu /home/ubuntu  # Not necessary, but feel free to be paranoid
sudo chmod u=rwx,g=rx,o=rx /home/ubuntu

# Set up sudoers for `ubuntu`, and enumerate explicit permissions
#   https://www.digitalocean.com/community/tutorials/how-to-edit-the-sudoers-file
gpasswd -a ubuntu sudo
sudo cat << EOF > /etc/sudoers.d/ubuntu
# Based off of AWS' sudoers.d
# User rules for ubuntu
ubuntu ALL=(ALL) NOPASSWD:ALL
EOF
sudo chown root:root /etc/sudoers.d/ubuntu
sudo chmod u=r,g=,o= /etc/sudoers.d/ubuntu

# Set up SSH for `ubuntu` user using current `root` SSH keys
mkdir ubuntu:ubuntu --mode u=rwx,g=,o= /home/ubuntu/.ssh
sudo chown ubuntu:ubuntu /home/ubuntu/.ssh  # `ubuntu:ubuntu` in last line didn't stick apparently?
cp /root/.ssh/authorized_keys /home/ubuntu/.ssh/authorized_keys
sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys
sudo chmod u=rw,g=,o= /home/ubuntu/.ssh/authorized_keys
```

7. In a separate terminal, SSH as `ubuntu` user to verify the above all worked

```bash
# In new tab
ssh digital-twolfson.com
```

8. Confirm permissions are as expected

```bash
ls /root # Should be denied
sudo ls /root  # Should work, no password required
```

9. Close `root` SSH session

```bash
# In root tab

# Exit session
exit
```

10. Continue provisioning in `ubuntu` SSH session

```bash
# In ubuntu tab

# Remove root user SSH permissions:

# (1) Verify permissions on SSH folder + files
sudo ls -la /root/.ssh
# Should be:
# drwx------ 2 root root 4096 [...] .
# -rw------- 1 root root [..] [...] authorized_keys

# (2) Empty out authorized keys
sudo su --command "echo '' > /root/.ssh/authorized_keys"

# (3) Lock out SSH shells for non-ubuntu users
#   https://github.com/mizzy/specinfra/blob/v2.44.7/lib/specinfra/command/base/user.rb#L61-L63
sudo usermod --shell /usr/sbin/nologin root
sudo usermod --shell /usr/sbin/nologin sync
# Sanity check no other users have shell permissions
cat /etc/passwd | grep -v /sbin/nologin | grep -v /bin/false
# Should only be `ubuntu` user
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

TODO: Consider unattended upgrades
