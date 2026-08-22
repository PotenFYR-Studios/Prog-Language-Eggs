# =============================================================================
#  Universal Programming Language Eggs - Universal Runtime Container
#  By PotenFYR Studios (https://github.com/PotenFYR-Studios/Prog-Language-Eggs)
#
#  Universal Panel Compatibility:
#    - Pterodactyl Panel (Wings)
#    - Pelican Panel
#    - Feather Panel (feather-panel / renoki-co)
#    - PufferPanel
#    - Jexactyl / Wisp
#    - Standalone Docker & Kubernetes
# =============================================================================

FROM ubuntu:22.04

LABEL author="PotenFYR Studios" maintainer="support@potenfyr.in"
LABEL org.opencontainers.image.source="https://github.com/potenfyr-studios/prog-language-eggs"
LABEL org.opencontainers.image.description="Universal container for 50+ programming languages across Pterodactyl, Pelican, Feather Panel, and PufferPanel"

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    USER=container \
    HOME=/home/container \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    PYTHONUNBUFFERED=1 \
    GOPATH=/home/container/go \
    CARGO_HOME=/home/container/.cargo \
    RUSTUP_HOME=/opt/rustup

ARG TARGETARCH

# 1. Base tools, compilers, interpreters, libraries & dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        jq \
        unzip \
        tar \
        xz-utils \
        bzip2 \
        zip \
        git \
        gnupg \
        build-essential \
        gcc \
        g++ \
        clang \
        make \
        cmake \
        ninja-build \
        gfortran \
        fp-compiler \
        nasm \
        iproute2 \
        tzdata \
        locales \
        procps \
        dnsutils \
        libssl-dev \
        zlib1g-dev \
        pkg-config \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        php-cli \
        php-curl \
        php-mbstring \
        php-xml \
        php-zip \
        php-bcmath \
        ruby \
        ruby-dev \
        lua5.4 \
        luajit \
        perl \
        tcl \
        swi-prolog \
        default-jdk-headless \
        default-jre-headless \
        golang-go \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Node.js (LTS 20.x), NPM, PNPM, Yarn, TypeScript, TS-Node, TSX, PM2
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g --no-fund --no-audit npm pnpm yarn typescript ts-node tsx nodemon pm2 \
    && rm -rf /var/lib/apt/lists/*

# 3. Install Bun (Direct release)
RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
        x86_64|amd64) BUN_ARCH="x64" ;; \
        aarch64|arm64) BUN_ARCH="aarch64" ;; \
        *) echo "Unsupported arch for Bun: $ARCH" && exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/oven-sh/bun/releases/latest/download/bun-linux-${BUN_ARCH}.zip" -o /tmp/bun.zip && \
    unzip -qo /tmp/bun.zip -d /tmp/bun-extract && \
    mv /tmp/bun-extract/bun-linux-*/bun /usr/local/bin/bun && \
    chmod 755 /usr/local/bin/bun && \
    ln -sf /usr/local/bin/bun /usr/local/bin/bunx && \
    rm -rf /tmp/bun.zip /tmp/bun-extract

# 4. Install Deno (Direct release)
RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
        x86_64|amd64) DENO_ARCH="x86_64" ;; \
        aarch64|arm64) DENO_ARCH="aarch64" ;; \
        *) echo "Unsupported arch for Deno: $ARCH" && exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/denoland/deno/releases/latest/download/deno-${DENO_ARCH}-unknown-linux-gnu.zip" -o /tmp/deno.zip && \
    unzip -qo /tmp/deno.zip -d /usr/local/bin && \
    chmod 755 /usr/local/bin/deno && \
    rm -f /tmp/deno.zip

# 5. Install Rust & Cargo Toolchain
RUN export RUSTUP_HOME=/opt/rustup CARGO_HOME=/opt/cargo \
    && (curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile minimal || true) \
    && chmod -R 777 /opt/cargo /opt/rustup 2>/dev/null || true

# 6. Install Python Astral uv & Composer (PHP)
RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
        x86_64|amd64) UV_ARCH="x86_64" ;; \
        aarch64|arm64) UV_ARCH="aarch64" ;; \
    esac && \
    curl -fsSL "https://github.com/astral-sh/uv/releases/latest/download/uv-${UV_ARCH}-unknown-linux-gnu.tar.gz" -o /tmp/uv.tar.gz && \
    tar -xzf /tmp/uv.tar.gz -C /tmp && \
    mv /tmp/uv-*/uv /tmp/uv-*/uvx /usr/local/bin/ && \
    chmod 755 /usr/local/bin/uv /usr/local/bin/uvx && \
    rm -rf /tmp/uv.tar.gz /tmp/uv-* && \
    (curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer || true)

# 7. Create multi-panel working directories and user compatibility
RUN groupadd -g 988 container 2>/dev/null || true \
    && useradd -d /home/container -m -u 988 -g 988 container 2>/dev/null || true \
    && mkdir -p /opt/runtimes /home/container /server /app /mnt/server \
    && chmod -R 777 /opt/runtimes /home/container /server /app /mnt/server /tmp

# 8. Copy runtime helper scripts
COPY entrypoint.sh /entrypoint.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY run.sh /run.sh
COPY run.sh /usr/local/bin/run.sh
COPY install.sh /install.sh
COPY install.sh /usr/local/bin/install.sh
COPY install-runtime.sh /usr/local/bin/install-runtime.sh

RUN sed -i 's/\r$//' /entrypoint.sh /run.sh /install.sh /usr/local/bin/*.sh \
    && chmod +x /entrypoint.sh \
                /run.sh \
                /install.sh \
                /usr/local/bin/entrypoint.sh \
                /usr/local/bin/run.sh \
                /usr/local/bin/install.sh \
                /usr/local/bin/install-runtime.sh

# 9. Path configuration
ENV PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/cargo/bin:/opt/go/bin:/opt/runtimes/bin:/home/container/.local/bin:/home/container/bin:/home/container/node_modules/.bin:${PATH}"

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

CMD ["/bin/bash", "/entrypoint.sh"]
