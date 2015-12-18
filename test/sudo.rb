# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
describe "sudo" do
  it "has expected permissions for ubuntu's sudoer file" do
    sudoers_ubuntu_file = file("/etc/sudoers.d/ubuntu")
    expect(sudoers_ubuntu_file.mode).to(eq((USER_R | GROUP_NONE | OTHER_NONE).to_s(8)))
    expect(sudoers_ubuntu_file.owner).to(eq(ROOT_USER))
    expect(sudoers_ubuntu_file.group).to(eq(ROOT_GROUP))
  end
end
