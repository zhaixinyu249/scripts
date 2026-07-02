#!/bin/bash
# +--------------------------------------------------+
# | Ubuntu 系统源 & Docker 源 一键替换为阿里云           |
# | 支持自动识别版本，安全备份，适用于 18.04+              |
# +--------------------------------------------------+
# bash <(curl -sSfLk https://3411.s.kuaicdn.cn:34112/shell/network/repos_ubuntu_aliyun.sh)
# shellcheck disable=SC1091
set -e  # 出错立即退出

echo "🔍 正在检测系统信息..."

# 检查是否为 Ubuntu
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" != "ubuntu" ]; then
        echo "❌ 本脚本仅支持 Ubuntu 系统！"
        exit 1
    fi
    if [ -z "$VERSION_CODENAME" ]; then
        echo "❌ 无法获取 Ubuntu 版本代号。"
        exit 1
    fi
else
    echo "❌ 无法读取系统信息。"
    exit 1
fi

echo "✅ 检测到 Ubuntu 版本: $PRETTY_NAME ($VERSION_CODENAME)"

# 获取系统架构
ARCH=$(uname -m)
case $ARCH in
    x86_64) ARCH_REPO="x86_64" ;;
    aarch64) ARCH_REPO="aarch64" ;;
    *)
        echo "❌ 不支持的架构: $ARCH"
        exit 1
        ;;
esac

# 源文件路径
SOURCES_LIST1="/etc/apt/sources.list"
SOURCES_LIST2="/etc/apt/sources.list.d"
DOCKER_LIST="/etc/apt/sources.list.d/docker.list"
BACKUP_DIR="/etc/apt/backup"

# 创建备份目录
mkdir -p $BACKUP_DIR

# 备份主源
case $VERSION_ID in
    24.04|26.04)
        mkdir -p ${BACKUP_DIR}/sources.list.d.bak.$(date +%Y%m%d)
        mv ${SOURCES_LIST2}/* ${BACKUP_DIR}/sources.list.d.bak.$(date +%Y%m%d) 2>/dev/null \
        && echo "📁 已备份主源到: ${BACKUP_DIR}/sources.list.d.bak.$(date +%Y%m%d)" \
        || echo "💡 未检测到主源，正在创建..."
        ;;
esac

# 备份 Docker 源（如果存在）
if [ -f "$DOCKER_LIST" ]; then
    cp "$DOCKER_LIST" "${BACKUP_DIR}/docker.list.bak.$(date +%Y%m%d)"
    echo "📁 已备份 Docker 源到: ${BACKUP_DIR}/docker.bak.$(date +%Y%m%d)"
fi

# === 替换主源为阿里云 ===
echo "🔄 正在替换主源为阿里云..."
case $VERSION_ID in
    24.04)
        case $ARCH_TYPE in
            x86_64)
                URIs="https://mirrors.aliyun.com/ubuntu"
                ;;
            aarch64)
                URIs="https://mirrors.aliyun.com/ubuntu-ports"
                ;;
        esac
        cat > /etc/apt/sources.list.d/ubuntu.sources < EOF
Types: deb
URIs: $URIs
Suites: noble noble-updates noble-backports
Components: main universe restricted multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: $URIs
Suites: noble-security
Components: main universe restricted multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF
        ;;
    26.04)
        case $ARCH_TYPE in
            x86_64)
                URIs="https://mirrors.aliyun.com/ubuntu"
                ;;
            aarch64)
                URIs="https://mirrors.aliyun.com/ubuntu-ports"
                ;;
        esac
        cat > /etc/apt/sources.list.d/ubuntu.sources < EOF
Types: deb
URIs: $URIs
Suites: resolute resolute-updates resolute-backports
Components: main universe restricted multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

Types: deb
URIs: $URIs
Suites: resolute-security
Components: main universe restricted multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
EOF
        ;;
esac


# === 替换或创建 Docker 源为阿里云 ===
echo "🔄 正在配置 Docker 源为阿里云..."

# 确保密钥环目录存在
KEYRING_DIR="/etc/apt/keyrings"
mkdir -p $KEYRING_DIR

# 判断是否已有 Docker 源文件
if [ -f "$DOCKER_LIST" ] || grep -q "docker" /etc/apt/sources.list.d/*.list 2>/dev/null; then
    echo "💡 检测到 Docker 源，正在替换为阿里云..."
else
    echo "💡 未检测到 Docker 源，正在创建..."
fi

# 写入阿里云 Docker 源
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://mirrors.aliyun.com/docker-ce/linux/ubuntu "$VERSION_CODENAME" stable" | \
sudo tee /etc/apt/sources.list.d/docker.list

# 提示用户导入 GPG 密钥（如果尚未添加）
GPG_KEY_PATH="/etc/apt/keyrings/docker.asc"
if [ ! -f "$GPG_KEY_PATH" ]; then
    # Docker官方公钥
    echo "🔐 正在下载并安装 Docker 官方 GPG 密钥（阿里云同步源）..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o "${GPG_KEY_PATH}"
    echo "✅ Docker GPG 密钥已安装到 ${GPG_KEY_PATH}"
    # 阿里源
    # echo "🔐 正在下载并安装 Docker 阿里云源..."
    # curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | gpg --dearmor -o "${GPG_KEY_PATH}"
    # chmod a+r /etc/apt/keyrings/docker.gpg
    # echo "✅ Docker GPG 密钥已安装到 ${GPG_KEY_PATH}"
fi

# === 清理旧缓存并更新 ===
echo "🔁 正在更新软件包列表..."
apt update

# === 完成提示 ===
echo ""
echo "🎉 换源成功！所有源均已切换为阿里云镜像。"
echo ""
echo "📌 主源: http://mirrors.aliyun.com/ubuntu/"
echo "📌 Docker 源: https://mirrors.aliyun.com/docker-ce/linux/ubuntu"
echo ""
echo "📦 已执行: apt update"
echo "📂 备份文件位于: ${BACKUP_DIR}"
echo ""