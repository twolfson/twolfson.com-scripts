# Load in our dependencies
include_recipe "common"

# Guarantee `node` is installed
# @depends_on execute[apt-get-update-periodic]
# https://github.com/nodesource/distributions/tree/564ec6.14.4fbfc3f2e3a47725f0abfeca678b1e#installation-instructions
# DEV: Equivalent to `sudo apt-get install -y "nodejs=6.14.4-1nodesource1"`
execute "add-nodejs-apt-repository" do
  command("curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -")
  only_if("! which node")
end
apt_package "nodejs" do
  version("6.14.4-1nodesource1")
  only_if("test \"$(node --version)\" != \"v6.14.4\"")
end

# Configure NGINX for `twolfson.com` node
# @depends_on service[nginx]
data_file "/etc/nginx/conf.d/twolfson.com.conf" do
  owner("root")
  group("root")
  mode("644") # u=rw,g=r,o=r

  # When we update, reload our NGINX
  # DEV: We have a delay to guarantee all configs reload at the same time
  notifies(:reload, "service[nginx]", :delayed)
end
data_file "/etc/nginx/conf.d/drive.twolfson.com.conf" do
  owner("root")
  group("root")
  mode("644")
  notifies(:reload, "service[nginx]", :delayed)
end
data_file "/etc/nginx/conf.d/twolfsn.com.conf" do
  owner("root")
  group("root")
  mode("644")
  notifies(:reload, "service[nginx]", :delayed)
end
data_file "/etc/nginx/nginx.conf" do
  owner("root")
  group("root")
  mode("644")
  notifies(:reload, "service[nginx]", :delayed)
end
# Guarantee we have a folder for `drive.twolfson.com`
directory "/var/www" do
  owner("root")
  group("root")
  mode("755") # u=rwx,g=rx,o=rx
end
directory "/var/www/drive.twolfson.com" do
  owner("ubuntu")
  group("ubuntu")
  mode("755") # u=rwx,g=rx,o=rx
end
