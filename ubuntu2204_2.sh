#!/bin/bash

USER=
USER_HOME=/home/${USER}
IP=

ansible-playbook -l k8s-cluster playbooks/k8s-cluster.yml

# enable kubectl command autocompletion
echo "source <(kubectl completion bash)" | sudo tee -a ${USER_HOME}/.bashrc
echo "source <(kubeadm completion bash)" | sudo tee -a ${USER_HOME}/.bashrc

echo "source <(kubectl completion bash)" | sudo tee -a /root/.bashrc
echo "source <(kubeadm completion bash)" | sudo tee -a /root/.bashrc
