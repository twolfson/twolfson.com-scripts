# Load in our dependencies
require "serverspec"
require "net/ssh"

# Define file constants
# Attribution to @brettlangdon for work on this
USER_NONE = 0o000
USER_R = 0o400
USER_W = 0o200
USER_X = 0o100
USER_RW = USER_R | USER_W
USER_RX = USER_R | USER_X
USER_WX = USER_W | USER_X
USER_RWX = USER_R | USER_W | USER_X

GROUP_NONE = 0o000
GROUP_R = 0o040
GROUP_W = 0o020
GROUP_X = 0o010
GROUP_RW = GROUP_R | GROUP_W
GROUP_RX = GROUP_R | GROUP_X
GROUP_WX = GROUP_W | GROUP_X
GROUP_RWX = GROUP_R | GROUP_W | GROUP_X

OTHER_NONE = 0o000
OTHER_R = 0o004
OTHER_W = 0o002
OTHER_X = 0o001
OTHER_RW = OTHER_R | OTHER_W
OTHER_RX = OTHER_R | OTHER_X
OTHER_WX = OTHER_W | OTHER_X
OTHER_RWX = OTHER_R | OTHER_W | OTHER_X

# Define user/group constants
ROOT_USER = "root".freeze()
ROOT_GROUP = "root".freeze()
UBUNTU_USER = "ubuntu".freeze()
UBUNTU_GROUP = "ubuntu".freeze()

# If we are using a SSH backend, then configure it
if ENV["SERVERSPEC_BACKEND"] == "ssh"
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
# Otherwise, if we are using an exec backend, then configure it
elsif ENV["SERVERSPEC_BACKEND"] == "exec"
  set(:backend, :exec)
# Otherwise, error out
else
  abort("Expected environment variable `SERVERSPEC_BACKEND` to be \"ssh\" or \"exec\" " +
    "but it was \"#{ENV["SERVERSPEC_BACKEND"]}\". Please correct it")
end
