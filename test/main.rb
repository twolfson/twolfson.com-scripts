# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
# TODO: Is there a better, less space dependent syntax for these matchers?
describe package("nginx") do
  it { should(be_installed()) }
end

describe port(80) do
  it { should(be_listening()) }
end
