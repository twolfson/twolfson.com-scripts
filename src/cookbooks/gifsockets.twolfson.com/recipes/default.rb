# Load in our dependencies
include_recipe "common"

# Load our constants
data_dir = ENV.fetch("data_dir")

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
file "/etc/supervisord.conf" do
  owner("root")
  group("root")
  mode("644") # u=rw,g=r,o=r
  content(::File.new("#{data_dir}/etc/supervisord.gifsockets.twolfson.com.conf").read())
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
  subscribes(:run, "file[/etc/supervisord.conf]", :delayed)
end

# Guarantee `node` is installed
# @depends_on execute[apt-get-update-periodic]
# https://github.com/nodesource/distributions/tree/96e9b7d40b6aff7ade7bc130d9e18fd140e9f4f8#installation-instructions
# DEV: Equivalent to `sudo apt-get install -y "nodejs=0.10.42-1nodesource1~trusty1"`
execute "add-nodejs-apt-repository" do
  command("curl -sL https://deb.nodesource.com/setup_0.10 | sudo -E bash -")
  only_if("! which node")
end
apt_package "nodejs" do
  version("0.10.42-1nodesource1~trusty1")
  only_if("test \"$(node --version)\" != \"v0.10.42\"")
end

# Configure NGINX for `gifsockets.twolfson.com` node
# @depends_on service[nginx]
data_file "/etc/nginx/conf.d/gifsockets.twolfson.com.conf" do
  owner("root")
  group("root")
  mode("644") # u=rw,g=r,o=r

  # When we update, reload our NGINX
  # DEV: We have a delay to guarantee all configs reload at the same time
  notifies(:reload, "service[nginx]", :delayed)
end
data_file "/etc/nginx/nginx.conf" do
  owner("root")
  group("root")
  mode("644")
  notifies(:reload, "service[nginx]", :delayed)
end

# Guarantee PhantomJS is installed
apt_package "phantomjs" do
  version("1.9.0-1")
  only_if("test \"$(phantomjs --version)\" != \"1.9.0\"")
end
