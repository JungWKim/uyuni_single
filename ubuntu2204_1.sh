#!/bin/bash

USER=
IP=

cd ~

# prevent auto upgrade
sudo sed -i 's/1/0/g' /etc/apt/apt.conf.d/20auto-upgrades

# change hostname to 'mgmt01'. If you want to keep your hostname, comment the below command and change all the "mgmt01" to current hostname in '~/deepops/config/inventory'
sudo hostnamectl set-hostname mgmt01

# install basic packages
sudo apt install -y net-tools nfs-common whois

# let deepops automation access the user account without authentication
sudo touch /etc/sudoers.d/${USER}_nopass
echo "${USER}   ALL=(ALL)   NOPASSWD: ALL" | sudo tee -a /etc/sudoers.d/${USER}_nopass
sudo chmod 440 /etc/sudoers.d/${USER}_nopass
sudo apt update
ssh-keygen
ssh-copy-id -i ~/.ssh/id_rsa.pub ${USER}@${IP}

# install deepops. Reboot will be executed automatically. Then run ubuntu2204_2.sh.
git clone https://github.com/NVIDIA/deepops.git
cd deepops
bash ./scripts/setup.sh
source /opt/deepops/env/bin/activate
sed -i "s/#mgmt01     ansible_host=10.0.0.1/mgmt01      ansible_host=${IP}/g" ~/deepops/config/inventory
sed -i "s/#mgmt01/mgmt01/g" ~/deepops/config/inventory
sed -i -r -e "/\[kube-node\]/a\\mgmt01" ~/deepops/config/inventory
ansible-playbook -l k8s-cluster playbooks/k8s-cluster.yml
cd ~
