# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
# DEV: We are avoiding the Serverspec variation of documentation because:
#   - Spaces and subjects felt too magical; it's at the cost of developers understanding what's going on
#   - By not using subjects, we catch edge cases like IPv6 support
describe "NGINX" do
  it "is installed via apt" do
    expect(package("nginx")).to(be_installed())
  end

  it "is serving HTTP to everyone" do
    # Check IPv4 and IPv6
    http_port = port(80)
    expect(http_port).to(be_listening().on("0.0.0.0"))
    expect(http_port).to(be_listening().on("::"))
  end

  it "is serving HTTPS to everyone" do
    # Check IPv4 and IPv6
    https_port = port(443)
    expect(https_port).to(be_listening().on("0.0.0.0"))
    expect(https_port).to(be_listening().on("::"))
  end

  it "has proper permissions for SSL certs" do
    # TODO: Verify proper setup for SSL /etc/ssl/certs and /etc/ssl/private
    # TODO: Verify proper permissions for `sites-enabled` and `sites-available` (or their lack of existence)
    # TODO: Verify proper permissions for `twolfson.com.conf`
    # TODO: Verify only `/etc/nginx/conf.d/twolfson.com.conf` exists
  end
end
