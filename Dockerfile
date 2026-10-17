FROM python:3.11-slim

ARG TZ
ENV TZ="$TZ"

# Install Node.js 20
RUN apt update && apt install -y curl gnupg2 && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt install -y nodejs
	
# Ensure npm global bin is in PATH for all shells
RUN echo 'export PATH="/usr/local/lib/node_modules/.bin:/usr/local/bin:$PATH"' >> /root/.zshenv

# Install basic development tools and network utilities
RUN apt update && apt install -y less \
  git \
  procps \
  sudo \
  fzf \
  zsh \
  man-db \
  unzip \
  gh \
  iptables \
  ipset \
  iproute2 \
  dnsutils \
  aggregate \
  jq \
  iputils-ping \
  curl \
  wget \
  net-tools \
  traceroute \
  build-essential \
  && apt clean \
  && rm -rf /var/lib/apt/lists/*

# Install .NET 8 SDK from Microsoft's Debian 13 feed
RUN wget -q https://packages.microsoft.com/config/debian/13/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb \
  && dpkg -i /tmp/packages-microsoft-prod.deb \
  && rm /tmp/packages-microsoft-prod.deb \
  && apt update \
  && apt install -y dotnet-sdk-8.0 \
  && apt clean \
  && rm -rf /var/lib/apt/lists/*

# Install Mike Farah's Go yq (Debian's apt yq is the unrelated Python jq-wrapper)
RUN wget -q https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq \
  && chmod +x /usr/local/bin/yq

# Install Rust + cargo via rustup (stable, minimal profile). lld and common
# system libs are installed alongside for projects that link against audio /
# input / TLS stacks.
RUN apt update && apt install -y lld pkg-config libssl-dev libasound2-dev libudev-dev \
  && apt clean && rm -rf /var/lib/apt/lists/*
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- \
    -y --default-toolchain stable --profile minimal --no-modify-path
ENV PATH="/root/.cargo/bin:${PATH}"
RUN echo 'export PATH="/root/.cargo/bin:$PATH"' >> /root/.zshenv

# Install Python packages (latest versions)
RUN pip install --no-cache-dir --upgrade pip setuptools wheel && \
    pip install --no-cache-dir \
  numpy \
  pandas \
  scipy \
  scikit-learn \
  torch \
  torchvision \
  torchaudio \
  shap \
  transformers \
  sentence-transformers \
  openai \
  anthropic \
  google-generativeai \
  pyyaml \
  requests \
  flask \
  flask-cors \
  jupyter \
  matplotlib \
  seaborn \
  plotly \
  tqdm \
  ipython

# Persist bash history.
RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  && mkdir /commandhistory \
  && touch /commandhistory/.bash_history

# Set `DEVCONTAINER` environment variable to help with orientation
ENV DEVCONTAINER=true

# Set sandbox to true to be able to use "claude --dangerously-skip-permissions" in root
ENV IS_SANDBOX=1

# There is a debug error present in claude code that hopefully this will prevent
ENV DEBUG=False
ENV CLAUDE_DEBUG=False

# Create workspace and config directories
RUN mkdir -p /workspace /root/.claude /root/.claude/shell-snapshots

WORKDIR /workspace

RUN ARCH=$(dpkg --print-architecture) && \
  wget "https://github.com/dandavison/delta/releases/download/0.18.2/git-delta_0.18.2_${ARCH}.deb" && \
  sudo dpkg -i "git-delta_0.18.2_${ARCH}.deb" && \
  rm "git-delta_0.18.2_${ARCH}.deb"

# Set the default shell to zsh
ENV SHELL /bin/zsh

# Default powerline10k theme
RUN sh -c "$(wget \
 -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" -- \
  -p git \
  -p fzf \
  -a 'eval "$(fzf --zsh)"' \
  -a "export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
  -x

# Install Claude Code
RUN npm install -g @anthropic-ai/claude-code

# Disable 'cd
RUN echo 'cd() { echo "Directory changing is disabled! Read CLAUDE.md again for etiquette."; return 1; }' >> /root/.zshenv

# Disable 'docker' and 'docker-compose'
RUN echo 'docker() { echo "Docker is disabled! Read CLAUDE.md again for etiquette."; return 1; }' >> /root/.zshenv
RUN echo 'docker-compose() { echo "Docker is disabled! Read CLAUDE.md again for etiquette."; return 1; }' >> /root/.zshenv