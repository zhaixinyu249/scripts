#!/bin/bash
# 添加密钥，禁用密码登录

info_echo() {
    # 流程信息
    echo -e "\t\e[46m=== $1 ===\e[0m"
}

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
info_echo "添加完成，可以使用密钥登录"