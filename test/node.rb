# frozen_string_literal: true

# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
describe "Node.js" do
  it "is installed via apt" do
    expect(package("nodejs")).to(be_installed())
  end

  it "has our expected version" do
    expect(command("node --version").stdout).to(eq("v6.14.4\n"))
  end
end
