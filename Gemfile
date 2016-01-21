# Specify our source for gems
source "https://rubygems.org"

# Install dev dependencies
group :development do
  gem("rubocop", "~>0.36.0")
  gem("serverspec", "~>2.29.0")
  # Lock down `net-ssh` for `serverspec`/`specinfra` for Ruby < 2.0.0
  #   https://github.com/mizzy/specinfra/pull/510
  if Gem::Version.new(RUBY_VERSION.dup) < Gem::Version.new("2.0.0")
    gem("net-ssh", "~> 2.9.2")
  end
end
