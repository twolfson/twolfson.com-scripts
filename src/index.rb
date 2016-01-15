# Load in our dependencies
# https://github.com/chef/chef/blob/12.6.0/bin/chef-apply#L21-L25
require "rubygems"
require "chef/application/apply"

# TODO: Consider writing standalone `common` and `twolfson.com` files that are run via `chef-apply` individually
# TODO: Also, verify that `chef-apply` can handle multiple actions as that might be the root cause
# TODO: Another option (now that we are finally accepting it)
#   is to create nested folders but `ln -s` them to `src's` root dir

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
  # recipe.instance_eval(recipe_text, recipe_filename, 2)

  # Add more recipes
  # https://github.com/chef/chef/blob/12.6.0/lib/chef/run_context.rb#L346-L355
  recipe_filename2 = "src/apt2.rb"
  run_context.load_recipe_file(recipe_filename2)

  # Run our actions
  runner = Chef::Runner.new(run_context)
  begin
    runner.converge()
  ensure
    recipe_fh.close()
  end
  Chef::Platform::Rebooter.reboot_if_needed!(runner)
  Chef::Application.exit!("Exiting", 0)
rescue SystemExit => e
  raise
rescue => e
  Chef::Application.debug_stacktrace(e)
  Chef::Application.fatal!("#{e.class}: #{e.message}", 1)
end

