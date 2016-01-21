# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
describe "`ubuntu` user" do
  it "exists" do
    expect(user("ubuntu")).to(exist())
  end

  it "has sudo access" do
    # Verify group access
    ubuntu_user = user("ubuntu")
    expect(ubuntu_user).to(belong_to_group("sudo"))

    # Verify sudoer permissions
    ubuntu_sudoers_file = file("/etc/sudoers.d/ubuntu")
    expect(ubuntu_sudoers_file.mode).to(eq((USER_R | GROUP_NONE | OTHER_NONE).to_s(8)))
    expect(ubuntu_sudoers_file.owner).to(eq(ROOT_USER))
    expect(ubuntu_sudoers_file.group).to(eq(ROOT_GROUP))
    expect(ubuntu_sudoers_file.content).to(include("ubuntu ALL=(ALL) NOPASSWD:ALL"))
  end

  it "has no password yet can log in via SSH" do
    # DEV: `!` and `*` are non-crypt passwords but only `*` allows SSH access
    ubuntu_user = user("ubuntu")
    expect(ubuntu_user.encrypted_password).to(eq("*"))
  end
end
