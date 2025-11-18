#!/bin/bash
set -e

# 安装 apt-transport-https 和 ca-certificates (如果尚未安装)
apt-get update
apt-get install -y --no-install-recommends apt-transport-https ca-certificates software-properties-common gnupg

echo "尝试添加 deadsnakes PPA..."
# 尝试方法1: 使用 add-apt-repository
if add-apt-repository -y ppa:deadsnakes/ppa; then
    apt-get update
    echo "✓ deadsnakes PPA 添加成功"
else
    echo "× PPA 添加失败，尝试备选方案..."
    
    # 尝试方法2: 手动添加 PPA
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F23C5A6CF475977595C89F51BA6932366A755776
    echo "deb http://ppa.launchpad.net/deadsnakes/ppa/ubuntu focal main" > /etc/apt/sources.list.d/deadsnakes-ppa.list
    apt-get update || {
        # 尝试方法3: 直接下载安装 Python 3.10
        echo "× 无法添加 PPA，直接下载 Python 3.10..."
        cd /tmp
        
        # 下载 Python 3.10 相关包
        wget https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa/+files/python3.10_3.10.4-1+focal1_amd64.deb
        wget https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa/+files/python3.10-dev_3.10.4-1+focal1_amd64.deb
        wget https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa/+files/python3.10-venv_3.10.4-1+focal1_amd64.deb
        wget https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa/+files/python3.10-minimal_3.10.4-1+focal1_amd64.deb
        wget https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa/+files/libpython3.10-dev_3.10.4-1+focal1_amd64.deb
        wget https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa/+files/libpython3.10-minimal_3.10.4-1+focal1_amd64.deb
        wget https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa/+files/libpython3.10-stdlib_3.10.4-1+focal1_amd64.deb
        
        # 安装包
        apt-get install -y ./python3.10-minimal_3.10.4-1+focal1_amd64.deb \
                         ./libpython3.10-minimal_3.10.4-1+focal1_amd64.deb \
                         ./libpython3.10-stdlib_3.10.4-1+focal1_amd64.deb \
                         ./python3.10_3.10.4-1+focal1_amd64.deb \
                         ./python3.10-venv_3.10.4-1+focal1_amd64.deb \
                         ./libpython3.10-dev_3.10.4-1+focal1_amd64.deb \
                         ./python3.10-dev_3.10.4-1+focal1_amd64.deb
        
        # 清理
        rm -f python3.10*.deb libpython3.10*.deb
        
        echo "✓ Python 3.10 直接安装成功"
    }
fi 