# -*- mode: ruby -*-
# # vi: set ft=ruby :
imagesDisk = "#{ENV['PMX_VAR_DIR']}/images.vdi" || 'images.vdi'

Vagrant.configure("2") do |config|
    Vagrant.require_version ">= 1.6.0"
    config.vm.box = ENV['PMX_BASEBOX'] || "panamax-coreos-box-522.6.0"
    config.vm.box_url = ENV['PMX_BASEBOX_URL'] || "http://storage.core-os.net/coreos/amd64-usr/522.6.0/coreos_production_vagrant.box"
    config.vm.hostname = ENV['PMX_VM_NAME'] || "panamax-vm"

    config.vm.network "private_network", ip: ENV['PMX_VM_PRIVATE_IP'] || "10.0.0.200"

    config.vm.provider :virtualbox do |vb, override|
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        vb.name = ENV['PMX_VM_NAME'] || "panamax-vm"
        vb.customize ["modifyvm", :id, "--memory", Integer(ENV['PMX_VM_MEMORY']||1536)]
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
      config.vm.provision "shell", inline: "cd /var/panamax && ./create-docker-mount", keep_color: "true"
    end

    config.vm.provision "shell", inline: "sudo mv /var/panamax/user-data /var/lib/coreos-vagrant/vagrantfile-user-data"
    config.vm.provision "shell", inline: "sudo chmod +x /var/panamax/coreos", keep_color: "true"
    config.vm.provision "shell", inline: "cd /var/panamax && ./coreos $1 --$2 -pid=\"$3\"", args: "#{ENV['PMX_OPERATION'] || 'install'} #{ENV['PMX_IMAGE_TAG'] || 'stable'} #{ENV['PMX_PANAMAX_ID'] || 'not-set'}", keep_color: "true"
    config.vm.synced_folder ".", "/vagrant", disabled: true
    config.ssh.username = "core"
    # always use Vagrants insecure key
    config.ssh.insert_key = false
end
