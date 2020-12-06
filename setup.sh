#!/bin/bash

sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo 
sudo yum -y install libvirt-daemon-kvm libvirt-client vagrant gcc-c++ make libstdc++-devel libvirt-devel rsync
sudo bash -c 'echo "user = \"root\"" >> /etc/libvirt/qemu.conf'
sudo systemctl enable --now libvirtd
sudo usermod -a -G libvirt $( id -un )
vagrant plugin install vagrant-libvirt vagrant-sshfs vagrant-hostmanager
mkdir ~/lab-env ; cd ~/lab-env

cat > Vagrantfile << EOF

# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "generic/rhel8"

  config.ssh.forward_x11 = true
  config.ssh.forward_agent = true

  #  config.vm.synced_folder ".", "/vagrant", type: "nfs"
  config.vm.synced_folder ".", "/vagrant", type: "sshfs"

  # vagrant-hostmanager: Configure /etc/hosts in machines so that they can look up each other
  config.hostmanager.enabled = true
  config.hostmanager.manage_guest = true

  config.vm.provider :libvirt do |libvirt|
    # Avoid "Call to virDomainCreateWithFlags failed: unsupported configuration: host doesn't support invariant TSC" error when using snapshots
    libvirt.cpu_mode = 'host-passthrough'

    ('b'..'e').map do |i|
      libvirt.storage :file, :device => "vd#{i}", :size => '20G', :type => 'qcow2', :cache => 'writeback'
    end

  end

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.cpus = 4
    vb.memory = "4096"
  end

  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end

  if Vagrant.has_plugin?('vagrant-registration')
    config.registration.manager = 'subscription_manager'
    config.registration.unregister_on_halt = false
  end

  config.vm.provision "shell", name: "link-vagrant", path: "lib/exec/link-vagrant"
  config.vm.provision "shell", name: "link-vagrant", path: "lib/exec/enable-ssh-password"

end

EOF

vagrant up --provider=libvirt
vagrant ssh
