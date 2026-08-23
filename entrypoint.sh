#!/bin/bash
# =============================================================================
#  Multi-Language Eggs - Container Entrypoint
#  By PotenFYR Studios (https://github.com/PotenFYR-Studios/Prog-Language-Eggs)
#
#  Multi-Panel Support:
#    - Pterodactyl Panel (Wings Daemon)
#    - Pelican Panel (Pelican Wings)
#    - Feather Panel (feather-panel / renoki-co)
#    - PufferPanel
#    - Jexactyl / Wisp (Pterodactyl forks)
#    - Standalone Docker & Kubernetes (Helm / Pods / Compose)
# =============================================================================

# --- Visual Colors & Styling ---
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_CYAN='\033[36m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_RED='\033[31m'
C_MAGENTA='\033[35m'
C_BLUE='\033[34m'
C_WHITE='\033[37m'
C_DIM='\033[2m'

log()   { printf "${C_CYAN}${C_BOLD}[potenfyr]${C_RESET} %s\n" "$*"; }
ok()    { printf "${C_GREEN}${C_BOLD}[potenfyr][✓]${C_RESET} %s\n" "$*"; }
warn()  { printf "${C_YELLOW}${C_BOLD}[potenfyr][!]${C_RESET} ${C_YELLOW}%s${C_RESET}\n" "$*"; }
error() { printf "${C_RED}${C_BOLD}[potenfyr][✗]${C_RESET} ${C_RED}%s${C_RESET}\n" "$*"; }
info()  { printf "${C_BLUE}${C_BOLD}[potenfyr][i]${C_RESET} %s\n" "$*"; }

# -----------------------------------------------------------------------------
# 1. Multi-Panel Working Directory Resolution
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
elif [ -d "/workspace" ]; then
    cd /workspace 2>/dev/null || true
    ACTIVE_WORK_DIR="/workspace"
else
    ACTIVE_WORK_DIR="${PWD}"
fi

export WORK_DIR="${ACTIVE_WORK_DIR}"

# -----------------------------------------------------------------------------
# 2. Multi-Panel Port & Network Resolution
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
# 3. Multi-Panel Host Detection (accurate, multi-panel, multi-platform)
# -----------------------------------------------------------------------------
# Detection strategy (most specific -> most generic), exporting both a human
# label and a machine family so launchers can adapt behaviour per platform:
#
#   FAMILY wings    : Pterodactyl, Pelican, Jexactyl, Wisp, Emerald (Wings-based)
#   FAMILY feather  : Feather Panel
#   FAMILY puffer   : PufferPanel
#   FAMILY k8s      : Kubernetes / OpenShift / Nomad orchestrators
#   FAMILY paas     : Railway / Render / Fly.io / Heroku-style platforms
#   FAMILY docker   : Plain Docker / Podman / containerd
#
PANEL_TYPE="Docker / Standalone"
PANEL_FAMILY="docker"

if [ -n "${KUBERNETES_SERVICE_HOST:-}" ]; then
    PANEL_TYPE="Kubernetes Pod"
    PANEL_FAMILY="k8s"
elif [ -n "${FLY_APP_NAME:-}" ] || [ -n "${FLY_MACHINE_ID:-}" ]; then
    PANEL_TYPE="Fly.io"
    PANEL_FAMILY="paas"
elif [ -n "${RAILWAY_ENVIRONMENT:-}" ] || [ -n "${RAILWAY_PROJECT_ID:-}" ]; then
    PANEL_TYPE="Railway"
    PANEL_FAMILY="paas"
elif [ -n "${RENDER_SERVICE_NAME:-}" ] || [ -n "${RENDER_INTERNAL_HOSTNAME:-}" ]; then
    PANEL_TYPE="Render"
    PANEL_FAMILY="paas"
elif [ -d "/app" ] && [ -f "/app/Procfile" ] && [ -z "${SERVER_PORT:-}" ] && [ -n "${DYNO:-}" ]; then
    PANEL_TYPE="Heroku-style Dyno"
    PANEL_FAMILY="paas"
elif [ -n "${PUFFER_PORT:-}" ] || [ -n "${PUFFER_SERVER_UUID:-}" ] || grep -qs "pufferpanel" /proc/1/cgroup 2>/dev/null; then
    PANEL_TYPE="PufferPanel"
    PANEL_FAMILY="puffer"
elif [ -n "${FEATHER_PORT:-}" ] || [ -n "${FEATHER_SERVER_ID:-}" ]; then
    PANEL_TYPE="Feather Panel"
    PANEL_FAMILY="feather"
elif [ -n "${P_SERVER_UUID:-}" ] || [ -n "${SERVER_UUID:-}" ] || [ -f "/etc/pterodactyl/config.json" ]; then
    # Wings-family discrimination:
    #   Pterodactyl Wings injects SERVER_UUID; Pelican uses P_SERVER_UUID.
    if [ -n "${PELICAN_PANEL_VERSION:-}" ] || { [ -n "${P_SERVER_UUID:-}" ] && [ -z "${SERVER_UUID:-}" ]; }; then
        PANEL_TYPE="Pelican Panel"
        PANEL_FAMILY="wings"
    elif [ -n "${JEXACTYL_VERSION:-}" ] || [ -f "/etc/jexactyl/config.json" ]; then
        PANEL_TYPE="Jexactyl"
        PANEL_FAMILY="wings"
    elif [ -n "${WISP_PANEL_VERSION:-}" ] || [ -f "/etc/wisp/config.json" ]; then
        PANEL_TYPE="Wisp"
        PANEL_FAMILY="wings"
    else
        PANEL_TYPE="Pterodactyl Panel"
        PANEL_FAMILY="wings"
    fi
elif [ -n "${EMERALD_SRV_UUID:-}" ]; then
    PANEL_TYPE="Emerald Panel"
    PANEL_FAMILY="wings"
elif [ -n "${HOSTNAME:-}" ] && grep -qs "kubepods" /proc/1/cgroup 2>/dev/null; then
    PANEL_TYPE="Kubernetes Pod"
    PANEL_FAMILY="k8s"
fi

export PANEL_TYPE PANEL_FAMILY

# -----------------------------------------------------------------------------
# 3.2 Architecture & Distro Assurance (works wherever the panel is hosted)
# -----------------------------------------------------------------------------
# * ARCH: exported for all runtime scripts; any CPU (amd64/arm64/armv7/ppc64le/
#   s390x/riscv64/...) proceeds - engines self-check upstream availability.
# * Cross-distro containers: if this egg is run on a foreign base image
#   (alpine yolks, debian slim, fedora, ...), make sure the handful of core
#   tools our launcher needs actually exist. Root gets them installed via the
#   detected package manager; non-root gets a precise, actionable notice.
export ARCH
ARCH="$(uname -m 2>/dev/null || echo unknown)"

ensure_core_tools() {
    local need="" t
    for t in curl tar unzip; do
        command -v "${t}" >/dev/null 2>&1 || need="${need} ${t}"
    done
    command -v jq >/dev/null 2>&1 || need="${need} jq"
    # busybox tar cannot read .tar.xz -> xz binary required on alpine-like bases
    command -v xz >/dev/null 2>&1 || need="${need} xz"
    [ -z "${need}" ] && return 0

    local pkgs="curl tar unzip jq xz ca-certificates bash"
    if [ "$(id -u)" = "0" ]; then
        info "Installing core tools:${need} ..."
        if command -v apt-get >/dev/null 2>&1; then
            apt-get update -qq >/dev/null 2>&1 || true
            DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends ${pkgs} >/dev/null 2>&1 || true
        elif command -v apk >/dev/null 2>&1; then
            apk add --no-cache ${pkgs} >/dev/null 2>&1 || true
        elif command -v dnf >/dev/null 2>&1; then
            dnf install -y -q ${pkgs} >/dev/null 2>&1 || true
        elif command -v yum >/dev/null 2>&1; then
            yum install -y -q ${pkgs} >/dev/null 2>&1 || true
        elif command -v zypper >/dev/null 2>&1; then
            zypper --non-interactive install ${pkgs} >/dev/null 2>&1 || true
        fi
    else
        warn "Base image lacks core tools:${need} and we are non-root, so they cannot be auto-installed."
        warn "Ask your panel admin to pick the official Multi-Language image, or add these packages to a custom image."
    fi
}
ensure_core_tools

# -----------------------------------------------------------------------------
# 3.5 Production Reliability: Console Mirroring, Version Stamp, Safety Checks
# -----------------------------------------------------------------------------
# Mirror the entire boot + runtime console into .logs/console.log so users can
# troubleshoot crashes even after the panel scrollback is gone. Opt out with
# LAUNCHER_LOG=0. Rotates the previous boot's log to .1 automatically.
LAUNCH_CONSOLE_LOG=""
if [ "${LAUNCHER_LOG:-1}" = "1" ]; then
    _LOGDIR="${ACTIVE_WORK_DIR}/.logs"
    mkdir -p "${_LOGDIR}" 2>/dev/null || true
    if [ -d "${_LOGDIR}" ] && [ -w "${_LOGDIR}" ]; then
        LAUNCH_CONSOLE_LOG="${_LOGDIR}/console.log"
        [ -f "${LAUNCH_CONSOLE_LOG}" ] && mv -f "${LAUNCH_CONSOLE_LOG}" "${LAUNCH_CONSOLE_LOG}.1" 2>/dev/null || true
        exec > >(tee -a "${LAUNCH_CONSOLE_LOG}") 2>&1
    fi
fi

# Running as root inside a panel container is a security anti-pattern; warn.
if [ "$(id -u 2>/dev/null || echo 1)" = "0" ]; then
    warn "Container is running as ROOT. Panels should launch images as a non-root user (e.g. uid 988)."
fi

# Image provenance stamp (written at docker build time) for supportability.
if [ -f "/etc/potenfyr-version" ]; then
    info "Image build: $(head -n1 /etc/potenfyr-version 2>/dev/null)"
fi

# -----------------------------------------------------------------------------
# 4. Toolchain & PATH Configuration (Multi-Panel)
# -----------------------------------------------------------------------------
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:${PATH}"
export PATH="${ACTIVE_WORK_DIR}/.runtimes/bin:${ACTIVE_WORK_DIR}/.local/bin:${ACTIVE_WORK_DIR}/bin:${ACTIVE_WORK_DIR}/node_modules/.bin:${ACTIVE_WORK_DIR}/custom/bin:${PATH}"
export PATH="/opt/runtimes/bin:/opt/runtimes/bun/bin:/opt/runtimes/deno/bin:/opt/runtimes/python/bin:/opt/runtimes/zig:/opt/runtimes/dart-sdk/bin:/opt/runtimes/nim/bin:/opt/runtimes/gleam/bin:/opt/runtimes/odin:/opt/runtimes/custom:/opt/runtimes/custom/bin:${PATH}"
export PATH="/root/.cargo/bin:/opt/cargo/bin:${ACTIVE_WORK_DIR}/.cargo/bin:${PATH}"
export PATH="/opt/go/bin:${ACTIVE_WORK_DIR}/go/bin:${PATH}"
export PATH="/opt/dotnet:${ACTIVE_WORK_DIR}/.dotnet:${PATH}"

export GOPATH="${GOPATH:-${ACTIVE_WORK_DIR}/go}"
export CARGO_HOME="${CARGO_HOME:-${ACTIVE_WORK_DIR}/.cargo}"
export RUSTUP_HOME="${RUSTUP_HOME:-/opt/rustup}"
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export PYTHONUNBUFFERED=1
export TZ="${TZ:-UTC}"

# Ensure cache directories are writable for rootless / custom UID environments
if [ -w "${ACTIVE_WORK_DIR}" ]; then
    export NPM_CONFIG_CACHE="${ACTIVE_WORK_DIR}/.npm"
    export PIP_CACHE_DIR="${ACTIVE_WORK_DIR}/.cache/pip"
else
    export NPM_CONFIG_CACHE="/tmp/.npm"
    export PIP_CACHE_DIR="/tmp/.cache/pip"
fi

# -----------------------------------------------------------------------------
# 5. Load Persisted Configuration (.multi-prog.conf)
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
            GIT_AUTH_TOKEN CUSTOM_COMMAND CUSTOM_RUNTIME_URL EXTRA_ARGS DEBUG RUNTIME_VERSION \
            STARTER_TEMPLATE SERVER_PORT MEMORY_AUTO_TUNE DEV_MODE \
            PRE_RUN_COMMAND POST_RUN_COMMAND CLEAN_BUILD_CACHE AUTO_ENV_INJECT \
            NODE_GYP_SUPPORT EXTRA_RUNTIMES SKIP_RUNTIMES SKIP_PYTHON \
            SUPERVISOR PROCFILE_RESTART PROCFILE_LOGS PROCFILE_MAX_RESTARTS \
            HEALTH_CHECK_PATH HEALTH_STRICT HEALTH_TIMEOUT LAUNCHER_LOG RESOLVER_CACHE_TTL; do
    apply_conf "${_key}"
done
unset _key

# -----------------------------------------------------------------------------
# 6. Automatic Memory Tuning & OOM Protection Engine
# -----------------------------------------------------------------------------
MEMORY_AUTO_TUNE="${MEMORY_AUTO_TUNE:-1}"
TOTAL_MEM_MB=0

if [ -n "${SERVER_MEMORY:-}" ] && [[ "${SERVER_MEMORY}" =~ ^[0-9]+$ ]]; then
    TOTAL_MEM_MB="${SERVER_MEMORY}"
elif [ -n "${MEMORY:-}" ] && [[ "${MEMORY}" =~ ^[0-9]+$ ]]; then
    TOTAL_MEM_MB="${MEMORY}"
elif [ -n "${FEATHER_MEMORY:-}" ] && [[ "${FEATHER_MEMORY}" =~ ^[0-9]+$ ]]; then
    TOTAL_MEM_MB="${FEATHER_MEMORY}"
elif [ -n "${PUFFER_MEMORY:-}" ] && [[ "${PUFFER_MEMORY}" =~ ^[0-9]+$ ]]; then
    TOTAL_MEM_MB="${PUFFER_MEMORY}"
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
    AUTO_TUNE_INFO="${SAFE_MEM_MB}MB (${TOTAL_MEM_MB}MB Limit -> 85% Safe Heap)"

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
# Auto-generated by PotenFYR Multi-Language Eggs
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

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 8. Clean, Modern ANSI Gradient Banner & System Information Card
# -----------------------------------------------------------------------------
print_card_row() {
    local label="$1"
    local value="$2"
    local color="$3"
    
    # Smart truncation to ensure pixel-perfect right border alignment
    if [ "${#value}" -gt 48 ]; then
        value="${value:0:45}..."
    fi
    
    printf " ${C_DIM}│${C_RESET}  ${C_CYAN}✦${C_RESET} ${C_BOLD}%-15s${C_RESET} : ${color}%-48s${C_RESET} ${C_DIM}│${C_RESET}\n" "${label}" "${value}"
}

print_banner() {
    printf "\n"
    printf "${C_CYAN}${C_BOLD}%s${C_RESET}\n" "   __  ___      ____  _       __                              "
    printf "${C_CYAN}${C_BOLD}%s${C_RESET}\n" "  /  |/  /_  __/ / /_(_)     / /   ____ _____  ____ _         "
    printf "${C_BLUE}${C_BOLD}%s${C_RESET}\n" " / /|_/ / / / / / __/ /_____/ /   / __ \`/ __ \/ __ \`/         "
    printf "${C_BLUE}${C_BOLD}%s${C_RESET}\n" "/ /  / / /_/ / / /_/ /_____/ /___/ /_/ / / / / /_/ /          "
    printf "${C_MAGENTA}${C_BOLD}%s${C_RESET}\n" "/_/  /_/\\__,_/_/\\__/_/     /_____/\\__,_/_/ /_/\\__, /          "
    printf "${C_MAGENTA}${C_BOLD}%s${C_RESET}\n" "                                             /____/           "
    printf "${C_YELLOW}${C_BOLD}  » Multi-Language Runtime Environment${C_RESET}\n"
    printf "${C_DIM}    By PotenFYR Studios • support@potenfyr.in${C_RESET}\n\n"

    printf " ${C_DIM}┌──────────────────────────────────────────────────────────────────────────┐${C_RESET}\n"
    print_card_row "Target Language" "${LANGUAGE:-Auto-Detect}" "${C_GREEN}"
    print_card_row "Runner / Engine" "${RUNNER:-Auto-Detect}" "${C_CYAN}"
    print_card_row "Entry Point"     "${MAIN_FILE:-Auto-Detect}" "${C_YELLOW}"
    print_card_row "Host Platform"   "${PANEL_TYPE}" "${C_BLUE}"
    print_card_row "Memory Tuning"   "${AUTO_TUNE_INFO}" "${C_MAGENTA}"
    print_card_row "Port Allocation" "${ACTIVE_PORT} (0.0.0.0)" "${C_GREEN}"
    print_card_row "Architecture"   "${ARCH} ($(uname -s 2>/dev/null || echo linux))" "${C_CYAN}"
    print_card_row "Working Dir"     "${ACTIVE_WORK_DIR}" "${C_DIM}"
    printf " ${C_DIM}└──────────────────────────────────────────────────────────────────────────┘${C_RESET}\n\n"
}

print_banner

# -----------------------------------------------------------------------------
# 9. Dynamic Toolchain & Auxiliary Runtime Orchestrator (On-Demand)
# -----------------------------------------------------------------------------
REQ_LANG="${LANGUAGE:-auto}"
REQ_VER="${RUNTIME_VERSION:-latest}"

if [ "${REQ_LANG}" != "auto" ] && [ "${REQ_LANG}" != "" ] && [ "${REQ_LANG}" != "custom" ]; then
    if [ -f /usr/local/bin/install-runtime.sh ]; then
        /usr/local/bin/install-runtime.sh "${REQ_LANG}" "${REQ_VER}" /opt/runtimes || true
    fi
fi

# Ensure specific engine/runner toolchain is provisioned if chosen (e.g. bun, deno)
if [ "${RUNNER:-auto}" = "bun" ] && ! command -v bun >/dev/null 2>&1; then
    if [ -f /usr/local/bin/install-runtime.sh ]; then
        /usr/local/bin/install-runtime.sh "bun" "latest" /opt/runtimes || true
    fi
elif [ "${RUNNER:-auto}" = "deno" ] && ! command -v deno >/dev/null 2>&1; then
    if [ -f /usr/local/bin/install-runtime.sh ]; then
        /usr/local/bin/install-runtime.sh "deno" "latest" /opt/runtimes || true
    fi
fi

if [ -n "${CUSTOM_RUNTIME_URL:-}" ]; then
    if [ -f /usr/local/bin/install-runtime.sh ]; then
        /usr/local/bin/install-runtime.sh "custom" "${CUSTOM_RUNTIME_URL}" /opt/runtimes || true
    fi
fi

if [ -n "${EXTRA_RUNTIMES:-}" ] && [ "${EXTRA_RUNTIMES}" != "none" ] && [ "${EXTRA_RUNTIMES}" != "auto" ]; then
    # Install companion runtimes in PARALLEL for fast boots; each stream is
    # logged separately to .logs/runtime-install-<name>.log and summarized.
    _LOGDIR="${ACTIVE_WORK_DIR}/.logs"
    mkdir -p "${_LOGDIR}" 2>/dev/null || true
    OLD_IFS="${IFS}"
    IFS=','
    for extra_r in ${EXTRA_RUNTIMES}; do
        IFS="${OLD_IFS}"
        extra_full=$(echo "${extra_r}" | tr -d '[:space:]')
        [ -z "${extra_full}" ] && continue
        # Per-component version syntax: name@version (e.g. python@3.12, java@21)
        extra_r="${extra_full%%@*}"; extra_ver="${extra_full#*@}"
        [ "${extra_ver}" = "${extra_full}" ] && extra_ver="latest"
        extra_r=$(echo "${extra_r}" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')

        if [ "${SKIP_PYTHON:-0}" = "1" ] && [ "${extra_r}" = "python" ]; then
            continue
        fi

        if [ -f /usr/local/bin/install-runtime.sh ]; then
            log "Installing companion runtime '${extra_r}' (${extra_ver}) in background..."
            (
                if /usr/local/bin/install-runtime.sh "${extra_r}" "${extra_ver}" /opt/runtimes \
                        >>"${_LOGDIR}/runtime-install-${extra_r}.log" 2>&1; then
                    : >"${_LOGDIR}/.${extra_r}.install-ok"
                else
                    : >"${_LOGDIR}/.${extra_r}.install-failed"
                fi
            ) &
        fi
    done
    IFS="${OLD_IFS}"
    wait
    # Summarize parallel install results
    _FAILED=0
    for marker in "${_LOGDIR}"/.*.install-failed; do
        [ -f "${marker}" ] || continue
        _name="$(basename "${marker}" .install-failed)"; _name="${_name#.}"
        warn "Companion runtime '${_name}' FAILED to install -> ${_LOGDIR}/runtime-install-${_name}.log"
        rm -f "${marker}"; _FAILED=1
    done
    for marker in "${_LOGDIR}"/.*.install-ok; do
        [ -f "${marker}" ] && rm -f "${marker}"
    done
    [ "${_FAILED}" = "0" ] && ok "All companion runtimes installed successfully."
    unset _FAILED
fi

# -----------------------------------------------------------------------------
# 10. Execute Startup Command
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 10. Execute Startup Command & Clean User Workspace
# -----------------------------------------------------------------------------
# Clean up any leftover launcher script files so user directory only contains project files
if [ -f "./run.sh" ] && grep -q "PotenFYR Studios" "./run.sh" 2>/dev/null; then
    rm -f "./run.sh" 2>/dev/null || true
fi
if [ -f "./install-runtime.sh" ] && grep -q "PotenFYR Studios" "./install-runtime.sh" 2>/dev/null; then
    rm -f "./install-runtime.sh" 2>/dev/null || true
fi

RAW_STARTUP="${STARTUP:-bash /usr/local/bin/run.sh}"

# If startup command is just /entrypoint.sh or empty, default to run.sh
if [ "${RAW_STARTUP}" = "/entrypoint.sh" ] || [ "${RAW_STARTUP}" = "/bin/bash /entrypoint.sh" ] || [ -z "${RAW_STARTUP}" ]; then
    RAW_STARTUP="bash /usr/local/bin/run.sh"
fi

# Replace Pterodactyl variable interpolation {{VAR}} with ${VAR}
MODIFIED_STARTUP=$(echo -e "${RAW_STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')

LAUNCHER_SCRIPT="/usr/local/bin/run.sh"
[ ! -f "${LAUNCHER_SCRIPT}" ] && [ -f "/run.sh" ] && LAUNCHER_SCRIPT="/run.sh"
if [ ! -f "${LAUNCHER_SCRIPT}" ]; then
    mkdir -p /tmp/potenfyr 2>/dev/null || true
    if [ ! -f "/tmp/potenfyr/run.sh" ]; then
        curl -fsSL --retry 3 https://raw.githubusercontent.com/PotenFYR-Studios/Prog-Language-Eggs/main/run.sh -o /tmp/potenfyr/run.sh 2>/dev/null || true
        chmod +x /tmp/potenfyr/run.sh 2>/dev/null || true
    fi
    LAUNCHER_SCRIPT="/tmp/potenfyr/run.sh"
fi

# 1. Normalize any variation of run.sh invocation across old/new/foreign configs.
#    ANY startup that references run.sh is forced to exactly "bash <launcher>":
#    this guarantees bash interpretation (run.sh uses bash features like
#    associative arrays) regardless of whether the old egg wrote sh/bash/./abs
#    paths, and drops stale extra arguments left over from previous eggs.
case "${MODIFIED_STARTUP}" in
    *run.sh*)
        MODIFIED_STARTUP="bash ${LAUNCHER_SCRIPT}"
        ;;
    *)
        # If server was migrated from another egg (e.g. startup was 'node index.js' or 'python main.py'),
        # route it safely through the multi-language launcher as CUSTOM_COMMAND so
        # the user's original command still runs, with all launcher features.
        if [ -n "${MODIFIED_STARTUP}" ] && [ "${MODIFIED_STARTUP}" != "${LAUNCHER_SCRIPT}" ] && [ "${MODIFIED_STARTUP}" != "bash ${LAUNCHER_SCRIPT}" ]; then
            export CUSTOM_COMMAND="${MODIFIED_STARTUP}"
            MODIFIED_STARTUP="bash ${LAUNCHER_SCRIPT}"
        fi
        ;;
esac

# Fallback to /bin/sh if bash is missing on minimal/alpine containers
if ! command -v bash >/dev/null 2>&1; then
    MODIFIED_STARTUP=$(echo "${MODIFIED_STARTUP}" | sed -E 's/\bbash\b/\/bin\/sh/g')
fi

log "Starting application process via launcher..."
printf "${C_DIM}>>> ${MODIFIED_STARTUP}${C_RESET}\n\n"

# Execute with signal trapping for clean container lifecycle
eval "${MODIFIED_STARTUP}"
