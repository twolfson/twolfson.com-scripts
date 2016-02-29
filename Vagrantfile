# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # Set our box as Ubuntu@14.04 LTS
  # https://atlas.hashicorp.com/ubuntu/boxes/trusty64
  config.vm.box = "ubuntu/trusty64"

  # Give additional memory and CPU to VirtualBox provider
  # https://docs.vagrantup.com/v2/virtualbox/configuration.html
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 2048
    vb.cpus = 2
  end

  # Set up our different node types with a common provisioner
  # DEV: If we find using `vagrant ssh gifsockets.twolfson.com` to be tedious
  #   then we can set up environment variables which are managed on shells via scripts like Python's virtualenv
  #   `source bin/vagrant/gifsockets.twolfson.com.sh` (set a `NODE_TYPE` variable)
  #      In this file, we would look for `NODE_TYPE` and if not set then assume `twolfson.com`
  #      Otherwise, use `NODE_TYPE` for setting `primary`
  #   `deactivate` (remove `NODE_TYPE` override, defined by the source)
  config.vm.define("twolfson.com", :primary => true) do |subconfig|
    # TODO: When Vagrant@1.8 is on `apt`, then move back to `path` and `env`
    node_type = "twolfson.com"
    subconfig.vm.provision("shell", :inline => "cd /vagrant && NODE_TYPE=\"#{node_type}\" bin/bootstrap-vagrant.sh")
  end

  config.vm.define("gifsockets.twolfson.com", :autostart => false) do |subconfig|
    # TODO: When Vagrant@1.8 is on `apt`, then move back to `path` and `env`
    node_type = "gifsockets.twolfson.com"
    subconfig.vm.provision("shell", :inline => "cd /vagrant && NODE_TYPE=\"#{node_type}\" bin/bootstrap-vagrant.sh")
  end
end
