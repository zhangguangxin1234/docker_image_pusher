# 基于docker.env的方式重新构建Dockerfile
FROM mambaorg/micromamba

# 元数据信息
LABEL maintainer="zhangguangxin@seekgene.com" \
      version="3.0" \
      description="Cloud analysis environment with R and Python support" \
      org.opencontainers.image.source="https://codeup.aliyun.com/seekgene/cloud_analysis" \
      org.opencontainers.image.licenses="MIT"

# 切换到 root 用户
USER root

# 设置root密码
RUN echo "root:123456zAA" | chpasswd

# 设置mambauser密码
RUN echo "mambauser:123456zAA" | chpasswd

# 环境变量统一设置
ENV TZ=Asia/Shanghai \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    SHELL=/bin/bash

# 设置时区
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# 配置apt清华源
RUN rm -rf /etc/apt/sources.list.d/* && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware" > /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-backports main contrib non-free non-free-firmware" >> /etc/apt/sources.list && \
    echo "deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list

# 配置全局pip源
RUN mkdir -p /etc/pip && \
    echo "[global]" > /etc/pip.conf && \
    echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> /etc/pip.conf && \
    echo "trusted-host = pypi.tuna.tsinghua.edu.cn" >> /etc/pip.conf && \
    echo "timeout = 1000" >> /etc/pip.conf && \
    echo "retries = 10" >> /etc/pip.conf

# 跳过系统包安装，使用基础镜像自带的工具

# 切换到mambauser用户
USER mambauser

# 创建分析环境并安装核心包
RUN micromamba create -p /home/mambauser/env/analysis  -y \
    python=3.9 \
    r-base=4.1.3 \
    r-essentials \
    r-seurat=4.1.1 \
    r-tidyverse=1.3.1 \
    r-matrix=1.4.1 \
    r-rcpp=1.0.8.3 \
    r-jsonlite \
    r-plotly=4.10.0 \
    r-httr=1.4.3 \
    r-plumber=1.1.0 \
    r-reticulate=1.25 \
    r-magrittr=2.0.3 \
    r-purrr \
    r-lubridate=1.8.0 \
    r-stringr=1.4.0 \
    r-readr=2.1.2 \
    r-tibble=3.1.7 \
    r-tidyr=1.2.0 \
    r-forcats \
    bioconductor-annotationdbi=1.56.1 \
    bioconductor-clusterprofiler=4.2.0 \
    bioconductor-edger=3.36.0 \
    bioconductor-singler=1.8.1 \
    bioconductor-genomicranges= \
    bioconductor-ensdb.hsapiens.v86 \
    bioconductor-bsgenome.hsapiens.ucsc.hg38 \
    bioconductor-bsgenome.mmusculus.ucsc.mm10 \
    r-signac=1.7.0 \
    r-future=1.26.1 \
    r-furrr \
    r-presto=1.0.0 \
    r-qs \
    r-magick \
    r-gridextra=2.3 \
    r-cowplot=1.1.1 \
    r-patchwork=1.1.1 \
    r-promises=1.2.0.1

# 设置默认shell为bash
ENV SHELL=/bin/bash

# 切换回root用户进行最终配置
USER root

# 配置全局bash设置
RUN echo '# Global bash settings' > /etc/bash.bashrc && \
    echo 'export HISTCONTROL=ignoreboth' >> /etc/bash.bashrc && \
    echo 'export HISTSIZE=1000' >> /etc/bash.bashrc && \
    echo 'export HISTFILESIZE=2000' >> /etc/bash.bashrc && \
    echo 'shopt -s histappend' >> /etc/bash.bashrc && \
    echo 'shopt -s checkwinsize' >> /etc/bash.bashrc && \
    echo 'PS1="\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ \n"' >> /etc/bash.bashrc && \
    echo 'alias ls="ls --color=auto"' >> /etc/bash.bashrc && \
    echo 'alias ll="ls -lh"' >> /etc/bash.bashrc && \
    echo 'alias la="ls -a"' >> /etc/bash.bashrc && \
    echo 'alias python="python3"' >> /etc/bash.bashrc && \
    echo 'alias pip="pip3"' >> /etc/bash.bashrc

# 创建工作目录
RUN mkdir -p /biocloud
WORKDIR /biocloud
