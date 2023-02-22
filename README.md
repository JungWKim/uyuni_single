# Summary
### 1. OS : Ubuntu 22.04.1 server
### 2. K8s version : 1.23.7
### 3. container runtime : containerd v1.6.4
### 4. primary provisioner : ceph-filesystem
### 5. mlops : uyuni-suite
### 6. nvidia driver version : 515.86.01
### 7. cni type : calico

# How to use
### fix the host's ip
### edit variables at the head of the first script
### Run the first script without "sudo"
### After the first script is finished, edit the value of the storage size in pv.yaml before you run the second script
### edit the value of NFS variable at the head of the second script if you need to use nfs-client storage class
### Run the second script without "sudo"
