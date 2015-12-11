# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
describe "Our open ports" do
  it "only have SSH, HTTP, and HTTPS listening to the world" do
    # Define our allowed ports
    ALLOWED_PORTS = [22, 80, 443]

    # Pluck the listening ports (IPv4/IPv6 on TCP/UDP)
    # https://github.com/mizzy/serverspec/blob/v2.24.3/lib/serverspec/type/port.rb#L33
    # https://github.com/mizzy/specinfra/blob/v2.44.7/lib/specinfra/command/base/port.rb#L3-L8
    # DEV: We use `[0-9]` over `\d` since `grep` doesn't know about `\d` =(
    open_ports = command("netstat -tunl | grep -E -- \"(0\\.0\\.0\\.0|::):[0-9]+ \"").stdout.split("\n")

    # If we are in Vagrant
    # DEV: This is running on the host OS
    if `which vagrant` != ""
      # Use `sudo` to get additional info (e.g. pid/program)
      # tcp        0      0 0.0.0.0:111             0.0.0.0:*               LISTEN      617/rpcbind
      # tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      1016/nginx
      open_ports = command("sudo netstat -tunlp | grep -E -- \"(0\\.0\\.0\\.0|::):[0-9]+ \"").stdout.split("\n")

      # Filter out trusted programs
      open_ports.select! { |open_port| ! %r{/(rpcbind|rpc.statd|dhclient)\s*$}.match(open_port) }
    end

    # Verify we only have our allowed ports
    open_ports.each do |open_port|
      # tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN
      # into:
      # 80 (int)
      port_num = %r{(0\.0\.0\.0|::):([0-9]+) }.match(open_port)[2].to_i
      expect(ALLOWED_PORTS).to(include(port_num))
    end
  end
end
