# =============================================================================
#  Universal Programming Language Eggs - Universal Runtime Container
#  By PotenFYR Studios (https://github.com/PotenFYR-Studios/Prog-Language-Eggs)
#
#  One Image. 50+ Programming Languages. All Package Managers & Toolchains.
#  Multi-arch support: linux/amd64 and linux/arm64
# =============================================================================

FROM ubuntu:22.04

LABEL author="PotenFYR Studios" maintainer="contact@potenfyr.com"
LABEL org.opencontainers.image.source="https://github.com/PotenFYR-Studios/Prog-Language-Eggs"
LABEL org.opencontainers.image.description="Universal Pterodactyl & Pelican egg container for 50+ programming languages"

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

# 1. Base tools, compilers, interpreters & libraries
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
        openjdk-21-jre-headless \
        golang-go \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Node.js (LTS), NPM, PNPM, Yarn, Bun, Deno, TS-Node, TSX, PM2
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g --no-fund --no-audit npm pnpm yarn typescript ts-node tsx nodemon pm2 \
    && rm -rf /var/lib/apt/lists/*

# 3. Install Bun
RUN curl -fsSL https://bun.sh/install | bash \
    && mv /root/.bun/bin/bun /usr/local/bin/bun \
    && ln -s /usr/local/bin/bun /usr/local/bin/bunx \
    && rm -rf /root/.bun

# 4. Install Deno
RUN curl -fsSL https://deno.land/install.sh | sh \
    && mv /root/.deno/bin/deno /usr/local/bin/deno \
    && rm -rf /root/.deno

# 5. Install Rust & Cargo Toolchain
RUN export RUSTUP_HOME=/opt/rustup CARGO_HOME=/opt/cargo \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile minimal \
    && chmod -R 777 /opt/cargo /opt/rustup

# 6. Install Python Astral uv (Ultra-fast package & version manager) & Composer (PHP)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && mv /root/.local/bin/uv /usr/local/bin/uv 2>/dev/null || true \
    && mv /root/.local/bin/uvx /usr/local/bin/uvx 2>/dev/null || true \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && rm -rf /root/.local

# 7. Create container user and runtime directory structure
RUN groupadd -g 988 container || true \
    && useradd -d /home/container -m -u 988 -g 988 container || true \
    && mkdir -p /opt/runtimes /home/container \
    && chmod -R 777 /opt/runtimes /home/container

# 8. Copy runtime helper scripts
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY run.sh /usr/local/bin/run.sh
COPY install.sh /usr/local/bin/install.sh
COPY install-runtime.sh /usr/local/bin/install-runtime.sh

RUN chmod +x /usr/local/bin/entrypoint.sh \
             /usr/local/bin/run.sh \
             /usr/local/bin/install.sh \
             /usr/local/bin/install-runtime.sh

# 9. Path configuration
ENV PATH="/opt/cargo/bin:/opt/go/bin:/opt/runtimes/bin:/home/container/.local/bin:/home/container/bin:/home/container/node_modules/.bin:${PATH}"

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

ENTRYPOINT ["/bin/bash", "/usr/local/bin/entrypoint.sh"]
CMD ["bash", "run.sh"]
