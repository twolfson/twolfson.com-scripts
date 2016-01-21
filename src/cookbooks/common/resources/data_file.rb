# Define an extension over `File` that auto-uses `data_dir` as `content`
# http://stackoverflow.com/a/20732016
class Chef
  class Provider::DataFile < Provider::File
  end
end

class Chef
  class Resource::DataFile < Resource::File
    def initialize(name, run_context=nil)
      # Run our parent constructor
      super(name, run_context)

      # Load our constants
      data_dir = ENV.fetch("data_dir")

      # Provide default content
      # Example: `data_dir = /vagrant`, `name = /etc/timezone` -> `/vagrant/etc/timezone`
      self.content(::File.new("#{data_dir}#{name}").read())
    end
  end
end
