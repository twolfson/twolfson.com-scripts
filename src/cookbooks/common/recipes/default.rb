# Define our constants
data_dir = ENV.fetch("data_dir")

# Guarantee `apt-get update` has been run in past 24 hours
# http://stackoverflow.com/a/9250482
# DEV: Relies on apt hook
execute "apt-get-update-periodic" do
  command("sudo apt-get update")
  only_if do
    # If we have have ran `apt-get update` before
    if File.exists?("/var/lib/apt/periodic/update-success-stamp")
      # Return if we ran it in the past 24 hours
      one_day_ago = Time.now().utc() - (60 * 60 * 24)
      next File.mtime("/var/lib/apt/periodic/update-success-stamp") < one_day_ago
    # Otherwise, tell it to run
    else
      next true
    end
  end
end

# Guarantee timezone is as we expect it
# https://www.digitalocean.com/community/questions/how-to-change-the-timezone-on-ubuntu-14
# http://serverfault.com/a/84528
execute "dpkg-reconfigure-tzdata" do
  command("sudo dpkg-reconfigure --frontend noninteractive tzdata")
  action(:nothing)
end
file "/etc/timezone" do
  content(File.new("#{data_dir}/etc/timezone").read())
  group("root")
  owner("root")
  mode("644") # u=rw,g=r,o=r

  # When we update, re-run our dpkg-reconfigure
  notifies(:run, "execute[dpkg-reconfigure-tzdata]", :immediately)
end
