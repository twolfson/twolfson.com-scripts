# Load in our dependencies
# https://github.com/chef/chef/blob/12.6.0/bin/chef-apply#L21-L25
require "rubygems"
require "chef/application/apply"

# Run our recipes
# DEV: We avoid the traditional Chef structure due to it
#   being overly complex and unnecessary for 1 node ecosystem
# https://github.com/chef/chef/blob/12.6.0/lib/chef/application/apply.rb#L202-L219
app_apply = Chef::Application::Apply.new()
app_apply.reconfigure()
begin
  app_apply.parse_options()
  # https://github.com/chef/chef/blob/12.6.0/lib/chef/application/apply.rb#L188-L199
  # Add our first recipe
  recipe_filename = "src/apt.rb"
  recipe_text, recipe_fh = app_apply.read_recipe_file(recipe_filename)
  recipe, run_context = app_apply.get_recipe_and_run_context()
  # recipe.instance_eval(recipe_text, recipe_filename, 1)

  # Add more recipes
  recipe_filename2 = "src/apt2.rb"
  recipe2 = Chef::Recipe.new("(chef-apply cookbook2)", "(chef-apply recipe2)", run_context)
  recipe_text2, recipe_fh2 = app_apply.read_recipe_file(recipe_filename2)
  recipe2.instance_eval(recipe_text2, recipe_filename2, 2)

  # Run our actions
  runner = Chef::Runner.new(run_context)
  begin
    runner.converge()
  ensure
    recipe_fh.close()
    recipe_fh2.close()
  end
  Chef::Platform::Rebooter.reboot_if_needed!(runner)
  Chef::Application.exit!("Exiting", 0)
rescue SystemExit => e
  raise
rescue => e
  Chef::Application.debug_stacktrace(e)
  Chef::Application.fatal!("#{e.class}: #{e.message}", 1)
end

