#!/bin/bash

GREEN() {
    echo -e "\033[32m$1\033[0m"
}
RED() {
    echo -e "\033[31m$1\033[0m"
}
YELLOW() {
    echo -e "\033[33m$1\033[0m"
}

# 初始化;需要配置ipv6
Init() {
    # curl -6 ip.sb &> /dev/null
    # if [ $? != 0 ]; then
    # RED "未检测到IPV6，请先配置IPV6"
    # exit 1
    # fi
    # systemctl restart docker
    # # 安装zbx监控
    # bash <(curl -sSfLk https://3411.s.kuaicdn.cn:34112/ruko.sh) 63
    # # 阵列磁盘挂载
    # # bash <(curl -sSfLk https://3411.s.kuaicdn.cn:34112/ruko.sh) 35
    # # 开启性能模式
    # tuned-adm profile latency-performance
    # # 输出内容填写到语雀表格
    # bash <(curl -sSfLk https://3411.s.kuaicdn.cn:34112/ruko.sh) 64
    # systemctl enable NetworkManager
    echo "This is test!!!"
}

#剔除机械磁盘
Delete_sdx() {
    XTDISK=$(lsblk 2>/dev/null | grep -A1 -B6 "\s/$" | grep -Eo '(s|v)d[a-z]{1,2}[2-9]{1}' | grep -Eo '(s|v)d[a-z]' | sort -u)
    _JXPSL=$(lsblk -d -o NAME,SIZE,ROTA 2>/dev/null | grep -v "nvme\|NAME\|$XTDISK\|sr0\|M\|B" | awk '{print $1}')
    for DISK in $_JXPSL; do
        echo "卸载磁盘： $DISK"
        if lsblk 2>/dev/null | grep -A1 "^$DISK" | grep -q "└─"; then
            umount -f "/dev/$DISK" 2>/dev/null
            mkfs.xfs -f "/dev/$DISK"
        fi
        lsscsi | grep "/dev/$DISK" | awk -F':' '{print$3}' | xargs -I @ /opt/MegaRAID/perccli/perccli64 /c0/v@ del
        echo 1 >"/sys/block/$DISK/device/delete"
    done
    sleep 5
    lsblk
}

# 格式化磁盘，并压测
Mkfs_yace() {
    # 卸载所有/disk下的磁盘挂载
    bash <(curl -sSfLk https://3411.s.kuaicdn.cn:34112/ruko.sh) 44 y
    sleep 3
    bash <(curl -sSfLk https://3411.s.kuaicdn.cn:34112/shell/yingjian/Disk_IOPS.sh)
}

# 查看tyy信息
TYY_info() {
    # 查看容器是否存在
    echo -e "----------------------------------------------"
    if docker ps | grep -q pouch; then
        # 获取IPMI信息
        _IPMItool=$(ipmitool lan print 2>/dev/null)
        echo "$_IPMItool" | grep -E 'IP Address[[:space:]]*:' | awk '{printf " IPMI :  %s\n", $NF}'
        echo "----------------------------------------------"
        # 查看TYY内网IP
        echo -e "内网IP:\t $(ip r | grep pbtun0 | grep -Eo "192.168.[0-9]{1,3}.[0-9]{1,3} " | awk '{print $1}')"
        echo "----------------------------------------------"
        # 查看TYY-SN 记录到表格
        echo -e "  SN  :\t $(cat /data/sn_file)"
    else
        echo "docker容器检测失败"
    fi
    echo -e "----------------------------------------------"
}

# 开机自动放行22端口
pass22() {
    iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT
    systemctl enable rc-local
    systemctl start rc-local
    echo "iptables -I INPUT 1 -p tcp --dport 22 -j ACCEPT" >> /etc/rc.d/rc.local
}

main() {
    case $1 in
        # 初始化
        "init")
            Init
            ;;
        # 剔除机械盘
        "delete_sdx")
            Delete_sdx
            ;;
        # 格盘，压测
        "mkfs")
            Mkfs_yace
            ;;
        # 业务信息
        "info")
            TYY_info
            ;;
        # 放行22端口
        "pass22")
            pass22
            ;;
    esac
}

main "#@"