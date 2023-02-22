#!/bin/bash

#--- install the rest of deepops process after reboot. This will install nfs-provisioner and gpu-operator
cd ~/deepops
ansible-playbook -l k8s-cluster playbooks/k8s-cluster.yml
sudo chmod go-r ~/.kube/config
cd ~

#--- enable kubectl command autocompletion
echo "source <(kubectl completion bash)" | sudo tee -a ~/.bashrc
echo "source <(kubeadm completion bash)" | sudo tee -a ~/.bashrc

echo "source <(kubectl completion bash)" | sudo tee -a /root/.bashrc
echo "source <(kubeadm completion bash)" | sudo tee -a /root/.bashrc

#--- install rook operator
git clone https://github.com/rook/rook.git
helm repo add rook-release https://charts.rook.io/release
helm search repo rook-ceph
kubectl create namespace rook-ceph
helm install --namespace rook-ceph rook-ceph rook-release/rook-ceph
sleep 20

#--- if you want to check if rook operator is installed completely, run the below commands.
# kubectl get all -n rook-ceph
# kubectl -n rook-ceph get pods -l "app=rook-ceph-operator"

#--- change important values of rook ceph cluster
sed -i "26s/false/true/g" ~/rook/deploy/charts/rook-ceph-cluster/values.yaml
sed -i "s/count: 3/count: 1/g" ~/rook/deploy/charts/rook-ceph-cluster/values.yaml
sed -i "s/count: 2/count: 1/g" ~/rook/deploy/charts/rook-ceph-cluster/values.yaml
sed -i "429s/3/2/g" ~/rook/deploy/charts/rook-ceph-cluster/values.yaml
sed -i "496s/3/2/g" ~/rook/deploy/charts/rook-ceph-cluster/values.yaml

#--- install rook ceph cluster
cd ~/rook/deploy/charts/rook-ceph-cluster
helm install -n rook-ceph rook-ceph-cluster --set operatorNamespace=rook-ceph rook-release/rook-ceph-cluster -f values.yaml
cd ~

#--- if you want to check if rook ceph cluster is installed completely, run the below commands.
# kubectl get all -n rook-ceph
# kubectl -n rook-ceph exec -it $(kubectl -n rook-ceph get pod -l "app=rook-ceph-tools" -o jsonpath='{.items[0].metadata.name}') -- bash
# ceph -s
# ceph osd status

#--- download files for uyuni deployment
wget --no-check-certificate --content-disposition http://cloud.itmaya.co.kr/s/h1slG9NqKCA6NHS/download
unzip Uyuni_Deploy_2302.zip
rm Uyuni_Deploy_2302.zip

wget --no-check-certificate --content-disposition http://cloud.itmaya.co.kr/s/cCqZOkZJ1Cxyhzc/download
unzip Uyuni_Kustomize_2302_2.zip
rm Uyuni_Kustomize_2302_2.zip
mv ~/Uyuni_Kustomize_2302_2/overlays/itmaya/dockerconfigjson ~/Uyuni_Kustomize_2302_2/overlays/itmaya/.dockerconfigjson

wget --no-check-certificate --content-disposition http://cloud.itmaya.co.kr/s/opsOLB7mbQxAuWJ/download
chmod 777 uyuni_2302_ip_config.sh

#--- install helmfile
wget https://github.com/helmfile/helmfile/releases/download/v0.150.0/helmfile_0.150.0_linux_amd64.tar.gz
tar -zxvf helmfile_0.150.0_linux_amd64.tar.gz
sudo mv helmfile /usr/bin/
rm LICENSE && rm README.md

#--- configure and edit uyuni installation files
./uyuni_2302_ip_config.sh

#--- make ceph-filesystem storageclass as default storageclass
kubectl patch storageclass nfs-client -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass ceph-block -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass ceph-bucket -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"false"}}}'
kubectl patch storageclass ceph-filesystem -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

#--- install prerequisite applications for uyuni deployment
cd ~/Uyuni_Deploy_2302
helmfile --environment itmaya -l type=base sync

#--- install uyuni kustomize
mv ~/Uyuni_Kustomize_2302_2/overlays/itmaya/volumes/kustomization-cephfs.yaml ~/Uyuni_Kustomize_2302_2/overlays/itmaya/volumes/kustomization.yaml
sudo snap install kustomize
kubectl create namespace uyuni-suite
kustomize build ~/Uyuni_Kustomize_2302_2/overlays/itmaya | kubectl apply -f -
