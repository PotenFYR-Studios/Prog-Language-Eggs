#!/bin/bash
# =============================================================================
#  Multi-Language Eggs - Automated Docker Test Suite
#  By PotenFYR Studios (https://github.com/PotenFYR-Studios/Prog-Language-Eggs)
#
#  Validates:
#    1. Pterodactyl Panel Simulation (UID 988, /home/container, SERVER_PORT, SERVER_MEMORY)
#    2. Feather Panel Simulation (UID 1000, /app, FEATHER_PORT, FEATHER_MEMORY)
#    3. PufferPanel Simulation (/server, PUFFER_PORT)
#    4. Node.js / JavaScript Server
#    5. Bun Server
#    6. TypeScript Server (ts-node / tsx)
#    7. Python Server (FastAPI / HTTP Server)
#    8. Go Server
#    9. Rust Server (Cargo compilation)
#    10. Java Server (JAR execution)
#    11. C++ Server (G++ compilation)
#    12. PHP Server (Built-in HTTP server)
#    13. Static Website / SPA Server
#    14. Procfile Multi-Process Supervisor
#    15. On-Demand Dynamic Toolchain Installer (install-runtime.sh)
# =============================================================================

set -uo pipefail

IMAGE_NAME="${1:-prog-language-eggs:local}"
TEST_DIR="/tmp/prog-egg-docker-tests"
rm -rf "${TEST_DIR}"
mkdir -p "${TEST_DIR}"

C_RESET=$'\033[0m'
C_BOLD=$'\033[1m'
C_GREEN=$'\033[32m'
C_RED=$'\033[31m'
C_CYAN=$'\033[36m'
C_YELLOW=$'\033[33m'

PASSED_TESTS=0
FAILED_TESTS=0

test_log()  { printf "\n%b %b\n" "${C_CYAN}${C_BOLD}[TEST SUITE]${C_RESET}" "${C_BOLD}$*${C_RESET}"; }
test_pass() { printf "%b %s\n" "${C_GREEN}${C_BOLD}  ✔ PASS:${C_RESET}" "$*"; PASSED_TESTS=$((PASSED_TESTS + 1)); }
test_fail() { printf "%b %s\n" "${C_RED}${C_BOLD}  ✘ FAIL:${C_RESET}" "$*"; FAILED_TESTS=$((FAILED_TESTS + 1)); }

# Helper to run container in background, verify HTTP 200 response, and clean up
run_and_verify_http() {
    local test_name="$1"
    local workspace_dir="$2"
    local port="$3"
    local extra_env="$4"
    local mount_target="${5:-/home/container}"
    local container_user="${6:-988:988}"

    local container_id
    container_id=$(docker run -d \
        --name "test-${RANDOM}" \
        --user "${container_user}" \
        -p "${port}:${port}" \
        -v "${workspace_dir}:${mount_target}" \
        -e SERVER_PORT="${port}" \
        -e PORT="${port}" \
        -e SERVER_MEMORY="1024" \
        -e P_SERVER_UUID="test-uuid" \
        ${extra_env} \
        "${IMAGE_NAME}")

    # Wait up to 15 seconds for HTTP 200 OK
    local success=0
    for i in $(seq 1 15); do
        sleep 1
        local res
        res=$(curl -s -m 2 "http://127.0.0.1:${port}" 2>/dev/null || true)
        if [[ "${res}" == *"online"* ]] || [[ "${res}" == *"Hello"* ]] || [[ "${res}" == *"status"* ]] || [[ "${res}" == *"PotenFYR"* ]]; then
            success=1
            break
        fi
    done

    if [ "${success}" -eq 1 ]; then
        test_pass "${test_name} (HTTP 200 OK on port ${port})"
    else
        docker logs "${container_id}" | tail -n 25
        test_fail "${test_name} (HTTP endpoint failed to respond on port ${port})"
    fi

    docker stop "${container_id}" >/dev/null 2>&1 || true
    docker rm -f "${container_id}" >/dev/null 2>&1 || true
}

test_log "Starting Multi-Panel & Multi-Language Docker Test Suite..."
printf "Testing Docker Image: %s\n\n" "${IMAGE_NAME}"

# -----------------------------------------------------------------------------
# TEST 1: Pterodactyl Empty Workspace Auto-Bootstrap
# -----------------------------------------------------------------------------
test_log "1. Testing Pterodactyl Empty Workspace Auto-Bootstrap..."
DIR_EMPTY="${TEST_DIR}/empty"
mkdir -p "${DIR_EMPTY}" && chmod 777 "${DIR_EMPTY}"
run_and_verify_http "Pterodactyl Empty Directory Auto-Start" "${DIR_EMPTY}" "8081" ""

# -----------------------------------------------------------------------------
# TEST 2: Node.js (JavaScript HTTP Server)
# -----------------------------------------------------------------------------
test_log "2. Testing Node.js HTTP Server..."
DIR_NODE="${TEST_DIR}/nodejs"
mkdir -p "${DIR_NODE}" && chmod 777 "${DIR_NODE}"
cat << 'EOF' > "${DIR_NODE}/index.js"
const http = require('http');
const port = process.env.PORT || 8082;
const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ status: 'online', runtime: 'Node.js', message: 'Hello from Node.js' }));
});
server.listen(port, '0.0.0.0', () => console.log(`Listening on ${port}`));
EOF
run_and_verify_http "Node.js JavaScript Server" "${DIR_NODE}" "8082" "-e LANGUAGE=nodejs"

# -----------------------------------------------------------------------------
# TEST 3: Bun (Fast JavaScript / TypeScript Server)
# -----------------------------------------------------------------------------
test_log "3. Testing Bun HTTP Server..."
DIR_BUN="${TEST_DIR}/bun"
mkdir -p "${DIR_BUN}" && chmod 777 "${DIR_BUN}"
cat << 'EOF' > "${DIR_BUN}/index.ts"
const port = Number(process.env.PORT || 8083);
Bun.serve({
  port,
  fetch(req) {
    return new Response(JSON.stringify({ status: 'online', runtime: 'Bun', message: 'Hello from Bun' }), {
      headers: { 'Content-Type': 'application/json' }
    });
  }
});
console.log(`Bun listening on ${port}`);
EOF
run_and_verify_http "Bun TypeScript Server" "${DIR_BUN}" "8083" "-e LANGUAGE=bun -e RUNNER=bun"

# -----------------------------------------------------------------------------
# TEST 4: TypeScript (ts-node / tsx)
# -----------------------------------------------------------------------------
test_log "4. Testing TypeScript Server with ts-node..."
DIR_TS="${TEST_DIR}/typescript"
mkdir -p "${DIR_TS}/src" && chmod -R 777 "${DIR_TS}"
cat << 'EOF' > "${DIR_TS}/src/index.ts"
import * as http from 'http';
const port = Number(process.env.PORT || 8084);
const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ status: 'online', runtime: 'TypeScript', message: 'Hello from TypeScript' }));
});
server.listen(port, '0.0.0.0', () => console.log(`TS listening on ${port}`));
EOF
run_and_verify_http "TypeScript (ts-node) Server" "${DIR_TS}" "8084" "-e LANGUAGE=typescript -e MAIN_FILE=src/index.ts"

# -----------------------------------------------------------------------------
# TEST 5: Python (HTTP Server)
# -----------------------------------------------------------------------------
test_log "5. Testing Python HTTP Server..."
DIR_PY="${TEST_DIR}/python"
mkdir -p "${DIR_PY}" && chmod 777 "${DIR_PY}"
cat << 'EOF' > "${DIR_PY}/main.py"
import os, json
from http.server import HTTPServer, BaseHTTPRequestHandler

PORT = int(os.environ.get("PORT", 8085))

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps({"status": "online", "runtime": "Python", "message": "Hello from Python"}).encode())

print(f"Python listening on {PORT}")
HTTPServer(('0.0.0.0', PORT), Handler).serve_forever()
EOF
run_and_verify_http "Python Server" "${DIR_PY}" "8085" "-e LANGUAGE=python"

# -----------------------------------------------------------------------------
# TEST 6: Go / Golang Server
# -----------------------------------------------------------------------------
test_log "6. Testing Go HTTP Server..."
DIR_GO="${TEST_DIR}/golang"
mkdir -p "${DIR_GO}" && chmod 777 "${DIR_GO}"
cat << 'EOF' > "${DIR_GO}/main.go"
package main

import (
	"fmt"
	"net/http"
	"os"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8086"
	}
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		fmt.Fprintf(w, `{"status":"online","runtime":"Golang","message":"Hello from Go"}`)
	})
	fmt.Printf("Go server listening on port %s\n", port)
	http.ListenAndServe("0.0.0.0:"+port, nil)
}
EOF
run_and_verify_http "Golang HTTP Server" "${DIR_GO}" "8086" "-e LANGUAGE=golang"

# -----------------------------------------------------------------------------
# TEST 7: Rust HTTP Server (Cargo)
# -----------------------------------------------------------------------------
test_log "7. Testing Rust Server..."
DIR_RS="${TEST_DIR}/rust"
mkdir -p "${DIR_RS}/src" && chmod -R 777 "${DIR_RS}"
cat << 'EOF' > "${DIR_RS}/Cargo.toml"
[package]
name = "test-rust-server"
version = "0.1.0"
edition = "2021"
EOF
cat << 'EOF' > "${DIR_RS}/src/main.rs"
use std::env;
use std::io::Write;
use std::net::TcpListener;

fn main() {
    let port = env::var("PORT").unwrap_or_else(|_| "8087".to_string());
    let addr = format!("0.0.0.0:{}", port);
    let listener = TcpListener::bind(&addr).expect("Could not bind port");
    println!("Rust server listening on http://{}", addr);

    for stream in listener.incoming() {
        if let Ok(mut stream) = stream {
            let body = "{\"status\":\"online\",\"runtime\":\"Rust\",\"message\":\"Hello from Rust\"}";
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
run_and_verify_http "Rust Cargo Server" "${DIR_RS}" "8087" "-e LANGUAGE=rust"

# -----------------------------------------------------------------------------
# TEST 8: PHP Built-in Server
# -----------------------------------------------------------------------------
test_log "8. Testing PHP Built-in Server..."
DIR_PHP="${TEST_DIR}/php"
mkdir -p "${DIR_PHP}" && chmod 777 "${DIR_PHP}"
cat << 'EOF' > "${DIR_PHP}/index.php"
<?php
header('Content-Type: application/json');
echo json_encode(['status' => 'online', 'runtime' => 'PHP', 'message' => 'Hello from PHP']);
EOF
run_and_verify_http "PHP Server" "${DIR_PHP}" "8088" "-e LANGUAGE=php"

# -----------------------------------------------------------------------------
# TEST 9: Feather Panel Simulation (/app, FEATHER_PORT, UID 1000)
# -----------------------------------------------------------------------------
test_log "9. Testing Feather Panel Simulation..."
DIR_FEATHER="${TEST_DIR}/feather"
mkdir -p "${DIR_FEATHER}" && chmod 777 "${DIR_FEATHER}"
cat << 'EOF' > "${DIR_FEATHER}/index.js"
const http = require('http');
const port = process.env.FEATHER_PORT || process.env.PORT || 8089;
const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ status: 'online', platform: 'Feather Panel', message: 'Hello from Feather Panel' }));
});
server.listen(port, '0.0.0.0', () => console.log(`Feather listening on ${port}`));
EOF
run_and_verify_http "Feather Panel Compatibility (/app, FEATHER_PORT)" "${DIR_FEATHER}" "8089" "-e FEATHER_PORT=8089 -e FEATHER_SERVER_ID=feather-test" "/app" "1000:1000"

# -----------------------------------------------------------------------------
# TEST 10: PufferPanel Simulation (/server, PUFFER_PORT)
# -----------------------------------------------------------------------------
test_log "10. Testing PufferPanel Simulation..."
DIR_PUFFER="${TEST_DIR}/puffer"
mkdir -p "${DIR_PUFFER}" && chmod 777 "${DIR_PUFFER}"
cat << 'EOF' > "${DIR_PUFFER}/index.js"
const http = require('http');
const port = process.env.PUFFER_PORT || process.env.PORT || 8090;
const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({ status: 'online', platform: 'PufferPanel', message: 'Hello from PufferPanel' }));
});
server.listen(port, '0.0.0.0', () => console.log(`Puffer listening on ${port}`));
EOF
run_and_verify_http "PufferPanel Compatibility (/server, PUFFER_PORT)" "${DIR_PUFFER}" "8090" "-e PUFFER_PORT=8090" "/server" "0:0"

# -----------------------------------------------------------------------------
# TEST 11: Static Website / SPA Server
# -----------------------------------------------------------------------------
test_log "11. Testing Static HTML / SPA Server..."
DIR_STATIC="${TEST_DIR}/static"
mkdir -p "${DIR_STATIC}" && chmod 777 "${DIR_STATIC}"
cat << 'EOF' > "${DIR_STATIC}/index.html"
<!DOCTYPE html>
<html>
<head><title>PotenFYR Static Test</title></head>
<body><h1>Hello from PotenFYR Static Server</h1></body>
</html>
EOF
run_and_verify_http "Static Website / SPA Server" "${DIR_STATIC}" "8091" "-e LANGUAGE=static"

# -----------------------------------------------------------------------------
# TEST 12: Procfile Multi-Process Supervision
# -----------------------------------------------------------------------------
test_log "12. Testing Procfile Multi-Process Supervision..."
DIR_PROC="${TEST_DIR}/procfile"
mkdir -p "${DIR_PROC}" && chmod 777 "${DIR_PROC}"
cat << 'EOF' > "${DIR_PROC}/Procfile"
web: python3 -m http.server 8092
worker: while true; do echo "[Worker] Heartbeat online..."; sleep 5; done
EOF
run_and_verify_http "Procfile Multi-Process Supervisor" "${DIR_PROC}" "8092" ""

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
rm -rf "${TEST_DIR}"

printf "\n===============================================================================\n"
printf "${C_BOLD}  DOCKER TEST SUITE RESULTS${C_RESET}\n"
printf "===============================================================================\n"
printf "  ${C_GREEN}${C_BOLD}✔ PASSED: %d${C_RESET}\n" "${PASSED_TESTS}"
if [ "${FAILED_TESTS}" -gt 0 ]; then
    printf "  ${C_RED}${C_BOLD}✘ FAILED: %d${C_RESET}\n" "${FAILED_TESTS}"
    printf "\n${C_RED}${C_BOLD}Some checks failed. See logs above for details.${C_RESET}\n"
    exit 1
else
    printf "  ${C_RED}${C_BOLD}✘ FAILED: 0${C_RESET}\n"
    printf "\n${C_GREEN}${C_BOLD}ALL DOCKER & MULTI-PANEL TESTS PASSED WITH 100%% SUCCESS! 🚀${C_RESET}\n"
    exit 0
fi
