#!/bin/bash
# 换源脚本
# bash <(curl -sSfLk https://github.com/zhaixinyu249/scripts/raw/refs/heads/main/operation/repos/repos_all.sh)

out_pink() {
    echo -e "\033[35m$1\033[0m"
}

out_cyan() {
    echo -e "\033[36m$1\033[0m"
}

out_yellow() {
    echo -e "\033[33m$1\033[0m"
}

read -t 10 -rp "选择源（1：阿里，2：腾讯，3：华为，4：清华）:（默认阿里） " repo_type
repo_type=${repo_type:-1}

# 检测系统名称
if grep -qi "sources" /home/.repos_updated 2>/dev/null; then
    out_yellow "已检测到已执行换源脚本,退出执行"
    out_yellow "Source script has already been executed, exiting"
    exit 1
else
    out_yellow "正在检测系统..."
    out_yellow "Detecting system..."
    system_name=$(awk -F '=' '/^ID=/{print $NF}' /etc/os-release | tr -d '"' | tr '[A-Z]' '[a-z]')
fi

# 匹配系统名称并换源
case "${system_name}" in
centos)
    echo "===== centos ====="
    case ${repo_type} in
        1)
            bash <(curl -sSfLk https://github.com/zhaixinyu249/scripts/raw/refs/heads/main/operation/repos/repos_centos_aliyun.sh)
            ;;
        2)
            echo "${system_name} ${repo_type} 待完善"
            ;;
        3)
            echo "${system_name} ${repo_type} 待完善"
            ;;
        4)
            echo "${system_name} ${repo_type} 待完善"
            ;;
        *)
            echo "${system_name} ${repo_type} 待完善"
            ;;
    esac
    ;;
ubuntu)
    echo "===== ubuntu ====="
    case ${repo_type} in
        1)
            bash <(curl -sSfLk https://github.com/zhaixinyu249/scripts/raw/refs/heads/main/operation/repos/repos_ubuntu_aliyun.sh)
            ;;
        2)
            echo "${system_name} ${repo_type} 待完善"
            ;;
        3)
            echo "${system_name} ${repo_type} 待完善"
            ;;
        4)
            echo "${system_name} ${repo_type} 待完善"
            ;;
        *)
            echo "${system_name} ${repo_type} 待完善"
            ;;
    esac
    ;;
debian)
    echo "===== debian ====="
    case ${repo_type} in
        1)
            bash <(curl -sSfLk https://3411.s.kuaicdn.cn:34112/shell/network/repos_centos.sh)
            ;;
        2)
            echo "${system_name} ${repo_type} 待完善"
            ;;
        3)
            echo "${system_name} ${repo_type} 待完善"
            ;;
        4)
            echo "${system_name} ${repo_type} 待完善"
            ;;
        *)
            echo "${system_name} ${repo_type} 待完善"
            ;;
    esac
    ;;
arch)
    echo "===== arch ====="
    bash <(curl -sSfLk https://3411.s.kuaicdn.cn:34112/shell/network/repos_arch.sh)
    ;;
*)
    echo "未知系统 => ${system_name},将不执行专用系统的标准处理流程"
    echo "Unknown system => ${system_name}, will not execute the standard processing flow for the specific system"
    out_yellow "当前换源脚本已支持以下系统: CentOS, Debian, Ubuntu"
    out_yellow "Current source script supports the following systems: CentOS, Debian, Ubuntu"
    exit 1
    ;;
esac