# Define our constants
data_dir = ENV.fetch("data_dir")

# Guarantee `apt-get update` has been run in past 24 hours
# http://stackoverflow.com/a/9250482
# DEV: Relies on apt hook
#   http://serverfault.com/questions/20747/find-last-time-update-was-performed-with-apt-get
execute "apt-get-update-periodic" do
  command("sudo apt-get update")
  only_if do
    # If we have have ran `apt-get update` before
    if File.exists?("/var/lib/apt/periodic/update-success-stamp")
      # Return if we ran it in the past 24 hours
      # DEV: Equivalent to `date +%s` compared to `stat --format %Y`
      one_day_ago = Time.now().utc() - (60 * 60 * 24)
      next File.mtime("/var/lib/apt/periodic/update-success-stamp") < one_day_ago
    # Otherwise, tell it to run
    else
      next true
    end
  end
end

# Guarantee timezone is as we expect it
# https://www.digitalocean.com/community/questions/how-to-change-the-timezone-on-ubuntu-14
# http://serverfault.com/a/84528
execute "dpkg-reconfigure-tzdata" do
  command("sudo dpkg-reconfigure --frontend noninteractive tzdata")
  action(:nothing)
end
file "/etc/timezone" do
  owner("root")
  group("root")
  mode("644") # u=rw,g=r,o=r

  content(File.new("#{data_dir}/etc/timezone").read())

  # When we update, re-run our dpkg-reconfigure
  notifies(:run, "execute[dpkg-reconfigure-tzdata]", :immediately)
end

# Guarantee we have a `ubuntu` user provisioned
# DEV: Digital Ocean's Ubuntu images provision us as the root user so we must create an ubuntu user
# DEV: Equivalent to `id ubuntu` then `adduser ubuntu --disabled-password --gecos "Ubuntu` and `gpasswd -a ubuntu sudo`
#   https://github.com/mizzy/specinfra/blob/v2.47.0/lib/specinfra/command/base/user.rb#L3-L5
#   https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-14-04
user "ubuntu" do
  # Create our user with a locked password
  action(:create)
  # DEV: `action(:lock)` acts as as `adduser --disabled-password`
  action(:lock)

  # Add a comment about their user info
  # DEV: `comment` acts as `adduser --gecos`
  comment("Ubuntu")

  # Add them to the `sudo` group
  group("sudo")
end
# Guarantee `.ssh` directory for authorized keys
# @depends_on user[ubuntu] (for `/home/ubuntu` creation)
# DEV: Equivalent to `mkdir ubuntu:ubuntu --mode u=rwx,g=,o= /home/ubuntu/.ssh`
directory "/home/ubuntu/.ssh" do
  owner("ubuntu")
  group("ubuntu")
  mode("700") # u=rwx,g=,o=
end
# Guarantee `sudo` rights for `ubuntu` for developer sanity
# https://www.digitalocean.com/community/tutorials/how-to-edit-the-sudoers-file-on-ubuntu-and-centos
# @depends_on user[ubuntu] (for `user` reference)
file "/etc/sudoers.d/ubuntu" do
  owner("root")
  group("root")
  mode("400") # u=r,g=,o=

  content(File.new("#{data_dir}/etc/sudoers.d/ubuntu").read())
end

# Guarantee we have authorized keys synced
# @depends_on user[ubuntu] (to prevent lock out)
# @depends_on directory[/home/ubuntu/.ssh] (for directory creation)
# DEV: This won't brick Vagrant since it uses a `vagrant` user for ssh
file "/home/ubuntu/.ssh/authorized_keys" do
  owner("ubuntu")
  group("ubuntu")
  mode("600") # u=rw,g=,o=

  content(File.new("#{data_dir}/home/ubuntu/.ssh/authorized_keys").read())
end
# WARNING: THIS WILL LOCK OUT THE ROOT USER
directory "/root/.ssh" do
  owner("root")
  group("root")
  mode("700") # u=rwx,g=,o=
end
# @depends_on directory[/root/.ssh] (for directory creation)
file "/root/.ssh/authorized_keys" do
  owner("root")
  group("root")
  mode("600") # u=rw,g=,o=

  content(File.new("#{data_dir}/root/.ssh/authorized_keys").read())
end

# Lock out SSH shells for non-`ubuntu` users
# @depends_on file[/home/ubuntu/.ssh/ubuntu/authorized_keys] (to prevent lock out)
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
# @depends_on file[/home/ubuntu/.ssh/ubuntu/authorized_keys] (to prevent lock out)
# WARNING: THIS WILL LOCK OUT THE ROOT USER
# DEV: Equivalent to `sudo service ssh *`
service "ssh" do
  # Always enable and run our SSH server
  # https://docs.chef.io/resource_service.html#examples
  provider Chef::Provider::Service::Upstart
  supports(:reload => true, :restart => true, :status => true)
  action([:enable, :start])
end
file "/etc/ssh/sshd_config" do
  owner("root")
  group("root")
  mode("600") # u=rw,g=,o=

  content(File.new("#{data_dir}/etc/ssh/sshd_config").read())

  # When we update, reload our ssh service
  # http://unix.stackexchange.com/a/127887
  notifies(:reload, "service[ssh]", :immediately)
end
