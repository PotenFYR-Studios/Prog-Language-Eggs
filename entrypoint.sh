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

# --- Visual Colors ---
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
if [ -d "/home/container" ]; then
    cd /home/container 2>/dev/null || true
    ACTIVE_WORK_DIR="/home/container"
elif [ -d "/app" ]; then
    cd /app 2>/dev/null || true
    ACTIVE_WORK_DIR="/app"
elif [ -d "/server" ]; then
    cd /server 2>/dev/null || true
    ACTIVE_WORK_DIR="/server"
else
    ACTIVE_WORK_DIR="${PWD}"
fi

export WORK_DIR="${ACTIVE_WORK_DIR}"

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
if [ -n "${P_SERVER_UUID:-}" ] || [ -d "/home/container" ]; then
    PANEL_TYPE="Pterodactyl / Pelican"
elif [ -n "${FEATHER_PORT:-}" ] || [ -n "${FEATHER_SERVER_ID:-}" ]; then
    PANEL_TYPE="Feather Panel"
elif [ -n "${PUFFER_PORT:-}" ] || [ -d "/server" ]; then
    PANEL_TYPE="PufferPanel"
elif [ -n "${KUBERNETES_SERVICE_HOST:-}" ]; then
    PANEL_TYPE="Kubernetes"
fi

# -----------------------------------------------------------------------------
# 4. System PATH Configuration
# -----------------------------------------------------------------------------
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:${PATH}"
export PATH="${ACTIVE_WORK_DIR}/.local/bin:${ACTIVE_WORK_DIR}/bin:${ACTIVE_WORK_DIR}/node_modules/.bin:${PATH}"
export PATH="/opt/runtimes/bin:/opt/runtimes/bun/bin:/opt/runtimes/deno/bin:/opt/runtimes/python/bin:/opt/runtimes/zig:/opt/runtimes/dart-sdk/bin:/opt/runtimes/nim/bin:/opt/runtimes/gleam/bin:/opt/runtimes/odin:${PATH}"
export PATH="/root/.cargo/bin:/opt/cargo/bin:${ACTIVE_WORK_DIR}/.cargo/bin:${PATH}"
export PATH="/opt/go/bin:${ACTIVE_WORK_DIR}/go/bin:${PATH}"
export PATH="/opt/dotnet:${ACTIVE_WORK_DIR}/.dotnet:${PATH}"

export GOPATH="${GOPATH:-${ACTIVE_WORK_DIR}/go}"
export CARGO_HOME="${CARGO_HOME:-${ACTIVE_WORK_DIR}/.cargo}"
export RUSTUP_HOME="${RUSTUP_HOME:-/opt/rustup}"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export PYTHONUNBUFFERED=1
export TZ="${TZ:-UTC}"

# -----------------------------------------------------------------------------
# 5. Persisted Settings (.multi-prog.conf)
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
        eval "export ${key}=\"${val}\"" 2>/dev/null || true
    fi
}

for _key in LANGUAGE RUNNER MAIN_FILE PACKAGE_MANAGER BUILD_COMMAND \
            AUTO_INSTALL_DEPS AUTO_RESTART GIT_REPO GIT_BRANCH \
            GIT_AUTH_TOKEN CUSTOM_COMMAND EXTRA_ARGS DEBUG RUNTIME_VERSION \
            STARTER_TEMPLATE SERVER_PORT MEMORY_AUTO_TUNE DEV_MODE \
            PRE_RUN_COMMAND POST_RUN_COMMAND CLEAN_BUILD_CACHE AUTO_ENV_INJECT; do
    apply_conf "${_key}"
done
unset _key

# -----------------------------------------------------------------------------
# 6. Automatic Memory Tuning & OOM Protection Engine
# -----------------------------------------------------------------------------
MEMORY_AUTO_TUNE="${MEMORY_AUTO_TUNE:-1}"
TOTAL_MEM_MB=0

# Safely extract numeric memory limit
if [ -n "${SERVER_MEMORY:-}" ] && [[ "${SERVER_MEMORY}" =~ ^[0-9]+$ ]]; then
    TOTAL_MEM_MB="${SERVER_MEMORY}"
elif [ -n "${MEMORY:-}" ] && [[ "${MEMORY}" =~ ^[0-9]+$ ]]; then
    TOTAL_MEM_MB="${MEMORY}"
elif [ -n "${FEATHER_MEMORY:-}" ] && [[ "${FEATHER_MEMORY}" =~ ^[0-9]+$ ]]; then
    TOTAL_MEM_MB="${FEATHER_MEMORY}"
fi

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

# -----------------------------------------------------------------------------
# 8. Execute Startup Command
# -----------------------------------------------------------------------------
RAW_STARTUP="${STARTUP:-bash run.sh}"

# If startup command is just /entrypoint.sh or empty, default to run.sh
if [ "${RAW_STARTUP}" = "/entrypoint.sh" ] || [ "${RAW_STARTUP}" = "/bin/bash /entrypoint.sh" ] || [ -z "${RAW_STARTUP}" ]; then
    RAW_STARTUP="bash run.sh"
fi

# Replace Pterodactyl variable interpolation {{VAR}} with ${VAR}
MODIFIED_STARTUP=$(echo -e "${RAW_STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')

# If startup refers to run.sh but run.sh is not in current folder, fallback to system run.sh
if [[ "${MODIFIED_STARTUP}" == *"run.sh"* ]] && [ ! -f "run.sh" ]; then
    if [ -f "/usr/local/bin/run.sh" ]; then
        MODIFIED_STARTUP=$(echo "${MODIFIED_STARTUP}" | sed -E 's/\brun\.sh\b/\/usr\/local\/bin\/run\.sh/g')
    elif [ -f "/run.sh" ]; then
        MODIFIED_STARTUP=$(echo "${MODIFIED_STARTUP}" | sed -E 's/\brun\.sh\b/\/run\.sh/g')
    fi
fi

log "Executing startup command: ${MODIFIED_STARTUP}"
printf "\n"

eval "${MODIFIED_STARTUP}"
