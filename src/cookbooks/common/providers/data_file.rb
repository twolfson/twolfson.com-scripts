# Define an extension over `File` that auto-uses `data_dir` as `content`
# http://stackoverflow.com/a/20732016
class Chef
  class Provider::DataFile < Provider::File
  end
end
