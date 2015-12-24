# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
describe "System" do
  it "has UTC timezone set" do
    timezone_result = command("date +\"%z\"")
    expect(timezone_result.exit_status).to(eq(0))
    expect(timezone_result.stdout).to(eq("+0000" + "\n"))
  end
end
