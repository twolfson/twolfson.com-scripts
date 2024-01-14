# DEV: Equivalent to `sudo /etc/init.d/nginx *`
service "nginx" do
  provider Chef::Provider::Service::Init
  supports(:reload => true, :restart => true, :status => true)
  action([:start])
end
# If there are default NGINX configuration files, then remove them
# DEV: Equivalent to `test "$(ls /etc/nginx/sites-enabled)" != ""` -> `rm /etc/nginx/sites-enabled/*`
file "/etc/nginx/sites-enabled/default" do
  action(:delete)

  # Upon deletion, reload NGINX
  notifies(:reload, "service[nginx]", :immediately)
end

# Create folder for log files
directory "/var/log/supervisor" do
  owner("root")
  group("root")
  mode("755") # u=rwx,g=rx,o=rx
end
# Set up our supervisor configuration
# TODO: Use a template for `supervisord.conf`
#   and don't run any `twolfson.com` services by default (e.g. use `if twolfson.com` for conf blocks)
data_file "/etc/supervisord.conf" do
  owner("root")
  group("root")
  mode("644") # u=rw,g=r,o=r
end
# Install our `init` script
# http://supervisord.org/running.html#running-supervisord-automatically-on-startup
# http://serverfault.com/a/96500
data_file "/etc/init.d/supervisord" do
  owner("root")
  group("root")
  mode("755") # u=rwx,g=rx,o=rx
end
service "supervisord" do
  provider(Chef::Provider::Service::Init)
  supports(:reload => false, :restart => true, :status => true)
  action([:start])
end
execute "autostart-supervisord" do
  command("sudo update-rc.d supervisord defaults")
  only_if("! ls /etc/rc0.d/K20supervisord")
end
execute "update-supervisorctl" do
  # DEV: We need to access socket as root user
  # DEV: This command might fail if we change anything with `supervisor.d's` config
  #   Be sure to use `/etc/init.d/supervisord restart` in that case
  command("sudo supervisorctl update")
  action(:nothing)

  # When our configuration changes, update ourself
  # DEV: We must wait until `/etc/init.d/supervisord` has launched
  subscribes(:run, "data_file[/etc/supervisord.conf]", :delayed)
end
