# Load in common dependencies
require_relative "../../common/recipes/default.rb"

# Run our provisioner
file "/home/vagrant/hello.txt" do
  content "hi"
end
