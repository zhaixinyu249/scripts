#!/bin/bash

Cat_conf() {
    case $1 in
        "pop")
            file="/data/kuaicdn/bbiz/pop/args.conf"
            ;;
        "ant")
            file="/data/kuaicdn/bbiz/ant/config.conf"
            ;;
    esac
    cat $file
}

main() {
    case $1 in
        # 查看配置文件
        "catconf")
            Cat_conf "${@:2}"
            ;;
        # 更换ip
        "update_ip")
            bash <(curl -sSfLk https://gitee.com/zhaixinyu249/scripts/raw/main/BDKJ/baidu_update_ip.sh) "${@:2}"
            ;;
    esac
}

main "$@"