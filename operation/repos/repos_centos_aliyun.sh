#!/bin/bash
# +--------------------------------------------------+
# | CentOS 换源为阿里云镜像 一键脚本                     |
# | 支持 CentOS 7, 8, Stream 8, Stream 9              |
# +--------------------------------------------------+
# 使用方法：
# 1）bash <(curl -sSfLk https://github.com/zhaixinyu249/scripts/raw/refs/heads/main/operation/repos/repos_centos_aliyun.sh)
# 2）bash <(curl -sSfLk https://gitee.com/zhaixinyu249/scripts/raw/main/operation/repos/repos_centos_aliyun.sh)

set -e # 遇错误退出

echo "🔍 正在检测系统信息..."

# 检查是否为 Ubuntu
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" != "centos" ]; then
        echo "❌ 本脚本仅支持 CentOS 系统！"
        exit 1
    fi
else
    echo "❌ 无法读取系统信息。"
    exit 1
fi

# 获取系统架构
ARCH=$(uname -m)
case $ARCH in
    "x86_64") ARCH_REPO="x86_64" ;;
    "aarch64") ARCH_REPO="aarch64" ;;
    *)
        echo "❌ 不支持的架构: $ARCH"
        exit 1
        ;;
esac

# 定义 repo 目录
REPO_DIR="/etc/yum.repos.d"
BACKUP_DIR="/etc/yum.repos.d/backup.bak.$(date +%Y%m%d)"
REPO_NAME="CentOS-Base.repo"

replace_centos_repo() {
    version=$1
    baseurl=$2
    extras_url=$3
    updates_url=$4

    repo_file=${REPO_DIR}/${REPO_NAME}

    # 创建备份目录
    mkdir -p $BACKUP_DIR
    # 备份
    mv /etc/yum.repos.d/*.repo $BACKUP_DIR
    echo "📁 之前的源已备份到 $BACKUP_DIR"

    # 生成阿里云 repo 内容
    cat > $repo_file <<EOF
[base]
name=CentOS-$version - Base - mirrors.aliyun.com
baseurl=${baseurl}
gpgcheck=1
gpgkey=${baseurl}/RPM-GPG-KEY-CentOS-$version
enabled=1
priority=1

[extras]
name=CentOS-$version - Extras - mirrors.aliyun.com
baseurl=$extras_url
gpgcheck=1
gpgkey=${extras_url}/RPM-GPG-KEY-CentOS-$version
enabled=1
priority=1

[updates]
name=CentOS-$version - Updates - mirrors.aliyun.com
baseurl=$updates_url
gpgcheck=1
gpgkey=${updates_url}/RPM-GPG-KEY-CentOS-$version
enabled=1
priority=1
EOF

    echo "✅ $REPO_NAME 已更新为阿里云镜像"
}

. /etc/os-release
# 根据版本执行替换
if [[ "$VERSION_ID" == "7" ]]; then
    echo "✅ 检测到 CentOS 7 ($ARCH_REPO)"
    replace_centos_repo "7" \
        "http://mirrors.aliyun.com/centos/7/os/$ARCH_REPO/" \
        "http://mirrors.aliyun.com/centos/7/extras/$ARCH_REPO/" \
        "http://mirrors.aliyun.com/centos/7/updates/$ARCH_REPO/"

elif [[ "$VERSION_ID" == "8" ]] || [[ "$PLATFORM_ID" == "platform:el8" ]]; then
    echo "✅ 检测到 CentOS 8 或 Stream 8 ($ARCH_REPO)"
    replace_centos_repo "8" \
        "http://mirrors.aliyun.com/centos/8-stream/BaseOS/$ARCH_REPO/os/" \
        "http://mirrors.aliyun.com/centos/8-stream/extras/$ARCH_REPO/os/" \
        "http://mirrors.aliyun.com/centos/8-stream/AppStream/$ARCH_REPO/os/"

elif [[ "$VERSION_ID" == "9" ]] || [[ "$PLATFORM_ID" == "platform:el9" ]]; then
    echo "✅ 检测到 CentOS Stream 9 ($ARCH_REPO)"
    replace_centos_repo "9" \
        "http://mirrors.aliyun.com/centos/9-stream/BaseOS/$ARCH_REPO/os/" \
        "http://mirrors.aliyun.com/centos/9-stream/extras/$ARCH_REPO/os/" \
        "http://mirrors.aliyun.com/centos/9-stream/AppStream/$ARCH_REPO/os/"
else
    echo "❌ 无法识别 CentOS 版本：VERSION_ID=$VERSION_ID, PLATFORM_ID=$PLATFORM_ID"
    exit 1
fi

# 清理并重建缓存
echo "🔁 正在清理并重建 YUM/DNF 缓存..."
if command -v dnf &>/dev/null; then
    dnf clean all && dnf makecache
elif command -v yum &>/dev/null; then
    yum clean all && yum makecache
else
    echo "❌ 未找到 yum 或 dnf 命令！"
    exit 1
fi

# 完成提示
echo ""
echo "🎉 CentOS 换源成功！所有源已切换为阿里云镜像。"
echo ""
echo "📌 镜像地址: http://mirrors.aliyun.com/centos/"
echo "📂 备份路径: $BACKUP_DIR"

{
    # 1. 下载 EPEL-7 的 GPG 公钥
    curl -o /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7
    # 2. 导入该密钥到 RPM 数据库
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
    # 3. 清理缓存并重新尝试安装
    yum clean all
    yum -y --assumeyes --setopt=tsflags=nodocs \
        --disableplugin=fastestmirror \
        --exclude='docker*' \
        --exclude='containerd*' \
        --exclude='runc' \
        update
    yum clean all
    yum makecache
    echo "repos sources updated" >/home/.repos_updated
}