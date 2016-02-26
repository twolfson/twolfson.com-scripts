# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
describe "Open ports" do
  it "only have SSH, HTTP, and HTTPS listening to the world" do
    # Define our allowed ports
    # rubocop:disable Style/MutableConstant
    ALLOWED_PORTS = [22, 80, 443]
    # rubocop:enable Style/MutableConstant

    # Pluck the listening ports (IPv4/IPv6 on TCP/UDP)
    # https://github.com/mizzy/serverspec/blob/v2.24.3/lib/serverspec/type/port.rb#L33
    # https://github.com/mizzy/specinfra/blob/v2.44.7/lib/specinfra/command/base/port.rb#L3-L8
    # DEV: We use `[0-9]` over `\d` since `grep` doesn't know about `\d` =(
    open_ports_result = command("netstat -tunl | grep -E -- \"(0\\.0\\.0\\.0|::):[0-9]+ \"")
    expect(open_ports_result.exit_status).to(eq(0))
    open_ports = open_ports_result.stdout.split("\n")

    # If we are in Vagrant or Travis CI
    # DEV: This is running on the host OS which is why `which vagrant` works
    if `which vagrant` != "" || ENV["TRAVIS"] == "true"
      # Use `sudo` to get additional info (e.g. pid/program)
      # tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      617/rpcbind
      # tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      1016/nginx
      open_ports_result = command("sudo netstat -tunlp | grep -E -- \"(0\\.0\\.0\\.0|::):[0-9]+ \"")
      expect(open_ports_result.exit_status).to(eq(0))
      open_ports = open_ports_result.stdout.split("\n")

      # Filter out trusted programs
      if `which vagrant` != ""
        open_ports.select! { |open_port| ! %r{/(rpcbind|rpc.statd|dhclient)\s*$}.match(open_port) }
      elsif ENV["TRAVIS"] == "true"
        open_ports.select! { |open_port| ! %r{/(dnsmasq|dhclient|ntpd)\s*$}.match(open_port) }
      end
    end

    # Verify we only have our allowed ports
    open_ports.each do |open_port|
      # tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN
      # into:
      # 80 (int)
      port_num = /(0\.0\.0\.0|::):([0-9]+)/.match(open_port)[2].to_i
      expect(ALLOWED_PORTS).to(include(port_num),
        "Did not expect \"#{port_num}\" to be listening to everything\n  \"#{open_port}\"")
    end
  end
end

describe "Login shells" do
  # DEV: This prevents SSH access for any other user
  #   We can still access other users via `sudo -u <user> bash`
  it "only `ubuntu` has a login shell" do
    # Define our constants
    # rubocop:disable Style/MutableConstant
    ALLOWED_USERS = ["ubuntu"]
    EMPTY_SHELLS = ["/usr/sbin/nologin", "/bin/false", nil]
    # rubocop:enable Style/MutableConstant

    # If we are on Vagrant, allow a Vagrant user to use ssh
    if `which vagrant` != ""
      ALLOWED_USERS.push("vagrant")
    # Otherise, if we are on Travis CI, allow "maria", "me", "solarce", and "travis" users
    elsif ENV["TRAVIS"] == "true"
      ALLOWED_USERS.push("maria", "me", "solarce", "travis")
    end

    # Collect the passwd entries for our users
    # Example output:
    #   daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
    #   ubuntu:x:1001:1001:Ubuntu:/home/ubuntu:/bin/bash
    # https://github.com/mizzy/specinfra/blob/v2.44.7/lib/specinfra/command/base/user.rb#L53-L55
    passwd_entries_result = command("getent passwd")
    expect(passwd_entries_result.exit_status).to(eq(0))
    passwd_entries = passwd_entries_result.stdout.split("\n")

    # For each of our entries
    passwd_entries.each do |passwd_entry|
      # Break up our entry by its colons
      passwd_entry_parts = passwd_entry.split(":")
      user = passwd_entry_parts[0]
      shell = passwd_entry_parts[6]

      # If our user is allowed, skip them
      if ALLOWED_USERS.include?(user)
        next
      end

      # Verify the user has a bad shell
      expect(EMPTY_SHELLS).to(include(shell), "Expected user \"#{user}\" to have bad shell but it was \"#{shell}\"")
    end
  end
end

# https://lobste.rs/s/mzodhj/openssh_client_bug_can_leak_keys_to_malicious_servers
# http://undeadly.org/cgi?action=article&sid=20160114142733
describe "ssh" do
  it "is a version patched for malicious UseRoaming" do
    expect(package("openssh-server").version).to(eq("1:6.6p1-2ubuntu2.6"))
  end
end
