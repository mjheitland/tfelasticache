#!/bin/bash
sudo echo "Host in ${subnet}" >> /var/log/mylog.txt

# update packages
sudo yum update -y
sudo echo "yum updated" >> /var/log/mylog.txt

# install Redis tools
sudo amazon-linux-extras install epel -y
sudo yum install gcc jemalloc-devel openssl-devel tcl tcl-devel -y
cd /home/ec2-user
sudo wget http://download.redis.io/redis-stable.tar.gz
sudo tar xvzf redis-stable.tar.gz
cd redis-stable
sudo make BUILD_TLS=yes
sudo echo "Redis tools installed" >> /var/log/mylog.txt
