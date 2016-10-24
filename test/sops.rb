# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
describe "SOPS" do
  it "is installed" do
    sops_version_result = command("sops --version")
    expect(sops_version_result.exit_status).to(eq(0))
    expect(sops_version_result.stderr.strip()).to(eq("sops 1.14"))
  end
end
