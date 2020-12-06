#!/bin/bash

# go to lab_env/test

vagrant up --provider=libvirt
vagrant ssh

# then

sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo 
sudo yum -y install libvirt-daemon-kvm libvirt-client vagrant gcc-c++ make libstdc++-devel libvirt-devel rsync
echo 'user = "root"' | sudo tee -a /etc/libvirt/qemu.conf

sudo systemctl enable  libvirtd
sudo systemctl restart  libvirtd
sudo usermod -a -G libvirt $( id -un )
vagrant plugin install vagrant-libvirt vagrant-sshfs vagrant-hostmanager vagrant-registration

# check

cd /vagrant/nested

unset SSH_AUTH_SOCK
echo unset SSH_AUTH_SOCK >>~/.bashrc

vagrant up
