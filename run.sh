#!/bin/bash
# =============================================================================
#  Universal Programming Language Eggs - Universal Launcher
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

# --- Visual formatting ---
C_RESET='\033[0m'
C_BOLD='\033[1m'
C_CYAN='\033[36m'
C_GREEN='\033[32m'
C_YELLOW='\033[33m'
C_RED='\033[31m'
C_MAGENTA='\033[35m'
C_BLUE='\033[34m'
C_DIM='\033[2m'

log()   { printf "${C_CYAN}${C_BOLD}[potenfyr]${C_RESET} %s\n" "$*"; }
ok()    { printf "${C_GREEN}${C_BOLD}[potenfyr][✓]${C_RESET} %s\n" "$*"; }
warn()  { printf "${C_YELLOW}${C_BOLD}[potenfyr][!]${C_RESET} ${C_YELLOW}%s${C_RESET}\n" "$*"; }
fail()  { printf "${C_RED}${C_BOLD}[potenfyr][✗]${C_RESET} ${C_RED}%s${C_RESET}\n" "$*"; exit 1; }
info()  { printf "${C_BLUE}${C_BOLD}[potenfyr][i]${C_RESET} %s\n" "$*"; }

# Determine active working directory across panels
WORK_DIR="${WORK_DIR:-${PWD}}"
if [ ! -d "${WORK_DIR}" ]; then
    if [ -d "/home/container" ]; then
        WORK_DIR="/home/container"
    elif [ -d "/server" ]; then
        WORK_DIR="/server"
    elif [ -d "/app" ]; then
        WORK_DIR="/app"
    else
        WORK_DIR="${PWD}"
    fi
fi

cd "${WORK_DIR}" 2>/dev/null || true

export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:${PATH}"
export PATH="${WORK_DIR}/.runtimes/bin:${WORK_DIR}/.local/bin:${WORK_DIR}/bin:${WORK_DIR}/node_modules/.bin:${WORK_DIR}/custom/bin:${PATH}"
export PATH="/opt/runtimes/bin:/opt/runtimes/bun/bin:/opt/runtimes/deno/bin:/opt/runtimes/python/bin:/opt/runtimes/zig:/opt/runtimes/dart-sdk/bin:/opt/runtimes/nim/bin:/opt/runtimes/gleam/bin:/opt/runtimes/odin:/opt/runtimes/custom:/opt/runtimes/custom/bin:${PATH}"
export PATH="/root/.cargo/bin:/opt/cargo/bin:${WORK_DIR}/.cargo/bin:${PATH}"
export PATH="/opt/go/bin:${WORK_DIR}/go/bin:${PATH}"
export PATH="/opt/dotnet:${WORK_DIR}/.dotnet:${PATH}"

CONF_FILE="${WORK_DIR}/.multi-prog.conf"

save_conf() {
    local key="$1" val="$2"
    grep -v "^${key}=" "${CONF_FILE}" 2>/dev/null > "${CONF_FILE}.tmp" || true
    printf '%s=%s\n' "${key}" "${val}" >> "${CONF_FILE}.tmp"
    mv "${CONF_FILE}.tmp" "${CONF_FILE}"
    chmod 600 "${CONF_FILE}" 2>/dev/null || true
}

# --- Variables with defaults ---
LANGUAGE="${LANGUAGE:-auto}"
RUNNER="${RUNNER:-auto}"
MAIN_FILE="${MAIN_FILE:-auto}"
PACKAGE_MANAGER="${PACKAGE_MANAGER:-auto}"
BUILD_COMMAND="${BUILD_COMMAND:-}"
CUSTOM_COMMAND="${CUSTOM_COMMAND:-}"
CUSTOM_RUNTIME_URL="${CUSTOM_RUNTIME_URL:-}"
EXTRA_ARGS="${EXTRA_ARGS:-}"
AUTO_INSTALL_DEPS="${AUTO_INSTALL_DEPS:-1}"
AUTO_RESTART="${AUTO_RESTART:-0}"
RESTART_DELAY="${RESTART_DELAY:-3}"
DEV_MODE="${DEV_MODE:-0}"
PRE_RUN_COMMAND="${PRE_RUN_COMMAND:-}"
POST_RUN_COMMAND="${POST_RUN_COMMAND:-}"
CLEAN_BUILD_CACHE="${CLEAN_BUILD_CACHE:-1}"
GIT_REPO="${GIT_REPO:-}"
GIT_BRANCH="${GIT_BRANCH:-main}"
GIT_AUTH_TOKEN="${GIT_AUTH_TOKEN:-}"
STARTER_TEMPLATE="${STARTER_TEMPLATE:-}"
SERVER_PORT="${SERVER_PORT:-${PORT:-${FEATHER_PORT:-${PUFFER_PORT:-8080}}}}"
NODE_GYP_SUPPORT="${NODE_GYP_SUPPORT:-1}"
EXTRA_RUNTIMES="${EXTRA_RUNTIMES:-}"
SKIP_RUNTIMES="${SKIP_RUNTIMES:-}"
SKIP_PYTHON="${SKIP_PYTHON:-0}"
DEBUG="${DEBUG:-0}"

[ "${DEBUG}" = "1" ] && set -x

# -----------------------------------------------------------------------------
# 1. Git Synchronization
# -----------------------------------------------------------------------------
if [ -n "${GIT_REPO}" ]; then
    log "Checking Git repository integration..."
    AUTH_REPO_URL="${GIT_REPO}"
    if [ -n "${GIT_AUTH_TOKEN}" ] && [[ "${GIT_REPO}" =~ ^https:// ]]; then
        AUTH_REPO_URL="https://${GIT_AUTH_TOKEN}@${GIT_REPO#https://}"
    fi

    if [ ! -d ".git" ]; then
        log "Cloning repository: ${GIT_REPO} (branch: ${GIT_BRANCH})..."
        if git clone --branch "${GIT_BRANCH}" --depth 1 "${AUTH_REPO_URL}" . ; then
            ok "Repository successfully cloned"
        else
            warn "Git clone with branch ${GIT_BRANCH} failed. Attempting default clone..."
            git clone --depth 1 "${AUTH_REPO_URL}" . || warn "Could not clone repository"
        fi
    else
        log "Existing Git repository found. Pulling latest commits..."
        git fetch origin "${GIT_BRANCH}" --depth 1 2>/dev/null || true
        git reset --hard "origin/${GIT_BRANCH}" 2>/dev/null || git pull || warn "Could not pull updates from remote"
        ok "Git repository up to date"
    fi
fi

# -----------------------------------------------------------------------------
# 2. Interactive Setup Wizard (Interactive TTY vs Non-Interactive)
# -----------------------------------------------------------------------------
FILE_COUNT=$(find . -mindepth 1 -maxdepth 1 -not -name '.*' -not -name 'run.sh' -not -name 'entrypoint.sh' -not -name 'install.sh' -not -name 'install-runtime.sh' 2>/dev/null | wc -l)

if [ "${FILE_COUNT}" -eq 0 ] && [ -z "${STARTER_TEMPLATE}" ]; then
    if [ "${LANGUAGE}" != "auto" ] && [ -n "${LANGUAGE}" ] && [ "${LANGUAGE}" != "custom" ]; then
        STARTER_TEMPLATE="${LANGUAGE}"
        log "Empty workspace detected with language '${LANGUAGE}'. Auto-scaffolding starter project..."
    elif [ -t 0 ]; then
        printf "\n${C_MAGENTA}${C_BOLD}===============================================================================${C_RESET}\n"
        printf "${C_CYAN}${C_BOLD}  Empty workspace detected! Choose a language to scaffold a starter project:${C_RESET}\n"
        printf "${C_MAGENTA}${C_BOLD}===============================================================================${C_RESET}\n"
        printf "  ${C_BOLD}1)${C_RESET} Node.js / Express (JavaScript HTTP Server)\n"
        printf "  ${C_BOLD}2)${C_RESET} Bun (Fast TypeScript / JavaScript Server)\n"
        printf "  ${C_BOLD}3)${C_RESET} TypeScript (Node.js + ts-node / tsx)\n"
        printf "  ${C_BOLD}4)${C_RESET} Python (FastAPI / Flask HTTP Server)\n"
        printf "  ${C_BOLD}5)${C_RESET} Java (Maven / Spring Boot / Spark)\n"
        printf "  ${C_BOLD}6)${C_RESET} Go / Golang (High Performance HTTP Server)\n"
        printf "  ${C_BOLD}7)${C_RESET} Rust (Axum / Actix Web Server)\n"
        printf "  ${C_BOLD}8)${C_RESET} C / C++ (High Performance Native Server)\n"
        printf "  ${C_BOLD}9)${C_RESET} PHP (Built-in Web Server)\n"
        printf "  ${C_BOLD}10)${C_RESET} .NET / C# (ASP.NET Core Web API)\n"
        printf "  ${C_BOLD}11)${C_RESET} Ruby (Sinatra / Puma Server)\n"
        printf "  ${C_BOLD}12)${C_RESET} Static HTML / React / Frontend Website\n"
        printf "\n"

        read -r -t 15 -p "$(echo -e "${C_YELLOW}${C_BOLD}Select choice [1-12] (Default 1): ${C_RESET}")" CHOICE 2>/dev/null || CHOICE="1"
        CHOICE="${CHOICE:-1}"

        case "${CHOICE}" in
            1) STARTER_TEMPLATE="nodejs" ;;
            2) STARTER_TEMPLATE="bun" ;;
            3) STARTER_TEMPLATE="typescript" ;;
            4) STARTER_TEMPLATE="python" ;;
            5) STARTER_TEMPLATE="java" ;;
            6) STARTER_TEMPLATE="golang" ;;
            7) STARTER_TEMPLATE="rust" ;;
            8) STARTER_TEMPLATE="c-cpp" ;;
            9) STARTER_TEMPLATE="php" ;;
            10) STARTER_TEMPLATE="dotnet" ;;
            11) STARTER_TEMPLATE="ruby" ;;
            12) STARTER_TEMPLATE="static" ;;
            *) STARTER_TEMPLATE="nodejs" ;;
        esac
    else
        log "Non-interactive environment detected. Defaulting to Node.js starter."
        STARTER_TEMPLATE="nodejs"
    fi
fi

# -----------------------------------------------------------------------------
# 3. Apply Starter Template if requested
# -----------------------------------------------------------------------------
if [ -n "${STARTER_TEMPLATE}" ] && [ "${STARTER_TEMPLATE}" != "empty" ]; then
    log "Generating starter project for template: '${STARTER_TEMPLATE}'..."
    case "${STARTER_TEMPLATE}" in
        nodejs|javascript|js)
            cat << 'EOF' > package.json
{
  "name": "potenfyr-node-server",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {}
}
EOF
            cat << 'EOF' > index.js
const http = require('http');
const port = process.env.SERVER_PORT || process.env.PORT || process.env.FEATHER_PORT || 8080;

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    status: 'online',
    message: 'Hello from PotenFYR Universal Programming Language Eggs!',
    runtime: `Node.js ${process.version}`,
    timestamp: new Date().toISOString()
  }, null, 2));
});

server.listen(port, '0.0.0.0', () => {
  console.log(`[PotenFYR] Node.js server listening on port ${port}`);
});
EOF
            LANGUAGE="nodejs"
            MAIN_FILE="index.js"
            ;;

        bun)
            cat << 'EOF' > index.ts
const port = Number(process.env.SERVER_PORT || process.env.PORT || process.env.FEATHER_PORT || 8080);

console.log(`[PotenFYR] Bun HTTP server listening on port ${port}`);

Bun.serve({
  port: port,
  fetch(req) {
    return new Response(JSON.stringify({
      status: "online",
      message: "Hello from PotenFYR Bun Egg!",
      runtime: `Bun ${Bun.version}`,
      url: req.url,
      timestamp: new Date().toISOString()
    }, null, 2), {
      headers: { "Content-Type": "application/json" }
    });
  }
});
EOF
            LANGUAGE="bun"
            MAIN_FILE="index.ts"
            [ "${RUNNER}" = "auto" ] || [ -z "${RUNNER}" ] && RUNNER="bun"
            ;;

        typescript|ts)
            cat << 'EOF' > package.json
{
  "name": "potenfyr-typescript-server",
  "version": "1.0.0",
  "main": "src/index.ts",
  "scripts": {
    "start": "ts-node src/index.ts",
    "build": "tsc"
  },
  "dependencies": {},
  "devDependencies": {
    "typescript": "^5.4.0",
    "@types/node": "^20.0.0",
    "ts-node": "^10.9.2"
  }
}
EOF
            cat << 'EOF' > tsconfig.json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "commonjs",
    "moduleResolution": "node",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "./dist"
  },
  "include": ["src/**/*"]
}
EOF
            mkdir -p src
            cat << 'EOF' > src/index.ts
import * as http from 'http';

const port = process.env.SERVER_PORT || process.env.PORT || process.env.FEATHER_PORT || 8080;

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    status: 'online',
    message: 'Hello from PotenFYR TypeScript Egg!',
    runtime: `Node.js ${process.version} + TypeScript`,
    timestamp: new Date().toISOString()
  }, null, 2));
});

server.listen(Number(port), '0.0.0.0', () => {
  console.log(`[PotenFYR] TypeScript server listening on port ${port}`);
});
EOF
            LANGUAGE="typescript"
            MAIN_FILE="src/index.ts"
            [ "${RUNNER}" = "auto" ] || [ -z "${RUNNER}" ] && RUNNER="tsx"
            ;;

        python|py)
            cat << 'EOF' > requirements.txt
# Add python dependencies
EOF
            cat << 'EOF' > main.py
import os
from http.server import HTTPServer, BaseHTTPRequestHandler
import json
from datetime import datetime

PORT = int(os.environ.get("SERVER_PORT", os.environ.get("PORT", os.environ.get("FEATHER_PORT", 8080))))

class RequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        response = {
            "status": "online",
            "message": "Hello from PotenFYR Python Egg!",
            "python_version": os.sys.version,
            "timestamp": datetime.utcnow().isoformat()
        }
        self.wfile.write(json.dumps(response, indent=2).encode('utf-8'))

print(f"[PotenFYR] Python HTTP server listening on port {PORT}")
httpd = HTTPServer(('0.0.0.0', PORT), RequestHandler)
httpd.serve_forever()
EOF
            LANGUAGE="python"
            MAIN_FILE="main.py"
            ;;

        golang|go)
            cat << 'EOF' > go.mod
module potenfyr-server

go 1.22
EOF
            cat << 'EOF' > main.go
package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"runtime"
	"time"
)

type StatusResponse struct {
	Status    string `json:"status"`
	Message   string `json:"message"`
	GoVersion string `json:"go_version"`
	Time      string `json:"timestamp"`
}

func main() {
	port := os.Getenv("SERVER_PORT")
	if port == "" {
		port = os.Getenv("PORT")
	}
	if port == "" {
		port = os.Getenv("FEATHER_PORT")
	}
	if port == "" {
		port = "8080"
	}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		resp := StatusResponse{
			Status:    "online",
			Message:   "Hello from PotenFYR Golang Egg!",
			GoVersion: runtime.Version(),
			Time:      time.Now().UTC().Format(time.RFC3339),
		}
		json.NewEncoder(w).Encode(resp)
	})

	fmt.Printf("[PotenFYR] Go HTTP server listening on port %s\n", port)
	if err := http.ListenAndServe("0.0.0.0:"+port, nil); err != nil {
		fmt.Printf("Server failed: %v\n", err)
	}
}
EOF
            LANGUAGE="golang"
            MAIN_FILE="main.go"
            ;;

        rust|rs)
            mkdir -p src
            cat << 'EOF' > Cargo.toml
[package]
name = "potenfyr-rust-server"
version = "0.1.0"
edition = "2021"

[dependencies]
EOF
            cat << 'EOF' > src/main.rs
use std::env;
use std::io::Write;
use std::net::TcpListener;

fn main() {
    let port = env::var("SERVER_PORT")
        .or_else(|_| env::var("PORT"))
        .or_else(|_| env::var("FEATHER_PORT"))
        .unwrap_or_else(|_| "8080".to_string());
    let addr = format!("0.0.0.0:{}", port);
    let listener = TcpListener::bind(&addr).expect("Could not bind port");
    println!("[PotenFYR] Rust server listening on http://{}", addr);

    for stream in listener.incoming() {
        if let Ok(mut stream) = stream {
            let body = "{\"status\":\"online\",\"message\":\"Hello from PotenFYR Rust Egg!\"}";
            let response = format!(
                "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: {}\r\nConnection: close\r\n\r\n{}",
                body.len(),
                body
            );
            let _ = stream.write_all(response.as_bytes());
        }
    }
}
EOF
            LANGUAGE="rust"
            ;;

        static|html)
            cat << 'EOF' > index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PotenFYR Static Server</title>
  <style>
    body { font-family: system-ui, -apple-system, sans-serif; background: #0f172a; color: #f8fafc; display: flex; align-items: center; justify-content: center; height: 100vh; margin: 0; }
    .card { background: #1e293b; padding: 2.5rem; border-radius: 1rem; box-shadow: 0 10px 25px rgba(0,0,0,0.5); text-align: center; border: 1px solid #334155; }
    h1 { color: #38bdf8; margin-top: 0; }
    p { color: #94a3b8; font-size: 1.1rem; }
    .badge { display: inline-block; background: #0284c7; color: white; padding: 0.25rem 0.75rem; border-radius: 9999px; font-size: 0.85rem; font-weight: 600; margin-top: 1rem; }
  </style>
</head>
<body>
  <div class="card">
    <h1>🚀 PotenFYR Static Server</h1>
    <p>Your static website / SPA is live and running at peak performance!</p>
    <div class="badge">Universal Programming Language Eggs</div>
  </div>
</body>
</html>
EOF
            LANGUAGE="static"
            ;;
    esac
    ok "Starter template generated"
fi

# -----------------------------------------------------------------------------
# 4. Multi-Process Supervisor (Procfile support)
# -----------------------------------------------------------------------------
run_procfile() {
    local procfile="Procfile"
    [ -f "${procfile}" ] || return 1
    
    log "Procfile detected! Launching Multi-Process Supervisor..."
    local pids=""

    while IFS=':' read -r name cmd || [ -n "$name" ]; do
        case "$name" in \#*) continue ;; esac
        [ -z "$name" ] && continue
        cmd=$(echo "$cmd" | sed -e 's/^[[:space:]]*//')
        [ -z "$cmd" ] && continue
        
        log "Starting process: [${name}] -> ${cmd}"
        (
            export PROCESS_NAME="${name}"
            eval "${cmd}" 2>&1 | while IFS= read -r line; do
                printf "\033[1;36m[%s]\033[0m %s\n" "${name}" "${line}"
            done
        ) &
        pids="${pids} $!"
    done < "${procfile}"

    if [ -n "${pids}" ]; then
        wait ${pids} 2>/dev/null || true
    fi
    exit 0
}

if [ -f "Procfile" ] && [ "${LANGUAGE}" = "auto" ] && [ -z "${CUSTOM_COMMAND}" ]; then
    run_procfile
fi

# -----------------------------------------------------------------------------
# 5. Project & Language Auto-Detection Engine
# -----------------------------------------------------------------------------
detect_language() {
    if [ "${LANGUAGE}" != "auto" ] && [ -n "${LANGUAGE}" ]; then
        echo "${LANGUAGE}" | tr '[:upper:]' '[:lower:]'
        return
    fi

    if [ -f "index.html" ] || [ -f "dist/index.html" ] || [ -f "build/index.html" ] || [ -f "public/index.html" ]; then
        if [ ! -f "package.json" ] && [ ! -f "main.py" ] && [ ! -f "main.go" ] && [ ! -f "Cargo.toml" ] && [ ! -f "pom.xml" ]; then
            echo "static"; return
        fi
    fi

    if [ -f "bun.lockb" ] || [ -f "bunfig.toml" ]; then
        echo "bun"; return
    fi
    if [ -f "deno.json" ] || [ -f "deno.jsonc" ]; then
        echo "deno"; return
    fi
    if [ -f "package.json" ]; then
        if grep -qE '"typescript"|"ts-node"|"tsx"' package.json 2>/dev/null; then
            echo "typescript"; return
        fi
        echo "nodejs"; return
    fi
    if [ -f "requirements.txt" ] || [ -f "Pipfile" ] || [ -f "pyproject.toml" ] || [ -f "main.py" ] || [ -f "app.py" ]; then
        echo "python"; return
    fi
    if [ -f "go.mod" ] || [ -f "main.go" ]; then
        echo "golang"; return
    fi
    if [ -f "Cargo.toml" ]; then
        echo "rust"; return
    fi
    if [ -f "pom.xml" ] || [ -f "build.gradle" ] || [ -f "build.gradle.kts" ] || ls *.jar 1>/dev/null 2>&1; then
        echo "java"; return
    fi
    if ls *.csproj 1>/dev/null 2>&1 || ls *.sln 1>/dev/null 2>&1 || [ -f "Program.cs" ]; then
        echo "dotnet"; return
    fi
    if [ -f "composer.json" ] || [ -f "index.php" ]; then
        echo "php"; return
    fi
    if [ -f "Gemfile" ] || ls *.rb 1>/dev/null 2>&1; then
        echo "ruby"; return
    fi
    if [ -f "Makefile" ] || [ -f "CMakeLists.txt" ] || ls *.cpp 1>/dev/null 2>&1 || ls *.c 1>/dev/null 2>&1; then
        echo "c-cpp"; return
    fi
    if [ -f "build.zig" ] || ls *.zig 1>/dev/null 2>&1; then
        echo "zig"; return
    fi
    if [ -f "Package.swift" ] || ls *.swift 1>/dev/null 2>&1; then
        echo "swift"; return
    fi
    if [ -f "pubspec.yaml" ] || ls *.dart 1>/dev/null 2>&1; then
        echo "dart"; return
    fi
    if [ -f "mix.exs" ] || ls *.ex 1>/dev/null 2>&1; then
        echo "elixir"; return
    fi
    if ls *.lua 1>/dev/null 2>&1; then
        echo "lua"; return
    fi
    if ls *.ts 1>/dev/null 2>&1; then
        echo "typescript"; return
    fi
    if ls *.js 1>/dev/null 2>&1; then
        echo "nodejs"; return
    fi

    # User shell scripts (skip system egg runner scripts)
    for sh_file in $(ls *.sh 2>/dev/null || true); do
        case "${sh_file}" in
            entrypoint.sh|run.sh|install.sh|install-runtime.sh) ;;
            *) echo "bash"; return ;;
        esac
    done

    echo "nodejs"
}

DETECTED_LANG=$(detect_language)
log "Target Language / Runtime: ${C_BOLD}${DETECTED_LANG}${C_RESET}"

if [ -n "${CUSTOM_RUNTIME_URL:-}" ]; then
    if [ -f /usr/local/bin/install-runtime.sh ]; then
        log "Downloading and configuring custom runtime from ${CUSTOM_RUNTIME_URL}..."
        /usr/local/bin/install-runtime.sh "custom" "${CUSTOM_RUNTIME_URL}" "${WORK_DIR}/.runtimes" || true
    fi
fi

# -----------------------------------------------------------------------------
# Dynamic Session-Layer PATH & Sandbox Isolation (Alternative 4 Hybrid Architecture)
# -----------------------------------------------------------------------------
build_isolated_environment() {
    local lang="${DETECTED_LANG}"
    local runner="${RUNNER:-auto}"

    # 1. Base clean system utilities
    local ISO_PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin"

    # 2. Local workspace project binaries (highest priority)
    ISO_PATH="${WORK_DIR}/.local/bin:${WORK_DIR}/bin:${WORK_DIR}/node_modules/.bin:${WORK_DIR}/.venv/bin:${ISO_PATH}"
    
    # 3. User-installed local runtimes (/home/container/.runtimes/<lang>/bin)
    if [ -d "${WORK_DIR}/.runtimes" ]; then
        ISO_PATH="${WORK_DIR}/.runtimes/bin:${WORK_DIR}/.runtimes/${lang}/bin:${WORK_DIR}/.runtimes/${runner}/bin:${ISO_PATH}"
    fi

    # 4. Activate ONLY the selected isolated runtime prefix
    case "${lang}" in
        typescript|ts)
            if [ "${runner}" = "bun" ]; then
                ISO_PATH="/opt/runtimes/bun/bin:${ISO_PATH}"
            elif [ "${runner}" = "deno" ]; then
                ISO_PATH="/opt/runtimes/deno/bin:${ISO_PATH}"
            else
                ISO_PATH="/opt/runtimes/node/bin:${ISO_PATH}"
            fi
            ;;
        bun)
            ISO_PATH="/opt/runtimes/bun/bin:${ISO_PATH}"
            ;;
        deno)
            ISO_PATH="/opt/runtimes/deno/bin:${ISO_PATH}"
            ;;
        node|nodejs|javascript|js)
            ISO_PATH="/opt/runtimes/node/bin:${ISO_PATH}"
            ;;
        python|py)
            ISO_PATH="/opt/runtimes/uv/bin:/opt/runtimes/python/bin:${ISO_PATH}"
            ;;
        rust)
            ISO_PATH="/opt/cargo/bin:${ISO_PATH}"
            ;;
        golang|go)
            ISO_PATH="${WORK_DIR}/go/bin:/opt/go/bin:/opt/runtimes/go/bin:${ISO_PATH}"
            ;;
        zig)
            ISO_PATH="/opt/runtimes/zig:${ISO_PATH}"
            ;;
        dart)
            ISO_PATH="/opt/runtimes/dart-sdk/bin:${ISO_PATH}"
            ;;
        dotnet)
            ISO_PATH="/opt/dotnet:${WORK_DIR}/.dotnet:${ISO_PATH}"
            ;;
    esac

    # 5. Handle EXTRA_RUNTIMES if specified (e.g. EXTRA_RUNTIMES="python,bun")
    if [ -n "${EXTRA_RUNTIMES:-}" ]; then
        local IFS=','
        for ext in ${EXTRA_RUNTIMES}; do
            ext=$(echo "${ext}" | tr -d "[:space:]" | tr "[:upper:]" "[:lower:]")
            [ -d "/opt/runtimes/${ext}/bin" ] && ISO_PATH="/opt/runtimes/${ext}/bin:${ISO_PATH}"
            [ -d "${WORK_DIR}/.runtimes/${ext}/bin" ] && ISO_PATH="${WORK_DIR}/.runtimes/${ext}/bin:${ISO_PATH}"
        done
    fi

    export PATH="${ISO_PATH}"

    # Per-language sandbox isolation directories
    export PYTHONUSERBASE="${WORK_DIR}/.local"
    export GOPATH="${WORK_DIR}/go"
    export GOCACHE="${WORK_DIR}/.cache/go-build"
    export CARGO_HOME="${WORK_DIR}/.cargo"
    export CARGO_TARGET_DIR="${WORK_DIR}/target"
    export BUN_INSTALL="${WORK_DIR}/.bun"
    export COMPOSER_HOME="${WORK_DIR}/.composer"
    export GEM_HOME="${WORK_DIR}/.gem"
    export DOTNET_CLI_HOME="${WORK_DIR}/.dotnet"
    mkdir -p "${WORK_DIR}/.local/bin" "${WORK_DIR}/bin" "${WORK_DIR}/.cache" 2>/dev/null || true
}

# Ensure runtime toolchain is present in container, install locally if absent
ensure_local_runtime() {
    build_isolated_environment

    local lang="${DETECTED_LANG}"
    local runner="${RUNNER:-auto}"
    
    # Check runner requirements
    if [ "${runner}" = "bun" ] && ! command -v bun >/dev/null 2>&1; then
        log "Runner 'bun' selected but not found in PATH. Installing Bun locally..."
        local inst_script=""
        [ -f "/usr/local/bin/install-runtime.sh" ] && inst_script="/usr/local/bin/install-runtime.sh"
        [ -z "${inst_script}" ] && [ -f "/install-runtime.sh" ] && inst_script="/install-runtime.sh"
        if [ -n "${inst_script}" ]; then
            bash "${inst_script}" "bun" "latest" "${WORK_DIR}/.runtimes" || true
            build_isolated_environment
        fi
    elif [ "${runner}" = "deno" ] && ! command -v deno >/dev/null 2>&1; then
        log "Runner 'deno' selected but not found in PATH. Installing Deno locally..."
        local inst_script=""
        [ -f "/usr/local/bin/install-runtime.sh" ] && inst_script="/usr/local/bin/install-runtime.sh"
        [ -z "${inst_script}" ] && [ -f "/install-runtime.sh" ] && inst_script="/install-runtime.sh"
        if [ -n "${inst_script}" ]; then
            bash "${inst_script}" "deno" "latest" "${WORK_DIR}/.runtimes" || true
            build_isolated_environment
        fi
    fi

    # Check language requirements
    local needed=0
    case "${lang}" in
        nodejs|javascript|js)
            command -v node >/dev/null 2>&1 || needed=1
            ;;
        typescript|ts)
            if [ "${runner}" = "bun" ]; then
                command -v bun >/dev/null 2>&1 || needed=1
                lang="bun"
            elif [ "${runner}" = "deno" ]; then
                command -v deno >/dev/null 2>&1 || needed=1
                lang="deno"
            else
                command -v node >/dev/null 2>&1 || needed=1
                lang="node"
            fi
            ;;
        bun)
            command -v bun >/dev/null 2>&1 || needed=1
            ;;
        python|py)
            command -v python3 >/dev/null 2>&1 || needed=1
            ;;
        golang|go)
            command -v go >/dev/null 2>&1 || needed=1
            ;;
        rust)
            command -v rustc >/dev/null 2>&1 || needed=1
            ;;
        java)
            command -v java >/dev/null 2>&1 || needed=1
            ;;
        dotnet)
            command -v dotnet >/dev/null 2>&1 || needed=1
            ;;
        php)
            command -v php >/dev/null 2>&1 || needed=1
            ;;
        ruby)
            command -v ruby >/dev/null 2>&1 || needed=1
            ;;
        zig)
            command -v zig >/dev/null 2>&1 || needed=1
            ;;
    esac

    if [ "${needed}" -eq 1 ]; then
        log "Runtime binary for '${lang}' not found in system PATH. Installing locally to container..."
        local inst_script=""
        if [ -f "/usr/local/bin/install-runtime.sh" ]; then
            inst_script="/usr/local/bin/install-runtime.sh"
        elif [ -f "/install-runtime.sh" ]; then
            inst_script="/install-runtime.sh"
        else
            mkdir -p /tmp/potenfyr 2>/dev/null || true
            curl -fsSL --retry 3 --connect-timeout 10 https://raw.githubusercontent.com/PotenFYR-Studios/Prog-Language-Eggs/main/install-runtime.sh -o /tmp/potenfyr/install-runtime.sh 2>/dev/null || true
            chmod +x /tmp/potenfyr/install-runtime.sh 2>/dev/null || true
            inst_script="/tmp/potenfyr/install-runtime.sh"
        fi
        
        if [ -f "${inst_script}" ]; then
            bash "${inst_script}" "${lang}" "${RUNTIME_VERSION:-latest}" "${WORK_DIR}/.runtimes" || true
            build_isolated_environment
        fi
    fi
}

ensure_local_runtime() {
    local lang="${DETECTED_LANG}"
    local runner="${RUNNER:-auto}"
    
    # Check runner requirements (e.g. user selected bun or deno engine)
    if [ "${runner}" = "bun" ] && ! command -v bun >/dev/null 2>&1; then
        log "Runner 'bun' selected but not found in PATH. Installing Bun locally..."
        local inst_script=""
        [ -f "/usr/local/bin/install-runtime.sh" ] && inst_script="/usr/local/bin/install-runtime.sh"
        [ -z "${inst_script}" ] && [ -f "/install-runtime.sh" ] && inst_script="/install-runtime.sh"
        if [ -n "${inst_script}" ]; then
            bash "${inst_script}" "bun" "latest" "${WORK_DIR}/.runtimes" || true
            export PATH="${WORK_DIR}/.runtimes/bin:${WORK_DIR}/.runtimes/bun/bin:/opt/runtimes/bun/bin:${PATH}"
        fi
    elif [ "${runner}" = "deno" ] && ! command -v deno >/dev/null 2>&1; then
        log "Runner 'deno' selected but not found in PATH. Installing Deno locally..."
        local inst_script=""
        [ -f "/usr/local/bin/install-runtime.sh" ] && inst_script="/usr/local/bin/install-runtime.sh"
        [ -z "${inst_script}" ] && [ -f "/install-runtime.sh" ] && inst_script="/install-runtime.sh"
        if [ -n "${inst_script}" ]; then
            bash "${inst_script}" "deno" "latest" "${WORK_DIR}/.runtimes" || true
            export PATH="${WORK_DIR}/.runtimes/bin:${WORK_DIR}/.runtimes/deno/bin:/opt/runtimes/deno/bin:${PATH}"
        fi
    fi

    # Check language requirements
    local needed=0
    case "${lang}" in
        nodejs|javascript|js)
            command -v node >/dev/null 2>&1 || needed=1
            ;;
        typescript|ts)
            if [ "${runner}" = "bun" ]; then
                command -v bun >/dev/null 2>&1 || needed=1
                lang="bun"
            elif [ "${runner}" = "deno" ]; then
                command -v deno >/dev/null 2>&1 || needed=1
                lang="deno"
            else
                command -v node >/dev/null 2>&1 || needed=1
            fi
            ;;
        bun)
            command -v bun >/dev/null 2>&1 || needed=1
            ;;
        python|py)
            command -v python3 >/dev/null 2>&1 || needed=1
            ;;
        golang|go)
            command -v go >/dev/null 2>&1 || needed=1
            ;;
        rust)
            command -v rustc >/dev/null 2>&1 || needed=1
            ;;
        java)
            command -v java >/dev/null 2>&1 || needed=1
            ;;
        dotnet)
            command -v dotnet >/dev/null 2>&1 || needed=1
            ;;
        php)
            command -v php >/dev/null 2>&1 || needed=1
            ;;
        ruby)
            command -v ruby >/dev/null 2>&1 || needed=1
            ;;
    esac

    if [ "${needed}" -eq 1 ]; then
        log "Runtime binary for '${lang}' not found in system PATH. Installing locally to container..."
        local inst_script=""
        if [ -f "/usr/local/bin/install-runtime.sh" ]; then
            inst_script="/usr/local/bin/install-runtime.sh"
        elif [ -f "/install-runtime.sh" ]; then
            inst_script="/install-runtime.sh"
        else
            mkdir -p /tmp/potenfyr 2>/dev/null || true
            curl -fsSL --retry 3 https://raw.githubusercontent.com/PotenFYR-Studios/Prog-Language-Eggs/main/install-runtime.sh -o /tmp/potenfyr/install-runtime.sh 2>/dev/null || true
            chmod +x /tmp/potenfyr/install-runtime.sh 2>/dev/null || true
            inst_script="/tmp/potenfyr/install-runtime.sh"
        fi
        
        if [ -f "${inst_script}" ]; then
            bash "${inst_script}" "${lang}" "${RUNTIME_VERSION:-latest}" "${WORK_DIR}/.runtimes" || true
            export PATH="${WORK_DIR}/.runtimes/bin:${WORK_DIR}/.runtimes/${lang}/bin:/opt/runtimes/${lang}/bin:${PATH}"
        fi
    fi
}

ensure_local_runtime

# -----------------------------------------------------------------------------
# 6. Pre-Run Hook Execution
# -----------------------------------------------------------------------------
if [ -n "${PRE_RUN_COMMAND}" ]; then
    log "Executing PRE_RUN_COMMAND: ${PRE_RUN_COMMAND}..."
    eval "${PRE_RUN_COMMAND}" || warn "Pre-run command finished with non-zero status"
    ok "Pre-run command finished"
fi

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 6.5. Companion Runtime Resolution (EXTRA_RUNTIMES & Complex App Support)
# -----------------------------------------------------------------------------
if [ -n "${EXTRA_RUNTIMES:-}" ]; then
    log "Configuring companion runtimes (EXTRA_RUNTIMES='${EXTRA_RUNTIMES}')..."
    IFS=',' read -ra ADDR <<< "${EXTRA_RUNTIMES}"
    for ext in "${ADDR[@]}"; do
        ext=$(echo "${ext}" | tr -d "[:space:]" | tr "[:upper:]" "[:lower:]")
        [ -z "${ext}" ] && continue
        if ! command -v "${ext}" >/dev/null 2>&1; then
            log "Installing companion runtime '${ext}' into isolated environment..."
            if [ -f /usr/local/bin/install-runtime.sh ]; then
                bash /usr/local/bin/install-runtime.sh "${ext}" "latest" "${WORK_DIR}/.runtimes" || true
            fi
        fi
    done
    build_isolated_environment
fi

if [ "${NODE_GYP_SUPPORT:-1}" = "1" ] && [ -f "package.json" ]; then
    if grep -qiE '("node-gyp"|"bindings"|"node-addon-api"|"canvas"|"sqlite3"|"bcrypt"|"sharp")' package.json 2>/dev/null; then
        if ! command -v python3 >/dev/null 2>&1; then
            log "Native C++/Python dependencies detected in package.json. Installing Python companion toolchain..."
            if [ -f /usr/local/bin/install-runtime.sh ]; then
                bash /usr/local/bin/install-runtime.sh "python" "latest" "${WORK_DIR}/.runtimes" >/dev/null 2>&1 || true
                build_isolated_environment
            fi
        fi
    fi
fi

# 7. Dependency Management & Package Installation
# -----------------------------------------------------------------------------
if [ "${AUTO_INSTALL_DEPS}" = "1" ]; then
    log "Synchronizing dependencies (AUTO_INSTALL_DEPS=1)..."
    case "${DETECTED_LANG}" in
        nodejs|javascript|js)
            if [ -f "package.json" ]; then
                if [ -f "pnpm-lock.yaml" ] && command -v pnpm >/dev/null 2>&1; then
                    log "Installing via pnpm..."
                    pnpm install --frozen-lockfile 2>/dev/null || pnpm install || true
                elif [ -f "yarn.lock" ] && command -v yarn >/dev/null 2>&1; then
                    log "Installing via yarn..."
                    yarn install --frozen-lockfile 2>/dev/null || yarn install || true
                elif [ -f "bun.lockb" ] && command -v bun >/dev/null 2>&1; then
                    log "Installing via bun..."
                    bun install || true
                else
                    log "Installing via npm..."
                    npm install --no-audit --no-fund 2>/dev/null || true
                fi
            fi
            ;;

        typescript|ts)
            if [ -f "package.json" ]; then
                if [ -f "pnpm-lock.yaml" ] && command -v pnpm >/dev/null 2>&1; then
                    pnpm install || true
                elif [ -f "yarn.lock" ] && command -v yarn >/dev/null 2>&1; then
                    yarn install || true
                elif [ -f "bun.lockb" ] && command -v bun >/dev/null 2>&1; then
                    bun install || true
                else
                    npm install --no-audit --no-fund 2>/dev/null || true
                fi
            fi
            ;;

        bun)
            if [ -f "package.json" ]; then
                bun install || true
            fi
            ;;

        python|py)
            if [ -f "requirements.txt" ]; then
                log "Installing Python packages from requirements.txt..."
                if command -v uv >/dev/null 2>&1; then
                    uv pip install -r requirements.txt --system 2>/dev/null || pip3 install -r requirements.txt || true
                else
                    pip3 install -r requirements.txt --no-warn-script-location 2>/dev/null || pip install -r requirements.txt || true
                fi
            elif [ -f "pyproject.toml" ] && command -v poetry >/dev/null 2>&1; then
                poetry install --no-interaction 2>/dev/null || true
            elif [ -f "Pipfile" ] && command -v pipenv >/dev/null 2>&1; then
                pipenv install --deploy 2>/dev/null || pipenv install || true
            fi
            ;;

        golang|go)
            if [ -f "go.mod" ]; then
                go mod download 2>/dev/null || true
            fi
            ;;

        rust|rs)
            if [ -f "Cargo.toml" ]; then
                cargo fetch 2>/dev/null || true
            fi
            ;;

        php)
            if [ -f "composer.json" ] && command -v composer >/dev/null 2>&1; then
                composer install --no-interaction --prefer-dist --optimize-autoloader 2>/dev/null || composer install || true
            fi
            ;;

        ruby)
            if [ -f "Gemfile" ] && command -v bundle >/dev/null 2>&1; then
                bundle install 2>/dev/null || true
            fi
            ;;

        dotnet)
            if ls *.csproj 1>/dev/null 2>&1 || ls *.sln 1>/dev/null 2>&1; then
                dotnet restore 2>/dev/null || true
            fi
            ;;
    esac
    ok "Dependencies ready"
fi

# -----------------------------------------------------------------------------
# 8. Build / Compilation Step
# -----------------------------------------------------------------------------
if [ -n "${BUILD_COMMAND}" ]; then
    log "Executing BUILD_COMMAND: ${BUILD_COMMAND}..."
    eval "${BUILD_COMMAND}" || true
    ok "Build command completed"
fi

if [ "${CLEAN_BUILD_CACHE}" = "1" ]; then
    rm -rf /tmp/.npm /tmp/.cargo /tmp/.cache /root/.cache ~/.npm/_cacache /tmp/pip* /tmp/*.tar.* /tmp/*.zip 2>/dev/null || true
fi

# -----------------------------------------------------------------------------
# 9. Entrypoint & Execution Dispatch
# -----------------------------------------------------------------------------
resolve_main_file() {
    if [ "${MAIN_FILE}" != "auto" ] && [ -n "${MAIN_FILE}" ]; then
        echo "${MAIN_FILE}"
        return
    fi

    case "${DETECTED_LANG}" in
        nodejs|javascript|js)
            for f in index.js app.js server.js main.js src/index.js src/app.js src/server.js src/main.js; do
                [ -f "$f" ] && echo "$f" && return
            done
            echo "index.js"
            ;;
        typescript|ts)
            for f in src/index.ts index.ts src/app.ts app.ts src/server.ts server.ts src/main.ts main.ts; do
                [ -f "$f" ] && echo "$f" && return
            done
            echo "src/index.ts"
            ;;
        bun)
            for f in index.ts index.js src/index.ts src/index.js app.ts server.ts main.ts; do
                [ -f "$f" ] && echo "$f" && return
            done
            echo "index.ts"
            ;;
        deno)
            for f in main.ts index.ts app.ts main.js index.js; do
                [ -f "$f" ] && echo "$f" && return
            done
            echo "main.ts"
            ;;
        python|py)
            for f in main.py app.py server.py bot.py src/main.py src/app.py manage.py; do
                [ -f "$f" ] && echo "$f" && return
            done
            echo "main.py"
            ;;
        golang|go)
            for f in main.go cmd/server/main.go cmd/main.go; do
                [ -f "$f" ] && echo "$f" && return
            done
            echo "main.go"
            ;;
        php)
            for f in index.php server.php app.php public/index.php; do
                [ -f "$f" ] && echo "$f" && return
            done
            echo "index.php"
            ;;
        ruby)
            for f in app.rb main.rb server.rb config.ru; do
                [ -f "$f" ] && echo "$f" && return
            done
            echo "app.rb"
            ;;
        static)
            for f in dist/index.html build/index.html public/index.html index.html; do
                [ -f "$f" ] && echo "$f" && return
            done
            echo "index.html"
            ;;
        bash|sh)
            for f in start.sh run.sh main.sh server.sh app.sh; do
                [ -f "$f" ] && echo "$f" && return
            done
            local sh_candidate
            sh_candidate=$(ls *.sh 2>/dev/null | grep -vE '^(entrypoint|run|install|install-runtime)\.sh$' | head -n1 || true)
            [ -n "${sh_candidate}" ] && echo "${sh_candidate}" && return
            echo "start.sh"
            ;;
        *)
            echo "index.js"
            ;;
    esac
}

RESOLVED_MAIN=$(resolve_main_file)

# Ensure fallback entrypoint exists so initial container run does not crash
if [ ! -f "${RESOLVED_MAIN}" ] && [ "${DETECTED_LANG}" != "static" ] && [ -z "${CUSTOM_COMMAND}" ]; then
    mkdir -p "$(dirname "${RESOLVED_MAIN}")" 2>/dev/null || true
    case "${DETECTED_LANG}" in
        nodejs|javascript|js)
            cat << 'EOF' > "${RESOLVED_MAIN}"
const http = require('http');
const port = process.env.SERVER_PORT || process.env.PORT || 8080;
const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    status: 'online',
    message: 'Hello from PotenFYR Universal Multi-Languages Runtime!',
    runtime: `Node.js ${process.version}`,
    timestamp: new Date().toISOString()
  }, null, 2));
});
server.listen(port, '0.0.0.0', () => {
  console.log(`[PotenFYR] Node.js server listening on port ${port}`);
});
EOF
            ok "Initialized entrypoint: ${RESOLVED_MAIN}"
            ;;

        typescript|ts)
            cat << 'EOF' > "${RESOLVED_MAIN}"
import http from 'http';
const port = Number(process.env.SERVER_PORT || process.env.PORT || 8080);
const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    status: 'online',
    message: 'Hello from PotenFYR TypeScript Runtime!',
    runtime: `Node.js ${process.version}`,
    timestamp: new Date().toISOString()
  }, null, 2));
});
server.listen(port, '0.0.0.0', () => {
  console.log(`[PotenFYR] TypeScript server listening on port ${port}`);
});
EOF
            ok "Initialized entrypoint: ${RESOLVED_MAIN}"
            ;;

        bun)
            cat << 'EOF' > "${RESOLVED_MAIN}"
const port = Number(process.env.SERVER_PORT || process.env.PORT || 8080);
console.log(`[PotenFYR] Bun HTTP server listening on port ${port}`);
Bun.serve({
  port: port,
  fetch(req) {
    return new Response(JSON.stringify({
      status: "online",
      message: "Hello from PotenFYR Bun Runtime!",
      runtime: `Bun ${Bun.version}`,
      timestamp: new Date().toISOString()
    }, null, 2), {
      headers: { "Content-Type": "application/json" }
    });
  }
});
EOF
            ok "Initialized entrypoint: ${RESOLVED_MAIN}"
            ;;

        python|py)
            cat << 'EOF' > "${RESOLVED_MAIN}"
import os
from http.server import HTTPServer, BaseHTTPRequestHandler
import json
from datetime import datetime

PORT = int(os.environ.get("SERVER_PORT", os.environ.get("PORT", 8080)))

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps({
            "status": "online",
            "message": "Hello from PotenFYR Python Runtime!",
            "runtime": f"Python {os.sys.version.split()[0]}",
            "timestamp": datetime.utcnow().isoformat()
        }, indent=2).encode())

print(f"[PotenFYR] Python HTTP server listening on port {PORT}")
HTTPServer(('0.0.0.0', PORT), Handler).serve_forever()
EOF
            ok "Initialized entrypoint: ${RESOLVED_MAIN}"
            ;;

        golang|go)
            cat << 'EOF' > "${RESOLVED_MAIN}"
package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"runtime"
	"time"
)

func main() {
	port := os.Getenv("SERVER_PORT")
	if port == "" {
		port = os.Getenv("PORT")
	}
	if port == "" {
		port = "8080"
	}

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]string{
			"status":    "online",
			"message":   "Hello from PotenFYR Go Runtime!",
			"runtime":   runtime.Version(),
			"timestamp": time.Now().Format(time.RFC3339),
		})
	})

	fmt.Printf("[PotenFYR] Go HTTP server listening on port %s\n", port)
	http.ListenAndServe("0.0.0.0:"+port, nil)
}
EOF
            [ -f "go.mod" ] || go mod init potenfyr-server 2>/dev/null || true
            ok "Initialized entrypoint: ${RESOLVED_MAIN}"
            ;;

        php)
            cat << 'EOF' > "${RESOLVED_MAIN}"
<?php
$port = getenv('SERVER_PORT') ?: (getenv('PORT') ?: 8080);
header('Content-Type: application/json');
echo json_encode([
    'status' => 'online',
    'message' => 'Hello from PotenFYR PHP Runtime!',
    'runtime' => 'PHP ' . PHP_VERSION,
    'timestamp' => gmdate('c')
], JSON_PRETTY_PRINT);
EOF
            ok "Initialized entrypoint: ${RESOLVED_MAIN}"
            ;;

        ruby)
            cat << 'EOF' > "${RESOLVED_MAIN}"
require 'webrick'
require 'json'
require 'time'

port = (ENV['SERVER_PORT'] || ENV['PORT'] || 8080).to_i
server = WEBrick::HTTPServer.new(:Port => port, :BindAddress => '0.0.0.0', :Logger => WEBrick::Log.new('/dev/null'), :AccessLog => [])

server.mount_proc '/' do |req, res|
  res['Content-Type'] = 'application/json'
  res.body = JSON.pretty_generate({
    status: 'online',
    message: 'Hello from PotenFYR Ruby Runtime!',
    runtime: "Ruby #{RUBY_VERSION}",
    timestamp: Time.now.utc.iso8601
  })
end

trap('INT') { server.shutdown }
puts "[PotenFYR] Ruby server listening on port #{port}"
server.start
EOF
            ok "Initialized entrypoint: ${RESOLVED_MAIN}"
            ;;
    esac
fi

construct_run_cmd() {
    if [ -n "${CUSTOM_COMMAND}" ]; then
        echo "${CUSTOM_COMMAND}"
        return
    fi

    if [ "${DETECTED_LANG}" = "static" ]; then
        local static_dir="."
        [ -d "dist" ] && static_dir="dist"
        [ -d "build" ] && static_dir="build"
        [ -d "public" ] && static_dir="public"
        
        if command -v bun >/dev/null 2>&1; then
            echo "bun x serve -p ${SERVER_PORT} -s ${static_dir}"
        else
            echo "python3 -m http.server ${SERVER_PORT} --directory ${static_dir}"
        fi
        return
    fi

    case "${DETECTED_LANG}" in
        nodejs|javascript|js)
            local watch_flag=""
            [ "${DEV_MODE}" = "1" ] && watch_flag="--watch"
            
            if [ "${RUNNER}" = "npm" ]; then
                echo "npm start ${EXTRA_ARGS}"
            elif [ "${RUNNER}" = "yarn" ]; then
                echo "yarn start ${EXTRA_ARGS}"
            elif [ "${RUNNER}" = "pnpm" ]; then
                echo "pnpm start ${EXTRA_ARGS}"
            elif [ "${RUNNER}" = "pm2" ]; then
                echo "pm2-runtime ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            elif [ "${RUNNER}" = "nodemon" ] || [ "${DEV_MODE}" = "1" ]; then
                echo "node ${watch_flag} ${EXTRA_ARGS} ${RESOLVED_MAIN}"
            else
                echo "node ${EXTRA_ARGS} ${RESOLVED_MAIN}"
            fi
            ;;

        typescript|ts)
            if [ "${RUNNER}" = "bun" ]; then
                local bun_watch=""
                [ "${DEV_MODE}" = "1" ] && bun_watch="--watch"
                echo "bun run ${bun_watch} ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            elif [ "${RUNNER}" = "deno" ]; then
                local deno_watch=""
                [ "${DEV_MODE}" = "1" ] && deno_watch="--watch"
                echo "deno run -A ${deno_watch} ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            elif [ "${RUNNER}" = "tsx" ]; then
                local tsx_watch=""
                [ "${DEV_MODE}" = "1" ] && tsx_watch="watch"
                if command -v tsx >/dev/null 2>&1; then
                    echo "tsx ${tsx_watch} ${RESOLVED_MAIN} ${EXTRA_ARGS}"
                else
                    echo "npx -y tsx ${tsx_watch} ${RESOLVED_MAIN} ${EXTRA_ARGS}"
                fi
            elif [ "${RUNNER}" = "ts-node" ]; then
                if command -v ts-node >/dev/null 2>&1; then
                    echo "ts-node ${RESOLVED_MAIN} ${EXTRA_ARGS}"
                else
                    echo "npx -y ts-node ${RESOLVED_MAIN} ${EXTRA_ARGS}"
                fi
            elif [ "${RUNNER}" = "tsc" ]; then
                echo "tsc && node dist/index.js ${EXTRA_ARGS}"
            else
                if command -v bun >/dev/null 2>&1; then
                    local bun_watch=""
                    [ "${DEV_MODE}" = "1" ] && bun_watch="--watch"
                    echo "bun run ${bun_watch} ${RESOLVED_MAIN} ${EXTRA_ARGS}"
                elif command -v tsx >/dev/null 2>&1; then
                    local tsx_watch=""
                    [ "${DEV_MODE}" = "1" ] && tsx_watch="watch"
                    echo "tsx ${tsx_watch} ${RESOLVED_MAIN} ${EXTRA_ARGS}"
                elif command -v ts-node >/dev/null 2>&1; then
                    echo "ts-node ${RESOLVED_MAIN} ${EXTRA_ARGS}"
                else
                    echo "npx -y tsx ${RESOLVED_MAIN} ${EXTRA_ARGS}"
                fi
            fi
            ;;

        bun)
            local bun_watch=""
            [ "${DEV_MODE}" = "1" ] && bun_watch="--watch"
            echo "bun run ${bun_watch} ${EXTRA_ARGS} ${RESOLVED_MAIN}"
            ;;

        deno)
            local deno_watch=""
            [ "${DEV_MODE}" = "1" ] && deno_watch="--watch"
            echo "deno run -A --unstable ${deno_watch} ${EXTRA_ARGS} ${RESOLVED_MAIN}"
            ;;

        python|py)
            if [ "${RUNNER}" = "uvicorn" ]; then
                local uvi_reload=""
                [ "${DEV_MODE}" = "1" ] && uvi_reload="--reload"
                MOD_NAME=$(basename "${RESOLVED_MAIN}" .py)
                echo "uvicorn ${MOD_NAME}:app --host 0.0.0.0 --port ${SERVER_PORT} ${uvi_reload} ${EXTRA_ARGS}"
            elif [ "${RUNNER}" = "gunicorn" ]; then
                MOD_NAME=$(basename "${RESOLVED_MAIN}" .py)
                echo "gunicorn -b 0.0.0.0:${SERVER_PORT} ${MOD_NAME}:app ${EXTRA_ARGS}"
            elif [ "${RUNNER}" = "poetry" ]; then
                echo "poetry run python ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            elif [ "${RUNNER}" = "pipenv" ]; then
                echo "pipenv run python ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            else
                echo "python3 ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            fi
            ;;

        golang|go)
            if [ -f "./server" ]; then
                echo "./server ${EXTRA_ARGS}"
            elif [ -f "${RESOLVED_MAIN}" ]; then
                echo "go run ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            else
                echo "go run . ${EXTRA_ARGS}"
            fi
            ;;

        rust|rs)
            if [ -f "./target/release/server" ]; then
                echo "./target/release/server ${EXTRA_ARGS}"
            elif [ -f "Cargo.toml" ]; then
                echo "cargo run --release ${EXTRA_ARGS}"
            else
                echo "rustc ${RESOLVED_MAIN} -o server && ./server ${EXTRA_ARGS}"
            fi
            ;;

        java|jdk|openjdk)
            local jvm_flags="${JAVA_AUTO_MEM_FLAGS} ${JAVA_AUTO_GC} ${EXTRA_ARGS}"
            JAR_FOUND=$(ls *.jar 2>/dev/null | head -n1 || true)
            if [ -n "${JAR_FOUND}" ]; then
                echo "java ${jvm_flags} -jar ${JAR_FOUND}"
            elif [ -f "pom.xml" ]; then
                [ -x "./mvnw" ] && echo "./mvnw spring-boot:run" || echo "mvn spring-boot:run"
            elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
                [ -x "./gradlew" ] && echo "./gradlew bootRun" || echo "gradle bootRun"
            elif [ -f "Main.java" ]; then
                echo "java ${jvm_flags} Main.java"
            else
                echo "java ${jvm_flags} -jar ${MAIN_FILE}"
            fi
            ;;

        c-cpp|cpp|c)
            if [ -f "Makefile" ]; then
                echo "make run ${EXTRA_ARGS}"
            elif [ -f "./server" ]; then
                echo "./server ${EXTRA_ARGS}"
            elif [ -f "./a.out" ]; then
                echo "./a.out ${EXTRA_ARGS}"
            elif ls *.cpp 1>/dev/null 2>&1; then
                CPP_FILE=$(ls *.cpp | head -n1)
                echo "g++ -O3 ${CPP_FILE} -o server && ./server ${EXTRA_ARGS}"
            elif ls *.c 1>/dev/null 2>&1; then
                C_FILE=$(ls *.c | head -n1)
                echo "gcc -O3 ${C_FILE} -o server && ./server ${EXTRA_ARGS}"
            else
                echo "./server ${EXTRA_ARGS}"
            fi
            ;;

        php)
            if [ "${RUNNER}" = "artisan" ]; then
                echo "php artisan serve --host=0.0.0.0 --port=${SERVER_PORT} ${EXTRA_ARGS}"
            else
                echo "php -S 0.0.0.0:${SERVER_PORT} ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            fi
            ;;

        dotnet|csharp|fsharp|vb)
            echo "dotnet run ${EXTRA_ARGS}"
            ;;

        ruby)
            if [ -f "Gemfile" ] && command -v bundle >/dev/null 2>&1; then
                echo "bundle exec ruby ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            else
                echo "ruby ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            fi
            ;;

        zig)
            if [ -f "build.zig" ]; then
                echo "zig build run ${EXTRA_ARGS}"
            else
                echo "zig run ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            fi
            ;;

        swift)
            if [ -f "Package.swift" ]; then
                echo "swift run ${EXTRA_ARGS}"
            else
                echo "swift ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            fi
            ;;

        dart)
            echo "dart run ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            ;;

        lua)
            if command -v luajit >/dev/null 2>&1; then
                echo "luajit ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            else
                echo "lua ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            fi
            ;;

        elixir)
            if [ -f "mix.exs" ]; then
                echo "mix run --no-halt ${EXTRA_ARGS}"
            else
                echo "elixir ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            fi
            ;;

        erlang)
            if [ -f "rebar.config" ]; then
                echo "rebar3 shell"
            else
                echo "escript ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            fi
            ;;

        haskell)
            if [ -f "*.cabal" ] || [ -f "stack.yaml" ]; then
                echo "cabal run ${EXTRA_ARGS}"
            else
                echo "runghc ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            fi
            ;;

        perl)
            echo "perl ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            ;;

        r)
            echo "Rscript ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            ;;

        julia)
            echo "julia ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            ;;

        clojure)
            if [ -f "project.clj" ]; then
                echo "lein run ${EXTRA_ARGS}"
            else
                echo "clojure -M ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            fi
            ;;

        groovy)
            echo "groovy ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            ;;

        crystal)
            echo "crystal run ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            ;;

        nim)
            echo "nim r -d:release ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            ;;

        ocaml)
            if [ -f "dune-project" ]; then
                echo "dune exec ./main.exe ${EXTRA_ARGS}"
            else
                echo "ocaml ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            fi
            ;;

        fortran)
            echo "gfortran ${RESOLVED_MAIN} -o app && ./app ${EXTRA_ARGS}"
            ;;

        pascal)
            echo "fpc ${RESOLVED_MAIN} && ./$(basename "${RESOLVED_MAIN}" .pas) ${EXTRA_ARGS}"
            ;;

        cobol)
            echo "cobc -x -free ${RESOLVED_MAIN} -o cobapp && ./cobapp ${EXTRA_ARGS}"
            ;;

        v)
            echo "v run ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            ;;

        odin)
            echo "odin run . ${EXTRA_ARGS}"
            ;;

        gleam)
            echo "gleam run ${EXTRA_ARGS}"
            ;;

        bash|sh)
            if [ -n "${RESOLVED_MAIN}" ] && [ -f "${RESOLVED_MAIN}" ]; then
                echo "bash ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            else
                echo "node index.js ${EXTRA_ARGS}"
            fi
            ;;

        powershell|pwsh)
            echo "pwsh ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            ;;

        *)
            echo "node ${RESOLVED_MAIN} ${EXTRA_ARGS}"
            ;;
    esac
}

RUN_CMD=$(construct_run_cmd)

# -----------------------------------------------------------------------------
# 10. Execution Loop & Process Handling
# -----------------------------------------------------------------------------
RUN_LOOP=1
CHILD_PID=0

handle_signal() {
    log "Received shutdown signal. Relaying to child process (PID: ${CHILD_PID})..."
    RUN_LOOP=0
    if [ "${CHILD_PID}" -ne 0 ]; then
        kill -TERM "${CHILD_PID}" 2>/dev/null || true
        wait "${CHILD_PID}" 2>/dev/null || true
    fi
    
    if [ -n "${POST_RUN_COMMAND}" ]; then
        log "Executing POST_RUN_COMMAND: ${POST_RUN_COMMAND}..."
        eval "${POST_RUN_COMMAND}" || true
    fi
    
    ok "Application process stopped cleanly"
    exit 0
}

trap handle_signal SIGTERM SIGINT SIGHUP

while [ "${RUN_LOOP}" -eq 1 ]; do
    log "Starting application process..."
    printf "${C_GREEN}${C_BOLD}>>> %s${C_RESET}\n\n" "${RUN_CMD}"
    
    eval "${RUN_CMD}" &
    CHILD_PID=$!
    
    wait "${CHILD_PID}" 2>/dev/null
    EXIT_CODE=$?
    CHILD_PID=0
    
    if [ "${RUN_LOOP}" -eq 0 ]; then
        break
    fi

    if [ "${AUTO_RESTART}" = "1" ]; then
        warn "Process exited with code ${EXIT_CODE}. AUTO_RESTART is enabled."
        log "Restarting in ${RESTART_DELAY} seconds... (Press Ctrl+C to abort)"
        sleep "${RESTART_DELAY}"
    else
        log "Process exited with code ${EXIT_CODE}."
        if [ -n "${POST_RUN_COMMAND}" ]; then
            eval "${POST_RUN_COMMAND}" || true
        fi
        exit "${EXIT_CODE}"
    fi
done
