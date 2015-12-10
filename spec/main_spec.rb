# Load in our dependencies
require "spec_helper"

# Start our tests
# TODO: Is there a better, less space dependent syntax for these matchers?
describe package("nginx") do
  it { should(be_installed()) }
end

describe port(80) do
  it { should(be_listening()) }
end
