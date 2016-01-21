# Define an extension over `File` that auto-uses `data_dir` as `content`
# http://stackoverflow.com/a/20732016
# DEV: Not sure why but provisioning breaks if we don't use `Provider::DataFile` syntax
# rubocop:disable Style/ClassAndModuleChildren
class Chef
  class Provider::DataFile < Provider::File
    provides(:data_file)
  end
end
# rubocop:enable Style/ClassAndModuleChildren

# rubocop:disable Style/ClassAndModuleChildren
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
# rubocop:enable Style/ClassAndModuleChildren
