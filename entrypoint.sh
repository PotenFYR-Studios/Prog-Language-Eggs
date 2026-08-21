#!/bin/bash
# =============================================================================
#  Universal Programming Language Eggs - Container Entrypoint
#  By PotenFYR Studios (https://github.com/PotenFYR-Studios/Prog-Language-Eggs)
#
#  Universal Panel Support:
#    - Pterodactyl Panel (Wings Daemon)
#    - Pelican Panel (Pelican Wings)
#    - Feather Panel (feather-panel / renoki-co)
#    - PufferPanel
#    - Jexactyl / Wisp (Pterodactyl forks)
#    - Standalone Docker & Kubernetes (Helm / Pods)
# =============================================================================

set -uo pipefail

# --- Color Definitions ---
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_CYAN='\033[36m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_RED='\033[31m'
C_MAGENTA='\033[35m'
C_BLUE='\033[34m'
C_DIM='\033[2m'

log()   { printf "${C_CYAN}${C_BOLD}prog-egg@universal~${C_RESET} ${C_BOLD}%s${C_RESET}\n" "$*"; }
warn()  { printf "${C_YELLOW}${C_BOLD}prog-egg@universal~${C_RESET} ${C_YELLOW}${C_BOLD}[warn]${C_RESET} %s\n" "$*"; }
error() { printf "${C_RED}${C_BOLD}prog-egg@universal~${C_RESET} ${C_RED}${C_BOLD}[error]${C_RESET} %s\n" "$*"; }
ok()    { printf "${C_GREEN}${C_BOLD}prog-egg@universal~${C_RESET} ${C_GREEN}${C_BOLD}[ok]${C_RESET} %s\n" "$*"; }

# -----------------------------------------------------------------------------
# 1. Universal Working Directory Resolution
# -----------------------------------------------------------------------------
if [ -n "${WORK_DIR:-}" ] && [ -d "${WORK_DIR}" ]; then
    ACTIVE_WORK_DIR="${WORK_DIR}"
elif [ -n "${P_SERVER_UUID:-}" ] && [ -d "/home/container" ]; then
    ACTIVE_WORK_DIR="/home/container"
elif [ -n "${FEATHER_SERVER_ID:-}" ] && [ -d "/app" ]; then
    ACTIVE_WORK_DIR="/app"
elif [ -n "${PUFFER_PORT:-}" ] && [ -d "/server" ]; then
    ACTIVE_WORK_DIR="/server"
elif [ -d "/home/container" ] && [ "$(pwd)" = "/home/container" -o "$(pwd)" = "/" ]; then
    ACTIVE_WORK_DIR="/home/container"
elif [ -d "/app" ] && [ "$(pwd)" = "/app" ]; then
    ACTIVE_WORK_DIR="/app"
elif [ -d "/server" ] && [ "$(pwd)" = "/server" ]; then
    ACTIVE_WORK_DIR="/server"
else
    ACTIVE_WORK_DIR="${PWD}"
fi

export WORK_DIR="${ACTIVE_WORK_DIR}"
cd "${ACTIVE_WORK_DIR}" 2>/dev/null || { error "Cannot enter working directory: ${ACTIVE_WORK_DIR}"; exit 1; }

# -----------------------------------------------------------------------------
# 2. Universal Port & Host Resolution
# -----------------------------------------------------------------------------
ACTIVE_PORT="${SERVER_PORT:-${PORT:-${FEATHER_PORT:-${PUFFER_PORT:-${ALLOCATED_PORT:-${HTTP_PORT:-8080}}}}}}"
export PORT="${ACTIVE_PORT}"
export SERVER_PORT="${ACTIVE_PORT}"
export FEATHER_PORT="${ACTIVE_PORT}"
export PUFFER_PORT="${ACTIVE_PORT}"
export APP_PORT="${ACTIVE_PORT}"
export HTTP_PORT="${ACTIVE_PORT}"
export HOST="0.0.0.0"
export BIND_ADDRESS="0.0.0.0"

# -----------------------------------------------------------------------------
# 3. Detect Host Panel Environment
# -----------------------------------------------------------------------------
PANEL_TYPE="Docker / Standalone"
if [ -n "${P_SERVER_UUID:-}" ] || [ -d "/home/container" -a -f "/entrypoint.sh" ]; then
    PANEL_TYPE="Pterodactyl / Pelican"
elif [ -n "${FEATHER_PORT:-}" ] || [ -n "${FEATHER_SERVER_ID:-}" ]; then
    PANEL_TYPE="Feather Panel"
elif [ -n "${PUFFER_PORT:-}" ] || [ -d "/server" -a "${ACTIVE_WORK_DIR}" = "/server" ]; then
    PANEL_TYPE="PufferPanel"
elif [ -n "${KUBERNETES_SERVICE_HOST:-}" ]; then
    PANEL_TYPE="Kubernetes"
fi

# -----------------------------------------------------------------------------
# 4. Persisted Settings (.multi-prog.conf)
# -----------------------------------------------------------------------------
CONF_FILE="${ACTIVE_WORK_DIR}/.multi-prog.conf"

read_conf() {
    [ -f "${CONF_FILE}" ] || return 1
    local val
    val=$(grep -E "^$1=" "${CONF_FILE}" 2>/dev/null | tail -n1 | cut -d= -f2-)
    [ -n "${val}" ] || return 1
    printf '%s' "${val}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
}

apply_conf() {
    local key="$1" val
    val=$(read_conf "${key}") || return 0
    if [ -z "${!key-}" ]; then
        printf -v "${key}" '%s' "${val}"
        export "${key}"
    fi
}

TZ=${TZ:-UTC}
export TZ

INTERNAL_IP=$(ip route get 1 2>/dev/null | awk '{print $(NF-2);exit}' || echo "127.0.0.1")
export INTERNAL_IP

for _key in LANGUAGE RUNNER MAIN_FILE PACKAGE_MANAGER BUILD_COMMAND \
            AUTO_INSTALL_DEPS AUTO_RESTART GIT_REPO GIT_BRANCH \
            GIT_AUTH_TOKEN CUSTOM_COMMAND EXTRA_ARGS DEBUG RUNTIME_VERSION \
            STARTER_TEMPLATE SERVER_PORT MEMORY_AUTO_TUNE DEV_MODE \
            PRE_RUN_COMMAND POST_RUN_COMMAND CLEAN_BUILD_CACHE AUTO_ENV_INJECT; do
    apply_conf "${_key}"
done
unset _key

# -----------------------------------------------------------------------------
# 5. System PATH Configuration
# -----------------------------------------------------------------------------
export PATH="${ACTIVE_WORK_DIR}/.local/bin:${ACTIVE_WORK_DIR}/bin:${ACTIVE_WORK_DIR}/node_modules/.bin:${PATH}"
export PATH="/opt/runtimes/bin:/opt/runtimes/bun/bin:/opt/runtimes/deno/bin:/opt/runtimes/python/bin:/opt/runtimes/zig:/opt/runtimes/dart-sdk/bin:/opt/runtimes/nim/bin:/opt/runtimes/gleam/bin:/opt/runtimes/odin:${PATH}"
export PATH="/root/.cargo/bin:/opt/cargo/bin:${ACTIVE_WORK_DIR}/.cargo/bin:${PATH}"
export PATH="/opt/go/bin:${ACTIVE_WORK_DIR}/go/bin:${PATH}"
export PATH="/opt/dotnet:${ACTIVE_WORK_DIR}/.dotnet:${PATH}"

for _dir in /opt/runtimes/node-*/bin /opt/runtimes/java-*/bin; do
    [ -d "${_dir}" ] && export PATH="${_dir}:${PATH}"
done
unset _dir

export GOPATH="${GOPATH:-${ACTIVE_WORK_DIR}/go}"
export CARGO_HOME="${CARGO_HOME:-${ACTIVE_WORK_DIR}/.cargo}"
export RUSTUP_HOME="${RUSTUP_HOME:-/opt/rustup}"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export PYTHONUNBUFFERED=1

# -----------------------------------------------------------------------------
# 6. Automatic Memory Tuning & OOM Protection Engine
# -----------------------------------------------------------------------------
MEMORY_AUTO_TUNE="${MEMORY_AUTO_TUNE:-1}"
TOTAL_MEM_MB="${SERVER_MEMORY:-${MEMORY:-${FEATHER_MEMORY:-${MAX_RAM:-0}}}}"

if [ "${TOTAL_MEM_MB}" -le 0 ]; then
    if [ -f /sys/fs/cgroup/memory/memory.limit_in_bytes ]; then
        CG_BYTES=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes 2>/dev/null || echo "0")
        if [ "${CG_BYTES}" -gt 0 ] && [ "${CG_BYTES}" -lt 9223372036854771712 ]; then
            TOTAL_MEM_MB=$((CG_BYTES / 1024 / 1024))
        fi
    elif [ -f /sys/fs/cgroup/memory.max ]; then
        CG_MAX=$(cat /sys/fs/cgroup/memory.max 2>/dev/null || echo "max")
        if [ "${CG_MAX}" != "max" ] && [ "${CG_MAX}" -gt 0 ]; then
            TOTAL_MEM_MB=$((CG_MAX / 1024 / 1024))
        fi
    fi
fi

SAFE_MEM_MB=0
if [ "${TOTAL_MEM_MB}" -gt 0 ]; then
    SAFE_MEM_MB=$((TOTAL_MEM_MB * 85 / 100))
fi

AUTO_TUNE_INFO="Default"
if [ "${MEMORY_AUTO_TUNE}" = "1" ] && [ "${SAFE_MEM_MB}" -gt 128 ]; then
    AUTO_TUNE_INFO="${SAFE_MEM_MB}MB (85% of ${TOTAL_MEM_MB}MB Limit)"

    if [[ " ${NODE_OPTIONS:-} " != *"--max-old-space-size"* ]]; then
        export NODE_OPTIONS="--max-old-space-size=${SAFE_MEM_MB} ${NODE_OPTIONS:-}"
    fi

    export GOMEMLIMIT="${SAFE_MEM_MB}MiB"

    export JAVA_AUTO_MEM_FLAGS="-Xmx${SAFE_MEM_MB}M -Xms$((SAFE_MEM_MB / 4))M"
    if [ "${SAFE_MEM_MB}" -ge 4096 ]; then
        export JAVA_AUTO_GC="-XX:+UseZGC"
    elif [ "${SAFE_MEM_MB}" -ge 1024 ]; then
        export JAVA_AUTO_GC="-XX:+UseG1GC"
    else
        export JAVA_AUTO_GC="-XX:+UseSerialGC"
    fi

    export MALLOC_TRIM_THRESHOLD_=100000
    export DOTNET_GCHeapHardLimit="0x$(printf '%X\n' $((SAFE_MEM_MB * 1024 * 1024)))"
fi

# -----------------------------------------------------------------------------
# 7. Automatic .env Network Binding Injector
# -----------------------------------------------------------------------------
AUTO_ENV_INJECT="${AUTO_ENV_INJECT:-1}"
if [ "${AUTO_ENV_INJECT}" = "1" ]; then
    if [ ! -f ".env" ]; then
        cat << EOF > .env
# Auto-generated by PotenFYR Universal Programming Language Eggs
PORT=${ACTIVE_PORT}
SERVER_PORT=${ACTIVE_PORT}
FEATHER_PORT=${ACTIVE_PORT}
HOST=0.0.0.0
BIND_ADDRESS=0.0.0.0
EOF
    else
        grep -qE "^PORT=" .env && sed -i "s/^PORT=.*/PORT=${ACTIVE_PORT}/" .env || echo "PORT=${ACTIVE_PORT}" >> .env
        grep -qE "^SERVER_PORT=" .env && sed -i "s/^SERVER_PORT=.*/SERVER_PORT=${ACTIVE_PORT}/" .env || echo "SERVER_PORT=${ACTIVE_PORT}" >> .env
        grep -qE "^HOST=" .env || echo "HOST=0.0.0.0" >> .env
    fi
fi

# --- Debug Mode ---
if [ "${DEBUG:-0}" = "1" ]; then
    warn "DEBUG mode active. Environment configuration:"
    env | grep -E '^(LANGUAGE|RUNNER|MAIN_FILE|PACKAGE_MANAGER|BUILD_|AUTO_|GIT_|CUSTOM_|EXTRA_|DEBUG|TZ|INTERNAL_IP|SERVER_PORT|PORT|FEATHER_|PUFFER_|DEV_MODE|MEMORY_AUTO_TUNE|GOMEMLIMIT|NODE_OPTIONS)' | sort
fi

# --- Dynamic Toolchain Check ---
REQ_LANG="${LANGUAGE:-auto}"
REQ_VER="${RUNTIME_VERSION:-latest}"

if [ "${REQ_LANG}" != "auto" ] && [ "${REQ_LANG}" != "" ]; then
    if [ -f /usr/local/bin/install-runtime.sh ]; then
        /usr/local/bin/install-runtime.sh "${REQ_LANG}" "${REQ_VER}" /opt/runtimes >/dev/null 2>&1 || true
    fi
fi

# --- Banner ---
print_banner() {
    local dev_badge="Production"
    [ "${DEV_MODE:-0}" = "1" ] && dev_badge="Dev Watch Mode (Hot Reload)"

    printf "${C_CYAN}${C_BOLD}"
    cat << "EOF"
.______   .______        ______    _______      .___  ___.  __    __   __      .___________. __  
|   _  \  |   _  \      /  __  \  /  _____|     |   \/   | |  |  |  | |  |     |           ||  | 
|  |_)  | |  |_)  |    |  |  |  ||  |  __  ____ |  \  /  | |  |  |  | |  |     `---|  |----`|  | 
|   ___/  |      /     |  |  |  ||  | |_ ||____||  |\/|  | |  |  |  | |  |         |  |     |  | 
|  |      |  |\  \----.|  `--'  ||  |__| |      |  |  |  | |  `--'  | |  `----.    |  |     |__| 
| _|      | _| `._____| \______/  \______|      |__|  |__|  \______/  |_______|    |__|     (__) 
EOF
    printf "${C_MAGENTA}${C_BOLD}   :: Universal Programming Language Eggs :: By PotenFYR Studios ::\n${C_RESET}\n"
    printf " ${C_DIM}┌──────────────────────────────────────────────────────────────────┐${C_RESET}\n"
    printf " ${C_DIM}│${C_RESET} ${C_BOLD}%-16s${C_RESET} : ${C_GREEN}%-45s${C_RESET} ${C_DIM}│${C_RESET}\n" "Target Language" "${LANGUAGE:-Auto-Detect}"
    printf " ${C_DIM}│${C_RESET} ${C_BOLD}%-16s${C_RESET} : ${C_CYAN}%-45s${C_RESET} ${C_DIM}│${C_RESET}\n" "Runner / Engine" "${RUNNER:-Auto-Detect}"
    printf " ${C_DIM}│${C_RESET} ${C_BOLD}%-16s${C_RESET} : ${C_YELLOW}%-45s${C_RESET} ${C_DIM}│${C_RESET}\n" "Entry Point" "${MAIN_FILE:-Auto-Detect}"
    printf " ${C_DIM}│${C_RESET} ${C_BOLD}%-16s${C_RESET} : ${C_BLUE}%-45s${C_RESET} ${C_DIM}│${C_RESET}\n" "Host Platform" "${PANEL_TYPE}"
    printf " ${C_DIM}│${C_RESET} ${C_BOLD}%-16s${C_RESET} : ${C_MAGENTA}%-45s${C_RESET} ${C_DIM}│${C_RESET}\n" "Auto Memory Tune" "${AUTO_TUNE_INFO}"
    printf " ${C_DIM}│${C_RESET} ${C_BOLD}%-16s${C_RESET} : ${C_GREEN}%-45s${C_RESET} ${C_DIM}│${C_RESET}\n" "Assigned Port" "${ACTIVE_PORT}"
    printf " ${C_DIM}│${C_RESET} ${C_BOLD}%-16s${C_RESET} : ${C_DIM}%-45s${C_RESET} ${C_DIM}│${C_RESET}\n" "Working Dir" "${ACTIVE_WORK_DIR}"
    printf " ${C_DIM}└──────────────────────────────────────────────────────────────────┘${C_RESET}\n\n"
}

print_banner

# --- Execute STARTUP Command ---
STARTUP_CMD="${STARTUP:-bash run.sh}"

ENTRYPOINT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "/usr/local/bin")"

# If startup command refers to run.sh but run.sh is not in current working dir, resolve to system/entrypoint path
if [ ! -f "run.sh" ]; then
    if [ -f "${ENTRYPOINT_DIR}/run.sh" ]; then
        STARTUP_CMD=$(echo "${STARTUP_CMD}" | sed -E "s|\\brun\\.sh\\b|\"${ENTRYPOINT_DIR}/run.sh\"|g")
    elif [ -f "/usr/local/bin/run.sh" ]; then
        STARTUP_CMD=$(echo "${STARTUP_CMD}" | sed -E 's/\brun\.sh\b/\/usr\/local\/bin\/run\.sh/g')
    fi
fi

MODIFIED_STARTUP=$(echo -e "${STARTUP_CMD}" | sed -e 's/{{/${/g' -e 's/}}/}/g')

log "Executing startup command: ${MODIFIED_STARTUP}"
printf "\n"

eval "${MODIFIED_STARTUP}"
