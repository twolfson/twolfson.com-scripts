# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
describe "OpenSSH" do
  it "is installed via apt" do
    expect(package("openssh-server")).to(be_installed())
  end

  it "is serving SSH to everyone" do
    # Check IPv4 and IPv6
    ssh_port = port(22)
    expect(ssh_port).to(be_listening().on("0.0.0.0"))
    expect(ssh_port).to(be_listening().on("::"))
  end

  it "has proper permissions for configuration" do
    sshd_config_file = file("/etc/ssh/sshd_config")
    expect(sshd_config_file.mode).to(eq((USER_RW | GROUP_R | OTHER_R).to_s(8)))
    expect(sshd_config_file.owner).to(eq(ROOT_USER))
    expect(sshd_config_file.group).to(eq(ROOT_GROUP))
  end

  it "has expected permissions setup" do
    # Verify root is locked out
    sshd_config_file = file("/etc/ssh/sshd_config")
    expect(sshd_config_file.content).to(include("PermitRootLogin no"))

    # Verify we only allow RSA/Pubkey authentication and disallow password auth
    expect(sshd_config_file.content).to(include("RSAAuthentication yes"))
    expect(sshd_config_file.content).to(include("PubkeyAuthentication yes"))
    expect(sshd_config_file.content).to(include("PermitEmptyPasswords no"))
    expect(sshd_config_file.content).to(include("PasswordAuthentication no"))
  end

  it "has expected persmission for root user's SSH directory" do
    root_ssh_dir = file("/root/.ssh")
    expect(root_ssh_dir.mode).to(eq((USER_RWX | GROUP_NONE | OTHER_NONE).to_s(8)))
    expect(root_ssh_dir.owner).to(eq(ROOT_USER))
    expect(root_ssh_dir.group).to(eq(ROOT_GROUP))
  end

  it "has no authorized keys for root user" do
    root_authorized_keys_file = file("/root/.ssh/authorized_keys")
    expect(root_authorized_keys_file.mode).to(eq((USER_RW | GROUP_NONE | OTHER_NONE).to_s(8)))
    expect(root_authorized_keys_file.owner).to(eq(ROOT_USER))
    expect(root_authorized_keys_file.group).to(eq(ROOT_GROUP))
    expect(root_authorized_keys_file.content).to(eq(""))
  end

  it "has expected persmission for ubuntu user's SSH directory" do
    ubuntu_ssh_dir = file("/home/ubuntu/.ssh")
    expect(ubuntu_ssh_dir.mode).to(eq((USER_RWX | GROUP_NONE | OTHER_NONE).to_s(8)))
    expect(ubuntu_ssh_dir.owner).to(eq(UBUNTU_USER))
    expect(ubuntu_ssh_dir.group).to(eq(UBUNTU_GROUP))
  end

  it "has authorized keys for ubuntu user" do
    ubuntu_authorized_keys_file = file("/home/ubuntu/.ssh/authorized_keys")
    expect(ubuntu_authorized_keys_file.mode).to(eq((USER_RW | GROUP_NONE | OTHER_NONE).to_s(8)))
    expect(ubuntu_authorized_keys_file.owner).to(eq(UBUNTU_USER))
    expect(ubuntu_authorized_keys_file.group).to(eq(UBUNTU_GROUP))
    expect(ubuntu_authorized_keys_file.content).not_to(eq(""))
  end
end
