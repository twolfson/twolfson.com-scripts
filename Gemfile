# Specify our source for gems
source "https://rubygems.org"

# Install dev dependencies
group :development do
  # TODO: Remove git ref once PR is landed
  # Added `.mode`, `.owner`, and `.group` attributes to file
  #   https://github.com/mizzy/serverspec/pull/544
  # Added `.link_target` attribute to file
  #   https://github.com/mizzy/serverspec/pull/547
  gem "serverspec", "~>2.24.3", :git => "https://github.com/twolfson/serverspec.git", :ref => "11a834c"
  # Lock down `net-ssh` for `serverspec`/`specinfra` for Ruby < 2.0.0
  #   https://github.com/mizzy/specinfra/pull/510
  if Gem::Version.new(RUBY_VERSION.dup) < Gem::Version.new('2.0.0')
    gem "net-ssh", "~> 2.9.2"
  end
end
