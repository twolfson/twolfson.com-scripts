# If `apt-get update` has never run nor ran in the past 24 hours, then update it now
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
