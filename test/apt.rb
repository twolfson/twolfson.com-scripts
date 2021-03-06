# frozen_string_literal: true

# Load in our dependencies
require_relative "utils/serverspec"

# Start our tests
describe "apt" do
  it "was updated within past 24 hours" do
    # rubocop:disable Style/DateTime
    one_day_ago = DateTime.now() - 60 * 60 * 24
    timestamp_file = file("/var/lib/apt/periodic/update-success-stamp")
    expect(timestamp_file.mtime).to(be >= one_day_ago)
    # rubocop:enable Style/DateTime
  end
end
