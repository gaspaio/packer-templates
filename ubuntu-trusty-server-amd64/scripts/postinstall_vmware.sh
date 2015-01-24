#!/bin/sh
# postinstall.sh created from Mitchell's official lucid32/64 baseboxes

date > /etc/vagrant_box_build_time

# Apt-install various things necessary for Ruby, guest additions,
# etc., and remove optional things to trim down the machine.
apt-get -y update
apt-get -y upgrade
apt-get -y install linux-headers-$(uname -r) build-essential

# Install VMWare Fusion guest tools
cd ~
wget https://www.dropbox.com/sh/guhhu9gc5gz350m/AADEL_OworETj_CVOybiLVc-a/linux.iso
sudo mount -o loop ~/linux.iso /media/cdrom
sudo cp /media/cdrom/VMwareTools*.tar.gz ~/
tar xfz VMwareTools*.tar.gz
cd ~/vmware-tools-distrib
sudo ./vmware-install.pl -d
sudo umount /media/cdrom
cd ~
rm -rf vmware-tools-distrib
rm -f VMwareTools*.tar.gz
rm linux.iso

echo "answer AUTO_KMODS_ENABLED yes" | sudo tee -a /etc/vmware-tools/locations

apt-get clean

# Setup sudo to allow no-password sudo for "admin"
groupadd -r admin
usermod -a -G admin vagrant
cp /etc/sudoers /etc/sudoers.orig
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=NOPASSWD:ALL/g' /etc/sudoers

# Install NFS client
apt-get -y install nfs-common

# Install Python for Ansible provisionning
apt-get -y install python

# Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

# Remove items used for building, since they aren't needed anymore
#apt-get -y remove linux-headers-$(uname -r) build-essential
#apt-get -y autoremove

# Zero out the free space to save space in the final image:
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# Removing leftover leases and persistent rules
echo "cleaning up dhcp leases"
rm /var/lib/dhcp/*

echo "Adding a 2 sec delay to the interface up, to make the dhclient happy"
echo "pre-up sleep 2" >> /etc/network/interfaces
exit
