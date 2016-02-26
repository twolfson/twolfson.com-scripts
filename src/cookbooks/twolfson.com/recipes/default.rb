# Load in our dependencies
include_recipe "common"

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
