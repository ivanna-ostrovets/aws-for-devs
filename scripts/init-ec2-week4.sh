#!/bin/bash -xe

yum update -y

yum install httpd -y

service httpd start

chkconfig httpd on

cd /var/www/html
