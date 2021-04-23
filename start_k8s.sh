#!/bin/bash
sudo su
apt update -y
snap install microk8s --classic --channel=1.21/stable
microk8s status --wait-ready

microk8s.enable dns
microk8s.enable dashboard
microk8s.enable ingress
microk8s.enable helm3
microk8s.enable storage
snap alias microk8s.helm3 helm
snap alias microk8s.kubectl kubectl

kubectl proxy --accept-hosts=.* --address=0.0.0.0 &
kubectl config view --raw >~/.kube/config
helm init

mkdir /home/k8s && \
  groupadd -r k8s && \
  useradd -s /bin/bash -d /home/k8s -r -g k8s k8s && \
  chown k8s:k8s /home/k8s

cd home/k8s
git clone https://github.com/LeonardoBozCaitano/terraform-singlenode-kubernetes-template.git
cd terraform-singlenode-kubernetes-template/charts

helm repo add bitnami https://charts.bitnami.com/bitnami

helm install --values=mongodb/values.yaml bitnami/mongodb --generate-name

mkdir ./ready