#!/bin/bash
# =============================================================================
#  Universal Programming Language Eggs - Container Entrypoint
#  By PotenFYR Studios (https://github.com/PotenFYR-Studios/Prog-Language-Eggs)
#
#  Responsibilities:
#    1. Load persisted settings (.multi-prog.conf) from the server directory.
#    2. Setup base environment (TZ, PATH, INTERNAL_IP, UTF-8 locale).
#    3. Automatic Memory Tuning & OOM Prevention Engine for Node, Java, Go, Python, .NET.
#    4. Automatic .env Network Binding Injector (PORT, HOST=0.0.0.0).
#    5. Dynamic Toolchain Downloader & Version Resolution.
#    6. High-Visibility ASCII Status Banner.
#    7. Evaluation and execution of panel STARTUP command.
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

log()   { printf "${C_CYAN}${C_BOLD}prog-egg@container~${C_RESET} ${C_BOLD}%s${C_RESET}\n" "$*"; }
warn()  { printf "${C_YELLOW}${C_BOLD}prog-egg@container~${C_RESET} ${C_YELLOW}${C_BOLD}[warn]${C_RESET} %s\n" "$*"; }
error() { printf "${C_RED}${C_BOLD}prog-egg@container~${C_RESET} ${C_RED}${C_BOLD}[error]${C_RESET} %s\n" "$*"; }
ok()    { printf "${C_GREEN}${C_BOLD}prog-egg@container~${C_RESET} ${C_GREEN}${C_BOLD}[ok]${C_RESET} %s\n" "$*"; }

# --- Persisted Settings ---
CONF_FILE="/home/container/.multi-prog.conf"

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

# --- Base Environment ---
TZ=${TZ:-UTC}
export TZ

# Internal IP lookup
INTERNAL_IP=$(ip route get 1 2>/dev/null | awk '{print $(NF-2);exit}' || echo "127.0.0.1")
export INTERNAL_IP

# Switch to container working directory
cd /home/container 2>/dev/null || { error "Cannot enter /home/container"; exit 1; }

# Load persisted variables if panel did not supply them
for _key in LANGUAGE RUNNER MAIN_FILE PACKAGE_MANAGER BUILD_COMMAND \
            AUTO_INSTALL_DEPS AUTO_RESTART GIT_REPO GIT_BRANCH \
            GIT_AUTH_TOKEN CUSTOM_COMMAND EXTRA_ARGS DEBUG RUNTIME_VERSION \
            STARTER_TEMPLATE SERVER_PORT MEMORY_AUTO_TUNE DEV_MODE \
            PRE_RUN_COMMAND POST_RUN_COMMAND CLEAN_BUILD_CACHE AUTO_ENV_INJECT; do
    apply_conf "${_key}"
done
unset _key

# --- PATH Configuration ---
export PATH="/home/container/.local/bin:/home/container/bin:/home/container/node_modules/.bin:${PATH}"
export PATH="/opt/runtimes/bin:/opt/runtimes/bun/bin:/opt/runtimes/deno/bin:/opt/runtimes/python/bin:/opt/runtimes/zig:/opt/runtimes/dart-sdk/bin:/opt/runtimes/nim/bin:/opt/runtimes/gleam/bin:/opt/runtimes/odin:${PATH}"
export PATH="/root/.cargo/bin:/opt/cargo/bin:/home/container/.cargo/bin:${PATH}"
export PATH="/opt/go/bin:/home/container/go/bin:${PATH}"
export PATH="/opt/dotnet:/home/container/.dotnet:${PATH}"

# Add any installed Node / Java version paths if present
for _dir in /opt/runtimes/node-*/bin /opt/runtimes/java-*/bin; do
    [ -d "${_dir}" ] && export PATH="${_dir}:${PATH}"
done
unset _dir

# RUST & GO paths
export GOPATH="${GOPATH:-/home/container/go}"
export CARGO_HOME="${CARGO_HOME:-/home/container/.cargo}"
export RUSTUP_HOME="${RUSTUP_HOME:-/opt/rustup}"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export PYTHONUNBUFFERED=1

# -----------------------------------------------------------------------------
# Automatic Memory Tuning & OOM Protection Engine
# -----------------------------------------------------------------------------
MEMORY_AUTO_TUNE="${MEMORY_AUTO_TUNE:-1}"
TOTAL_MEM_MB="${SERVER_MEMORY:-0}"

# Fallback: check cgroups if SERVER_MEMORY is not provided by panel
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

# If memory limit is identified, calculate 85% safe target
SAFE_MEM_MB=0
if [ "${TOTAL_MEM_MB}" -gt 0 ]; then
    SAFE_MEM_MB=$((TOTAL_MEM_MB * 85 / 100))
fi

AUTO_TUNE_INFO="Default"
if [ "${MEMORY_AUTO_TUNE}" = "1" ] && [ "${SAFE_MEM_MB}" -gt 128 ]; then
    AUTO_TUNE_INFO="${SAFE_MEM_MB}MB (85% of ${TOTAL_MEM_MB}MB Limit)"

    # 1. Node.js V8 Heap Tuning
    if [[ " ${NODE_OPTIONS:-} " != *"--max-old-space-size"* ]]; then
        export NODE_OPTIONS="--max-old-space-size=${SAFE_MEM_MB} ${NODE_OPTIONS:-}"
    fi

    # 2. Golang Runtime Memory Limit (Go 1.19+)
    export GOMEMLIMIT="${SAFE_MEM_MB}MiB"

    # 3. Java JVM Heap & GC Selection
    export JAVA_AUTO_MEM_FLAGS="-Xmx${SAFE_MEM_MB}M -Xms$((SAFE_MEM_MB / 4))M"
    if [ "${SAFE_MEM_MB}" -ge 4096 ]; then
        export JAVA_AUTO_GC="-XX:+UseZGC"
    elif [ "${SAFE_MEM_MB}" -ge 1024 ]; then
        export JAVA_AUTO_GC="-XX:+UseG1GC"
    else
        export JAVA_AUTO_GC="-XX:+UseSerialGC"
    fi

    # 4. Python Memory Trim Threshold (prevents fragmented heap bloat)
    export MALLOC_TRIM_THRESHOLD_=100000

    # 5. .NET GC Heap Hard Limit
    export DOTNET_GCHeapHardLimit="0x$(printf '%X\n' $((SAFE_MEM_MB * 1024 * 1024)))"
fi

# -----------------------------------------------------------------------------
# Automatic .env Network Binding Injector
# -----------------------------------------------------------------------------
AUTO_ENV_INJECT="${AUTO_ENV_INJECT:-1}"
ACTIVE_PORT="${SERVER_PORT:-${PORT:-8080}}"

if [ "${AUTO_ENV_INJECT}" = "1" ]; then
    if [ ! -f ".env" ]; then
        cat << EOF > .env
# Auto-generated by PotenFYR Universal Programming Language Eggs
PORT=${ACTIVE_PORT}
SERVER_PORT=${ACTIVE_PORT}
HOST=0.0.0.0
BIND_ADDRESS=0.0.0.0
EOF
    else
        # Safely update PORT if present or append if missing
        if grep -qE "^PORT=" .env; then
            sed -i "s/^PORT=.*/PORT=${ACTIVE_PORT}/" .env
        else
            echo "PORT=${ACTIVE_PORT}" >> .env
        fi
        if grep -qE "^SERVER_PORT=" .env; then
            sed -i "s/^SERVER_PORT=.*/SERVER_PORT=${ACTIVE_PORT}/" .env
        else
            echo "SERVER_PORT=${ACTIVE_PORT}" >> .env
        fi
        if ! grep -qE "^HOST=" .env; then
            echo "HOST=0.0.0.0" >> .env
        fi
    fi
fi

# --- Debug Mode ---
if [ "${DEBUG:-0}" = "1" ]; then
    warn "DEBUG mode active. Resolved environment variables:"
    env | grep -E '^(LANGUAGE|RUNNER|MAIN_FILE|PACKAGE_MANAGER|BUILD_|AUTO_|GIT_|CUSTOM_|EXTRA_|DEBUG|TZ|INTERNAL_IP|SERVER_PORT|PORT|DEV_MODE|MEMORY_AUTO_TUNE|GOMEMLIMIT|NODE_OPTIONS)' | sort
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
    printf " ${C_DIM}│${C_RESET} ${C_BOLD}%-16s${C_RESET} : ${C_GREEN}%-45s${C_RESET} ${C_DIM}│${C_RESET}\n" "Language" "${LANGUAGE:-Auto-Detect}"
    printf " ${C_DIM}│${C_RESET} ${C_BOLD}%-16s${C_RESET} : ${C_CYAN}%-45s${C_RESET} ${C_DIM}│${C_RESET}\n" "Runner / Engine" "${RUNNER:-Auto-Detect}"
    printf " ${C_DIM}│${C_RESET} ${C_BOLD}%-16s${C_RESET} : ${C_YELLOW}%-45s${C_RESET} ${C_DIM}│${C_RESET}\n" "Entry Point" "${MAIN_FILE:-Auto-Detect}"
    printf " ${C_DIM}│${C_RESET} ${C_BOLD}%-16s${C_RESET} : ${C_BLUE}%-45s${C_RESET} ${C_DIM}│${C_RESET}\n" "Execution Mode" "${dev_badge}"
    printf " ${C_DIM}│${C_RESET} ${C_BOLD}%-16s${C_RESET} : ${C_MAGENTA}%-45s${C_RESET} ${C_DIM}│${C_RESET}\n" "Auto Memory Tune" "${AUTO_TUNE_INFO}"
    printf " ${C_DIM}│${C_RESET} ${C_BOLD}%-16s${C_RESET} : ${C_GREEN}%-45s${C_RESET} ${C_DIM}│${C_RESET}\n" "Assigned Port" "${ACTIVE_PORT}"
    printf " ${C_DIM}│${C_RESET} ${C_BOLD}%-16s${C_RESET} : ${C_DIM}%-45s${C_RESET} ${C_DIM}│${C_RESET}\n" "Internal IP" "${INTERNAL_IP}"
    printf " ${C_DIM}└──────────────────────────────────────────────────────────────────┘${C_RESET}\n\n"
}

print_banner

# --- Execute STARTUP Command ---
STARTUP_CMD="${STARTUP:-bash run.sh}"
MODIFIED_STARTUP=$(echo -e "${STARTUP_CMD}" | sed -e 's/{{/${/g' -e 's/}}/}/g')

log "Executing startup command: ${MODIFIED_STARTUP}"
printf "\n"

eval "${MODIFIED_STARTUP}"
