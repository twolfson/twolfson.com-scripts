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
    crt_file = file("/etc/ssl/certs/twolfson.com.crt")
    expect(crt_file.mode).to(eq((USER_RWX | GROUP_RWX | OTHER_RWX).to_s(8)))
    expect(crt_file.owner).to(eq(ROOT_USER))
    expect(crt_file.group).to(eq(ROOT_GROUP))

    key_file = file("/etc/ssl/private/twolfson.com.key")
    expect(key_file.mode).to(eq((USER_R | GROUP_NONE | OTHER_NONE).to_s(8)))
    expect(key_file.owner).to(eq(ROOT_USER))
    expect(key_file.group).to(eq(ROOT_GROUP))
  end

  it "isn't hosting default site configuration" do
    expect(command("ls /etc/nginx/sites-available").exit_status).not_to(eq(0))
    expect(command("ls /etc/nginx/sites-enabled").exit_status).not_to(eq(0))
    # TODO: Verify proper permissions for `sites-enabled` and `sites-available` (or their lack of existence)
  end

  it "has proper permissions for configurations" do
    # TODO: Verify proper permissions for `twolfson.com.conf`
  end

  it "has only expected configurations" do
    # TODO: Verify only `/etc/nginx/conf.d/twolfson.com.conf` exists
  end
end
