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
end
