# Prog-Language-Eggs

> One egg. Every programming language. Every runtime. Every panel. Installs, updates, compiles and runs **50+ programming languages** across **Pterodactyl**, **Pelican**, **Feather Panel**, **PufferPanel**, **Jexactyl**, **Wisp**, and **Standalone Docker / Kubernetes**.

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
[![Platform](https://img.shields.io/badge/Panels-Pterodactyl%20%7C%20Pelican%20%7C%20Feather%20%7C%20Puffer-orange)](https://github.com/PotenFYR-Studios/Prog-Language-Eggs)
[![Architecture](https://img.shields.io/badge/Arch-linux%2Famd64%20%7C%20linux%2Farm64-success)](https://github.com/PotenFYR-Studios/Prog-Language-Eggs)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## Table of Contents
1. [Features](#features)
2. [Universal Multi-Panel Support](#universal-multi-panel-support)
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

- 🌐 **Universal Multi-Panel Compatibility**: Zero-configuration compatibility across **Pterodactyl**, **Pelican**, **Feather Panel**, **PufferPanel**, **Jexactyl**, **Wisp**, and **Docker/Kubernetes**.
- 🧠 **Smart Memory Tuning (OOM Protection)**: Automatically computes safe memory ceilings (`--max-old-space-size`, `GOMEMLIMIT`, `-Xmx`, `DOTNET_GCHeapHardLimit`, `MALLOC_TRIM_THRESHOLD_`) to prevent host panel hard-kills.
- ⚡ **50+ Languages & Modern Toolchains**: Preconfigured with `npm`, `pnpm`, `yarn`, `bun`, `deno`, `pip`, `uv`, `poetry`, `pipenv`, `cargo`, `go mod`, `maven`, `gradle`, `composer`, `gem`, `dotnet`, `mix`, and more.
- 🔄 **Procfile Multi-Process Supervision**: Run web servers, bots, and background workers concurrently in a single container with colored log streams.
- 🔥 **Native Dev Watch Mode (`DEV_MODE=1`)**: Hot-reloads your application on code changes for instant developer feedback.
- 📱 **Static Frontend & SPA Hosting**: Automatic static web server with client-side SPA routing fallback for React, Vue, Vite, and HTML.
- 🧙 **Interactive First-Run Wizard**: Start with an empty directory — the launcher interactively prompts you for your language choice and bootstraps a starter template (with non-interactive fallback for automated panel provisioning).
- 🔄 **Git Synchronization**: Automated Git repository cloning and live auto-pull on container boot (`GIT_REPO`, `GIT_BRANCH`, and private token support).
- 💻 **Cross-Platform Multi-Arch**: Full native support for both `linux/amd64` (Intel/AMD) and `linux/arm64` (Apple Silicon, Ampere, Raspberry Pi).

---

## Universal Multi-Panel Support

The container dynamically adapts to any panel environment:

| Panel / Platform | Working Directory | Port Variable Unified | Memory Variable Unified |
|---|---|---|---|
| **Pterodactyl Panel** | `/home/container` | `SERVER_PORT` / `PORT` | `SERVER_MEMORY` |
| **Pelican Panel** | `/home/container` | `SERVER_PORT` / `PORT` | `SERVER_MEMORY` |
| **Feather Panel** | `/app` or `/home/container` | `FEATHER_PORT` / `PORT` | `FEATHER_MEMORY` / `MEMORY` |
| **PufferPanel** | `/server` | `PORT` / `PUFFER_PORT` | `MEMORY` / `MAX_RAM` |
| **Jexactyl / Wisp** | `/home/container` | `SERVER_PORT` / `PORT` | `SERVER_MEMORY` |
| **Standalone Docker** | `/home/container` or `$PWD` | `PORT` / `HTTP_PORT` | Cgroup v1/v2 limits |
| **Kubernetes** | `/home/container` or `/app` | `PORT` / `HTTP_PORT` | Cgroup v1/v2 limits |

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
├── egg-programming-universal.json       ← Flagship Universal Egg (Import into Pterodactyl / Pelican / Feather)
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
├── Dockerfile                            ← Universal Multi-Arch Runtime Container
├── entrypoint.sh                         ← Multi-Panel Entrypoint (Settings, Environment, Banner)
├── run.sh                                ← Universal Launcher & Project Auto-Detector
├── install.sh                            ← Multi-Panel Installer Script
├── install-runtime.sh                    ← Dynamic On-Demand Toolchain Downloader
├── .github/workflows/docker-image.yml    ← Automated CI/CD Multi-Arch Build Workflow
└── README.md                             ← Comprehensive Documentation
```

---

## Quick Setup Guide

### 1. Import the Egg (Pterodactyl, Pelican, Feather Panel)
1. Download [egg-programming-universal.json](https://github.com/PotenFYR-Studios/Prog-Language-Eggs/blob/main/egg-programming-universal.json).
2. Open your Panel Admin Area (**Nests** / **Templates**).
3. Click **Import Egg**, select `egg-programming-universal.json`, and click **Save**.

### 2. Create a Server
1. Create a server using the imported egg.
2. Under **Docker Image**, select `Universal (50+ Languages)`.
3. Launch the server from your panel console.

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
| **Target Language** | `LANGUAGE` | `auto` | 👤 Yes | Target language or 'auto' for intelligent file auto-detection. |
| **Execution Runner** | `RUNNER` | `auto` | 👤 Yes | Runner or engine to use (e.g. auto, node, bun, tsx, uvicorn, cargo, go). |
| **Main Entry File** | `MAIN_FILE` | `auto` | 👤 Yes | The main script or file to execute (leave 'auto' for smart detection). |
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
| **Extra URLs** | `EXTRA_URLS` | `""` | 👤 Yes | Additional files or archives to download on boot (URL or dest\|URL). |
| **Auto Restart** | `AUTO_RESTART` | `0` | 👤 Yes | Automatically restart process on unexpected crash (1 = Enabled, 0 = Disabled). |
| **Restart Delay** | `RESTART_DELAY` | `3` | 👤 Yes | Delay in seconds before attempting to auto-restart. |
| **Assigned Port** | `SERVER_PORT` | `{{server.build.default.port}}` | 🔒 Admin | Primary network port allocated by the panel. |
| **Debug Mode** | `DEBUG` | `0` | 👤 Yes | Enable verbose script debug output (1 = Enabled, 0 = Disabled). |

---

## License

This project is open-source under the **MIT License**.

Developed with ❤️ by **[PotenFYR Studios](https://github.com/PotenFYR-Studios)** (support@potenfyr.in).