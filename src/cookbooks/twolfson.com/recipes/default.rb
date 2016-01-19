# Load in our dependencies
include_recipe "common"

# Guarantee `node` is installed
# @depends_on execute[apt-get-update-periodic]
# https://github.com/nodesource/distributions/tree/96e9b7d40b6aff7ade7bc130d9e18fd140e9f4f8#installation-instructions
# DEV: Equivalent to `sudo apt-get install -y "nodejs=0.10.41-1nodesource1~trusty1"`
execute "add-nodejs-apt-repository" do
  execute("curl -sL https://deb.nodesource.com/setup_0.10 | sudo -E bash -")
  only_if("! which node")
end
apt_package "nodejs" do
  version("0.10.41-1nodesource1~trusty1")
  only_if("test \"$(node --version)\" != \"v0.10.41\"")
end
