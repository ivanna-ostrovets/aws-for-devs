#!/bin/bash -xe
yum install java-1.8.0-openjdk -y
curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
unzip awscliv2.zip
./aws/install
yum install postgresql postgresql-server -y
