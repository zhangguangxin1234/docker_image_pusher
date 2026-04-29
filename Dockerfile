FROM codercom/code-server:latest

USER root

# 1. 彻底覆盖 apt 源为清华源 (针对 Debian Trixie)
RUN rm -rf /etc/apt/sources.list.d/* && \
    echo "Types: deb\nURIs: https://mirrors.tuna.tsinghua.edu.cn/debian\nSuites: trixie trixie-updates\nComponents: main\nSigned-By: /usr/share/keyrings/debian-archive-keyring.pgp\n\nTypes: deb\nURIs: https://mirrors.tuna.tsinghua.edu.cn/debian-security\nSuites: trixie-security\nComponents: main\nSigned-By: /usr/share/keyrings/debian-archive-keyring.pgp" > /etc/apt/sources.list.d/debian.sources

# 2. 切换到微软官方插件市场 (通常比 Open VSX 在国内更快)
RUN sed -i 's|"serviceUrl": "https://open-vsx.org/vscode/gallery"|"serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery"|g' /usr/lib/code-server/lib/vscode/product.json && \
    sed -i 's|"itemUrl": "https://open-vsx.org/vscode/item"|"itemUrl": "https://marketplace.visualstudio.com/items"|g' /usr/lib/code-server/lib/vscode/product.json

# 3. 配置全局 pip 清华源
RUN mkdir -p /etc/pip && \
    echo "[global]" > /etc/pip.conf && \
    echo "index-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> /etc/pip.conf && \
    echo "trusted-host = pypi.tuna.tsinghua.edu.cn" >> /etc/pip.conf && \
    echo "timeout = 1000" >> /etc/pip.conf && \
    echo "retries = 10" >> /etc/pip.conf

# 4. 安装系统依赖
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-venv \
    nodejs \
    npm \
    git \
    curl \
    htop \
    && rm -rf /var/lib/apt/lists/*

# 5. 安装 Jupyter 核心组件及常用库
RUN pip3 install --no-cache-dir --break-system-packages \
    ipykernel \
    numpy \
    pandas \
    matplotlib \
    scikit-learn \
    requests

# 6. 配置 npm 阿里源并安装全局 CLI 工具
RUN npm config set registry https://registry.npmmirror.com \
    && npm install -g @google/gemini-cli @anthropic-ai/claude-code

# 声明构建参数，以便在构建时使用代理
ARG http_proxy
ARG https_proxy

USER coder

# 7. 安装插件 (受益于构建代理和微软市场源，速度将大幅提升)
RUN code-server --install-extension ms-python.python \
    && code-server --install-extension ms-toolsai.jupyter \
    && code-server --install-extension ms-toolsai.jupyter-renderers \
    && code-server --install-extension Anthropic.claude-code \
    && code-server --install-extension google.gemini-vscode \
    && code-server --install-extension AlibabaCloud.tongyi-lingma \
    && code-server --install-extension Continue.continue

WORKDIR /home/coder/project
