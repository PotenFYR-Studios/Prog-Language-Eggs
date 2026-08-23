# Prog-Language-Eggs

> One egg. Every programming language. Every runtime. Every panel. Installs, updates, compiles and runs **50+ programming languages** across **Pterodactyl**, **Pelican**, **Feather Panel**, **PufferPanel**, **Jexactyl**, **Wisp**, and **Standalone Docker / Kubernetes**.

```text
   __  ___      ____  _       __                              
  /  |/  /_  __/ / /_(_)     / /   ____ _____  ____ _         
 / /|_/ / / / / / __/ /_____/ /   / __ `/ __ \/ __ `/         
/ /  / / /_/ / / /_/ /_____/ /___/ /_/ / / / / /_/ /          
/_/  /_/\__,_/_/\__/_/     /_____/\__,_/_/ /_/\__, /          
                                             /____/           
  » Multi-Language Runtime Environment
    By PotenFYR Studios • support@potenfyr.in
```

[![CI Build](https://github.com/PotenFYR-Studios/Prog-Language-Eggs/actions/workflows/docker-image.yml/badge.svg)](https://github.com/PotenFYR-Studios/Prog-Language-Eggs/actions)
[![Docker Image](https://img.shields.io/badge/ghcr.io-prog--language--eggs-blue?logo=docker)](https://github.com/PotenFYR-Studios/Prog-Language-Eggs/pkgs/container/prog-language-eggs)
[![Platform](https://img.shields.io/badge/Panels-Pterodactyl%20%7C%20Pelican%20%7C%20Feather%20%7C%20Puffer-orange)](https://github.com/PotenFYR-Studios/Prog-Language-Eggs)
[![Architecture](https://img.shields.io/badge/Arch-linux%2Famd64%20%7C%20linux%2Farm64-success)](https://github.com/PotenFYR-Studios/Prog-Language-Eggs)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## Table of Contents
1. [Features](#features)
2. [Multi-Panel Support](#multi-panel-support)
3. [Supported Languages & Toolchains (50+ Matrix)](#supported-languages--toolchains)
4. [Advanced Capabilities](#advanced-capabilities)
5. [Repository Layout](#repository-layout)
6. [Quick Setup Guide](#quick-setup-guide)
7. [Docker Images (GHCR)](#docker-images-ghcr)
8. [How It Works](#how-it-works)
9. [Egg Variables Reference](#egg-variables-reference)
10. [Code Examples & Walkthroughs](#code-examples--walkthroughs)
11. [Troubleshooting & FAQ](#troubleshooting--faq)
12. [License](#license)

---

## Features

- 🌐 **Multi-Panel Compatibility**: Zero-configuration compatibility across **Pterodactyl**, **Pelican**, **Feather Panel**, **PufferPanel**, **Jexactyl**, **Wisp**, and **Docker/Kubernetes**.
- 🧠 **Smart Memory Tuning (OOM Protection)**: Automatically computes safe memory ceilings (`--max-old-space-size`, `GOMEMLIMIT`, `-Xmx`, `DOTNET_GCHeapHardLimit`, `MALLOC_TRIM_THRESHOLD_`) to prevent host panel hard-kills.
- ⚡ **50+ Languages & Modern Toolchains**: Preconfigured with `npm`, `pnpm`, `yarn`, `bun`, `deno`, `pip`, `uv`, `poetry`, `pipenv`, `cargo`, `go mod`, `maven`, `gradle`, `composer`, `gem`, `dotnet`, `mix`, and more.
- 🔄 **Procfile Multi-Process Supervision**: Run web servers, bots, and background workers concurrently in a single container with colored log streams.
- 🔥 **Native Dev Watch Mode (`DEV_MODE=1`)**: Hot-reloads your application on code changes for instant developer feedback.
- 📱 **Static Frontend & SPA Hosting**: Automatic static web server with client-side SPA routing fallback for React, Vue, Vite, and HTML.
- 🧙 **Interactive First-Run Wizard**: Start with an empty directory - the launcher interactively prompts you for your language choice and bootstraps a starter template (with non-interactive fallback for automated panel provisioning).
- 🔄 **Git Synchronization**: Automated Git repository cloning and live auto-pull on container boot (`GIT_REPO`, `GIT_BRANCH`, and private token support).
- 💻 **Cross-Platform Multi-Arch**: Full native support for both `linux/amd64` (Intel/AMD) and `linux/arm64` (Apple Silicon, Ampere, Raspberry Pi).

---

## Multi-Panel Support

The container detects its host platform **accurately** at boot (via environment markers, cgroup inspection
and well-known paths) and adapts working directory, port and memory conventions automatically. The detected
platform is exposed as `PANEL_TYPE` (human label) and `PANEL_FAMILY` (`wings|feather|puffer|k8s|paas|docker`)
for scripts that need to branch on it.

| Panel / Platform | Detected As (`PANEL_TYPE`) | Family | Working Directory | Port Variable Unified |
|---|---|---|---|---|
| **Pterodactyl Panel** | Pterodactyl Panel | wings | `/home/container` | `SERVER_PORT` / `PORT` |
| **Pelican Panel** | Pelican Panel | wings | `/home/container` | `SERVER_PORT` / `PORT` |
| **Feather Panel** | Feather Panel | feather | `/app` or `/home/container` | `FEATHER_PORT` / `PORT` |
| **PufferPanel** | PufferPanel | puffer | `/server` | `PORT` / `PUFFER_PORT` |
| **Jexactyl / Wisp / Emerald** | per-panel label | wings | `/home/container` | `SERVER_PORT` / `PORT` |
| **Kubernetes / OpenShift** | Kubernetes Pod | k8s | `/home/container` or `/app` | `PORT` / `HTTP_PORT` |
| **Fly.io** | Fly.io | paas | `$PWD` | `PORT` |
| **Railway** | Railway | paas | `$PWD` | `PORT` |
| **Render** | Render | paas | `$PWD` | `PORT` |
| **Heroku-style dynos** | Heroku-style Dyno | paas | `/app` | `PORT` |
| **Standalone Docker / Podman** | Docker / Standalone | docker | `/home/container` or `$PWD` | `PORT` / `HTTP_PORT` |

The single multi-language egg imports cleanly into every PTDL_v2-compatible panel (Pterodactyl, Pelican, Feather,
Jexactyl, Wisp, Emerald, Convoy) - one egg file covers them all.

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

## Repository Layout

```
Prog-Language-Eggs/
├── egg-programming-multi.json       ← THE Single multi Egg (Import into Pterodactyl / Pelican / Feather)
├── Dockerfile                            ← Single Multi-Arch Runtime Image (single image)
├── entrypoint.sh                         ← Multi-Panel Entrypoint (Settings, Environment, Banner)
├── run.sh                                ← multi Launcher & Project Auto-Detector (+ Environment Isolation)
├── install.sh                            ← Multi-Panel Installer Script
├── install-runtime.sh                    ← Dynamic On-Demand Toolchain Downloader (version-aware)
├── resolve-version.sh                    ← Version Validator & Channel Resolver (live upstream feeds)
├── .github/workflows/docker-image.yml    ← Automated CI/CD Multi-Arch Build Workflow
└── README.md                             ← Comprehensive Documentation
```

> **One egg. One image.** All previous per-language eggs (`eggs/egg-*.json`) have been consolidated into
> `egg-programming-multi.json`. The target language and its exact version are chosen at startup via
> variables (`LANGUAGE`, `RUNTIME_VERSION`, `EXTRA_RUNTIMES=name@version`, ...) and the runtime is downloaded
> **inside your container** on demand - fully isolated, rootless, nothing pre-baked.

---

## Quick Setup Guide

### 1. Import the Egg (Pterodactyl, Pelican, Feather Panel)
1. Download [egg-programming-multi.json](https://github.com/PotenFYR-Studios/Prog-Language-Eggs/blob/main/egg-programming-multi.json).
2. Open your Panel Admin Area (**Nests** / **Templates**).
3. Click **Import Egg**, select `egg-programming-multi.json`, and click **Save**.

### 2. Create a Server
1. Create a server using the imported egg.
2. Under **Docker Image**, select `Multi-Language (50+ Languages)`.
3. Launch the server from your panel console.

---

## Docker Image (GHCR)

ONE image, ONE tag, every language. Published as a clean multi-arch build (no stale layer caches) to GitHub Container Registry:

```bash
ghcr.io/potenfyr-studios/prog-language-eggs:latest
```

### Runs on any host CPU & OS a panel can be hosted on

| Host architecture | Status | Notes |
|---|---|---|
| `linux/amd64` | ✅ Full | Standard panel nodes |
| `linux/arm64` | ✅ Full | Apple Silicon, Ampere, Raspberry Pi 4/5 (64-bit), Oracle ARM |
| `linux/arm/v7` | ✅ Full image | SBC-hosted panels; engines without upstream armv7 builds self-provision alternatives |
| `ppc64le` / `s390x` / `riscv64` | ⚙️ On-demand | Pull an amd64/arm64 base or any distro image + this egg: Node.js, Go, Rust, Java, .NET and more resolve official upstream builds automatically at container boot |

**Host OS**: the egg runs wherever the panel can run containers - Linux hosts natively, and Windows/macOS
panel hosts through Docker Desktop / WSL2 backends (the container itself is always Linux). Inside the
container, a cross-distro assurance step detects alpine/debian/fedora-style bases and installs or flags
any missing core tool (`curl`, `jq`, `xz`, ...) automatically.

Per-engine availability is checked at install time with actionable messages - nothing hard-fails on an
unusual CPU; you simply get told which engines ship for your platform.


---

## Available Egg Configurations

There is exactly **one** egg to maintain:

| Egg File | Name in Panel | Target Stack / Use-case |
|---|---|---|
| [`egg-programming-multi.json`](egg-programming-multi.json) | **Multi-Languages (All-In-One)** | The single egg: all 50+ languages, dynamic auto-detection, on-demand runtime installation inside the container, per-version environment isolation, and version channel keywords. One docker image serves every language. |

---

## Version Selection & Channels (`RUNTIME_VERSION`)

Version requests are **validated and resolved from live upstream feeds** before anything downloads - invalid
input fails fast with clear guidance instead of a broken install. No hardcoded pins.

| Request | Example | Behaviour |
|---|---|---|
| `latest` | `RUNTIME_VERSION=latest` | Newest stable/GA release (default). |
| `stable` | `RUNTIME_VERSION=stable` | Newest LTS/stable line (Node → newest LTS, Rust → `stable`, .NET → LTS channel). |
| `lts` | `RUNTIME_VERSION=lts` | Newest LTS (Node.js, Java/Adoptium, .NET). |
| `alpha`, `beta`, `rc`, `preview`, `pre` | `RUNTIME_VERSION=beta` | Pre-release channel where upstream publishes one (Go beta/rc, Deno pre-releases, .NET STS preview, Dart beta, Java EA, Zig latest, Rust `beta`). Falls back to newest stable with a console notice when no pre-release exists. |
| `nightly`, `dev`, `canary`, `tip`, `edge` | `RUNTIME_VERSION=nightly` | Nightly/canary line (Node nightly CDN, Rust `nightly`, Zig `master`, .NET daily, Dart dev, Bun canary, Java tip-EA). |
| Concrete | `22`, `20.11`, `v22.1.4`, `3.12`, `1.22`, `17`, `9.0` | Resolved to the newest matching release from the feed; unknown series are rejected with the list of valid ones. |
| Invalid input | `22.abc!!` | **Rejected before any download** - exit 64 with accepted-form examples. |

Companion runtimes accept a **per-component version**: `EXTRA_RUNTIMES=python@3.12,bun@1.1,java@21`.

Resolution diagnostics are logged to `.logs/version-resolver.log`.

---

## Per-Language Environment Isolation & Data Retention

Everything installs **inside your container** (workspace `.runtimes/`) - rootless, isolated from the host.
Each language + major-version series gets its own environment folder so switching never conflicts or deletes:

```text
.environments/
├── active                    ← last used instance marker
├── nodejs/
│   ├── node22/               ← npm/bun caches, tool state for Node 22.x
│   └── node24/               ← kept intact if you switch to 24 and back
├── python/py3.12/  golang/go1.22/  java/jdk21/  rust/rust-stable/ ...
└── .resolved/<lang>          ← resolved concrete version cache
```

**Switch behaviour (nothing is ever auto-deleted):**

| Change | What happens |
|---|---|
| Same language, same major series (e.g. patch update) | ✅ Compatible - same environment folder reused. Console: info message. |
| Same language, new major series (e.g. Node 22 → 24) | ⚠️ Breaking boundary - **new** folder created; previous folder preserved untouched; yellow console warning shows both paths. |
| Different language (e.g. Python → Go) | ⚠️ Separate subtree created; previous language's environment fully retained; console warning lists it. |

Retained environments are listed in the console with their sizes on every boot, including instructions to
delete them **manually** via the panel File Manager when you no longer need them.

---

## Production & Multi-Layer Applications

Built for both tiny services and multi-layer architectures (web + worker + api) inside one container:

### Multi-Process Supervisor (Procfile)
Create a `Procfile` in your workspace:

```procfile
web:    node server.js
api:    wait_port 127.0.0.1 6379 30 && python -m uvicorn api:app --port 8081
worker: node worker.js
```

| Capability | Detail |
|---|---|
| Forced mode | `SUPERVISOR=procfile` runs the supervisor even when a single language is detected; `SUPERVISOR=single` disables it. Default `auto`. |
| Crash recovery | Crashed processes restart with linear backoff (1s→2s→3s...), giving up after 5 attempts (`PROCFILE_RESTART=1`, `PROCFILE_MAX_RESTARTS`). |
| Graceful shutdown | SIGTERM from the panel relays to every child; hard-kill only after a drain window. |
| Per-process logs | `PROCFILE_LOGS=1` mirrors each stream to `.logs/processes/<name>.log`. |
| Startup ordering | Built-in `wait_port <host> <port> [timeout]` helper lets layers wait on dependencies (databases, caches, queues). |

### Health Checks
Set `HEALTH_CHECK_PATH=/healthz` and the launcher probes `http://127.0.0.1:$SERVER_PORT/healthz`
after boot until it answers (default budget 60s). With `HEALTH_STRICT=1`, a failed probe exits non-zero
so panels mark the server unhealthy instead of silently running.

### Speed & Efficiency
* **Parallel companion installs** - `EXTRA_RUNTIMES=a,b,c` download simultaneously; each stream logged to
  `.logs/runtime-install-<name>.log`.
* **Resolver TTL cache** - version lookups are cached under `.cache/version-resolver/` for 6h
  (`RESOLVER_CACHE_TTL` seconds, `0` disables) so warm boots skip upstream feeds entirely.
* **Idempotent installs** - already-downloaded runtimes short-circuit before any network I/O.

### Security Posture
* **Checksum verification** - Node.js tarballs verified against official `SHASUMS256.txt`; Zig against the
  published `shasum`; mismatch aborts the install loudly.
* **URL validation** - `GIT_REPO`, `CUSTOM_RUNTIME_URL` must be well-formed https/ssh/http URLs
  (CRLF/header-injection shapes rejected before any fetch).
* **Secret redaction** - credentials embedded in URLs or tokens never reach console/log output.
* **Root guard** - warns when the container runs as uid 0 (panels should use the non-root image user).
* **Full audit trail** - every boot mirrors the complete console to `.logs/console.log`
  (previous boot kept as `.1`; disable with `LAUNCHER_LOG=0`), plus an image provenance stamp
  (`/etc/potenfyr-version`) printed at startup.

---

## Troubleshooting & Diagnostics

| Symptom | Where to look |
|---|---|
| Version request rejected / wrong version picked | `.logs/version-resolver.log` |
| Runtime download or extraction failure | Installer console output (each step is logged with retry counts and sizes) |
| Environment not reused after restart | Check `.environments/active` marker contents |
| Full step-by-step script trace | Restart with `DEBUG=1` - bash xtrace is written to log files while the console stays readable |

---

## Egg Variables Reference

| Variable Name | Env Variable | Default | Editable | Description |
|---|---|---|---|---|
| **Target Language** | `LANGUAGE` | `auto` | 👤 Yes | Target language or 'auto' for intelligent file auto-detection. |
| **Execution Runner** | `RUNNER` | `auto` | 👤 Yes | Runner or engine to use (e.g. auto, node, bun, tsx, uvicorn, cargo, go). |
| **Main Entry File** | `MAIN_FILE` | `auto` | 👤 Yes | The main script or file to execute (leave 'auto' for smart detection). |
| **Extra Runtimes** | `EXTRA_RUNTIMES` | `none` | 👤 Yes | Comma-separated auxiliary toolchains to install (e.g. `python,java,go`) with optional per-component versions (`python@3.12,bun@1.1`). |
| **Skip Runtimes** | `SKIP_RUNTIMES` | `none` | 👤 Yes | Comma-separated runtimes to skip/disable (e.g. `python,java`). |
| **Runtime Version** | `RUNTIME_VERSION` | `latest` | 👤 Yes | Primary runtime version: concrete (`22`, `20.11.1`) or channel keyword (`latest`, `stable`, `lts`, `alpha`, `beta`, `rc`, `preview`, `nightly`). Validated against live upstream feeds - invalid values fail fast with guidance. |
| **Custom Download URL** | `CUSTOM_RUNTIME_URL` | `""` | 👤 Yes | Direct URL to download a custom runtime (.tar.gz, .zip, or standalone binary). |
| **Package Manager** | `PACKAGE_MANAGER` | `auto` | 👤 Yes | Package manager for dependency resolution (e.g. auto, npm, pnpm, yarn, bun, pip, cargo). |
| **Memory Auto Tune** | `MEMORY_AUTO_TUNE` | `1` | 👤 Yes | Auto-tune GC & memory limits to prevent container OOM (1 = Enabled, 0 = Disabled). |
| **Dev Watch Mode** | `DEV_MODE` | `0` | 👤 Yes | Enable watch and hot-reload mode during development (1 = Enabled, 0 = Disabled). |
| **Pre-Run Command** | `PRE_RUN_COMMAND` | `""` | 👤 Yes | Command to execute before starting the main process (e.g. database migrations). |
| **Post-Run Command** | `POST_RUN_COMMAND` | `""` | 👤 Yes | Command to execute when application stops or shuts down. |
| **Clean Build Cache** | `CLEAN_BUILD_CACHE` | `1` | 👤 Yes | Purge compiler caches after build to save disk space (1 = Enabled, 0 = Disabled). |
| **Auto .env Inject** | `AUTO_ENV_INJECT` | `1` | 👤 Yes | Ensure .env has correct PORT and HOST=0.0.0.0 bindings (1 = Enabled, 0 = Disabled). |
| **Auto Install Deps** | `AUTO_INSTALL_DEPS` | `1` | 👤 Yes | Automatically install missing dependencies on container boot (1 = Enabled, 0 = Disabled). |
| **Build Command** | `BUILD_COMMAND` | `""` | 👤 Yes | Optional build or compilation command (e.g. 'npm run build', 'cargo build --release'). |
| **Custom Command** | `CUSTOM_COMMAND` | `""` | 👤 Yes | Custom command to override the default runner entirely. |
| **Extra Arguments** | `EXTRA_ARGS` | `""` | 👤 Yes | Extra CLI arguments passed to the runner or executable. |
| **Starter Template** | `STARTER_TEMPLATE` | `empty` | 👤 Yes | Starter project template if workspace is empty (e.g. nodejs, bun, python, golang, rust). |
| **Git Repository** | `GIT_REPO` | `""` | 👤 Yes | Git repository URL to clone and sync on startup. |
| **Git Branch** | `GIT_BRANCH` | `main` | 👤 Yes | Target branch to clone or track from the Git repository. |
| **Git Auth Token** | `GIT_AUTH_TOKEN` | `""` | 👤 Yes | Personal Access Token for private Git repositories. |
| **Node-gyp Support** | `NODE_GYP_SUPPORT` | `1` | 👤 Yes | Install Python 3 & build tools for native node addon compilation (1=Enabled, 0=Disabled). |
| **Skip Python Companion** | `SKIP_PYTHON` | `0` | 👤 Yes | Prevent the Python companion toolchain from being installed (1 = Skip). |
| **Extra URLs** | `EXTRA_URLS` | `""` | 👤 Yes | Additional files or archives to download on boot (URL or dest\|URL). |
| **Auto Restart** | `AUTO_RESTART` | `0` | 👤 Yes | Automatically restart process on unexpected crash (1 = Enabled, 0 = Disabled). |
| **Restart Delay** | `RESTART_DELAY` | `3` | 👤 Yes | Delay in seconds before attempting to auto-restart. |
| **Supervisor Mode** | `SUPERVISOR` | `auto` | 👤 Yes | Multi-process mode: `auto`, `procfile` (force), or `single`. Powers multi-layer apps in one container. |
| **Procfile Auto-Restart** | `PROCFILE_RESTART` | `1` | 👤 Yes | Restart crashed Procfile processes with backoff (1 = Enabled, 0 = Disabled). |
| **Procfile Per-Process Logs** | `PROCFILE_LOGS` | `0` | 👤 Yes | Mirror each supervised process stream to `.logs/processes/<name>.log` (1 = Enabled). |
| **Health Check Path** | `HEALTH_CHECK_PATH` | `""` | 👤 Yes | HTTP path probed after boot (e.g. `/healthz`). Empty = disabled. |
| **Health Check Strict** | `HEALTH_STRICT` | `0` | 👤 Yes | Exit non-zero when the health check fails (1 = Strict, 0 = Warn only). |
| **Assigned Port** | `SERVER_PORT` | `{{server.build.default.port}}` | 🔒 Admin | Primary network port allocated by the panel (`nullable|string`). |
| **Debug Mode** | `DEBUG` | `0` | 👤 Yes | Enable verbose script debug output (1 = Enabled, 0 = Disabled). |

---

## License

This project is open-source under the **MIT License**.

Developed with ❤️ by **[PotenFYR Studios](https://github.com/PotenFYR-Studios)** (support@potenfyr.in).