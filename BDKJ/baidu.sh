#!/bin/bash

Cat_conf() {
    cat /data/kuaicdn/bbiz/$1/args.conf
}

main() {
    case $1 in
        # 查看pop配置文件
        "catconf")
            Cat_conf "$@"
            ;;
        # 更换ip
        "update_ip")
            bash <(curl -sSfLk https://gitee.com/zhaixinyu249/scripts/raw/main/BDKJ/baidu_update_ip.sh) "$@"
            ;;
    esac
}

main "$@"