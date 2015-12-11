# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
describe "bash" do
  it "is installed via apt" do
    expect(package("bash")).to(be_installed())
  end

  it "has our expected version" do
    expect(command("bash --version").stdout).to(include("version 4.3.11(1)-release"))
  end
end
