#!/bin/bash

# 安装 ansible 的仓库以及 ansible
sudo apt update 
sudo apt install -y software-properties-common python3-pip python-pip
sudo apt-add-repository --yes --update ppa:ansible/ansible 
sudo apt install -y ansible

# 安装 python3 的 Docker 模块
sudo pip3 install docker

# 安装 python2 的 Docker 模块
sudo pip install docker
