#!/bin/bash

Pop_conf() {
    cat /data/kuaicdn/bbiz/pop/args.conf
}

main() {
    case $1 in
        # 查看配置文件
        "popconf")
            Pop_conf
            ;;
        # pop更换ip
        "pop_update_ip")
            ;;
    esac
}

main "$@"