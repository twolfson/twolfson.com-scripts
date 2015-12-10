# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
# TODO: Is there a better, less space dependent syntax for these matchers?
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
end
