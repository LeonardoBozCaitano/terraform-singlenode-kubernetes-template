#!/bin/bash
sudo apt update -y
sudo groupadd k8s
sudo useradd -m -r -g k8s k8s
mkdir /home/k8s/.kube

snap install microk8s --classic --channel=1.21/stable

sudo usermod -a -G microk8s k8s
sudo chown -f -R k8s ~/.kube

microk8s status --wait-ready
microk8s config > ~/.kube/config
microk8s.enable helm3

snap alias microk8s.kubectl kubectl
snap alias microk8s.helm3 helm