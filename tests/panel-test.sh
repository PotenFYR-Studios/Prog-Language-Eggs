#!/usr/bin/env bash
# Panel-behavior test suite for Prog-Language Eggs.
# Simulates the daemon lifecycle: start, stop (SIGTERM), kill (SIGKILL),
# restart, console-text stop, crash diagnostics, health check, error journal,
# multi-process sweep and startup-value pinning.
set -u
cd "$(dirname "$0")/.."

# Git Bash on Windows mangles POSIX paths in command args (docker exec paths,
# HEALTH_CHECK_PATH=/ etc.) - disable that for this suite.
export MSYS_NO_PATHCONV=1
export MSYS2_ARG_CONV_EXCL="*"

IMG=prog-eggs-test
VOL=prog-test-ws
PASS=0; FAIL=0
ok()  { echo "  PASS: $1"; PASS=$((PASS+1)); }
bad() { echo "  FAIL: $1"; FAIL=$((FAIL+1)); }

cleanup() { docker rm -f prog-t1 prog-t7 prog-t8 >/dev/null 2>&1; docker volume rm -f "$VOL" >/dev/null 2>&1; }
trap cleanup EXIT

echo "== building test image =="
if ! docker build -q -t "$IMG" -f tests/Dockerfile.test . >/dev/null 2>&1; then
    echo "docker build failed:"; docker build -t "$IMG" -f tests/Dockerfile.test . | tail -20; exit 1
fi
echo "  image ready"

# ---------------------------------------------------------------- T1: START
echo "== T1: start (panel env, nodejs starter) =="
docker rm -f prog-t1 >/dev/null 2>&1; docker volume rm -f "$VOL" >/dev/null 2>&1
docker run -d --name prog-t1 -v "$VOL:/home/container" \
    -e P_SERVER_UUID=11111111-2222-3333-4444-555555555555 \
    -e SERVER_PORT=25565 -e SERVER_MEMORY=2048 -e AUTO_UPDATE_EGG=0 \
    -e STARTER_TEMPLATE=nodejs "$IMG" >/dev/null
booted=0
for i in $(seq 1 90); do
    docker logs prog-t1 2>&1 | grep -q "listening on port 25565" && { booted=1; break; }
    sleep 1
done
[ "$booted" = "1" ] && ok "app booted and listening on 25565" || { bad "app never listened"; docker logs prog-t1 2>&1 | tail -60; }
docker logs prog-t1 2>&1 | grep -q "Pelican Panel" && ok "panel family detected (Pelican via P_SERVER_UUID)" || { bad "panel detection"; docker logs prog-t1 2>&1 | grep -iE "panel=|Host Platform" | head -3; }
docker logs prog-t1 2>&1 | grep -q "prog-language-eggs" && ok "agent theme active" || bad "theme prefix"
docker logs prog-t1 2>&1 | grep -q "Programming Languages" && ok "banner says Programming Languages" || bad "banner name"
docker exec prog-t1 curl -s http://127.0.0.1:25565/ 2>/dev/null | grep -q '"status": "online"' \
    && ok "HTTP 200 JSON response" || bad "HTTP not responding"
docker exec prog-t1 grep -q "prog-language-eggs" /home/container/.logs/console.log 2>/dev/null \
    && ok "console mirror .logs/console.log active" || bad "console mirror missing"
docker exec prog-t1 grep -q "boot @" /home/container/.logs/console.log 2>/dev/null \
    && ok "boot header in mirror" || bad "boot header missing"
docker logs prog-t1 2>&1 | grep -q "Server UUID" && ok "boot card shows server UUID" || bad "boot card UUID row"
docker logs prog-t1 2>&1 | grep "Target Language" | grep -q "nodejs" && ok "card shows detected language (nodejs)" || { bad "card language"; docker logs prog-t1 2>&1 | grep "Target Language"; }
docker logs prog-t1 2>&1 | grep "Entry Point" | grep -q "index.js" && ok "card shows resolved entry point" || { bad "card entry point"; docker logs prog-t1 2>&1 | grep "Entry Point"; }
docker logs prog-t1 2>&1 | grep -q "Startup value pinned: RUNTIME_VERSION=" && ok "RUNTIME_VERSION pinned to resolved exact version" || bad "RUNTIME_VERSION pin"
docker logs prog-t1 2>&1 | grep -q "Startup value pinned: RUNNER=node" && ok "RUNNER pinned to effective engine (node)" || bad "RUNNER pin"
docker exec prog-t1 grep -q "RUNTIME_VERSION=" /home/container/.multi-prog.conf 2>/dev/null \
    && ok "RUNTIME_VERSION pinned in .multi-prog.conf" || bad "RUNTIME_VERSION pin"
docker exec prog-t1 grep -q "^RUNNER=node" /home/container/.multi-prog.conf 2>/dev/null \
    && ok "RUNNER=node pinned in .multi-prog.conf" || bad "RUNNER pin"

# ---------------------------------------------------------------- T2: STOP
echo "== T2: stop from panel (SIGTERM to PID 1) =="
t0=$(date +%s)
docker stop -t 25 prog-t1 >/dev/null
t1=$(date +%s); elapsed=$((t1-t0))
[ "$elapsed" -lt 15 ] && ok "graceful stop in ${elapsed}s (<15s before daemon SIGKILL)" || bad "stop took ${elapsed}s"
docker logs prog-t1 2>&1 | grep -q "Received shutdown signal" && ok "shutdown log line present" || bad "no shutdown log"
docker logs prog-t1 2>&1 | grep -q "stopped cleanly" && ok "clean stop confirmation" || bad "no clean-stop confirmation"

# ---------------------------------------------------------------- T3: RESTART
echo "== T3: restart from panel (pins must persist) =="
docker start prog-t1 >/dev/null
restarted=0
for i in $(seq 1 90); do
    docker logs --since 90s prog-t1 2>&1 | grep -q "listening on port 25565" && { restarted=1; break; }
    sleep 1
done
[ "$restarted" = "1" ] && ok "app restarted and listening again" || bad "restart failed"
http_ok=0
for i in $(seq 1 30); do
    docker exec prog-t1 curl -s http://127.0.0.1:25565/ 2>/dev/null | grep -q '"status": "online"' && { http_ok=1; break; }
    sleep 1
done
[ "$http_ok" = "1" ] && ok "HTTP responds after restart" || bad "HTTP down after restart"
docker exec prog-t1 test -f /home/container/.logs/console.log.1 2>/dev/null \
    && ok "previous boot mirror rotated to console.log.1" || bad "mirror rotation"
docker logs --since 90s prog-t1 2>&1 | grep -qE ">>> node index.js|>>> node .*index.js" \
    && ok "pinned values used on second boot (node index.js)" || { bad "pin not used on boot 2"; docker logs --since 90s prog-t1 2>&1 | grep ">>>" | head -3; }

# ---------------------------------------------------------------- T4: KILL
echo "== T4: kill from panel (SIGKILL) =="
docker kill prog-t1 >/dev/null 2>&1
code=$(docker inspect -f '{{.State.ExitCode}}' prog-t1 2>/dev/null)
[ "$code" = "137" ] && ok "SIGKILL exit code 137" || bad "kill exit code was ${code}"
docker rm -f prog-t1 >/dev/null 2>&1

# ------------------------------------------------------- T5: CONSOLE-TEXT STOP
echo "== T5: stop via console text (Feather-style daemon) =="
out=$( (sleep 14; echo stop) | docker run -i --rm \
    -e SERVER_PORT=25566 -e STARTER_TEMPLATE=nodejs -e AUTO_UPDATE_EGG=0 "$IMG" 2>&1 )
echo "$out" | grep -q "Stop command 'stop' received via console" \
    && ok "watcher caught console stop text" || bad "watcher missed stop text"
echo "$out" | grep -q "stopped cleanly" && ok "text-stop ended cleanly (exit 0)" || bad "text-stop exit"
echo "$out" | grep -q "listening on port 25566" && ok "app was serving before text-stop" || bad "app never served in T5"

# --------------------------------------------------- T6: MULTI-PROCESS (pm2-ish)
echo "== T6: multi-process container (detached daemon + workers) =="
mp_out=$( (sleep 20; echo stop) | docker run -i --rm \
    -e CUSTOM_COMMAND="nohup node -e 'require(\"http\").createServer((q,s)=>{s.end(1)}).listen(25590); console.log(\"DAEMON-UP\", process.pid)' >/dev/null 2>&1 & sleep 1; node -e 'require(\"http\").createServer((q,s)=>{s.end(2)}).listen(25591); console.log(\"MAIN-UP\", process.pid)'" \
    -e SERVER_PORT=25591 -e AUTO_UPDATE_EGG=0 "$IMG" 2>&1 )
echo "$mp_out" | grep -q "DAEMON-UP" && ok "detached daemon booted alongside main app" || { bad "daemon never booted"; echo "$mp_out" | tail -20; }
echo "$mp_out" | grep -q "MAIN-UP" && ok "main app booted" || bad "main app never booted"
echo "$mp_out" | grep -q "stopped cleanly" && ok "clean stop with detached daemon present" || bad "stop not clean with daemon"
echo "$mp_out" | grep -qE "Swept [0-9]+ stray process" && ok "stray daemon swept on stop" || { bad "no stray sweep log"; echo "$mp_out" | grep -iE "sweep|stray" | head -3; }

# ---------------------------------------------------------------- T7: CRASH
echo "== T7: crash diagnostics + error journal =="
docker run --rm -v "$VOL:/home/container" "$IMG" bash -c 'printf "this is (( not valid js\n" > /home/container/broken.js' >/dev/null 2>&1
crash_out=$(docker run --rm -v "$VOL:/home/container" \
    -e LANGUAGE=nodejs -e MAIN_FILE=broken.js -e AUTO_INSTALL_DEPS=0 \
    -e AUTO_UPDATE_EGG=0 -e SERVER_PORT=25567 "$IMG" 2>&1)
echo "$crash_out" | grep -q "PROCESS CRASH & DIAGNOSTIC REPORT" && ok "crash report box printed" || bad "no crash report"
echo "$crash_out" | grep -q "last 12 console lines" && ok "recent-output tail in report" || bad "no output tail"
echo "$crash_out" | grep -q "launcher-errors.log" && ok "error-journal pointer shown" || bad "no journal pointer"
docker run --rm -v "$VOL:/home/container" "$IMG" bash -c 'grep -q "crashed with exit code" /home/container/.logs/launcher-errors.log 2>/dev/null' \
    && ok "crash recorded in .logs/launcher-errors.log" || bad "crash not journalled"

# ------------------------------------------------------------- T8: GIT FAILURE
echo "== T8: git failure surfaces in journal =="
docker rm -f prog-t7 >/dev/null 2>&1
docker run -d --name prog-t7 -v "$VOL:/home/container" \
    -e GIT_REPO=https://example.invalid/team/repo.git -e GIT_BRANCH=main \
    -e AUTO_INSTALL_DEPS=0 -e AUTO_UPDATE_EGG=0 -e SERVER_PORT=25568 "$IMG" >/dev/null
seen=0
for i in $(seq 1 40); do
    docker logs prog-t7 2>&1 | grep -q "Could not clone repository" && { seen=1; break; }
    sleep 1
done
[ "$seen" = "1" ] && ok "git failure warning on console" || bad "git failure not surfaced"
docker logs prog-t7 2>&1 | grep -q "check network, URL" && ok "actionable git hint shown" || bad "no actionable hint"
docker exec prog-t7 grep -q "git clone failed" /home/container/.logs/launcher-errors.log 2>/dev/null \
    && ok "git failure journalled" || bad "git failure not journalled"
docker rm -f prog-t7 >/dev/null 2>&1

# ------------------------------------------------------------ T9: HEALTH CHECK
echo "== T9: health check probe =="
docker rm -f prog-t8 >/dev/null 2>&1
docker run -d --name prog-t8 -v "$VOL:/home/container" \
    -e HEALTH_CHECK_PATH=/ -e AUTO_INSTALL_DEPS=0 -e AUTO_UPDATE_EGG=0 -e SERVER_PORT=25569 "$IMG" >/dev/null
hseen=0
for i in $(seq 1 60); do
    docker logs prog-t8 2>&1 | grep -q "Health check PASS" && { hseen=1; break; }
    sleep 1
done
[ "$hseen" = "1" ] && ok "health check PASS logged" || { bad "health check never passed"; docker logs prog-t8 2>&1 | tail -20; }
docker rm -f prog-t8 >/dev/null 2>&1

# ------------------------------------------------- T10: AUTO-DETECT RE-ARM
echo "== T10: auto-detect re-arm clears pins =="
docker run --rm -v "$VOL:/home/container" "$IMG" bash -c '
    sed -i "s/^LANGUAGE=nodejs/LANGUAGE=auto-detect/" /home/container/.multi-prog.conf 2>/dev/null
    grep -q "^LANGUAGE=" /home/container/.multi-prog.conf && echo "PIN-STILL-THERE" || echo "PIN-CLEARED"
' 2>&1 | grep -q "PIN-CLEARED" || true
rm_out=$(docker run --rm -v "$VOL:/home/container" \
    -e LANGUAGE=auto-detect -e AUTO_INSTALL_DEPS=0 -e AUTO_UPDATE_EGG=0 \
    -e SERVER_PORT=25570 "$IMG" bash -lc '
        timeout 40 bash /entrypoint.sh >/dev/null 2>&1
        grep -q "^LANGUAGE=" /home/container/.multi-prog.conf && echo "RE-PINNED:$(grep ^LANGUAGE= /home/container/.multi-prog.conf | head -1)" || echo "NO-PIN"
    ' 2>&1 | tail -1)
echo "$rm_out" | grep -q "RE-PINNED:LANGUAGE=nodejs" && ok "auto-detect re-ran detection and re-pinned nodejs" || { bad "re-arm behavior"; echo "  got: ${rm_out}"; }

# --------------------------------------------- T11: MULTI-PORT APP LIFECYCLE
echo "== T11: multi-port app (two listeners) start/stop/restart =="
docker rm -f prog-mp >/dev/null 2>&1
docker run --rm -v "$VOL:/home/container" "$IMG" bash -c 'cat > /home/container/mp.js <<"EOF"
const http = require("http");
http.createServer((q,s)=>{s.setHeader("Content-Type","text/plain");s.end("main-25580")}).listen(25580,"0.0.0.0");
http.createServer((q,s)=>{s.setHeader("Content-Type","text/plain");s.end("second-25581")}).listen(25581,"0.0.0.0");
console.log("MP-UP main=25580 second=25581");
setInterval(()=>{},1000);
EOF
echo written' >/dev/null 2>&1
docker run -d --name prog-mp -v "$VOL:/home/container" \
    -e LANGUAGE=nodejs -e MAIN_FILE=mp.js -e AUTO_INSTALL_DEPS=0 \
    -e AUTO_UPDATE_EGG=0 -e SERVER_PORT=25580 "$IMG" >/dev/null
mp_up=0
for i in $(seq 1 60); do
    a=$(docker exec prog-mp curl -s http://127.0.0.1:25580 2>/dev/null)
    b=$(docker exec prog-mp curl -s http://127.0.0.1:25581 2>/dev/null)
    [ "$a" = "main-25580" ] && [ "$b" = "second-25581" ] && { mp_up=1; break; }
    sleep 1
done
[ "$mp_up" = "1" ] && ok "both ports serve concurrently (25580 main + 25581 second)" || { bad "multi-port app not serving"; docker logs prog-mp 2>&1 | tail -30; }
t0=$(date +%s)
docker stop -t 25 prog-mp >/dev/null
t1=$(date +%s); elapsed=$((t1-t0))
[ "$elapsed" -lt 15 ] && ok "multi-port graceful stop in ${elapsed}s" || bad "multi-port stop took ${elapsed}s"
docker logs prog-mp 2>&1 | grep -q "stopped cleanly" && ok "multi-port stop confirmation" || bad "no stop confirmation"
docker start prog-mp >/dev/null
mp_re=0
for i in $(seq 1 60); do
    a=$(docker exec prog-mp curl -s http://127.0.0.1:25580 2>/dev/null)
    b=$(docker exec prog-mp curl -s http://127.0.0.1:25581 2>/dev/null)
    [ "$a" = "main-25580" ] && [ "$b" = "second-25581" ] && { mp_re=1; break; }
    sleep 1
done
[ "$mp_re" = "1" ] && ok "both ports live again after restart" || { bad "multi-port restart failed"; docker logs prog-mp 2>&1 | tail -30; }
docker kill prog-mp >/dev/null 2>&1
kcode=$(docker inspect -f '{{.State.ExitCode}}' prog-mp 2>/dev/null)
[ "$kcode" = "137" ] && ok "multi-port container kill -> 137" || bad "multi-port kill code ${kcode}"
docker rm -f prog-mp >/dev/null 2>&1

echo
echo "=========================================="
echo "  RESULTS: $PASS passed, $FAIL failed"
echo "=========================================="
[ "$FAIL" = "0" ]
