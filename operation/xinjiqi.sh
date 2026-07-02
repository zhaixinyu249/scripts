#!/bin/bash
# 添加密钥，禁用密码登录

touch /root/.ssh/authorized_keys 2>/dev/null
# 公钥
public='XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
chattr -i /etc/ssh/sshd_config /root/.ssh/authorized_keys 2>/dev/null
# 禁用密码登录
sed -i 's/^#*PasswordAuthentication.*$/PasswordAuthentication no/' /etc/ssh/sshd_config
# 开启公钥登录
sed -i 's/^#*PubkeyAuthentication.*$/PubkeyAuthentication yes/' /etc/ssh/sshd_config
echo "${public}" >>/root/.ssh/authorized_keys
chattr +i /etc/ssh/sshd_config /root/.ssh/authorized_keys 2>/dev/null
systemctl restart ssh
systemctl restart sshd 2>/dev/null
