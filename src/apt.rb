# Based on http://stackoverflow.com/a/9250482
execute "apt-get-update-periodic" do
  command("apt-get update")
  only_if do
    # If we have have ran `apt-get update` before
    if File.exists?('/var/lib/apt/periodic/update-success-stamp')
      # Return if we ran it in the past 24 hours
      one_day_ago = Time.now() - (60 * 60 * 24)
      return File.mtime('/var/lib/apt/periodic/update-success-stamp') < one_day_ago
    end
    return false
  end
end
