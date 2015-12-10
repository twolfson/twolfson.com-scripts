# Load in our dependencies
require "serverspec"
require "net/ssh"

# Load in our environment variable to the SSH config
ssh_config = ENV.fetch("SSH_CONFIG")
host = ENV.fetch("TARGET_HOST")

# Extract the SSH setup for our server
#   Host default
#     HostName 127.0.0.1
#     User vagrant
#     Port 2222
# into:
#   {host_name, user, port, ...}
options = Net::SSH::Config.for(host, [ssh_config])

# Configure serverspec
set(:backend, :ssh)
set(:host, options[:host_name])
set(:ssh_options, options)
