# =============================================================================
#  Universal Programming Language Eggs - Automated Docker Test Suite (PowerShell)
#  By PotenFYR Studios (https://github.com/PotenFYR-Studios/Prog-Language-Eggs)
# =============================================================================

param (
    [string]$ImageName = "prog-language-eggs:local"
)

$TestBaseDir = Join-Path $env:TEMP "prog-egg-docker-tests-$(Get-Random)"
New-Item -ItemType Directory -Path $TestBaseDir -Force | Out-Null

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Write-Utf8File {
    param ([string]$Path, [string[]]$Lines)
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $content = ($Lines -join "`n") + "`n"
    [System.IO.File]::WriteAllText($Path, $content, $Utf8NoBom)
}

$Passed = 0
$Failed = 0
$BasePort = 24000

function Run-Test {
    param (
        [string]$TestName,
        [string]$TestFolder,
        [string[]]$EnvVars = @(),
        [string]$MountTarget = "/home/container",
        [string]$User = "988:988",
        [int]$MaxWaitSec = 20
    )

    $script:BasePort++
    $Port = $script:BasePort

    Write-Host "`n[TEST SUITE] $TestName (Port $Port)..." -ForegroundColor Cyan

    $FolderPath = Join-Path $TestBaseDir $TestFolder
    if (-not (Test-Path $FolderPath)) {
        New-Item -ItemType Directory -Path $FolderPath -Force | Out-Null
    }

    $ContainerName = "test-egg-$Port-$(Get-Random)"
    $EnvArgs = @(
        "-e", "SERVER_PORT=$Port",
        "-e", "PORT=$Port",
        "-e", "SERVER_MEMORY=1024",
        "-e", "P_SERVER_UUID=test-uuid"
    )
    if ($EnvVars) {
        foreach ($e in $EnvVars) {
            $EnvArgs += @("-e", $e)
        }
    }

    $MountSpec = "$($FolderPath):$($MountTarget)"
    $DockerArgs = @(
        "run", "-d",
        "--name", $ContainerName,
        "--user", $User,
        "-p", "$($Port):$($Port)",
        "-v", $MountSpec
    ) + $EnvArgs + @($ImageName)

    $ContainerId = & docker @DockerArgs

    # Poll HTTP endpoint
    $Success = $false
    for ($i = 0; $i -lt $MaxWaitSec; $i++) {
        Start-Sleep -Seconds 1
        try {
            $response = Invoke-RestMethod -Uri "http://127.0.0.1:$Port" -TimeoutSec 2 -ErrorAction SilentlyContinue
            if ($response) {
                $Success = $true
                break
            }
        } catch {
            # Retry
        }
    }

    if ($Success) {
        Write-Host "  [PASS] $TestName (HTTP 200 OK on port $Port)" -ForegroundColor Green
        $script:Passed++
    } else {
        Write-Host "  [FAIL] $TestName (Endpoint failed to respond on port $Port)" -ForegroundColor Red
        Write-Host "Container Logs:" -ForegroundColor Yellow
        docker logs $ContainerName 2>&1 | Select-Object -Last 25
        $script:Failed++
    }

    docker stop $ContainerName 2>$null | Out-Null
    docker rm -f $ContainerName 2>$null | Out-Null
}

Write-Host "===============================================================================" -ForegroundColor Magenta
Write-Host "  STARTING UNIVERSAL MULTI-PANEL AND MULTI-LANGUAGE DOCKER TEST SUITE" -ForegroundColor Cyan
Write-Host "  Testing Image: $ImageName" -ForegroundColor Yellow
Write-Host "===============================================================================" -ForegroundColor Magenta

# 1. Pterodactyl Empty Workspace Auto-Bootstrap
Run-Test -TestName "1. Pterodactyl Empty Workspace Auto-Bootstrap" -TestFolder "empty"

# 2. Node.js HTTP Server
$nodeDir = Join-Path $TestBaseDir "nodejs"
$nodeLines = @(
    'const http = require("http");',
    'const port = process.env.PORT || 8080;',
    'const server = http.createServer((req, res) => {',
    '  res.writeHead(200, { "Content-Type": "application/json" });',
    '  res.end(JSON.stringify({ status: "online", runtime: "Node.js" }));',
    '});',
    'server.listen(port, "0.0.0.0", () => console.log("Listening on " + port));'
)
Write-Utf8File (Join-Path $nodeDir "index.js") $nodeLines
Run-Test -TestName "2. Node.js HTTP Server" -TestFolder "nodejs" -EnvVars @("LANGUAGE=nodejs")

# 3. Bun HTTP Server
$bunDir = Join-Path $TestBaseDir "bun"
$bunLines = @(
    'const port = Number(process.env.PORT || 8080);',
    'Bun.serve({',
    '  port: port,',
    '  fetch(req) {',
    '    return new Response(JSON.stringify({ status: "online", runtime: "Bun" }), {',
    '      headers: { "Content-Type": "application/json" }',
    '    });',
    '  }',
    '});',
    'console.log("Bun listening on " + port);'
)
Write-Utf8File (Join-Path $bunDir "index.ts") $bunLines
Run-Test -TestName "3. Bun TypeScript HTTP Server" -TestFolder "bun" -EnvVars @("LANGUAGE=bun", "RUNNER=bun")

# 4. TypeScript (ts-node / tsx)
$tsDir = Join-Path $TestBaseDir "typescript"
$tsLines = @(
    'import * as http from "http";',
    'const port = Number(process.env.PORT || 8080);',
    'const server = http.createServer((req, res) => {',
    '  res.writeHead(200, { "Content-Type": "application/json" });',
    '  res.end(JSON.stringify({ status: "online", runtime: "TypeScript" }));',
    '});',
    'server.listen(port, "0.0.0.0", () => console.log("TS listening on " + port));'
)
Write-Utf8File (Join-Path $tsDir "src\index.ts") $tsLines
Run-Test -TestName "4. TypeScript Server (ts-node / tsx)" -TestFolder "typescript" -EnvVars @("LANGUAGE=typescript", "MAIN_FILE=src/index.ts")

# 5. Python HTTP Server
$pyDir = Join-Path $TestBaseDir "python"
$pyLines = @(
    'import os, json',
    'from http.server import HTTPServer, BaseHTTPRequestHandler',
    'PORT = int(os.environ.get("PORT", 8080))',
    'class Handler(BaseHTTPRequestHandler):',
    '    def do_GET(self):',
    '        self.send_response(200)',
    '        self.send_header("Content-type", "application/json")',
    '        self.end_headers()',
    '        self.wfile.write(json.dumps({"status": "online", "runtime": "Python"}).encode())',
    'print(f"Python listening on {PORT}")',
    'HTTPServer(("0.0.0.0", PORT), Handler).serve_forever()'
)
Write-Utf8File (Join-Path $pyDir "main.py") $pyLines
Run-Test -TestName "5. Python HTTP Server" -TestFolder "python" -EnvVars @("LANGUAGE=python")

# 6. Go / Golang Server
$goDir = Join-Path $TestBaseDir "golang"
$goLines = @(
    'package main',
    'import (',
    '	"fmt"',
    '	"net/http"',
    '	"os"',
    ')',
    'func main() {',
    '	port := os.Getenv("PORT")',
    '	if port == "" { port = "8080" }',
    '	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {',
    '		w.Header().Set("Content-Type", "application/json")',
    '		fmt.Fprintf(w, `{"status":"online","runtime":"Golang"}`)',
    '	})',
    '	fmt.Printf("Go listening on port %s\n", port)',
    '	http.ListenAndServe("0.0.0.0:"+port, nil)',
    '}'
)
Write-Utf8File (Join-Path $goDir "main.go") $goLines
Run-Test -TestName "6. Golang HTTP Server" -TestFolder "golang" -EnvVars @("LANGUAGE=golang")

# 7. Rust Server (Cargo)
$rsDir = Join-Path $TestBaseDir "rust"
$cargoLines = @(
    '[package]',
    'name = "test-rust-server"',
    'version = "0.1.0"',
    'edition = "2021"'
)
Write-Utf8File (Join-Path $rsDir "Cargo.toml") $cargoLines

$rsLines = @(
    'use std::env;',
    'use std::io::Write;',
    'use std::net::TcpListener;',
    'fn main() {',
    '    let port = env::var("PORT").unwrap_or_else(|_| "8080".to_string());',
    '    let addr = format!("0.0.0.0:{}", port);',
    '    let listener = TcpListener::bind(&addr).expect("Could not bind port");',
    '    println!("Rust server listening on http://{}", addr);',
    '    for stream in listener.incoming() {',
    '        if let Ok(mut stream) = stream {',
    '            let response = "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nContent-Length: 6\r\nConnection: close\r\n\r\nonline";',
    '            let _ = stream.write_all(response.as_bytes());',
    '        }',
    '    }',
    '}'
)
Write-Utf8File (Join-Path $rsDir "src\main.rs") $rsLines
Run-Test -TestName "7. Rust HTTP Server" -TestFolder "rust" -EnvVars @("LANGUAGE=rust") -MaxWaitSec 45

# 8. PHP Built-in Server
$phpDir = Join-Path $TestBaseDir "php"
$phpLines = @(
    '<?php',
    'header("Content-Type: application/json");',
    'echo json_encode(["status" => "online", "runtime" => "PHP"]);'
)
Write-Utf8File (Join-Path $phpDir "index.php") $phpLines
Run-Test -TestName "8. PHP HTTP Server" -TestFolder "php" -EnvVars @("LANGUAGE=php")

# 9. Java Server (Main.java)
$javaDir = Join-Path $TestBaseDir "java"
$javaLines = @(
    'import java.io.OutputStream;',
    'import java.net.InetSocketAddress;',
    'import com.sun.net.httpserver.HttpServer;',
    'import com.sun.net.httpserver.HttpHandler;',
    'import com.sun.net.httpserver.HttpExchange;',
    'public class Main {',
    '    public static void main(String[] args) throws Exception {',
    '        int port = Integer.parseInt(System.getenv().getOrDefault("PORT", "8080"));',
    '        HttpServer server = HttpServer.create(new InetSocketAddress(port), 0);',
    '        server.createContext("/", new HttpHandler() {',
    '            public void handle(HttpExchange t) throws java.io.IOException {',
    '                String response = "online";',
    '                t.getResponseHeaders().set("Content-Type", "text/plain");',
    '                t.sendResponseHeaders(200, response.length());',
    '                OutputStream os = t.getResponseBody();',
    '                os.write(response.getBytes());',
    '                os.close();',
    '            }',
    '        });',
    '        server.setExecutor(null);',
    '        System.out.println("Java server listening on port " + port);',
    '        server.start();',
    '    }',
    '}'
)
Write-Utf8File (Join-Path $javaDir "Main.java") $javaLines
Run-Test -TestName "9. Java OpenJDK HTTP Server" -TestFolder "java" -EnvVars @("LANGUAGE=java")

# 10. Feather Panel Simulation (/app, FEATHER_PORT, UID 1000)
$featherDir = Join-Path $TestBaseDir "feather"
$featherLines = @(
    'const http = require("http");',
    'const port = process.env.FEATHER_PORT || process.env.PORT || 8080;',
    'const server = http.createServer((req, res) => {',
    '  res.writeHead(200, { "Content-Type": "application/json" });',
    '  res.end(JSON.stringify({ status: "online", platform: "Feather Panel" }));',
    '});',
    'server.listen(port, "0.0.0.0", () => console.log("Feather listening on " + port));'
)
Write-Utf8File (Join-Path $featherDir "index.js") $featherLines
Run-Test -TestName "10. Feather Panel Compatibility" -TestFolder "feather" -EnvVars @("FEATHER_PORT=24010", "FEATHER_SERVER_ID=feather-test") -MountTarget "/app" -User "1000:1000"

# 11. PufferPanel Simulation (/server, PUFFER_PORT)
$pufferDir = Join-Path $TestBaseDir "puffer"
$pufferLines = @(
    'const http = require("http");',
    'const port = process.env.PUFFER_PORT || process.env.PORT || 8080;',
    'const server = http.createServer((req, res) => {',
    '  res.writeHead(200, { "Content-Type": "application/json" });',
    '  res.end(JSON.stringify({ status: "online", platform: "PufferPanel" }));',
    '});',
    'server.listen(port, "0.0.0.0", () => console.log("Puffer listening on " + port));'
)
Write-Utf8File (Join-Path $pufferDir "index.js") $pufferLines
Run-Test -TestName "11. PufferPanel Compatibility" -TestFolder "puffer" -EnvVars @("PUFFER_PORT=24011") -MountTarget "/server" -User "0:0"

# 12. Static Website / SPA Server
$staticDir = Join-Path $TestBaseDir "static"
$staticLines = @(
    '<!DOCTYPE html>',
    '<html>',
    '<head><title>PotenFYR Static Test</title></head>',
    '<body><h1>Hello from PotenFYR Static Server</h1></body>',
    '</html>'
)
Write-Utf8File (Join-Path $staticDir "index.html") $staticLines
Run-Test -TestName "12. Static Website / SPA Server" -TestFolder "static" -EnvVars @("LANGUAGE=static")

# 13. Procfile Multi-Process Supervision
$procDir = Join-Path $TestBaseDir "procfile"
$procLines = @(
    'web: python3 -m http.server $PORT',
    'worker: while true; do echo "[Worker] Heartbeat online..."; sleep 5; done'
)
Write-Utf8File (Join-Path $procDir "Procfile") $procLines
Run-Test -TestName "13. Procfile Multi-Process Supervision" -TestFolder "procfile"

# Cleanup test files
Remove-Item -Recurse -Force $TestBaseDir -ErrorAction SilentlyContinue

Write-Host "`n===============================================================================" -ForegroundColor Magenta
Write-Host "  UNIVERSAL DOCKER TEST SUITE RESULTS" -ForegroundColor Cyan
Write-Host "===============================================================================" -ForegroundColor Magenta
Write-Host "  PASSED: $Passed" -ForegroundColor Green
if ($Failed -gt 0) {
    Write-Host "  FAILED: $Failed" -ForegroundColor Red
    Write-Host "`nSome checks failed." -ForegroundColor Red
    exit 1
} else {
    Write-Host "  FAILED: 0" -ForegroundColor Green
    Write-Host "`nALL DOCKER & MULTI-PANEL TESTS PASSED WITH 100% SUCCESS!" -ForegroundColor Green
}
