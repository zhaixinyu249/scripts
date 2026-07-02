#!/bin/bash
# 配置本地hosts解析
# 使用方法：bash <(curl -sSfLk https://github.com/zhaixinyu249/scripts/raw/refs/heads/main/hosts.sh) www.example.com

ip=$(getent ahosts $1 | awk 'NR==1{print $1}')
echo "$ip $1" >> /etc/hosts
echo "=========================="
tail /etc/hosts