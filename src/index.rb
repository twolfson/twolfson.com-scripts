# Load in our dependencies
# https://github.com/chef/chef/blob/12.6.0/bin/chef-apply#L21-L25
require "rubygems"
require "chef/application/apply"

# Run our recipes
# DEV: We avoid the traditional Chef structure due to it
#   being overly complex and unnecessary for 1 node ecosystem
apply = Chef::Application::Apply.new()
# recipe_filename = "apt.rb"
# recipe_text, recipe_fh = read_recipe_file recipe_filename
# recipe,run_context = get_recipe_and_run_context()
# recipe.instance_eval(recipe_text, recipe_filename, 1)
# runner = Chef::Runner.new(run_context)
# begin
#   runner.converge
# ensure
#   recipe_fh.close
# end
# Chef::Platform::Rebooter.reboot_if_needed!(runner)
