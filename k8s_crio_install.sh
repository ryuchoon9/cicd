#!/bin/bash
# Install required packages for containerd and Docker
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release apt-transport-https
# Add Docker GPG key to apt keyring
sudo mkdir -p /etc/apt/keyrings
sudo chmod 755 /etc/apt/keyrings
cat <<EOF | sudo tee /etc/modules-load.d/crio.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

export OS=xUbuntu_20.04 # OS 버전
export VERSION=1.24     # cri-o 버전

echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list

curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/$OS/Release.key | apt-key add -
curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:/$VERSION/$OS/Release.key | apt-key add -

sudo apt-get update

sudo apt-get install -y cri-o cri-o-runc

sudo systemctl daemon-reload
sudo systemctl enable crio --now

# Enable required kernel modules
sudo cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
sudo cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

sudo curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
sudo chmod a+r /etc/apt/keyrings/kubernetes-archive-keyring.gpg
#sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
sudo echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
# Reload systemd configuration and restart kubelet
sudo systemctl daemon-reload
sudo systemctl restart kubelet
# Enable required kernel modules
sudo modprobe br_netfilter
sudo sysctl net.bridge.bridge-nf-call-iptables=1
sudo sysctl net.ipv4.ip_forward=1
sudo cat <<EOF | sudo tee /etc/sysctl.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl -p
# Initialize Kubernetes cluster
sudo kubeadm init
# Create the kube config directory in the current user's home directory
sudo mkdir -p $HOME/.kube
# Copy the Kubernetes cluster configuration file from the default location to the kube config directory
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# Change the ownership of the copied configuration file to the current user and group
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Calico
sudo kubectl apply -f https://github.com/projectcalico/calico/blob/master/manifests/tigera-operator.yaml
sudo kubectl apply -f https://github.com/projectcalico/calico/blob/master/manifests/custom-resources.yaml
# Taint all nodes with the node-role.kubernetes.io/control-plane taint to prevent pods from being scheduled on the control plane node(s)
sudo kubectl taint nodes --all node-role.kubernetes.io/control-plane-
# Update the package list and install the bash-completion package for kubectl command completion
sudo apt-get update
sudo apt-get install bash-completion
# Configure bash shell command completion for kubectl
echo "source <(kubectl completion bash)" >> ~/.bashrc
echo "alias k=kubectl" >> ~/.bashrc
echo "complete -F __start_kubectl k" >> ~/.bashrc
# Source ~/.bashrc
source ~/.bashrc
