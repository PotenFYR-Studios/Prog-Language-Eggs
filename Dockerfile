# =============================================================================
#  Universal Programming Language Eggs - Multi-Variant Container Architecture
#  By PotenFYR Studios (https://github.com/PotenFYR-Studios/Prog-Language-Eggs)
#
#  Variant Images:
#    - latest (All-in-One Multi-Language Environment)
#    - bun (Lean Bun Runtime + Companion Support)
#    - nodejs (Lean Node.js LTS + NPM/PNPM/Yarn + Companion Support)
#    - python (Lean Python 3 + Astral uv + Companion Support)
#    - golang (Lean Go Toolchain + Companion Support)
#    - rust (Lean Rustc & Cargo + Companion Support)
#    - php (Lean PHP CLI & Composer + Companion Support)
#    - ruby (Lean Ruby & Bundler + Companion Support)
#    - java (Lean Temurin OpenJDK + Companion Support)
#    - dotnet (Lean .NET SDK/Runtime + Companion Support)
#    - c-cpp (Lean GCC, Clang, Make, CMake + Companion Support)
# =============================================================================

FROM ubuntu:22.04

LABEL author="PotenFYR Studios" maintainer="support@potenfyr.in"
LABEL org.opencontainers.image.source="https://github.com/potenfyr-studios/prog-language-eggs"
LABEL org.opencontainers.image.description="Multi-variant isolated runtime container across Pterodactyl, Pelican, Feather Panel, and PufferPanel"

ARG RUNTIME_VARIANT=all
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    USER=container \
    HOME=/home/container \
    DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    PYTHONUNBUFFERED=1 \
    GOPATH=/home/container/go \
    CARGO_HOME=/home/container/.cargo \
    RUSTUP_HOME=/opt/rustup \
    IMAGE_VARIANT=${RUNTIME_VARIANT}

# 1. Base tools, networking, archive utilities & shared dependencies
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
        iproute2 \
        tzdata \
        locales \
        procps \
        dnsutils \
        libssl-dev \
        zlib1g-dev \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

# 2. Compilers & Build Tools (Included in all, c-cpp, rust, golang, nodejs)
RUN if [ "${RUNTIME_VARIANT}" = "all" ] || [ "${RUNTIME_VARIANT}" = "c-cpp" ] || [ "${RUNTIME_VARIANT}" = "rust" ] || [ "${RUNTIME_VARIANT}" = "golang" ] || [ "${RUNTIME_VARIANT}" = "nodejs" ]; then \
        apt-get update && apt-get install -y --no-install-recommends \
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
        && rm -rf /var/lib/apt/lists/*; \
    fi

# 3. Node.js & Tooling (Included in all, nodejs)
RUN if [ "${RUNTIME_VARIANT}" = "all" ] || [ "${RUNTIME_VARIANT}" = "nodejs" ]; then \
        curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
        && apt-get install -y --no-install-recommends nodejs \
        && npm install -g --no-fund --no-audit npm pnpm yarn typescript ts-node tsx nodemon pm2 \
        && mkdir -p /opt/runtimes/node/bin \
        && ln -sf /usr/bin/node /opt/runtimes/node/bin/node 2>/dev/null || true \
        && rm -rf /var/lib/apt/lists/*; \
    fi

# 4. Bun (Included in all, bun)
RUN if [ "${RUNTIME_VARIANT}" = "all" ] || [ "${RUNTIME_VARIANT}" = "bun" ]; then \
        ARCH=$(uname -m) && \
        case "$ARCH" in \
            x86_64|amd64) BUN_ARCH="x64" ;; \
            aarch64|arm64) BUN_ARCH="aarch64" ;; \
            *) echo "Unsupported arch for Bun: $ARCH" && exit 1 ;; \
        esac && \
        curl -fsSL "https://github.com/oven-sh/bun/releases/latest/download/bun-linux-${BUN_ARCH}.zip" -o /tmp/bun.zip && \
        unzip -qo /tmp/bun.zip -d /tmp/bun-extract && \
        mkdir -p /opt/runtimes/bun/bin && \
        mv /tmp/bun-extract/bun-linux-*/bun /opt/runtimes/bun/bin/bun && \
        chmod -R 755 /opt/runtimes/bun && \
        ln -sf /opt/runtimes/bun/bin/bun /opt/runtimes/bun/bin/bunx && \
        ln -sf /opt/runtimes/bun/bin/bun /usr/local/bin/bun && \
        ln -sf /opt/runtimes/bun/bin/bunx /usr/local/bin/bunx && \
        rm -rf /tmp/bun.zip /tmp/bun-extract; \
    fi

# 5. Deno (Included in all)
RUN if [ "${RUNTIME_VARIANT}" = "all" ]; then \
        ARCH=$(uname -m) && \
        case "$ARCH" in \
            x86_64|amd64) DENO_ARCH="x86_64" ;; \
            aarch64|arm64) DENO_ARCH="aarch64" ;; \
            *) echo "Unsupported arch for Deno: $ARCH" && exit 1 ;; \
        esac && \
        curl -fsSL "https://github.com/denoland/deno/releases/latest/download/deno-${DENO_ARCH}-unknown-linux-gnu.zip" -o /tmp/deno.zip && \
        mkdir -p /opt/runtimes/deno/bin && \
        unzip -qo /tmp/deno.zip -d /opt/runtimes/deno/bin && \
        chmod -R 755 /opt/runtimes/deno && \
        ln -sf /opt/runtimes/deno/bin/deno /usr/local/bin/deno && \
        rm -f /tmp/deno.zip; \
    fi

# 6. Python & Astral uv (Included in all, python, nodejs)
RUN if [ "${RUNTIME_VARIANT}" = "all" ] || [ "${RUNTIME_VARIANT}" = "python" ] || [ "${RUNTIME_VARIANT}" = "nodejs" ]; then \
        apt-get update && apt-get install -y --no-install-recommends \
            python3 \
            python3-pip \
            python3-venv \
            python3-dev \
        && rm -rf /var/lib/apt/lists/* && \
        ARCH=$(uname -m) && \
        case "$ARCH" in \
            x86_64|amd64) UV_ARCH="x86_64" ;; \
            aarch64|arm64) UV_ARCH="aarch64" ;; \
        esac && \
        curl -fsSL "https://github.com/astral-sh/uv/releases/latest/download/uv-${UV_ARCH}-unknown-linux-gnu.tar.gz" -o /tmp/uv.tar.gz && \
        tar -xzf /tmp/uv.tar.gz -C /tmp && \
        mkdir -p /opt/runtimes/uv/bin && \
        mv /tmp/uv-*/uv /tmp/uv-*/uvx /opt/runtimes/uv/bin/ && \
        chmod -R 755 /opt/runtimes/uv && \
        ln -sf /opt/runtimes/uv/bin/uv /usr/local/bin/uv && \
        ln -sf /opt/runtimes/uv/bin/uvx /usr/local/bin/uvx && \
        rm -rf /tmp/uv.tar.gz /tmp/uv-*; \
    fi

# 7. Golang (Included in all, golang)
RUN if [ "${RUNTIME_VARIANT}" = "all" ] || [ "${RUNTIME_VARIANT}" = "golang" ]; then \
        apt-get update && apt-get install -y --no-install-recommends golang-go \
        && mkdir -p /opt/runtimes/go/bin \
        && ln -sf /usr/bin/go /opt/runtimes/go/bin/go 2>/dev/null || true \
        && rm -rf /var/lib/apt/lists/*; \
    fi

# 8. Rust & Cargo (Included in all, rust)
RUN if [ "${RUNTIME_VARIANT}" = "all" ] || [ "${RUNTIME_VARIANT}" = "rust" ]; then \
        export RUSTUP_HOME=/opt/rustup CARGO_HOME=/opt/cargo && \
        (curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile minimal || true) && \
        chmod -R 777 /opt/cargo /opt/rustup 2>/dev/null || true; \
    fi

# 9. PHP & Composer (Included in all, php)
RUN if [ "${RUNTIME_VARIANT}" = "all" ] || [ "${RUNTIME_VARIANT}" = "php" ]; then \
        apt-get update && apt-get install -y --no-install-recommends \
            php-cli \
            php-curl \
            php-mbstring \
            php-xml \
            php-zip \
            php-bcmath \
        && rm -rf /var/lib/apt/lists/* && \
        (curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer || true); \
    fi

# 10. Ruby & Bundler (Included in all, ruby)
RUN if [ "${RUNTIME_VARIANT}" = "all" ] || [ "${RUNTIME_VARIANT}" = "ruby" ]; then \
        apt-get update && apt-get install -y --no-install-recommends ruby ruby-dev \
        && gem install bundler --no-document 2>/dev/null || true \
        && rm -rf /var/lib/apt/lists/*; \
    fi

# 11. Java OpenJDK (Included in all, java)
RUN if [ "${RUNTIME_VARIANT}" = "all" ] || [ "${RUNTIME_VARIANT}" = "java" ]; then \
        apt-get update && apt-get install -y --no-install-recommends \
            default-jdk-headless \
            default-jre-headless \
            maven \
        && rm -rf /var/lib/apt/lists/*; \
    fi

# 12. .NET SDK & ASP.NET Core Runtime (Included in all, dotnet)
RUN if [ "${RUNTIME_VARIANT}" = "all" ] || [ "${RUNTIME_VARIANT}" = "dotnet" ]; then \
        apt-get update && apt-get install -y --no-install-recommends \
            dotnet-sdk-8.0 \
            aspnetcore-runtime-8.0 \
        || ( \
            wget -q https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O /tmp/packages-microsoft-prod.deb \
            && dpkg -i /tmp/packages-microsoft-prod.deb \
            && rm -f /tmp/packages-microsoft-prod.deb \
            && apt-get update && apt-get install -y --no-install-recommends dotnet-sdk-8.0 aspnetcore-runtime-8.0 \
        ) \
        && rm -rf /var/lib/apt/lists/*; \
    fi

# 13. Interpreted Languages (Lua, Perl, Tcl, Prolog - in all)
RUN if [ "${RUNTIME_VARIANT}" = "all" ]; then \
        apt-get update && apt-get install -y --no-install-recommends \
            lua5.4 \
            luajit \
            perl \
            tcl \
            swi-prolog \
        && rm -rf /var/lib/apt/lists/*; \
    fi

# 14. Create multi-panel working directories and non-root container user
RUN groupadd -g 988 container 2>/dev/null || true \
    && useradd -d /home/container -m -u 988 -g 988 container 2>/dev/null || true \
    && mkdir -p /opt/runtimes /home/container /server /app /mnt/server \
    && chmod -R 777 /opt/runtimes /home/container /server /app /mnt/server /tmp

# 14. Copy runtime orchestration & installation scripts
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

# 15. Base Path configuration
ENV PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/cargo/bin:/opt/go/bin:/opt/runtimes/bin:/home/container/.local/bin:/home/container/bin:/home/container/node_modules/.bin:${PATH}"

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

CMD ["/bin/bash", "/entrypoint.sh"]