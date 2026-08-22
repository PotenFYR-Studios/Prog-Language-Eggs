#!/bin/bash
# =============================================================================
#  Universal Programming Language Eggs - Toolchain & Runtime Installer
#  By PotenFYR Studios (https://github.com/PotenFYR-Studios/Prog-Language-Eggs)
#
#  Usage:
#    install-runtime.sh <language> [version] [target_dir]
#
#  Examples:
#    install-runtime.sh node 20
#    install-runtime.sh bun latest
#    install-runtime.sh python 3.12
#    install-runtime.sh java 21
#    install-runtime.sh go 1.22
#    install-runtime.sh rust stable
#    install-runtime.sh dotnet 8.0
#    install-runtime.sh zig 0.13.0
#    install-runtime.sh custom https://example.com/custom-runtime.tar.gz
# =============================================================================

set -euo pipefail

# --- Visual formatting ---
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_CYAN='\033[36m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_RED='\033[31m'

log()   { printf "${C_CYAN}${C_BOLD}[potenfyr]${C_RESET} %s\n" "$*"; }
ok()    { printf "${C_GREEN}${C_BOLD}[potenfyr][✓]${C_RESET} %s\n" "$*"; }
warn()  { printf "${C_YELLOW}${C_BOLD}[potenfyr][!]${C_RESET} ${C_YELLOW}%s${C_RESET}\n" "$*"; }
fail()  { printf "${C_RED}${C_BOLD}[potenfyr][✗]${C_RESET} ${C_RED}%s${C_RESET}\n" "$*"; exit 1; }
info()  { printf "${C_BLUE}${C_BOLD}[potenfyr][i]${C_RESET} %s\n" "$*"; }

LANG_REQ="${1:-}"
VERSION_REQ="${2:-latest}"
TARGET_BASE="${3:-/opt/runtimes}"

if [ -z "${LANG_REQ}" ]; then
    fail "No language specified. Usage: install-runtime.sh <language> [version]"
fi

# Detect system architecture
ARCH=$(uname -m)
case "${ARCH}" in
    x86_64|amd64)
        ARCH_ALT="x64"
        ARCH_DEB="amd64"
        ARCH_JAVA="x64"
        ARCH_RUST="x86_64-unknown-linux-gnu"
        ARCH_GO="amd64"
        ;;
    aarch64|arm64)
        ARCH_ALT="arm64"
        ARCH_DEB="arm64"
        ARCH_JAVA="aarch64"
        ARCH_RUST="aarch64-unknown-linux-gnu"
        ARCH_GO="arm64"
        ;;
    *)
        fail "Unsupported architecture: ${ARCH}"
        ;;
esac

USER_AGENT="ProgLanguageEggs/1.0 (PotenFYR Studios; Linux ${ARCH})"

download() {
    local url="$1" dest="$2"
    if ! curl -fsSL --retry 3 --connect-timeout 20 -A "${USER_AGENT}" -o "${dest}" "${url}"; then
        rm -f "${dest}"
        fail "Failed to download from ${url}"
    fi
}

if [ ! -w "${TARGET_BASE}" ] && [ ! -w "$(dirname "${TARGET_BASE}")" ]; then
    if [ -d "/home/container" ] && [ -w "/home/container" ]; then
        TARGET_BASE="/home/container/.runtimes"
    elif [ -d "/app" ] && [ -w "/app" ]; then
        TARGET_BASE="/app/.runtimes"
    elif [ -d "/server" ] && [ -w "/server" ]; then
        TARGET_BASE="/server/.runtimes"
    else
        TARGET_BASE="/tmp/runtimes"
    fi
fi
mkdir -p "${TARGET_BASE}" 2>/dev/null || true

LANG_LOWER=$(echo "${LANG_REQ}" | tr '[:upper:]' '[:lower:]')

case "${LANG_LOWER}" in
    # -------------------------------------------------------------------------
    # Node.js / JavaScript / TypeScript
    # -------------------------------------------------------------------------
    node|nodejs|javascript|js)
        if command -v node >/dev/null 2>&1 && [ "${VERSION_REQ}" = "latest" -o "${VERSION_REQ}" = "default" -o -z "${VERSION_REQ}" ]; then
            ok "Node.js $(node -v 2>/dev/null) is already installed and ready"
            exit 0
        fi
        log "Resolving Node.js runtime (version: ${VERSION_REQ})..."
        if [ "${VERSION_REQ}" = "latest" ] || [ "${VERSION_REQ}" = "lts" ] || [ -z "${VERSION_REQ}" ]; then
            NODE_VER=$(curl -fsSL https://nodejs.org/dist/index.json 2>/dev/null | jq -r '[.[] | select(.lts != false)][0].version' || echo "v20.18.0")
        elif [[ "${VERSION_REQ}" =~ ^v?[0-9]+$ ]]; then
            MAJOR="${VERSION_REQ#v}"
            NODE_VER=$(curl -fsSL https://nodejs.org/dist/index.json 2>/dev/null | jq -r --arg m "v${MAJOR}." '[.[] | select(.version | startswith($m))][0].version' || echo "v${MAJOR}.0.0")
        else
            [[ "${VERSION_REQ}" =~ ^v ]] && NODE_VER="${VERSION_REQ}" || NODE_VER="v${VERSION_REQ}"
        fi
        
        DEST_DIR="${TARGET_BASE}/node-${NODE_VER}"
        if [ -x "${DEST_DIR}/bin/node" ]; then
            ok "Node.js ${NODE_VER} is already installed at ${DEST_DIR}"
        else
            log "Downloading Node.js ${NODE_VER} for ${ARCH_ALT}..."
            TAR_URL="https://nodejs.org/dist/${NODE_VER}/node-${NODE_VER}-linux-${ARCH_ALT}.tar.xz"
            TMP_TAR="/tmp/node.tar.xz"
            download "${TAR_URL}" "${TMP_TAR}"
            mkdir -p "${DEST_DIR}"
            tar -xJf "${TMP_TAR}" --strip-components=1 -C "${DEST_DIR}"
            rm -f "${TMP_TAR}"
            ok "Installed Node.js ${NODE_VER} to ${DEST_DIR}"
        fi
        
        export PATH="${DEST_DIR}/bin:${PATH}"
        npm install -g --no-fund --no-audit npm pnpm yarn typescript ts-node tsx nodemon pm2 2>/dev/null || true
        ;;

    # -------------------------------------------------------------------------
    # Bun
    # -------------------------------------------------------------------------
    bun)
        log "Resolving Bun runtime..."
        DEST_DIR="${TARGET_BASE}/bun"
        mkdir -p "${DEST_DIR}/bin"
        if [ "${ARCH_ALT}" = "x64" ]; then
            BUN_ARCH="x64"
        else
            BUN_ARCH="aarch64"
        fi
        BUN_URL="https://github.com/oven-sh/bun/releases/latest/download/bun-linux-${BUN_ARCH}.zip"
        TMP_ZIP="/tmp/bun.zip"
        download "${BUN_URL}" "${TMP_ZIP}"
        unzip -qo "${TMP_ZIP}" -d /tmp/bun-extract
        mv /tmp/bun-extract/bun-linux-*/bun "${DEST_DIR}/bin/bun"
        chmod +x "${DEST_DIR}/bin/bun"
        ln -sf "${DEST_DIR}/bin/bun" "${DEST_DIR}/bin/bunx"
        rm -rf "${TMP_ZIP}" /tmp/bun-extract
        ok "Installed Bun to ${DEST_DIR}/bin/bun"
        ;;

    # -------------------------------------------------------------------------
    # Deno
    # -------------------------------------------------------------------------
    deno)
        log "Resolving Deno runtime..."
        DEST_DIR="${TARGET_BASE}/deno"
        mkdir -p "${DEST_DIR}/bin"
        DENO_ARCH="${ARCH}"
        [ "${DENO_ARCH}" = "arm64" ] && DENO_ARCH="aarch64"
        DENO_URL="https://github.com/denoland/deno/releases/latest/download/deno-${DENO_ARCH}-unknown-linux-gnu.zip"
        TMP_ZIP="/tmp/deno.zip"
        download "${DENO_URL}" "${TMP_ZIP}"
        unzip -qo "${TMP_ZIP}" -d "${DEST_DIR}/bin"
        chmod +x "${DEST_DIR}/bin/deno"
        rm -f "${TMP_ZIP}"
        ok "Installed Deno to ${DEST_DIR}/bin/deno"
        ;;

    # -------------------------------------------------------------------------
    # Python & Package Managers (pip, poetry, uv, pipenv)
    # -------------------------------------------------------------------------
    python|python3|py)
        log "Setting up Python environment and tools (uv, poetry, pipenv)..."
        DEST_DIR="${TARGET_BASE}/python"
        mkdir -p "${DEST_DIR}/bin"
        
        # Install Astral uv (ultra-fast Python package & version manager)
        UV_ARCH="${ARCH}"
        [ "${UV_ARCH}" = "arm64" ] && UV_ARCH="aarch64"
        UV_URL="https://github.com/astral-sh/uv/releases/latest/download/uv-${UV_ARCH}-unknown-linux-gnu.tar.gz"
        TMP_TAR="/tmp/uv.tar.gz"
        if curl -fsSL -o "${TMP_TAR}" "${UV_URL}"; then
            tar -xzf "${TMP_TAR}" -C /tmp
            mv /tmp/uv-*/uv /tmp/uv-*/uvx "${DEST_DIR}/bin/" 2>/dev/null || true
            chmod +x "${DEST_DIR}/bin/uv" "${DEST_DIR}/bin/uvx" 2>/dev/null || true
            rm -rf "${TMP_TAR}" /tmp/uv-*
            ok "Installed uv & uvx toolchain"
        fi
        ;;

    # -------------------------------------------------------------------------
    # Java (Adoptium Temurin OpenJDK 8, 11, 17, 21, 25, 26+)
    # -------------------------------------------------------------------------
    java|jdk|openjdk)
        JV="${VERSION_REQ}"
        [ "${JV}" = "latest" ] && JV="21"
        JV="${JV#java}"
        JV="${JV#jdk}"
        
        DEST_DIR="${TARGET_BASE}/java-${JV}"
        if [ -x "${DEST_DIR}/bin/java" ]; then
            ok "Java ${JV} already installed at ${DEST_DIR}"
        else
            log "Downloading Adoptium OpenJDK ${JV} for ${ARCH_JAVA}..."
            API_URL="https://api.adoptium.net/v3/binary/latest/${JV}/ga/linux/${ARCH_JAVA}/jdk/hotspot/normal/eclipse?project=jdk"
            TMP_TAR="/tmp/jdk${JV}.tar.gz"
            download "${API_URL}" "${TMP_TAR}"
            mkdir -p "${DEST_DIR}"
            tar -xzf "${TMP_TAR}" --strip-components=1 -C "${DEST_DIR}"
            rm -f "${TMP_TAR}"
            ok "Installed Adoptium OpenJDK ${JV} to ${DEST_DIR}"
        fi
        ;;

    # -------------------------------------------------------------------------
    # Go (Golang)
    # -------------------------------------------------------------------------
    go|golang)
        log "Resolving Go toolchain (version: ${VERSION_REQ})..."
        if [ "${VERSION_REQ}" = "latest" ] || [ -z "${VERSION_REQ}" ]; then
            GO_VER=$(curl -fsSL 'https://go.dev/dl/?mode=json' | jq -r '.[0].version')
        else
            [[ "${VERSION_REQ}" =~ ^go ]] && GO_VER="${VERSION_REQ}" || GO_VER="go${VERSION_REQ}"
        fi
        
        DEST_DIR="${TARGET_BASE}/${GO_VER}"
        if [ -x "${DEST_DIR}/bin/go" ]; then
            ok "Go ${GO_VER} already installed at ${DEST_DIR}"
        else
            GO_URL="https://go.dev/dl/${GO_VER}.linux-${ARCH_GO}.tar.gz"
            TMP_TAR="/tmp/go.tar.gz"
            download "${GO_URL}" "${TMP_TAR}"
            mkdir -p "${DEST_DIR}"
            tar -xzf "${TMP_TAR}" --strip-components=1 -C "${DEST_DIR}"
            rm -f "${TMP_TAR}"
            ok "Installed ${GO_VER} to ${DEST_DIR}"
        fi
        ;;

    # -------------------------------------------------------------------------
    # Rust & Cargo
    # -------------------------------------------------------------------------
    rust|cargo|rustc)
        log "Setting up Rust toolchain via rustup..."
        export RUSTUP_HOME="${TARGET_BASE}/rustup"
        export CARGO_HOME="${TARGET_BASE}/cargo"
        mkdir -p "${RUSTUP_HOME}" "${CARGO_HOME}"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --no-modify-path
        ok "Rust & Cargo toolchain ready at ${CARGO_HOME}/bin"
        ;;

    # -------------------------------------------------------------------------
    # Zig
    # -------------------------------------------------------------------------
    zig)
        log "Resolving Zig compiler (version: ${VERSION_REQ})..."
        ZIG_ARCH="${ARCH}"
        [ "${ZIG_ARCH}" = "arm64" ] && ZIG_ARCH="aarch64"
        if [ "${VERSION_REQ}" = "latest" ] || [ -z "${VERSION_REQ}" ]; then
            ZIG_URL=$(curl -fsSL https://ziglang.org/download/index.json | jq -r ".master.\"${ZIG_ARCH}-linux\".tarball")
        else
            ZIG_URL=$(curl -fsSL https://ziglang.org/download/index.json | jq -r ".\"${VERSION_REQ}\".\"${ZIG_ARCH}-linux\".tarball")
        fi
        
        DEST_DIR="${TARGET_BASE}/zig"
        TMP_TAR="/tmp/zig.tar.xz"
        download "${ZIG_URL}" "${TMP_TAR}"
        mkdir -p "${DEST_DIR}"
        tar -xJf "${TMP_TAR}" --strip-components=1 -C "${DEST_DIR}"
        rm -f "${TMP_TAR}"
        ok "Installed Zig to ${DEST_DIR}/zig"
        ;;

    # -------------------------------------------------------------------------
    # .NET SDK (C#, F#, VB.NET)
    # -------------------------------------------------------------------------
    dotnet|csharp|fsharp|vb)
        log "Setting up .NET SDK (${VERSION_REQ})..."
        DEST_DIR="${TARGET_BASE}/dotnet"
        mkdir -p "${DEST_DIR}"
        TMP_SH="/tmp/dotnet-install.sh"
        download "https://dot.net/v1/dotnet-install.sh" "${TMP_SH}"
        chmod +x "${TMP_SH}"
        DOTNET_CHANNEL="8.0"
        [ "${VERSION_REQ}" != "latest" ] && DOTNET_CHANNEL="${VERSION_REQ}"
        bash "${TMP_SH}" --channel "${DOTNET_CHANNEL}" --install-dir "${DEST_DIR}" --no-path
        rm -f "${TMP_SH}"
        ok "Installed .NET SDK to ${DEST_DIR}/dotnet"
        ;;

    # -------------------------------------------------------------------------
    # Swift
    # -------------------------------------------------------------------------
    swift)
        log "Resolving Swift toolchain..."
        DEST_DIR="${TARGET_BASE}/swift"
        SWIFT_VER="5.10.1"
        SWIFT_ARCH="${ARCH}"
        [ "${SWIFT_ARCH}" = "arm64" ] && SWIFT_ARCH="aarch64"
        SWIFT_URL="https://download.swift.org/swift-${SWIFT_VER}-release/ubuntu2204/swift-${SWIFT_VER}-RELEASE/swift-${SWIFT_VER}-RELEASE-ubuntu22.04-${SWIFT_ARCH}.tar.gz"
        TMP_TAR="/tmp/swift.tar.gz"
        if curl -fsSL -o "${TMP_TAR}" "${SWIFT_URL}"; then
            mkdir -p "${DEST_DIR}"
            tar -xzf "${TMP_TAR}" --strip-components=1 -C "${DEST_DIR}"
            rm -f "${TMP_TAR}"
            ok "Installed Swift to ${DEST_DIR}"
        else
            warn "Could not download official Swift tarball directly for this target."
        fi
        ;;

    # -------------------------------------------------------------------------
    # Julia
    # -------------------------------------------------------------------------
    julia)
        log "Resolving Julia runtime..."
        DEST_DIR="${TARGET_BASE}/julia"
        JULIA_ARCH="${ARCH}"
        [ "${JULIA_ARCH}" = "arm64" ] && JULIA_ARCH="aarch64"
        JULIA_URL="https://julialang-s3.julialang.org/bin/linux/${JULIA_ARCH}/1.10/julia-1.10.4-linux-${JULIA_ARCH}.tar.gz"
        TMP_TAR="/tmp/julia.tar.gz"
        download "${JULIA_URL}" "${TMP_TAR}"
        mkdir -p "${DEST_DIR}"
        tar -xzf "${TMP_TAR}" --strip-components=1 -C "${DEST_DIR}"
        rm -f "${TMP_TAR}"
        ok "Installed Julia to ${DEST_DIR}"
        ;;

    # -------------------------------------------------------------------------
    # Dart
    # -------------------------------------------------------------------------
    dart)
        log "Resolving Dart SDK..."
        DEST_DIR="${TARGET_BASE}/dart-sdk"
        DART_ARCH="${ARCH}"
        [ "${DART_ARCH}" = "amd64" ] || [ "${DART_ARCH}" = "x86_64" ] && DART_ARCH="x64"
        DART_URL="https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-linux-${DART_ARCH}-release.zip"
        TMP_ZIP="/tmp/dart.zip"
        download "${DART_URL}" "${TMP_ZIP}"
        unzip -qo "${TMP_ZIP}" -d "${TARGET_BASE}"
        rm -f "${TMP_ZIP}"
        ok "Installed Dart SDK to ${DEST_DIR}"
        ;;

    # -------------------------------------------------------------------------
    # Odin
    # -------------------------------------------------------------------------
    odin)
        log "Resolving Odin programming language..."
        DEST_DIR="${TARGET_BASE}/odin"
        mkdir -p "${DEST_DIR}"
        ODIN_URL="https://github.com/odin-lang/Odin/releases/latest/download/odin-linux-amd64.tar.gz"
        if [ "${ARCH_DEB}" = "amd64" ]; then
            TMP_TAR="/tmp/odin.tar.gz"
            download "${ODIN_URL}" "${TMP_TAR}"
            tar -xzf "${TMP_TAR}" -C "${DEST_DIR}"
            rm -f "${TMP_TAR}"
            ok "Installed Odin to ${DEST_DIR}"
        fi
        ;;

    # -------------------------------------------------------------------------
    # Gleam
    # -------------------------------------------------------------------------
    gleam)
        log "Resolving Gleam compiler..."
        DEST_DIR="${TARGET_BASE}/gleam/bin"
        mkdir -p "${DEST_DIR}"
        GLEAM_ARCH="${ARCH_RUST}"
        GLEAM_URL="https://github.com/gleam-lang/gleam/releases/latest/download/gleam-v1.4.1-${GLEAM_ARCH}.tar.gz"
        TMP_TAR="/tmp/gleam.tar.gz"
        if curl -fsSL -o "${TMP_TAR}" "${GLEAM_URL}"; then
            tar -xzf "${TMP_TAR}" -C "${DEST_DIR}"
            chmod +x "${DEST_DIR}/gleam"
            rm -f "${TMP_TAR}"
            ok "Installed Gleam to ${DEST_DIR}/gleam"
        fi
        ;;

    # -------------------------------------------------------------------------
    # Nim
    # -------------------------------------------------------------------------
    nim)
        log "Setting up Nim..."
        DEST_DIR="${TARGET_BASE}/nim"
        NIM_ARCH="${ARCH_ALT}"
        NIM_URL="https://nim-lang.org/download/nim-2.0.8-linux_${NIM_ARCH}.tar.xz"
        TMP_TAR="/tmp/nim.tar.xz"
        if curl -fsSL -o "${TMP_TAR}" "${NIM_URL}"; then
            mkdir -p "${DEST_DIR}"
            tar -xJf "${TMP_TAR}" --strip-components=1 -C "${DEST_DIR}"
            rm -f "${TMP_TAR}"
            ok "Installed Nim to ${DEST_DIR}"
        fi
        ;;

    # -------------------------------------------------------------------------
    # Custom Download URL
    # -------------------------------------------------------------------------
    custom)
        [ -n "${VERSION_REQ}" ] || fail "Custom runtime requires a URL as the second parameter"
        log "Downloading custom runtime archive from ${VERSION_REQ}..."
        DEST_DIR="${TARGET_BASE}/custom"
        mkdir -p "${DEST_DIR}"
        TMP_ARCHIVE="/tmp/custom-runtime"
        download "${VERSION_REQ}" "${TMP_ARCHIVE}"
        case "${VERSION_REQ}" in
            *.tar.gz|*.tgz)
                tar -xzf "${TMP_ARCHIVE}" -C "${DEST_DIR}"
                ;;
            *.tar.xz)
                tar -xJf "${TMP_ARCHIVE}" -C "${DEST_DIR}"
                ;;
            *.zip)
                unzip -qo "${TMP_ARCHIVE}" -d "${DEST_DIR}"
                ;;
            *)
                mv "${TMP_ARCHIVE}" "${DEST_DIR}/custom-binary"
                chmod +x "${DEST_DIR}/custom-binary"
                ;;
        esac
        chmod -R +x "${DEST_DIR}" 2>/dev/null || true
        for bin in "${DEST_DIR}"/*; do
            [ -f "${bin}" ] && [ -x "${bin}" ] && ln -sf "${bin}" "/usr/local/bin/$(basename "${bin}")" 2>/dev/null || true
        done
        rm -f "${TMP_ARCHIVE}"
        ok "Custom runtime installed to ${DEST_DIR} and linked to PATH"
        ;;

    *)
        log "Language '${LANG_REQ}' relies on pre-installed system packages or custom setup."
        ;;
esac
