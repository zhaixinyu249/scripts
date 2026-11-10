#!/bin/bash

Catconf() {
    cat /data/kuaicdn/bbiz/pop/args.conf
}


main() {
    case $1 in
        # 查看配置文件
        "catconf")
            Catconf
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
        "delete_tyy")
            delete_tyy
            ;;
    esac
}

main "$@"