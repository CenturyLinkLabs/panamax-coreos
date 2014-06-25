# -*- mode: ruby -*-
# # vi: set ft=ruby :
imagesDisk = 'images.vdi'

Vagrant.configure("2") do |config|
    Vagrant.require_version ">= 1.6.0"
    config.vm.box = ENV['BASEBOX'] || "panamax-coreos-box"
    config.vm.box_url = ENV['BASEBOX_URL'] || "http://storage.core-os.net/coreos/amd64-usr/310.1.0/coreos_production_vagrant.box"
    config.vm.hostname = ENV['PMX_VM_NAME'] || "panamax-vm"

    config.vm.network "forwarded_port", guest: 3000, host: Integer(ENV['PANAMAX_PORT_UI']||8888)
    config.vm.network "forwarded_port", guest: 3001, host: Integer(ENV['PANAMAX_PORT_API']||8889)
    config.vm.network "forwarded_port", guest: 8080, host: 8668
    config.vm.network "forwarded_port", guest: 8088, host: 8669
    # Fix docker not being able to resolve private registry in VirtualBox
    config.vm.provider :virtualbox do |vb, override|
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        vb.name = ENV['PMX_VM_NAME'] || "panamax-vm"
        vb.customize ["modifyvm", :id, "--memory", Integer(ENV['PMX_VM_MEMORY']||2048)]
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
        vb.customize ["modifyvm", :id, "--cpus", Integer(ENV['PMX_VM_CPUS']||2)]
        vb.customize ['storageattach', :id, '--storagectl', 'IDE Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', imagesDisk]
    end
    config.vm.define :ENV['PMX_VM_NAME'] || "panamax-vm"

    # plugin conflict
    if Vagrant.has_plugin?("vagrant-vbguest") then
        config.vbguest.auto_update = false
    end
    config.vm.synced_folder ".", "/var/panamax", type: "rsync", rsync__exclude: "images*"
    #Docker Mount
    if ARGV[0] == "up" then
        config.vm.provision "shell", inline: "cd /var/panamax && ./create-docker-mount"
    end
    config.vm.provision "shell", inline: "sudo chmod +x /var/panamax/coreos"
    config.vm.provision "shell", inline: "cd /var/panamax && ./coreos $1 --$2 -pid=\"$3\"", args: "#{ENV['OPERATION'] || 'install'} #{ENV['IMAGE_TAG'] || 'stable'} #{ENV['PANAMAX_ID'] || 'not-set'} "
    config.vm.synced_folder ".", "/vagrant", disabled: true
    config.ssh.username = "core"
end
