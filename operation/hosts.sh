#!/bin/bash
# 配置本地hosts解析
# 使用方法：bash <(curl -sSfLk https://github.com/zhaixinyu249/scripts/raw/refs/heads/main/hosts.sh) www.example.com

ip=$(nslookup $1 | awk -F ' ' '/Address: [0-9]/{print $NF}')
echo "${ip} $1" >> /etc/hosts
tail /etc/hosts
