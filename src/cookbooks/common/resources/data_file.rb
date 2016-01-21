# Load our constants
data_dir = ENV.fetch("data_dir")

# Define an extension over `File` that auto-uses `data_dir` as `content`
# http://stackoverflow.com/a/20732016
module Hello
  class DataFile
    resource_name :data_file
    include Resource::File
    def initialize(name, run_context=nil)
      # Run our parent constructor
      super(name, run_context)

      # If there is no content, then overwrite it
      puts name
      # if @content.nil?
      #   @content = nil
      # end
    end
  end
end
