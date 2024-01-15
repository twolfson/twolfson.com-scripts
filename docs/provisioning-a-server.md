# Provisioning a server
To provision a new server via [DigitalOcean][], follow the steps below

## Creating and connecting to our server
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

# If there's an old server you're transferring from,
# rename it to: digital-twolfson.com-old
# DEV: We recommend a timestamp comment as well, for clarity on age

# Also (still if transferring),
# now would be a great time to reduce DNS TTL (e.g. "60" for 60s)
```

5. SSH into our server as `root` user to set up `ubuntu` one

```bash
ssh root@digital-twolfson.com
```

## Setting up users and security
6. Run the following provisioning commands

```bash
# Update apt cache
sudo apt-get update

# Sanity check timezone is configured as UTC
# DEV: This was a legacy Ubuntu 14 issue, resolved in 22, https://www.digitalocean.com/community/questions/how-to-change-the-timezone-on-ubuntu-14
#   https://serverfault.com/a/84528
# Feel free to double check via: `cat /etc/timezone` and `cat /etc/localtime` (should be Etc/UTC)
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

10. Upload files required for following steps

```bash
# In a new tab
rsync --chmod u=rw,g=,o= \
    --human-readable --archive --verbose --compress \
    data digital-twolfson.com:/home/ubuntu/twolfson.com-scripts-data
```

11. Remove SSH access to `root` user

```bash
# In ubuntu tab

# Verify permissions on SSH folder + files
sudo ls -la /root/.ssh
# Should be:
# drwx------ 2 root root 4096 [...] .
# -rw------- 1 root root [..] [...] authorized_keys

# Empty out authorized keys
sudo su --command "echo '' > /root/.ssh/authorized_keys"

# Lock out SSH shells for non-ubuntu users
#   https://github.com/mizzy/specinfra/blob/v2.44.7/lib/specinfra/command/base/user.rb#L61-L63
sudo usermod --shell /usr/sbin/nologin root
sudo usermod --shell /usr/sbin/nologin sync
# Sanity check no other users have shell permissions
cat /etc/passwd | grep -v /sbin/nologin | grep -v /bin/false
# Should only be `ubuntu` user

# At this point, in another tab, feel free to try out `root` SSH again
# ssh root@digital-twolfson.com

# Sanity check `openssh-server` version to be at least 7.1, for CVE-2016-0777 and 0778
#   https://undeadly.org/cgi?action=article&sid=20160114142733
#   https://lobste.rs/s/mzodhj/openssh_client_bug_can_leak_keys_to_malicious_servers
dpkg --list | grep openssh-server
# Current version: 1:8.9p1-3ubuntu0.1

# Update `sshd_config`
cd ~/twolfson.com-scripts
sudo chown root:root data/etc/ssh/sshd_config
sudo chmod u=rw,g=r,o=r data/etc/ssh/sshd_config
sudo mv data/etc/ssh/sshd_config /etc/ssh/sshd_config

# Reload SSH
sudo /etc/init.d/ssh reload
```

## Setting up services
12. Install system level dependencies

```bash
# Apt level dependencies
# DEV: Node.js requires apt override, https://github.com/nodesource/distributions/tree/27fffb96936373a2a4a5e7834f0dd335dd198fdf#using-ubuntu-1
#   https://www.digitalocean.com/community/tutorials/how-to-install-node-js-on-ubuntu-20-04
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
# DEV: Versions are for tracking, not for enforcement (can find via `dpkg --list | grep`)
sudo apt-get install -y \
    nginx `# NGINX, for reverse proxy, 1.18.0-6ubuntu14.4` \
    python-setuptools `# Setuptools, unsure why, 44.1.1-1.2ubuntu0.22.04.1` \
    python3-pip `# pip, for installing supervisor, 20.3.4+dfsg-4` \
    nodejs  `# Node.js runtime, 20.11.0-1nodesource1`
# If prompted around "Daemons using outdated libraries", navigate to "Cancel"

# Verify `pip` version (needed 7.1.2 from past notes, currently 22.0.2)
pip --version

# Supervisor dependencies
sudo pip install supervisor  # Version used: 4.2.5 (see `pip freeze`)
```

13. Configure NGINX

```bash
# Remove default site
# If you want a before/after, then visit this server's IP address in a browser
sudo rm /etc/nginx/sites-enabled/default
sudo /etc/init.d/nginx reload

# Remove undesired files from our `conf.d`, https://askubuntu.com/a/929385
rm -i data/etc/nginx/conf.d

# Install our sites via `conf.d` (weak preference to `sites-enabled/`sites-available`)
sudo chown root:root data/etc/nginx/conf.d/*
sudo chmod u=rw,g=r,o=r data/etc/nginx/conf.d/*
sudo mv data/etc/nginx/conf.d/* /etc/nginx/conf.d/

# Remove placeholder static HTML
sudo rm -rf /var/www/html

# Set up `drive.twolfson.com` and other static content sites
mkdir /var/www/drive.twolfson.com
mkdir /var/www/mentor.twolfson.com
chmod u=rwx,g=rx,o=rx /var/www/drive.twolfson.com
chmod u=rwx,g=rx,o=rx /var/www/mentor.twolfson.com
sudo chown ubuntu:ubuntu /var/www/*
# Verify: ls -la /var/www
# Expect: . is `root:root` and `u=rwx,g=rx,o=rx`
# Expect: Subfolders are `ubuntu:ubuntu` and `u=rwx,g=rx,o=rx`

# Comment out `ssl_certificate` lines from each NGINX config
# DEV: NGINX doesn't need these to run,
#   but files at `/etc/letsencrypt` confuses Let's Encrypt `certbot`
sudo pico /etc/nginx/conf.d/*
Trying with `break`, nope

# If you're transferring between servers, now is a good time to transfer `/var/www` files
rsync -r --human-readable --archive --verbose --compress digital-twolfson.com-old:/var/www .
rsync --chmod u=rw,g=rw,o=r \
    --human-readable --archive --verbose --compress \
    www digital-twolfson.com:/var
# Don't forget to `rm` the `www` folder

# Restart NGINX service (reload wasn't sticking)
sudo /etc/init.d/nginx restart

# Sanity check that NGINX is working:
# curl --include --insecure -H "Host: drive.twolfson.com" https://137.184.49.25/favicon.ico
```

14. Configure and deploy twolfson.com

```bash
# Create folder for log files
sudo mkdir /var/log/supervisor
# `ls -la /var/log/supervisor` should be `root:root` u=rwx,g=rx,o=rx

# Install twolfson.com supervisor config
sudo chown root:root data/etc/supervisord.conf
sudo chmod u=rw,g=r,o=r data/etc/supervisord.conf
sudo mv data/etc/supervisord.conf /etc/supervisord.conf

# Modify supervisord.conf with appropriate secrets
# TODO: Task up using `.env` instead for this
sudo pico /etc/supervisord.conf

# If we update the `supervisord.conf` after setup, run `sudo supervisorctl update` after

# Set up supervisor `init` script and autostart
# http://supervisord.org/running.html#running-supervisord-automatically-on-startup
# http://serverfault.com/a/96500
sudo chown root:root data/etc/init.d/supervisord
sudo chmod u=rwx,g=rx,o=rx data/etc/init.d/supervisord
sudo mv data/etc/init.d/supervisord /etc/init.d/supervisord

sudo /etc/init.d/supervisord start

sudo update-rc.d supervisord defaults
# You should see new `supervisord` files in `ls /etc/rc*`
```

```bash
# In a new tab, run our `twolfson.com` deploy script
bin/deploy-twolfson.com.sh digital-twolfson.com
```

```bash
# Back on the server, we can check it's running:
curl 127.0.0.1:8080 # Should see website content
sudo supervisorctl status # Should see RUNNING status
```

15. Shutdown server to verify autostart works for supervisor

```bash
sudo poweroff
```

16. Start server via Digital Ocean UI

17. Reopen SSH connection via `ssh digital-twolfson.com`

```bash
# Verify server automatically started
curl 127.0.0.1:8080 # Should see website content
sudo supervisorctl status # Should see RUNNING status
```

18. Update DNS records to point to new IP
    - Ideally keep the TTL low (e.g. "60" for 60s)

19. Set up HTTPS certificates via Let's Encrypt
    - Run the installation instructions, https://certbot.eff.org/instructions?ws=nginx&os=ubuntufocal&tab=standard
    - Use `certonly` not `certbot` since we already have `ssl_certificate` lines in our configs
    - At install time, `systemctl list-timers`  renewal gets (without need for `certbot` or `certonly`)
    - If you run into trouble with self-signed certificates, [this forum discussion was useful](https://community.letsencrypt.org/t/how-to-overwrite-existing-certificates-to-use-on-different-websites/124923/4)

21. Re-enable `ssl_certificate` in each NGINX config
    - `sudo pico /etc/nginx/conf.d/*`

21. Verify all websites look good

22. Increase DNS TTL to "1800" (30 minutes)

TODO: Ensure certbot is still installed at the end

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

TODO: If there was an old server being transferred from, can delete it + remove from `~/.ssh/config`

TODO: Callout that gifsockets is not in this setup at all
