# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
describe "SOPS" do
  it "is installed" do
    supervisor_version_result = command("sops --help")
    expect(supervisor_version_result.exit_status).to(eq(0))
    expect(supervisor_version_result.stdout.strip()).to(include("Version 1.3"))
  end
end
