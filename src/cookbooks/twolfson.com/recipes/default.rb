# Load in common dependencies
include_recipe "common"

# Run our provisioner
file "/home/vagrant/hello.txt" do
  content "hi"
end
