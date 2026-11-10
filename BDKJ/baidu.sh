#!/bin/bash

# 查看配置文件
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

# 删除非pop缓存
Delele_nopop_cache() {
    # 过滤掉的缓存目录名称
    SC_huanc="cache-bcdn\|instanc"
    Wen_jian=$(lsblk | grep "/disk/" | awk '{print $NF}')
    Wen_A() {
        local w_jian="$1"
        local _ljhc
        _ljhc=$(ls "$w_jian" | grep -v "$SC_huanc")
        if [[ -n "$_ljhc" ]]; then
            for _lj in $_ljhc; do
                echo "删除: ${w_jian:?}/${_lj:?}"
                [[ -n $_lj && -n $_ljhc ]] && rm -rf "${w_j:?}/${_lj:?}" &
            done
        fi
        wait
    }
    for w_j in $Wen_jian; do
        Wen_A "$w_j" &
    done
    wait
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
        # 删除非pop缓存
        "delele_nopop_cache")
            Delele_nopop_cache
            ;;
    esac
}

main "$@"