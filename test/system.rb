# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
describe "System" do
  it "has UTC timezone set" do
    timezone_result = command("date +\"%z\"")
    expect(timezone_result.exit_status).to(eq(0))
    expect(timezone_result.stdout).to(eq("+0000" + "\n"))
  end

  it "has proper permissions set for timezone file" do
    timezone_file = file("/etc/timezone")
    expect(timezone_file.mode).to(eq((USER_RW | GROUP_R | OTHER_R).to_s(8)))
    expect(timezone_file.owner).to(eq(ROOT_USER))
    expect(timezone_file.group).to(eq(ROOT_GROUP))
  end
end
