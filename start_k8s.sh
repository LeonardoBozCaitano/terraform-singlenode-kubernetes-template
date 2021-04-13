#!/bin/bash
sudo su
apt update -y
snap install microk8s --classic --channel=1.16/stable
microk8s status --wait-ready

microk8s.enable dns dashboard helm
alias microk8s.helm helm
alias microk8s.kubectl kubectl
kubectl proxy --accept-hosts=.* --address=0.0.0.0 &
kubectl config view --raw >~/.kube/config

mkdir /home/k8s && \
  groupadd -r k8s && \
  useradd -s /bin/bash -d /home/k8s -r -g k8s k8s && \
  chown k8s:k8s /home/k8s

USER k8s
cd home/k8s
git clone https://github.com/LeonardoBozCaitano/terraform-singlenode-kubernetes-template.git
cd terraform-singlenode-kubernetes-template/helm-config

sh install-components.txt