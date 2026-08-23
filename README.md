# Prog-Language-Eggs

> **One egg. One image. Every language.** A production-grade hosting platform that installs, updates,
> compiles and runs **50+ programming languages** inside your container - across **Pterodactyl**, **Pelican**,
> **Feather Panel**, **PufferPanel**, **Jexactyl**, **Wisp**, **Emerald**, **Kubernetes**, **Fly.io**,
> **Railway**, **Render**, and plain **Docker / Podman**.

```text
   __  ___      ____  _       __
  /  |/  /_  __/ / /_(_)     / /   ____ _____  ____ _
 / /|_/ / / / / / __/ /_____/ /   / __ `/ __ \/ __ `/
/ /  / / /_/ / / /_/ /_____/ /___/ /_/ / / / / /_/ /
/_/  /_/\__,_/_/\__/_/     /_____/\__,_/_/ /_/\__, /
                                              /____/
```

[![CI Build](https://github.com/PotenFYR-Studios/Prog-Language-Eggs/actions/workflows/docker-image.yml/badge.svg)](https://github.com/PotenFYR-Studios/Prog-Language-Eggs/actions)
[![Docker Image](https://img.shields.io/badge/ghcr.io-prog--language--eggs-blue?logo=docker)](https://github.com/PotenFYR-Studios/Prog-Language-Eggs/pkgs/container/prog-language-eggs)
[![Platform](https://img.shields.io/badge/Panels-Pterodactyl%20%7C%20Pelican%20%7C%20Feather%20%7C%20Puffer-orange)](#multi-panel-support)
[![Arch](https://img.shields.io/badge/Arch-amd64%20%7C%20arm64%20%7C%20armv7-success)](#runs-anywhere)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## Table of Contents

1. [What Is This? (60 seconds)](#what-is-this-60-seconds)
2. [Quick Start](#quick-start)
3. [Supported Languages (50+)](#supported-languages-50)
4. [Multi-Panel Support](#multi-panel-support)
5. [Runs Anywhere (CPU / OS)](#runs-anywhere-cpu--os)
6. [Choosing Languages & Versions](#choosing-languages--versions)
7. [Environment Isolation & Data Retention](#environment-isolation--data-retention)
8. [Multi-Layer Apps (Procfile Supervisor)](#multi-layer-apps-procfile-supervisor)
9. [Health Checks & Operations](#health-checks--operations)
10. [Security Posture](#security-posture)
11. [Performance & Efficiency](#performance--efficiency)
12. [All Startup Variables Reference](#all-startup-variables-reference)
13. [Egg Switching & Migration Guarantees](#egg-switching--migration-guarantees)
14. [Image Publishing Policy (CI)](#image-publishing-policy-ci)
15. [Repository Layout](#repository-layout)
16. [Troubleshooting & FAQ](#troubleshooting--faq)

---

## What Is This? (60 seconds)

You host games, bots, APIs, websites or microservices. Instead of installing one egg per language,
you import **one egg** and pick the language at startup:

| You want | You set | Result |
|---|---|---|
| A Discord bot in Python | `LANGUAGE=python` | Python runs your bot, deps auto-installed |
| A Node.js REST API | `LANGUAGE=nodejs` | npm install runs, server starts |
| Rust web service, pinned compiler | `LANGUAGE=rust` + `RUNTIME_VERSION=stable` | cargo build --release, binary served |
| Web + worker together | `Procfile` in workspace | Both supervised, crashes restarted |
| Anything else | leave everything `auto` | The launcher detects your project files |

The language runtime itself is downloaded **inside your container, on demand**, at whatever version you
request (`22`, `lts`, `nightly`, ...). Nothing is pre-baked that you do not use, and nothing you created
is ever deleted behind your back.

---

## Quick Start

### Panels (Pterodactyl / Pelican / Feather / Jexactyl / Wisp / Emerald)

1. Download [`egg-programming-multi.json`](https://github.com/PotenFYR-Studios/Prog-Language-Eggs/blob/main/egg-programming-multi.json).
2. Admin Area -> **Nests / Templates** -> **Import Egg** -> select the file -> Save.
3. Create a server with the egg. Under **Docker Image** pick `Multi-Language (50+ Languages)`.
4. Set variables if you want (or leave all `auto`). Press **Start**. Done.

### Plain Docker

```bash
docker run -d --name my-app \
  -p 8080:8080 \
  -e SERVER_PORT=8080 \
  -e LANGUAGE=nodejs \
  -v "$PWD/my-project:/home/container" \
  ghcr.io/potenfyr-studios/prog-language-eggs:latest
```

### Kubernetes / Fly.io / Railway / Render

Use the same image with `PORT` env; working directory and port detection adapt automatically.

---

## Supported Languages (50+)

| # | Language / Platform | Runners / Engines | Package Managers & Build Tools |
|---|---------------------|-------------------|--------------------------------|
| 1 | Node.js (JavaScript) | node, nodemon, pm2 | npm, pnpm, yarn |
| 2 | TypeScript | ts-node, tsx, bun, tsc | npm, pnpm, yarn, tsc |
| 3 | Bun | bun run, bun test, bunx | bun install |
| 4 | Deno | deno run, deno task | deno.json, URL imports |
| 5 | Python | python3, uvicorn, gunicorn | uv, pip, poetry, pipenv |
| 6 | Java | java -jar, mvnw, gradlew | maven, gradle |
| 7 | Go | go run, ./server | go mod |
| 8 | Rust | cargo run, ./server | cargo |
| 9 | C | gcc, clang, make | make, cmake, ninja |
| 10 | C++ | g++, clang++, make | make, cmake, ninja |
| 11 | C# / .NET | dotnet run, dotnet exec | dotnet restore, nuget |
| 12 | PHP | php -S, php artisan | composer |
| 13 | Ruby | ruby, puma, bundle exec | gem, bundler |
| 14 | Static Website / SPA | serve, python http.server | static files |
| 15 | Kotlin | kotlin, kotlinc, gradle | gradle, maven |
| 16 | Scala | scala, sbt | sbt |
| 17 | Swift | swift run, swiftc | swift package |
| 18 | Dart | dart run | dart pub |
| 19 | Zig | zig run, zig build | build.zig |
| 20 | Lua / LuaJIT | lua, luajit | luarocks |
| 21 | Elixir | mix run, elixir | mix, hex |
| 22 | Erlang | escript, rebar3 | rebar3 |
| 23 | Haskell | runghc, cabal, stack | cabal, stack |
| 24 | Perl | perl | cpanm |
| 25 | R | Rscript | install.packages() |
| 26 | Julia | julia | Pkg |
| 27 | Clojure | lein run, clojure -M | leiningen, deps.edn |
| 28 | Groovy | groovy, groovyc | gradle |
| 29 | Crystal | crystal run | shards |
| 30 | Nim | nim r, nimble run | nimble |
| 31 | OCaml | ocaml, dune exec | opam, dune |
| 32 | F# | dotnet run | nuget, dotnet |
| 33 | Fortran | gfortran | make |
| 34 | FreePascal | fpc | fpc |
| 35 | COBOL | cobc (GnuCOBOL) | cobc |
| 36 | Assembly (x86/ARM) | nasm, as, ld | make |
| 37 | V | v run | v |
| 38 | Odin | odin run | odin |
| 39 | Gleam | gleam run | gleam |
| 40 | ReScript / ReasonML | rescript, node | npm, bsb |
| 41 | Haxe | haxe --run | haxelib |
| 42 | Racket | racket | raco |
| 43 | Scheme / Guile | guile, csi | chicken-install |
| 44 | Common Lisp | sbcl --script | quicklisp |
| 45 | D | rdmd, dub run | dub |
| 46 | Ada | gnatmake | gprbuild |
| 47 | Smalltalk | gst | gst-package |
| 48 | Tcl | tclsh | tcl |
| 49 | Prolog | swipl | swi-prolog |
| 50 | Solidity (Dev/Node) | npx hardhat node, anvil | hardhat, foundry |
| 51 | Bash / Shell | bash, sh | apt |
| 52 | PowerShell | pwsh | PSGallery |
| 53 | Visual Basic .NET | dotnet run | nuget |
| 54 | Vala | valac | meson, ninja |

Anything not listed falls through to smart file detection (`index.js`, `main.py`, `main.go`, ...) or your own
`CUSTOM_COMMAND`.

---

## Multi-Panel Support

The entrypoint identifies its host precisely at boot and exports two variables scripts can rely on:
`PANEL_TYPE` (human label) and `PANEL_FAMILY` (`wings | feather | puffer | k8s | paas | docker`).

| Panel / Platform | Detected As | Family | Working Dir | Port Variables Unified |
|---|---|---|---|---|
| Pterodactyl | Pterodactyl Panel | wings | `/home/container` | `SERVER_PORT`, `PORT` |
| Pelican | Pelican Panel | wings | `/home/container` | `SERVER_PORT`, `PORT` |
| Feather Panel | Feather Panel | feather | `/app` or `/home/container` | `FEATHER_PORT`, `PORT` |
| PufferPanel | PufferPanel | puffer | `/server` | `PORT`, `PUFFER_PORT` |
| Jexactyl / Wisp / Emerald | per-panel label | wings | `/home/container` | `SERVER_PORT`, `PORT` |
| Kubernetes / OpenShift | Kubernetes Pod | k8s | `/home/container` or `/app` | `PORT`, `HTTP_PORT` |
| Fly.io / Railway / Render | per-platform label | paas | `$PWD` | `PORT` |
| Heroku-style dynos | Heroku-style Dyno | paas | `/app` | `PORT` |
| Standalone Docker / Podman | Docker / Standalone | docker | `/home/container` or `$PWD` | `PORT`, `HTTP_PORT` |

Memory limits are unified too: `SERVER_MEMORY` / `MEMORY` / `FEATHER_MEMORY` / cgroup limits all feed the
OOM-protection tuner.

---

## Runs Anywhere (CPU / OS)

| Host architecture | Status | Notes |
|---|---|---|
| `linux/amd64` | Full | Standard panel nodes |
| `linux/arm64` | Full | Apple Silicon, Ampere, Raspberry Pi 4/5 (64-bit), Oracle ARM |
| `linux/arm/v7` | Full image | SBC-hosted panels; engines lacking armv7 upstreams self-provision alternatives |
| `ppc64le`, `s390x`, `riscv64` | On demand | Pair any distro base image with this egg: Node.js, Go, Rust, Java resolve official upstream builds automatically at boot |

- **Host OS does not matter**: wherever the panel can run containers (Linux natively; Windows/macOS via
  Docker Desktop / WSL2 backends), the egg works - the container is always Linux.
- **Any distro inside the container**: `ensure_core_tools()` detects alpine/debian/fedora/suse-style bases
  and installs missing essentials (`curl jq xz unzip tar`) when root, or prints exact guidance when not.
- **Per-engine availability checks**: nothing hard-fails on unusual CPUs; each engine reports precisely
  what ships for your platform (see `.logs/db-install.log` naming under [.logs/](#troubleshooting--faq)).

---

## Choosing Languages & Versions

### Language selection

- `LANGUAGE=auto` (default) - inspects your files (`package.json`, `requirements.txt`, `go.mod`,
  `Cargo.toml`, `*.csproj`, ...) and picks the stack.
- `LANGUAGE=<name>` - force one (`python`, `nodejs`, `rust`, ...). Aliases accepted (`py`, `js`, `ts`, `go`).
- `RUNNER=` - engine override (`bun`, `deno`, `tsx`, `uvicorn`, `pm2`, ...).
- `MAIN_FILE=` - explicit entry point, otherwise smart detection order applies.
- `CUSTOM_COMMAND=` - full control: replaces the launcher's command entirely.

### Version selection (`RUNTIME_VERSION`)

Versions are resolved from **live upstream feeds** before anything downloads; garbage fails fast with
accepted-form guidance. No hardcoded pins anywhere.

| Request | Example | Behaviour |
|---|---|---|
| `latest` | default | Newest stable/GA release |
| `stable` | `stable` | Newest LTS/stable line (Node -> newest LTS, Rust -> stable, .NET -> LTS channel) |
| `lts` | `lts` | Newest LTS cycle (Node, Java/Adoptium, .NET) |
| `alpha` `beta` `rc` `pre` `preview` | `beta` | Pre-release channel when upstream publishes one; otherwise newest stable with a notice |
| `nightly` `dev` `canary` `tip` `edge` `master` | `nightly` | Nightly/canary line (Node nightly CDN, Rust nightly, Zig master, .NET daily, Dart dev, Bun canary, Java EA) |
| Concrete | `22`, `20.11`, `v20.11.1`, `3.12`, `1.22`, `17`, `9.0` | Newest matching release verified against the feed; unknown series rejected with valid options |

Companion runtimes take their own versions:

```
EXTRA_RUNTIMES=python@3.12,bun@1.1,java@21
SKIP_RUNTIMES=python          # opt out entirely
NODE_GYP_SUPPORT=1            # native addon toolchain for node modules
```

Results are cached under `.cache/version-resolver/` (6h TTL, `RESOLVER_CACHE_TTL` to tune) so warm boots
skip network round-trips.

---

## Environment Isolation & Data Retention

Every language + major-version series gets its own environment folder. Switching languages or upgrading
majors never destroys anything:

```text
.environments/
|-- active                    <- last used instance marker
|-- nodejs/
|   |-- node22/               <- npm/bun caches, tool state for Node 22.x
|   `-- node24/               <- preserved if you switch to 24 and later return
|-- python/py3.12/
|-- golang/go1.22/
|-- rust/rust-stable/
`-- .resolved/<lang>          <- resolved concrete version cache
```

| Change | What happens |
|---|---|
| Same language, same major series | Compatible - folder reused, info message |
| Same language, new major series | New folder created; old preserved; yellow console warning shows both paths |
| Different language | Separate subtree; previous language fully retained; console warning lists it |

Retained environments are listed on every boot with sizes plus manual-deletion instructions. **Nothing is
auto-deleted, by design.**

---

## Multi-Layer Apps (Procfile Supervisor)

Drop a `Procfile` in your workspace to run several processes in one container - ideal for
web + API + worker architectures or tiny multi-service setups:

```procfile
web:    node server.js
api:    wait_port 127.0.0.1 6379 30 && python -m uvicorn api:app --port 8081
worker: node worker.js
```

| Capability | Detail |
|---|---|
| Modes | `SUPERVISOR=auto` (default: Procfile wins when language is auto), `procfile` forces it, `single` disables |
| Crash recovery | Linear-backoff restarts (1s, 2s, 3s...), gives up after `PROCFILE_MAX_RESTARTS` (5) |
| Graceful shutdown | Panel SIGTERM relays to every child; hard kill only after a drain window |
| Per-process logs | `PROCFILE_LOGS=1` mirrors streams to `.logs/processes/<name>.log` |
| Startup ordering | Built-in `wait_port <host> <port> [timeout]` waits on databases/caches/queues first |

Single-process servers get the same treatment via `AUTO_RESTART=1` + crash diagnostic cards.

---

## Health Checks & Operations

- `HEALTH_CHECK_PATH=/healthz` - after boot, the launcher probes `http://127.0.0.1:$SERVER_PORT<path>`
  until it answers (budget `HEALTH_TIMEOUT=60`s).
- `HEALTH_STRICT=1` - failed probe exits non-zero so panels mark the server unhealthy instead of silently running.
- **Console mirror** - every boot duplicates the full console into `.logs/console.log` (previous boot kept
  as `.1`; disable with `LAUNCHER_LOG=0`).
- **Trace mode** - `DEBUG=1` writes bash xtrace to `.logs/launcher-trace.log`; console stays readable.
- **Provenance** - `/etc/potenfyr-version` stamp printed at boot (variant + build date).
- **Crash diagnostics** - non-zero exits trigger a report card: exit code, active runtime version, memory
  usage vs limit, disk space, recommendations.

---

## Security Posture

| Control | Detail |
|---|---|
| Checksum verification | Node.js tarballs verified against official `SHASUMS256.txt`; Zig against published shasum; mismatch aborts loudly |
| URL validation | `GIT_REPO`, `CUSTOM_RUNTIME_URL` must be well-formed https/ssh/http URLs; header-injection shapes rejected before any fetch |
| Secret redaction | Credentials embedded in URLs and tokens never reach console or logs |
| Root guard | Warns when the container runs as uid 0 (panels should use the non-root image user) |
| Least privilege | All installs happen inside the workspace as the container user; no host access |
| Audit trail | Console mirror + per-installer logs + resolver logs give full replay of what ran and why |

---

## Performance & Efficiency

- **Parallel companion installs** - `EXTRA_RUNTIMES=a,b,c` download simultaneously, each logged to
  `.logs/runtime-install-<name>.log`.
- **TTL resolver cache** - warm boots skip upstream feed lookups.
- **Idempotent installs** - present binaries short-circuit before any network I/O.
- **Memory auto-tune** - computes safe heap ceilings per runtime (`NODE_OPTIONS`, `GOMEMLIMIT`, `-Xmx`,
  `DOTNET_GCHeapHardLimit`, MALLOC trim) from panel memory limits to prevent OOM kills.
- **Build-cache cleanup** - `CLEAN_BUILD_CACHE=1` purges compiler/package caches after builds.

---

## All Startup Variables Reference

### Core selection
| Variable | Default | Editable | Description |
|---|---|---|---|
| `LANGUAGE` | `auto` | Yes | Target language or auto-detect |
| `RUNNER` | `auto` | Yes | Engine override (bun, deno, tsx, uvicorn, pm2, ...) |
| `MAIN_FILE` | `auto` | Yes | Entry point override |
| `PACKAGE_MANAGER` | `auto` | Yes | Dependency manager override |
| `RUNTIME_VERSION` | `latest` | Yes | Primary runtime version or channel keyword |
| `CUSTOM_COMMAND` | empty | Yes | Replace launcher command entirely |
| `BUILD_COMMAND` | empty | Yes | Optional build step before run |
| `EXTRA_ARGS` | empty | Yes | Extra CLI args passed to your app |

### Runtimes & companions
| Variable | Default | Editable | Description |
|---|---|---|---|
| `EXTRA_RUNTIMES` | `auto` | Yes | Companions, optionally versioned: `python@3.12,bun@latest` |
| `SKIP_RUNTIMES` | `none` | Yes | Engines to skip completely |
| `RUNTIME_VERSION` | `latest` | Yes | See version tables above |
| `CUSTOM_RUNTIME_URL` | empty | Yes | Direct download of a custom runtime archive/binary |
| `NODE_GYP_SUPPORT` | `1` | Yes | Python/build tools for native node addons |
| `SKIP_PYTHON` | `0` | Yes | Prevent the Python companion entirely |
| `AUTO_INSTALL_DEPS` | `1` | Yes | Auto dependency installation on boot |

### Process behaviour
| Variable | Default | Editable | Description |
|---|---|---|---|
| `SUPERVISOR` | `auto` | Yes | `auto` / `procfile` (force) / `single` |
| `PROCFILE_RESTART` | `1` | Yes | Restart crashed Procfile processes with backoff |
| `PROCFILE_LOGS` | `0` | Yes | Mirror process streams to `.logs/processes/` |
| `AUTO_RESTART` | `0` | Yes | Restart single main process on crash |
| `RESTART_DELAY` | `3` | Yes | Seconds between restart attempts |
| `DEV_MODE` | `0` | Yes | Watch/hot-reload mode |
| `PRE_RUN_COMMAND` | empty | Yes | Runs before the main process (migrations...) |
| `POST_RUN_COMMAND` | empty | Yes | Runs on stop/shutdown |
| `CLEAN_BUILD_CACHE` | `1` | Yes | Purge caches after builds |
| `MEMORY_AUTO_TUNE` | `1` | Yes | OOM-protective heap tuning |

### Networking & repository
| Variable | Default | Editable | Description |
|---|---|---|---|
| `SERVER_PORT` | panel-assigned | Admin | Primary allocation (also reads PORT/FEATHER_PORT/PUFFER_PORT) |
| `AUTO_ENV_INJECT` | `1` | Yes | Keep `.env` PORT/HOST bindings correct |
| `GIT_REPO` | empty | Yes | Clone/sync repository on boot |
| `GIT_BRANCH` | `main` | Yes | Branch to track |
| `GIT_AUTH_TOKEN` | empty | Yes | PAT for private repos (redacted in logs) |
| `EXTRA_URLS` | empty | Yes | Extra archives/files fetched at boot |

### Health & reliability
| Variable | Default | Editable | Description |
|---|---|---|---|
| `HEALTH_CHECK_PATH` | empty | Yes | HTTP path probed post-boot; empty disables |
| `HEALTH_STRICT` | `0` | Yes | Exit non-zero when probe fails |
| `HEALTH_TIMEOUT` | `60` | Yes | Probe budget in seconds |
| `STARTER_TEMPLATE` | `empty` | Yes | Scaffold a starter project on empty workspaces |
| `DEBUG` | `0` | Yes | Bash trace to `.logs/launcher-trace.log` |
| `LAUNCHER_LOG` | `1` | Yes | Console mirroring toggle |
| `RESOLVER_CACHE_TTL` | `21600` | Yes | Version cache seconds (0 disables) |
| `DATABASE_*` | - | - | Reserved prefix for future companion services |

Admin-locked: `SERVER_PORT`. Everything else is user-editable in the panel UI.

---

## Egg Switching & Migration Guarantees

Moving between eggs (ours or third-party) is designed to be boring:

- **Startup commands normalize safely.** Any startup referencing `run.sh` becomes exactly
  `bash <launcher>` (kills interpreter mismatches like `sh run.sh` under dash); foreign commands such as
  `node index.js` are preserved verbatim as `CUSTOM_COMMAND`.
- **Legacy runtime folders migrate in place.** Old unversioned install dirs (bun/deno/cargo) move to the
  new layout instead of re-downloading.
- **Variables survive.** Every historical variable name still exists with compatible semantics; panel-set
  values always win over persisted config.
- **Your data is sacred.** Project files, `.environments/`, caches and logs are never touched by upgrades;
  retained items are announced with sizes and deletion instructions.

---

## Image Publishing Policy (CI)

- ONE image, ONE job. Pushes to `main` build `linux/amd64` + `linux/arm64` + `linux/arm/v7`
  **with `no-cache: true`** - every tag is a clean rebuild of the exact committed sources.
- Tags published: `latest` (moving) and `<commit-sha>` (immutable, for rollbacks/digest pinning).
- Pull requests build without pushing.

```bash
ghcr.io/potenfyr-studios/prog-language-eggs:latest
ghcr.io/potenfyr-studios/prog-language-eggs:<commit-sha>
```

---

## Repository Layout

```
Prog-Language-Eggs/
|-- egg-programming-multi.json        THE single egg (import into any PTDL_v2 panel)
|-- Dockerfile                        Single multi-arch image definition
|-- entrypoint.sh                     Boot: panel detect, arch/distro assurance, banner, launch
|-- run.sh                            Launcher: detection, isolation, supervisor, health, restarts
|-- install-runtime.sh                On-demand toolchain installer (checksummed, arch-aware)
|-- resolve-version.sh                Version validator + live-feed keyword resolver
|-- install.sh                        Cross-panel workspace installer script
|-- test-docker.sh / test-docker.ps1  Multi-panel simulation test suites
`-- .github/workflows/docker-image.yml  Clean-build publish pipeline
```

---

## Troubleshooting & FAQ

### Newbie quick answers

<details>
<summary><b>My server starts but says "Hello from PotenFYR" - where is my app?</b></summary>
Your workspace was empty, so a starter placeholder was scaffolded. Upload your code (or set GIT_REPO),
then restart.
</details>

<details>
<summary><b>How do I change the language later?</b></summary>
Panel -> Startup -> change <code>LANGUAGE</code>. Your previous environment stays in
<code>.environments/</code>; the console tells you exactly where and how to delete it if unwanted.
</details>

<details>
<summary><b>A version keyword did not resolve</b></summary>
Read the console message (it lists valid series) and check <code>.logs/version-resolver.log</code>.
Numeric forms look like <code>22</code>, <code>20.11.1</code>, <code>v3.12</code>.
</details>

<details>
<summary><b>The app crashed - where do I look?</b></summary>
Console shows a crash card automatically. Deeper: <code>.logs/console.log</code>,
<code>.logs/processes/&lt;name&gt;.log</code> (Procfile mode), and <code>.logs/launcher-trace.log</code>
after a <code>DEBUG=1</code> restart.
</details>

### Expert diagnostics map

| Symptom | First place to look |
|---|---|
| Version request rejected / wrong version picked | `.logs/version-resolver.log` |
| Runtime download/extraction failure | Installer output (retry counts, sizes, checksum verdicts included) |
| Wrong panel detected | Compare boot banner `Host Platform` row; open an issue with `env | grep -iE 'pterodactyl\|pelican\|puffer\|feather'` |
| Environment not reused across restarts | Inspect `.environments/active` marker format `lang\|series\|version` |
| Procfile process keeps dying | `.logs/processes/<name>.log` + restart counter messages |
| Health probe failing | App binding must be `0.0.0.0:$SERVER_PORT` inside the container; check app logs first |
| Full step replay | `DEBUG=1` then read `.logs/launcher-trace.log` top-to-bottom |

### Support

- Issues: https://github.com/PotenFYR-Studios/Prog-Language-Eggs/issues
- Email: support@potenfyr.in

---

## License

MIT - see [LICENSE](LICENSE). Developed by [PotenFYR Studios](https://github.com/PotenFYR-Studios).
