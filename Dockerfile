# 第一阶段：构建依赖
FROM nvidia/cuda:12.8.0-base-ubuntu22.04 as builder

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV TZ=Asia/Shanghai

# 配置 APT 源为华为云镜像
RUN echo "deb https://repo.huaweicloud.com/ubuntu/ jammy main restricted universe multiverse" > /etc/apt/sources.list && \
    echo "deb https://repo.huaweicloud.com/ubuntu/ jammy-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://repo.huaweicloud.com/ubuntu/ jammy-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb https://repo.huaweicloud.com/ubuntu/ jammy-security main restricted universe multiverse" >> /etc/apt/sources.list

# 安装 Python 和必要的构建工具
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.10 \
    python3.10-dev \
    python3.10-distutils \
    python3.10-venv \
    python3-pip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 设置 Python 默认版本
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1

# 配置 pip
RUN mkdir -p /root/.pip && \
    echo "[global]" > /root/.pip/pip.conf && \
    echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> /root/.pip/pip.conf && \
    echo "trusted-host = pypi.tuna.tsinghua.edu.cn" >> /root/.pip/pip.conf && \
    echo "timeout = 120" >> /root/.pip/pip.conf && \
    echo "retries = 3" >> /root/.pip/pip.conf

# 升级 pip
RUN python3.10 -m pip install --upgrade pip --no-cache-dir

# 设置工作目录
WORKDIR /workspace

# 复制项目文件
COPY pyproject.toml poetry.lock* ./

# 安装 poetry 并导出依赖（排除 jupyterlab）
RUN pip install poetry -i https://pypi.tuna.tsinghua.edu.cn/simple && \
    poetry export -f requirements.txt --output requirements.txt --without-hashes --without jupyterlab

# 安装项目依赖
RUN pip install -r requirements.txt

# 第二阶段：最终镜像
FROM nvidia/cuda:12.8.0-base-ubuntu22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV TZ=Asia/Shanghai

# 配置 APT 源
COPY --from=builder /etc/apt/sources.list /etc/apt/sources.list

# 安装必要的运行时依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.10 \
    python3.10-distutils \
    cuda-toolkit-12-8 \
    git \
    vim \
    wget \
    zsh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 配置 Oh My Zsh
RUN wget -O /tmp/install.sh https://gitee.com/mirrors/oh-my-zsh/raw/master/tools/install.sh && \
    chmod +x /tmp/install.sh && \
    sh /tmp/install.sh --unattended || true && \
    rm -f /tmp/install.sh && \
    chsh -s $(which zsh) root || true

# 从构建阶段复制 Python 环境
COPY --from=builder /usr/local/lib/python3.10/dist-packages /usr/local/lib/python3.10/dist-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# 设置工作目录
WORKDIR /workspace

# 复制应用代码
COPY . .

# 设置环境变量
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/workspace
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV APP_MODE='streamlit'

# 复制并设置入口点脚本权限
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 暴露 Streamlit 端口
EXPOSE 8501

# 设置入口点
ENTRYPOINT ["docker-entrypoint.sh"]

# 设置默认命令
CMD ["/bin/zsh"] 