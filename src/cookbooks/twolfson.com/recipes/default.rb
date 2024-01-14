# Guarantee `node` is installed
# @depends_on execute[apt-get-update-periodic]
# https://github.com/nodesource/distributions/tree/564ec6.14.4fbfc3f2e3a47725f0abfeca678b1e#installation-instructions
# DEV: Equivalent to `sudo apt-get install -y "nodejs=6.14.4-1nodesource1"`
# execute "add-nodejs-apt-repository" do
#   command("curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -")
#   only_if("! which node")
# end
# apt_package "nodejs" do
#   version("6.14.4-1nodesource1")
#   only_if("test \"$(node --version)\" != \"v6.14.4\"")
# end
