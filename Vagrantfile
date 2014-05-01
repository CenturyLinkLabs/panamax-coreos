# -*- mode: ruby -*-
# # vi: set ft=ruby :

Vagrant.configure("2") do |config|
  Vagrant.require_version ">= 1.5.0"
  config.vm.box = ENV['BASEBOX'] || "coreos-alpha"
  config.vm.box_url = "http://storage.core-os.net/coreos/amd64-usr/alpha/coreos_production_vagrant.box"

  config.vm.network "forwarded_port", guest: 3000, host: Integer(ENV['PANAMAX_PORT_UI']||8898)
  config.vm.network "forwarded_port", guest: 3001, host: Integer(ENV['PANAMAX_PORT_API']||8900)
  # Fix docker not being able to resolve private registry in VirtualBox
  config.vm.provider :virtualbox do |vb, override|
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  # plugin conflict
  if Vagrant.has_plugin?("vagrant-vbguest") then
    config.vbguest.auto_update = false
  end
  config.vm.synced_folder ".", "/var/panamax", type: "rsync"
  config.vm.provision "shell", inline: "sudo chmod +x /var/panamax/coreos"
  config.vm.provision "shell", inline: "cd /var/panamax && ./coreos install"
 
 config.vm.synced_folder ".", "/vagrant", disabled: true
 config.ssh.username = "core"
end
