# frozen_string_literal: true

# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
describe "bash" do
  it "is installed via apt" do
    expect(package("bash")).to(be_installed())
  end

  it "has our expected version" do
    expect(command("bash --version").stdout).to(include("version 5.1.16(1)-release"))
  end
end
