#!/bin/sh
apt-get update && apt-get install -y openssh-server
mkdir /var/run/sshd
echo 'root:screencast' | chpasswd
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
echo "export VISIBLE=now" >> /etc/profile
/usr/sbin/sshd -D

apt-get update
apt-get install default-jdk r-base wget python
