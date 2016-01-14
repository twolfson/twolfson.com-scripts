# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
describe "apt" do
  it "was updated within past 24 hours" do
    one_day_ago = Time.now() - 60 * 60 * 24
    last_update_timestamp = File.mtime("/var/lib/apt/periodic/update-success-stamp")
    expect(last_update_timestamp).to(be < one_day_ago)
    expect(package("bash")).to(be_installed())
  end
end
