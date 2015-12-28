# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
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

  it "has proper permissions for Diffie-Hellman group" do
    dhparam_file = file("/etc/ssl/private/dhparam.pem")
    expect(dhparam_file.mode).to(eq((USER_R | GROUP_NONE | OTHER_NONE).to_s(8)))
    expect(dhparam_file.owner).to(eq(ROOT_USER))
    expect(dhparam_file.group).to(eq(ROOT_GROUP))
  end

  it "has proper permissions for configurations" do
    # Verify only root can modify nginf.conf
    nginx_conf = file("/etc/nginx/nginx.conf")
    expect(nginx_conf.mode).to(eq((USER_RW | GROUP_R | OTHER_R).to_s(8)))
    expect(nginx_conf.owner).to(eq(ROOT_USER))
    expect(nginx_conf.group).to(eq(ROOT_GROUP))

    # Verify only root can write in conf directories
    conf_d_dir = file("/etc/nginx/conf.d")
    expect(conf_d_dir.mode).to(eq((USER_RWX | GROUP_RX | OTHER_RX).to_s(8)))
    expect(conf_d_dir.owner).to(eq(ROOT_USER))
    expect(conf_d_dir.group).to(eq(ROOT_GROUP))

    sites_available_dir = file("/etc/nginx/sites-available")
    expect(sites_available_dir.mode).to(eq((USER_RWX | GROUP_RX | OTHER_RX).to_s(8)))
    expect(sites_available_dir.owner).to(eq(ROOT_USER))
    expect(sites_available_dir.group).to(eq(ROOT_GROUP))

    # Verify permissions for our configurations
    twolfson_com_conf = file("/etc/nginx/conf.d/twolfson.com.conf")
    expect(twolfson_com_conf.mode).to(eq((USER_RW | GROUP_R | OTHER_R).to_s(8)))
    expect(twolfson_com_conf.owner).to(eq(ROOT_USER))
    expect(twolfson_com_conf.group).to(eq(ROOT_GROUP))
    drive_twolfson_com_conf = file("/etc/nginx/conf.d/drive.twolfson.com.conf")
    expect(drive_twolfson_com_conf.mode).to(eq((USER_RW | GROUP_R | OTHER_R).to_s(8)))
    expect(drive_twolfson_com_conf.owner).to(eq(ROOT_USER))
    expect(drive_twolfson_com_conf.group).to(eq(ROOT_GROUP))
    twolfsn_com_conf = file("/etc/nginx/conf.d/twolfsn.com.conf")
    expect(twolfsn_com_conf.mode).to(eq((USER_RW | GROUP_R | OTHER_R).to_s(8)))
    expect(twolfsn_com_conf.owner).to(eq(ROOT_USER))
    expect(twolfsn_com_conf.group).to(eq(ROOT_GROUP))
  end

  it "has only expected configurations" do
    expect(command("ls /etc/nginx/sites-enabled").stdout).to(eq(""))
    expect(command("ls /etc/nginx/conf.d").stdout).to(eq([
      "drive.twolfson.com.conf",
      "twolfsn.com.conf",
      "twolfson.com.conf",
    ].join("\n") + "\n"))
  end

  it "has a locked down folder for www static files" do
    www_dir = file("/var/www")
    expect(www_dir.mode).to(eq((USER_RWX | GROUP_RX | OTHER_RX).to_s(8)))
    expect(www_dir.owner).to(eq(ROOT_USER))
    expect(www_dir.group).to(eq(ROOT_GROUP))
  end

  it "has a folder for drive.twolfson.com" do
    drive_twolfson_com_dir = file("/var/www/drive.twolfson.com")
    expect(drive_twolfson_com_dir.mode).to(eq((USER_RWX | GROUP_RX | OTHER_RX).to_s(8)))
    expect(drive_twolfson_com_dir.owner).to(eq(UBUNTU_USER))
    expect(drive_twolfson_com_dir.group).to(eq(UBUNTU_GROUP))
  end
end
