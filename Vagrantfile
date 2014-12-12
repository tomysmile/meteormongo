# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "meteor"

  def provisioning(config, shell_arguments)
    config.vm.provision "shell", path: "provision.sh", args: shell_arguments
  end

  config.vm.define "dev" do |dev|
    dev.vm.box = "ubuntu/trusty64"
    dev.vm.hostname = "meteordev"

    dev.vm.network "forwarded_port", host: 27018, guest: 27018, id: "mongodb", auto_correct: true

    provisioning(dev, ["development", "vagrant"])
  end

end
