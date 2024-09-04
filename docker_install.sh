#!/bin/bash

yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

yum -y install docker-ce docker-ce-cli containerd.io
systemctl enable docker --now

folder="/usr/local/docker-compose"

mkdir ${folder}/cli-plugins -p
curl -SL https://github.com/docker/compose/releases/download/v2.10.0/docker-compose-linux-x86_64 -o ${folder}/cli-plugins/docker-compose


chmod +x ${folder}/cli-plugins/docker-compose

ln -fs ${folder}/cli-plugins/docker-compose /usr/local/bin/docker-compose

