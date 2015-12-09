# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # Set our box as Ubuntu@14.04 LTS
  # https://atlas.hashicorp.com/ubuntu/boxes/trusty64
  config.vm.box = "ubuntu/trusty64"

  # Forward HTTP and HTTPS ports
  config.vm.network "forwarded_port", guest: 80, host: 80
  config.vm.network "forwarded_port", guest: 443, host: 443

  # Give additional memory and CPU to VirtualBox provider
  # https://docs.vagrantup.com/v2/virtualbox/configuration.html
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 2048
    vb.cpus = 2
  end

  # Provision our box with a script
  # TODO: Find syntax for path and start writing our bootstrap script
  config.vm.provision "shell", inline <<-EOF
    echo "Hello World"
  EOF
end
