# Specify our source for gems
source "https://rubygems.org"

# Install dev dependencies
group :development do
  # TODO: Remove git ref once PR is landed
  # https://github.com/mizzy/serverspec/pull/544
  gem "serverspec", "~>2.24.3", :git => "https://github.com/twolfson/serverspec.git", :ref => "1533623"
  # TODO: Remove git ref once PR is landed
  # https://github.com/mizzy/specinfra/pull/509
  gem "specinfra", "~>2.46.0", :git => "https://github.com/twolfson/specinfra.git", :ref => "cb1961f"
end
