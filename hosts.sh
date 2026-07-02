#!/bin/bash
# 配置本地hosts解析

ip=$(nslookup $1 | awk -F ' ' '/Address: [0-9]/{print $NF}')
echo "${ip} $1" >> /etc/hosts
tail /etc/hosts
