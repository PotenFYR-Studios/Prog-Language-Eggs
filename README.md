# Prog-Language-Eggs

> One egg. Every programming language. Every runtime. Installs, updates, compiles and runs **50+ programming languages** — from Node.js, Bun, TypeScript, Python, and Java to Go, Rust, C/C++, .NET, PHP, Zig, Swift, and beyond — with **automatic memory tuning (OOM protection)**, **Procfile multi-process supervision**, **native Dev Watch Mode**, **static SPA hosting**, and **Git auto-sync**.

```
.______   .______        ______    _______      .___  ___.  __    __   __      .___________. __  
|   _  \  |   _  \      /  __  \  /  _____|     |   \/   | |  |  |  | |  |     |           ||  | 
|  |_)  | |  |_)  |    |  |  |  ||  |  __  ____ |  \  /  | |  |  |  | |  |     `---|  |----`|  | 
|   ___/  |      /     |  |  |  ||  | |_ ||____||  |\/|  | |  |  |  | |  |         |  |     |  | 
|  |      |  |\  \----.|  `--'  ||  |__| |      |  |  |  | |  `--'  | |  `----.    |  |     |__| 
| _|      | _| `._____| \______/  \______|      |__|  |__|  \______/  |_______|    |__|     (__) 
                           - By PotenFYR Studios
```

[![CI Build](https://github.com/PotenFYR-Studios/Prog-Language-Eggs/actions/workflows/docker-image.yml/badge.svg)](https://github.com/PotenFYR-Studios/Prog-Language-Eggs/actions)
[![Docker Image](https://img.shields.io/badge/ghcr.io-prog--language--eggs-blue?logo=docker)](https://github.com/PotenFYR-Studios/Prog-Language-Eggs/pkgs/container/prog-language-eggs)
[![Platform](https://img.shields.io/badge/Platform-Pterodactyl%20%7C%20Pelican-orange)](https://pterodactyl.io)
[![Architecture](https://img.shields.io/badge/Arch-linux%2Famd64%20%7C%20linux%2Farm64-success)](https://github.com/PotenFYR-Studios/Prog-Language-Eggs)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## Table of Contents
1. [Features](#features)
2. [Supported Languages & Toolchains (50+ Matrix)](#supported-languages--toolchains)
3. [Advanced Capabilities](#advanced-capabilities)
   - [Automatic Memory Tuning & OOM Protection](#1-automatic-memory-tuning--oom-protection)
   - [Native Dev Watch & Hot-Reload Mode](#2-native-dev-watch--hot-reload-mode)
   - [Procfile Multi-Process Supervision](#3-procfile-multi-process-supervision)
   - [Zero-Config Static Frontend / SPA Hosting](#4-zero-config-static-frontend--spa-hosting)
   - [Pre-Run & Post-Run Lifecycle Hooks](#5-pre-run--post-run-lifecycle-hooks)
   - [Automatic .env Network Binding](#6-automatic-env-network-binding)
   - [Storage Efficiency & Build Cache Pruning](#7-storage-efficiency--build-cache-pruning)
4. [Repository Layout](#repository-layout)
5. [Quick Setup Guide](#quick-setup-guide)
6. [Docker Images (GHCR)](#docker-images-ghcr)
7. [How It Works](#how-it-works)
8. [Egg Variables Reference](#egg-variables-reference)
9. [Code Examples & Walkthroughs](#code-examples--walkthroughs)
10. [Interactive Console Wizard](#interactive-console-wizard)
11. [Git Synchronization](#git-synchronization)
12. [Troubleshooting & FAQ](#troubleshooting--faq)
13. [License](#license)

---

## Features

- 🌐 **Universal Polyglot Engine**: Execute over 50+ programming languages from a single egg without changing Docker images.
- 🧠 **Smart Memory Tuning (OOM Protection)**: Automatically computes and applies optimal memory ceilings (`--max-old-space-size`, `GOMEMLIMIT`, `-Xmx`, `DOTNET_GCHeapHardLimit`, `MALLOC_TRIM_THRESHOLD_`) to prevent Pterodactyl Wings hard-kills.
- ⚡ **Modern Package Managers & Toolchains**: Preconfigured with `npm`, `pnpm`, `yarn`, `bun`, `deno`, `pip`, `uv`, `poetry`, `pipenv`, `cargo`, `go mod`, `maven`, `gradle`, `composer`, `gem`, `dotnet`, `mix`, and more.
- 🚀 **Multi-Runner TypeScript Engine**: Zero-configuration execution for TypeScript via `ts-node`, `tsx`, `bun run`, or compiled `tsc -> node`.
- 🔄 **Procfile Multi-Process Supervision**: Run web servers, Discord bots, and background queue workers concurrently inside one container with unified colored logging.
- 🔥 **Native Dev Watch Mode (`DEV_MODE=1`)**: Auto-reloads your application on code changes for instant developer feedback.
- 📱 **Static Frontend & SPA Hosting**: Drop your React, Vue, Svelte, or static HTML build in — the egg spins up a high-performance HTTP server with SPA fallback routing.
- 🔍 **Intelligent Auto-Detection**: Automatically identifies project languages, entry points (`index.js`, `main.py`, `main.go`, `src/main.rs`, `Program.cs`, etc.), and package managers on boot.
- 🧙 **Interactive First-Run Wizard**: Start with a completely empty directory — the launcher interactively prompts you for your language choice and bootstraps a production-ready starter template.
- 🔄 **Git Synchronization**: Automated Git repository cloning and live auto-pull on container boot (`GIT_REPO`, `GIT_BRANCH`, and private token support).
- 🧹 **Storage Efficiency**: Automatically prunes compiler caches (`.npm/_cacache`, `/tmp/*`, `.cargo/registry/cache`) after builds to save host disk space.
- 💻 **Cross-Platform Multi-Arch**: Full native support for both `linux/amd64` (Intel/AMD) and `linux/arm64` (Apple Silicon, Ampere, Raspberry Pi).

---

## Supported Languages & Toolchains

| # | Language / Platform | Primary Runners / Engines | Package Managers & Build Tools | Default Entry Points |
|---|---------------------|---------------------------|--------------------------------|----------------------|
| **1** | **Node.js (JavaScript)** | `node`, `nodemon`, `pm2` | `npm`, `pnpm`, `yarn` | `index.js`, `app.js`, `server.js` |
| **2** | **TypeScript** | `ts-node`, `tsx`, `bun`, `tsc` | `npm`, `pnpm`, `yarn`, `tsc` | `src/index.ts`, `index.ts` |
| **3** | **Bun** | `bun run`, `bun test`, `bunx` | `bun install` | `index.ts`, `index.js`, `src/index.ts` |
| **4** | **Deno** | `deno run`, `deno task` | `deno.json`, URL imports | `main.ts`, `index.ts`, `main.js` |
| **5** | **Python** | `python3`, `uvicorn`, `gunicorn` | `uv`, `pip`, `poetry`, `pipenv` | `main.py`, `app.py`, `server.py` |
| **6** | **Java** | `java -jar`, `mvnw`, `gradlew` | `maven`, `gradle` | `server.jar`, `pom.xml`, `build.gradle` |
| **7** | **Go (Golang)** | `go run`, `./server` | `go mod` | `main.go`, `cmd/server/main.go` |
| **8** | **Rust** | `cargo run`, `./server` | `cargo` | `src/main.rs`, `Cargo.toml` |
| **9** | **C** | `gcc`, `clang`, `make` | `make`, `cmake`, `ninja` | `main.c`, `Makefile` |
| **10** | **C++** | `g++`, `clang++`, `make` | `make`, `cmake`, `ninja` | `main.cpp`, `Makefile` |
| **11** | **C# / .NET** | `dotnet run`, `dotnet exec` | `dotnet restore`, `nuget` | `Program.cs`, `*.csproj` |
| **12** | **PHP** | `php -S`, `php artisan`, `php` | `composer` | `index.php`, `server.php` |
| **13** | **Ruby** | `ruby`, `puma`, `bundle exec` | `gem`, `bundler` | `app.rb`, `main.rb`, `config.ru` |
| **14** | **Static Website / SPA** | `serve`, `python -m http.server` | Static files | `index.html`, `dist/index.html` |
| **15** | **Kotlin** | `kotlin`, `kotlinc`, `gradle` | `gradle`, `maven` | `Main.kt`, `build.gradle.kts` |
| **16** | **Scala** | `scala`, `sbt` | `sbt` | `Main.scala`, `build.sbt` |
| **17** | **Swift** | `swift run`, `swiftc` | `swift package` | `Sources/main.swift`, `Package.swift` |
| **18** | **Dart** | `dart run` | `dart pub` | `bin/server.dart`, `main.dart` |
| **19** | **Zig** | `zig run`, `zig build run` | `build.zig` | `src/main.zig`, `main.zig` |
| **20** | **Lua / LuaJIT** | `lua`, `luajit` | `luarocks` | `main.lua`, `init.lua` |
| **21** | **Elixir** | `mix run`, `elixir` | `mix`, `hex` | `mix.exs`, `main.ex` |
| **22** | **Erlang** | `escript`, `rebar3 shell` | `rebar3` | `rebar.config`, `main.erl` |
| **23** | **Haskell** | `runghc`, `cabal run`, `stack` | `cabal`, `stack` | `Main.hs`, `app/Main.hs` |
| **24** | **Perl** | `perl` | `cpan`, `cpanm` | `main.pl`, `app.pl` |
| **25** | **R** | `Rscript` | `install.packages()` | `main.R`, `script.R` |
| **26** | **Julia** | `julia` | `Pkg` | `main.jl`, `app.jl` |
| **27** | **Clojure** | `lein run`, `clojure -M` | `leiningen`, `deps.edn` | `project.clj`, `src/main.clj` |
| **28** | **Groovy** | `groovy`, `groovyc` | `gradle` | `main.groovy` |
| **29** | **Crystal** | `crystal run` | `shards` | `src/main.cr`, `shard.yml` |
| **30** | **Nim** | `nim r`, `nimble run` | `nimble` | `main.nim`, `src/main.nim` |
| **31** | **OCaml** | `ocaml`, `dune exec` | `opam`, `dune` | `main.ml`, `dune-project` |
| **32** | **F#** | `dotnet run` | `nuget`, `dotnet` | `Program.fs`, `*.fsproj` |
| **33** | **Fortran** | `gfortran` | `make` | `main.f90`, `main.for` |
| **34** | **FreePascal** | `fpc` | `fpc` | `main.pas` |
| **35** | **COBOL** | `cobc` (GnuCOBOL) | `cobc` | `main.cob`, `main.cbl` |
| **36** | **Assembly (x86/ARM)** | `nasm`, `as`, `ld` | `make` | `main.asm`, `main.s` |
| **37** | **V (Vlang)** | `v run` | `v` | `main.v`, `v.mod` |
| **38** | **Odin** | `odin run` | `odin` | `main.odin` |
| **39** | **Gleam** | `gleam run` | `gleam` | `src/main.gleam`, `gleam.toml` |
| **40** | **ReScript / ReasonML** | `rescript`, `node` | `npm`, `bsb` | `src/Index.res` |
| **41** | **Haxe** | `haxe --run` | `haxelib` | `Main.hx` |
| **42** | **Racket** | `racket` | `raco` | `main.rkt` |
| **43** | **Scheme / Guile** | `guile`, `csi` | `chicken-install` | `main.scm`, `main.ss` |
| **44** | **Common Lisp** | `sbcl --script` | `quicklisp` | `main.lisp`, `main.cl` |
| **45** | **D (Dlang)** | `rdmd`, `dub run` | `dub` | `main.d`, `dub.json` |
| **46** | **Ada** | `gnatmake` | `gprbuild` | `main.adb` |
| **47** | **Smalltalk** | `gst` | `gst-package` | `main.st` |
| **48** | **Tcl** | `tclsh` | `tcl` | `main.tcl` |
| **49** | **Prolog** | `swipl` | `swi-prolog` | `main.pl`, `main.pro` |
| **50** | **Solidity (Dev/Node)** | `npx hardhat node`, `anvil` | `hardhat`, `foundry` | `hardhat.config.js` |
| **51** | **Bash / Shell** | `bash`, `sh` | `apt` | `main.sh`, `start.sh` |
| **52** | **PowerShell** | `pwsh` | `PSGallery` | `main.ps1`, `run.ps1` |
| **53** | **Visual Basic .NET** | `dotnet run` | `nuget` | `Program.vb`, `*.vbproj` |
| **54** | **Vala** | `valac` | `meson`, `ninja` | `main.vala` |

---

## Advanced Capabilities

### 1. Automatic Memory Tuning & OOM Protection
Default container environments are susceptible to being abruptly killed by Pterodactyl Wings when runtimes exceed container memory limits. With `MEMORY_AUTO_TUNE=1` (default), the egg calculates an 85% safe target and configures runtimes accordingly:
- **Node.js**: Automatically sets `--max-old-space-size` to 85% of allocated RAM.
- **Go**: Sets `GOMEMLIMIT` to trigger garbage collection before container OOM.
- **Java**: Injects optimal `-Xmx` heap size and auto-selects **ZGC** (for ≥4GB) or **G1GC** (for ≥1GB).
- **.NET**: Limits the GC Heap via `DOTNET_GCHeapHardLimit`.
- **Python**: Injects `MALLOC_TRIM_THRESHOLD_=100000` to immediately return free heap pages to Linux.

### 2. Native Dev Watch & Hot-Reload Mode
Set `DEV_MODE=1` in your panel variables:
- **Node.js**: Runs with `node --watch` (native Node 18+) or `nodemon`.
- **Bun**: Runs with `bun --watch` or `bun --hot`.
- **TypeScript**: Runs with `tsx watch`.
- **Python**: Runs with `uvicorn --reload` or `watchfiles`.
- **Deno**: Runs with `deno --watch`.

### 3. Procfile Multi-Process Supervision
Need to run a web server AND a background queue worker or Discord bot concurrently? Simply create a `Procfile` in your server directory:

```yaml
web: node server.js
worker: python worker.py
bot: bun run src/bot.ts
```

The egg automatically spawns all processes, aggregates their logs with distinct colored prefixes `[web]`, `[worker]`, `[bot]`, and coordinates graceful termination across all child processes.

### 4. Zero-Config Static Frontend / SPA Hosting
Have a frontend website, dashboard, or SPA (React, Vue, Vite, Next static export)?
Upload your `index.html` or `dist/` folder: the egg automatically detects it and boots a high-speed web server bound to your assigned panel port with client-side SPA routing support.

### 5. Pre-Run & Post-Run Lifecycle Hooks
Execute database migrations or pre-boot tasks seamlessly:
- **`PRE_RUN_COMMAND`**: e.g. `npx prisma migrate deploy` or `python manage.py migrate`
- **`POST_RUN_COMMAND`**: e.g. cleanup routines or log rotation

### 6. Automatic .env Network Binding
To prevent common port binding errors, the egg automatically inspects your `.env` and ensures `PORT`, `SERVER_PORT`, `HOST=0.0.0.0`, and `BIND_ADDRESS=0.0.0.0` match your allocated Pterodactyl port.

### 7. Storage Efficiency & Build Cache Pruning
With `CLEAN_BUILD_CACHE=1`, compiler temporary directories (`.npm/_cacache`, `/tmp/*`, `.cargo/registry/cache`) are automatically pruned after compilation, preventing disk bloat on host servers.

---

## Repository Layout

```
Prog-Language-Eggs/
├── egg-programming-universal.json       ← Flagship Universal Egg (Import into Pterodactyl / Pelican)
├── eggs/                                 ← Modular Dedicated Eggs per Category
│   ├── egg-nodejs-bun-typescript.json
│   ├── egg-python.json
│   ├── egg-golang.json
│   ├── egg-rust.json
│   ├── egg-java.json
│   ├── egg-c-cpp.json
│   ├── egg-php.json
│   ├── egg-dotnet.json
│   └── egg-ruby.json
├── templates/                            ← Starter Project Templates
│   ├── nodejs/
│   ├── bun/
│   ├── typescript/
│   ├── python/
│   ├── golang/
│   ├── rust/
│   └── php/
├── Dockerfile                            ← Universal Multi-Arch Runtime Container
├── entrypoint.sh                         ← Container Entrypoint (Settings load, Environment, Banner)
├── run.sh                                ← Universal Launcher & Project Auto-Detector
├── install.sh                            ← Pterodactyl Container Installer Script
├── install-runtime.sh                    ← Dynamic On-Demand Toolchain Downloader
├── .github/workflows/docker-image.yml    ← Automated CI/CD Multi-Arch Build Workflow
└── README.md                             ← Comprehensive Documentation
```

---

## Quick Setup Guide

### 1. Import the Egg
1. Download [egg-programming-universal.json](https://github.com/PotenFYR-Studios/Prog-Language-Eggs/blob/main/egg-programming-universal.json).
2. Open your Pterodactyl / Pelican Admin Panel.
3. Navigate to **Nests** → Select your Nest (e.g. *Generic* or *Programming Languages*).
4. Click **Import Egg**, choose `egg-programming-universal.json`, and click **Save**.

### 2. Create a Server
1. In the Admin Panel, go to **Servers** → **Create New**.
2. Under **Nest & Egg**, select **Universal Programming Languages & Toolchains**.
3. Set your memory and CPU allocations (512 MB – 8 GB+).
4. Under **Docker Image**, select `Universal (50+ Languages)`.
5. Set your variables (or leave defaults for auto-detection).
6. Click **Create Server**.

### 3. Launch & Console
- Start the server from the panel console.
- If your directory is empty, the interactive wizard will ask you which starter template you want.
- If your files are already uploaded or cloned via Git, the engine will automatically detect your language, tune memory, install dependencies, compile if needed, and start your application!

---

## Docker Images (GHCR)

The runtime images are automatically built for multi-arch (`linux/amd64` and `linux/arm64`) and published to GitHub Container Registry:

```bash
ghcr.io/potenfyr-studios/prog-language-eggs:latest
```

---

## Egg Variables Reference

| Variable Name | Env Variable | Default | Editable | Description |
|---|---|---|---|---|
| **Target Language** | `LANGUAGE` | `auto` | 👤 Yes | Target language or `auto` for smart file detection. |
| **Execution Runner** | `RUNNER` | `auto` | 👤 Yes | Specific runner (`node`, `bun`, `deno`, `ts-node`, `tsx`, `tsc`, `uvicorn`, `cargo`, `go`, etc.). |
| **Main Entry File** | `MAIN_FILE` | `auto` | 👤 Yes | Entrypoint file (`index.js`, `main.py`, `main.go`, `src/main.rs`, `Program.cs`, etc.). |
| **Package Manager** | `PACKAGE_MANAGER` | `auto` | 👤 Yes | Package manager (`npm`, `pnpm`, `yarn`, `bun`, `pip`, `poetry`, `uv`, `cargo`, `composer`, etc.). |
| **Memory Auto Tune** | `MEMORY_AUTO_TUNE` | `1` | 👤 Yes | Automatically tunes GC & memory limits to prevent container OOM (`1` = On). |
| **Dev Watch Mode** | `DEV_MODE` | `0` | 👤 Yes | Enable auto-reload on file changes during development (`1` = On). |
| **Pre-Run Command** | `PRE_RUN_COMMAND` | `""` | 👤 Yes | Hook command executed before starting (e.g. database migrations). |
| **Post-Run Command** | `POST_RUN_COMMAND` | `""` | 👤 Yes | Hook command executed when application stops or shuts down. |
| **Clean Build Cache** | `CLEAN_BUILD_CACHE` | `1` | 👤 Yes | Cleans temporary build artifacts after compilation to save disk space. |
| **Auto .env Inject** | `AUTO_ENV_INJECT` | `1` | 👤 Yes | Injects correct PORT and HOST=0.0.0.0 into .env automatically. |
| **Auto Install Deps** | `AUTO_INSTALL_DEPS` | `1` | 👤 Yes | Auto-install missing dependencies on startup (`1` = On, `0` = Off). |
| **Build Command** | `BUILD_COMMAND` | `""` | 👤 Yes | Custom build command before running (e.g. `npm run build`, `cargo build --release`). |
| **Custom Command** | `CUSTOM_COMMAND` | `""` | 👤 Yes | Full custom launch command overriding default runner entirely. |
| **Extra Arguments** | `EXTRA_ARGS` | `""` | 👤 Yes | Extra CLI arguments passed directly to the binary/runner. |
| **Starter Template** | `STARTER_TEMPLATE` | `empty` | 👤 Yes | Starter project template (`nodejs`, `bun`, `typescript`, `python`, `golang`, `rust`, `php`, `static`). |
| **Git Repository** | `GIT_REPO` | `""` | 👤 Yes | Git repository URL to clone and sync on startup. |
| **Git Branch** | `GIT_BRANCH` | `main` | 👤 Yes | Git branch to clone or track. |
| **Git Auth Token** | `GIT_AUTH_TOKEN` | `""` | 👤 Yes | Personal Access Token (PAT) for private Git repositories. |
| **Extra URLs** | `EXTRA_URLS` | `""` | 👤 Yes | Newline-separated list of URLs or `dest\|url` to download. |
| **Auto Restart** | `AUTO_RESTART` | `0` | 👤 Yes | Auto-restart application if it crashes (`1` = On, `0` = Off). |
| **Restart Delay** | `RESTART_DELAY` | `3` | 👤 Yes | Cooldown in seconds before auto-restarting. |
| **Assigned Port** | `SERVER_PORT` | `{{server.build.default.port}}` | 🔒 Admin | Primary network port allocated by the panel. |
| **Debug Mode** | `DEBUG` | `0` | 👤 Yes | Enable verbose script debugging (`1` = On). |

---

## License

This project is open-source under the **MIT License**.

Developed with ❤️ by **[PotenFYR Studios](https://github.com/PotenFYR-Studios)**.