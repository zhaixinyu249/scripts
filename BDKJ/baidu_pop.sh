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
    esac
}

main "$@"