#!/bin/bash
set -x

GREEN() {
    echo -e "\033[32m$1\033[0m"
}
RED() {
    echo -e "\033[31m$1\033[0m"
}
WHITE_RED() {
    echo -e "\033[1;31;47m$1\033[0m"
}
YELLOW() {
    echo -e "\033[33m$1\033[0m"
}

_IPv4_change() {
    # 更换IPv4
    cat > /root/m-net-tui << EOF
$1 $2 $3 $4
EOF

    # 配置新IPv4
    bash <(curl -sSfLk https://3411.s.kuaicdn.cn:34112/ruko.sh) 51 &
    wait $!

    # 检查IPv4是否更换成功
    ipv4_new=$(curl -4 ip.sb)
    ipv4=$(echo $2 | awk -F'/' '{print $1}' )
    if [ "$ipv4_new" != "$ipv4" ]; then
        RED "IPv4更换失败"
        exit 1
    fi
    sleep 4

    ping -c 4 www.baidu.com
    sleep 8
}

_IPv6_change() {
    #配置IPv6
    bash <(curl -sSfLk https://3411.s.kuaicdn.cn:34112/ruko.sh) 81 $1  $2 &
    wait $!

    # 检查IPv6是否更换成功
    ipv6_new=$(curl -6 ip.sb)
    ipv6=$(echo $1 | awk -F'/' '{print $1}' )
    if [ "$ipv6_new" != "$ipv6" ]; then
        RED "IPv6更换失败"
        exit 1
    fi
    sleep 4

    ping -6 -c 4 www.baidu.com
    sleep 8
}

_ANT(){
    # 百度ANT

    # 卸载拨号
    bash <(curl -sSfLk https://3411.s.kuaicdn.cn:34112/ruko.sh) 52 &
    wait $!

    # 更换IPv4
    _IPv4_change $1 $2 $3 $4

    # 更换IPv6
    _IPv6_change $5 $6

    # 修改ant配置文件
    ipv4=$(echo $2 | awk -F'/' '{print $1}' )
    ipv6=$(echo $5 | awk -F'/' '{print $1}' )
    sed -i "s/ips=.*/ips=${ipv4}/" /data/kuaicdn/bbiz/ant/config.conf
    sed -i "s/ipv6s=.*/ipv6s=${ipv6}/" /data/kuaicdn/bbiz/ant/config.conf

    # 重启容器
    docker restart $(docker ps -qa)
}

# 百度POP
_POP(){
    cat /data/kuaicdn/labels/suid
    # 卸载拨号
    bash <(curl -sSfLk https://3411.s.kuaicdn.cn:34112/ruko.sh) 52 &
    wait $!

    # 更换IPv4
    _IPv4_change $1 $2 $3 $4

    # 更换IPv6
    _IPv6_change $5 $6

    # 重新注册
    #bash <(curl -sSfLk https://3411.s.kuaicdn.cn:34112/ruko.sh) 24
    sleep 5

    # 重启容器
    docker restart $(docker ps -qa)

}

_main() {
    # 检查是否提供了足够的参数
    if [ $# -ge 5 ]; then
        echo "用法: bash <(curl XXXXX)  ant/pop  vlan   IPv4/掩码   v4网关    速率   [IPv6/掩码  IPv6网关](pop可选)"
        exit 1
    fi

    if [ $1 == "ant" ]; then
        if [ -z "$6" ] && [ -z "$7" ]; then
            RED "IPv6地址提供有误，请重新配置"
            exit 1
        fi
        echo "============百度ANT============"
        _ANT $2 $3 $4 $5 $6 $7
        if [ $? -eq 0 ]; then
            GREEN "IPv4已更换为$3"
            GREEN "IPv6已更换为$6"
        fi
        echo "ANT配置文件:"
        cat /data/kuaicdn/bbiz/ant/config.conf
    elif [ $1 == "pop" ]; then
        if [ -z "$6" ] && [ -z "$7" ]; then
            YELLOW "未提供IPv6地址，POP将只更换IPv4"
        fi
        echo "============百度POP============"
        _POP $2 $3 $4 $5 $6 $7
        if [ $? -eq 0 ]; then
            GREEN "IPv4已更换为$3"
            if [ -z "$6" ] && [ -z "$7" ]; then
                GREEN "IPv6已更换为$6"
            else
                YELLOW "未提供IPv6地址，当前设备IPv6为$(curl -6 ip.sb)"
            fi
            WHITE_RED "更换 IP 后请发邮件注册，否则无法跑量,影响计费"
        fi
        echo "POP配置文件:"
        cat /data/kuaicdn/bbiz/pop/args.conf
    fi
}

_main "$@"