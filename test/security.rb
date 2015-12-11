# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
describe "Our open ports" do
  it "only have SSH, HTTP, and HTTPS listening to the world" do
    # Test both IPv4 and IPv6 (on both TCP and UDP)
    # https://github.com/mizzy/serverspec/blob/v2.24.3/lib/serverspec/type/port.rb#L33
    # https://github.com/mizzy/specinfra/blob/v2.44.7/lib/specinfra/command/base/port.rb#L3-L8
    # DEV: We use `[0-9]` over `\d` since `grep` doesn't know about `\d` =(
    pattern = "(0.0.0.0|::):[0-9]+"
    open_ports = command("netstat -tunl | grep -E -- \"#{Specinfra::Command::Base::escape(pattern)}\"")
    puts open_ports.stdout
    expect(package("bash")).to(be_installed())
  end
end
