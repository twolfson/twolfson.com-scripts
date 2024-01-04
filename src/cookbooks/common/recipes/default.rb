# Guarantee `.ssh` directory for authorized keys
# @depends_on user[ubuntu] (for owner/group reference)
# @depends_on directory[/home/ubuntu] (for parent directory creation)
# DEV: Equivalent to `mkdir ubuntu:ubuntu --mode u=rwx,g=,o= /home/ubuntu/.ssh`
directory "/home/ubuntu/.ssh" do
  owner("ubuntu")
  group("ubuntu")
  mode("700") # u=rwx,g=,o=
end
# Guarantee `sudo` rights for `ubuntu` for developer sanity
# https://www.digitalocean.com/community/tutorials/how-to-edit-the-sudoers-file-on-ubuntu-and-centos
# @depends_on user[ubuntu] (for `user` reference)
data_file "/etc/sudoers.d/ubuntu" do
  owner("root")
  group("root")
  mode("400") # u=r,g=,o=
end

# Guarantee we have authorized keys synced
# @depends_on user[ubuntu] (to prevent lock out)
# @depends_on directory[/home/ubuntu/.ssh] (for directory creation)
# DEV: This won't brick Vagrant since it uses a `vagrant` user for ssh
data_file "/home/ubuntu/.ssh/authorized_keys" do
  owner("ubuntu")
  group("ubuntu")
  mode("600") # u=rw,g=,o=
end
# WARNING: THIS WILL LOCK OUT THE ROOT USER
directory "/root/.ssh" do
  owner("root")
  group("root")
  mode("700") # u=rwx,g=,o=
end
# @depends_on directory[/root/.ssh] (for directory creation)
data_file "/root/.ssh/authorized_keys" do
  owner("root")
  group("root")
  mode("600") # u=rw,g=,o=
end

# Lock out SSH shells for non-`ubuntu` users
# @depends_on data_file[/home/ubuntu/.ssh/ubuntu/authorized_keys] (to prevent lock out)
# DEV: Equivalent to `test "$(getent passwd root | cut -f 7 -d ":")" != "/usr/sbin/nologin"`
#   and `sudo usermod --shell /usr/sbin/nologin root`
# https://github.com/mizzy/specinfra/blob/v2.44.7/lib/specinfra/command/base/user.rb#L53-L55
# https://github.com/mizzy/specinfra/blob/v2.44.7/lib/specinfra/command/base/user.rb#L61-L63
user "root" do
  shell("/usr/sbin/nologin")
end
user "sync" do
  shell("/usr/sbin/nologin")
end

# Configure root for security (e.g. no direct `root` login, restrict SSL algorithms)
# @depends_on exectue[apt-get-update-periodic] (to make sure apt is updated)
# @depends_on data_file[/home/ubuntu/.ssh/ubuntu/authorized_keys] (to prevent lock out)
# WARNING: SSHD_CONFIG UPDATE WILL LOCK OUT THE ROOT USER
# Update `openssh-server` for security
#   https://lobste.rs/s/mzodhj/openssh_client_bug_can_leak_keys_to_malicious_servers
#   http://undeadly.org/cgi?action=article&sid=20160114142733
apt_package "openssh-server" do
  version("1:6.6p1-2ubuntu2.8")
end
# DEV: Equivalent to `sudo service ssh *`
service "ssh" do
  # Always enable and run our SSH server
  # https://docs.chef.io/resource_service.html#examples
  provider(Chef::Provider::Service::Upstart)
  supports(:reload => true, :restart => true, :status => true)
  action([:enable, :start])
end
data_file "/etc/ssh/sshd_config" do
  owner("root")
  group("root")
  mode("644") # u=rw,g=r,o=r

  # When we update, reload our ssh service
  # http://unix.stackexchange.com/a/127887
  notifies(:reload, "service[ssh]", :immediately)
end

# Guarantee `nginx` is installed
# @depends_on exectue[apt-get-update-periodic] (to make sure apt is updated)
# DEV: Equivalent to `sudo apt-get install -y "nginx=1.4.6-1ubuntu3.8"`
apt_package "nginx" do
  version("1.4.6-1ubuntu3.8")
end
# DEV: Equivalent to `sudo /etc/init.d/nginx *`
service "nginx" do
  provider Chef::Provider::Service::Init
  supports(:reload => true, :restart => true, :status => true)
  action([:start])
end
# If there are default NGINX configuration files, then remove them
# DEV: Equivalent to `test "$(ls /etc/nginx/sites-enabled)" != ""` -> `rm /etc/nginx/sites-enabled/*`
file "/etc/nginx/sites-enabled/default" do
  action(:delete)

  # Upon deletion, reload NGINX
  notifies(:reload, "service[nginx]", :immediately)
end

# Guarantee `python` and `pip` are installed
# @depends_on exectue[apt-get-update-periodic] (to make sure apt is updated)
# DEV: Equivalent to `sudo apt-get install -y "python-setuptools=3.3-1ubuntu2" "python-pip=1.5.4-1ubuntu3"`
apt_package "python-setuptools" do
  version("3.3-1ubuntu2")
end
apt_package "python-pip" do
  version("1.5.4-1ubuntu4")
end
# If pip is out of date, then upgrade it
execute "upgrade-pip" do
  command("sudo pip install \"pip==7.1.2\"")
  # `pip --version`: `pip 7.1.2 from /usr/local/lib/python2.7/dist-packages (python 2.7)`
  # DEV: Equivalent to `! pip --version | grep "pip 7.1.2" &> /dev/null`
  only_if("! pip --version | grep \"pip 7.1.2\"")
end

# Guarantee `supervisor` is installed and configured
# @depends_on execute[upgrade-pip]
execute "install-supervisor" do
  command("sudo pip install \"supervisor==3.2.0\"")
  # `pip --version`: `pip 7.1.2 from /usr/local/lib/python2.7/dist-packages (python 2.7)`
  # DEV: Equivalent to `! pip --version | grep "pip 7.1.2" &> /dev/null`
  only_if("test \"$(supervisord --version)\" != \"3.2.0\"")
end
# Create folder for log files
directory "/var/log/supervisor" do
  owner("root")
  group("root")
  mode("755") # u=rwx,g=rx,o=rx
end
# Set up our supervisor configuration
# TODO: Use a template for `supervisord.conf`
#   and don't run any `twolfson.com` services by default (e.g. use `if twolfson.com` for conf blocks)
data_file "/etc/supervisord.conf" do
  owner("root")
  group("root")
  mode("644") # u=rw,g=r,o=r
end
# Install our `init` script
# http://supervisord.org/running.html#running-supervisord-automatically-on-startup
# http://serverfault.com/a/96500
data_file "/etc/init.d/supervisord" do
  owner("root")
  group("root")
  mode("755") # u=rwx,g=rx,o=rx
end
service "supervisord" do
  provider(Chef::Provider::Service::Init)
  supports(:reload => false, :restart => true, :status => true)
  action([:start])
end
execute "autostart-supervisord" do
  command("sudo update-rc.d supervisord defaults")
  only_if("! ls /etc/rc0.d/K20supervisord")
end
execute "update-supervisorctl" do
  # DEV: We need to access socket as root user
  # DEV: This command might fail if we change anything with `supervisor.d's` config
  #   Be sure to use `/etc/init.d/supervisord restart` in that case
  command("sudo supervisorctl update")
  action(:nothing)

  # When our configuration changes, update ourself
  # DEV: We must wait until `/etc/init.d/supervisord` has launched
  subscribes(:run, "data_file[/etc/supervisord.conf]", :delayed)
end
