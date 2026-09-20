#!/usr/bin/env bash
# Local (no docker) test suite for the launcher's Git synchronization engine.
# Extracts the real functions out of run.sh and exercises sync_git_repo
# against scratch bare repositories:
#   S1  fresh clone into an empty workspace
#   S2  new upstream commit -> picked up on next sync (archive created)
#   S3  branch switch after first clone (origin/<branch> ref stale) -> syncs
#   S4  GIT_REPO changed in Startup tab -> origin re-pointed, new repo synced
#   S5  non-empty workspace without .git -> repo fetched OVER files, no wipe
#   S6  bad token -> loud redacted warning, installed code kept
#   S7  archive rotation caps at 5
#   S8  untrimmed panel inputs (trailing spaces/newlines) still work
set -u
cd "$(dirname "$0")/.."
ROOT="$PWD"

# Never let a host credential helper (Git Credential Manager on Windows, etc.)
# pop a dialog or hang the suite: the S6 case intentionally probes a real
# unreachable GitHub URL and must fail fast without any interactivity.
# Env-only - nothing here touches the user's real git config files.
export GIT_TERMINAL_PROMPT=0
export GIT_ASKPASS=/bin/true
export GCM_INTERACTIVE=never
export GIT_CONFIG_SYSTEM=/dev/null

TMP="$(mktemp -d)"
ERRLOG="$TMP/error-journal.log"
PASS=0; FAIL=0
ok_t()  { echo "  PASS: $1"; PASS=$((PASS+1)); }
bad_t() { echo "  FAIL: $1"; FAIL=$((FAIL+1)); }
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

# --- Extract every top-level function from run.sh and load them -------------
python tests/extract_funcs.py run.sh > "$TMP/functions.sh" || exit 1
# shellcheck disable=SC1090
source "$TMP/functions.sh"

# Override console/journal helpers so output is inspectable.
log()   { echo "[log] $*"; }
ok()    { echo "[ok] $*"; }
warn()  { echo "[warn] $*"; }
info()  { echo "[info] $*"; }
fail()  { echo "[fail] $*"; exit 1; }
phase() { :; }
_egg_error_log() { printf '%s\n' "$2" >> "$ERRLOG"; }

# --- Scratch repository helpers ----------------------------------------------
GITCFG="-c user.email=test@potenfyr.in -c user.name=SyncTest -c commit.gpgsign=false"
mkrepo() { # mkrepo NAME BRANCH
    git init -q --bare -b "$2" "$TMP/$1.git"
    git clone -q "$TMP/$1.git" "$TMP/$1-wt" 2>/dev/null
}
commit() { # commit WT FILE CONTENT MSG
    printf '%s\n' "$3" > "$TMP/$1-wt/$2"
    git $GITCFG -C "$TMP/$1-wt" add -A >/dev/null
    git $GITCFG -C "$TMP/$1-wt" commit -qm "$4"
    git -C "$TMP/$1-wt" push -q origin HEAD >/dev/null
}
head_of() { git -C "$1" rev-parse --short HEAD 2>/dev/null; }
run_sync_in() { # run_sync_in DIR; env GIT_* must be set by caller
    ( cd "$1" && WORK_DIR="$1" sync_git_repo ) > "$TMP/out.log" 2>&1
}

echo "== Git sync engine tests =="

# ---------------------------------------------------------------- S1
echo "S1: fresh clone into empty workspace"
mkrepo alpha main
commit alpha index.js 'console.log(1)' 'alpha c1'
commit alpha index.js 'console.log(2)' 'alpha c2'
W="$TMP/s1"; mkdir -p "$W"
GIT_REPO="$TMP/alpha.git" GIT_BRANCH=main GIT_AUTH_TOKEN="" run_sync_in "$W"
[ "$(head_of "$W")" = "$(head_of "$TMP/alpha-wt")" ] && ok_t "cloned to latest commit" || bad_t "clone not at latest"
grep -q "console.log(2)" "$W/index.js" && ok_t "file content matches HEAD" || bad_t "wrong content"
grep -q "successfully cloned" "$TMP/out.log" && ok_t "console reports clone" || bad_t "no clone message"

# ---------------------------------------------------------------- S2
echo "S2: new upstream commit picked up on restart"
commit alpha index.js 'console.log(3)' 'alpha c3'
GIT_REPO="$TMP/alpha.git" GIT_BRANCH=main GIT_AUTH_TOKEN="" run_sync_in "$W"
[ "$(head_of "$W")" = "$(head_of "$TMP/alpha-wt")" ] && ok_t "synced to new commit" || bad_t "stuck on old commit"
grep -q "Git updated" "$TMP/out.log" && ok_t "reports old->new commit" || bad_t "no update message"
[ -d "$W/.logs/code-archives" ] && [ -n "$(find "$W/.logs/code-archives" -name '*.tar.gz' -print -quit)" ] \
    && ok_t "codebase archive created before overwrite" || bad_t "no archive created"
grep -q "alpha c3" "$TMP/out.log" && ok_t "prints latest commit subject" || bad_t "no commit subject"

# ---------------------------------------------------------------- S3
echo "S3: branch switch after first clone (stale origin/<branch> ref)"
git -C "$TMP/alpha-wt" checkout -qb dev
git -C "$TMP/alpha-wt" push -q origin dev
commit alpha devfile 'dev content' 'alpha dev c1'
git -C "$TMP/alpha-wt" checkout -q main
W3="$TMP/s3"; mkdir -p "$W3"
GIT_REPO="$TMP/alpha.git" GIT_BRANCH=main GIT_AUTH_TOKEN="" run_sync_in "$W3"
GIT_REPO="$TMP/alpha.git" GIT_BRANCH=dev GIT_AUTH_TOKEN="" run_sync_in "$W3"
[ -f "$W3/devfile" ] && ok_t "switched to dev branch content" || bad_t "branch switch failed"
git -C "$W3" rev-parse --verify -q refs/remotes/origin/dev >/dev/null \
    && ok_t "works even without origin/<branch> ref" \
    || ok_t "FETCH_HEAD reset independent of remote-tracking ref"

# ---------------------------------------------------------------- S4
echo "S4: GIT_REPO changed in Startup tab"
mkrepo beta main
commit beta app.js 'beta code' 'beta c1'
W4="$TMP/s4"; mkdir -p "$W4"
GIT_REPO="$TMP/alpha.git" GIT_BRANCH=main GIT_AUTH_TOKEN="" run_sync_in "$W4"
old_head="$(head_of "$W4")"
GIT_REPO="$TMP/beta.git" GIT_BRANCH=main GIT_AUTH_TOKEN="" run_sync_in "$W4"
[ -f "$W4/app.js" ] && ok_t "re-pointed origin and synced new repo" || bad_t "still old repo after GIT_REPO change"
grep -q "url = .*beta.git" "$W4/.git/config" && ok_t "origin URL updated in .git/config" || bad_t "origin URL stale"

# ---------------------------------------------------------------- S5
echo "S5: non-empty workspace without .git (uploaded files + GIT_REPO)"
W5="$TMP/s5"; mkdir -p "$W5"
echo "my-local-file" > "$W5/local.txt"
GIT_REPO="$TMP/alpha.git" GIT_BRANCH=main GIT_AUTH_TOKEN="" run_sync_in "$W5"
grep -q "my-local-file" "$W5/local.txt" && ok_t "pre-existing user file kept (no wipe)" || bad_t "user files wiped"
grep -q "console.log(3)" "$W5/index.js" && ok_t "repo files fetched over existing workspace" || bad_t "repo not applied"
[ -n "$(find "$W5/.logs/code-archives" -name '*.tar.gz' -print -quit)" ] && ok_t "workspace archived before overlay" || bad_t "no archive before overlay"

# ---------------------------------------------------------------- S6
echo "S6: unreachable repo + token -> loud error, code kept, no leak"
rm -rf "$ERRLOG"
W6="$TMP/s6"; mkdir -p "$W6"
echo "existing" > "$W6/old.js"
GIT_REPO="https://127.0.0.1:1/potenfyr-invalid/does-not-exist.git" GIT_BRANCH=main GIT_AUTH_TOKEN="SECRETTOKEN123" run_sync_in "$W6"
grep -q "SECRETTOKEN123" "$TMP/out.log" && bad_t "TOKEN LEAKED to console" || ok_t "token not printed to console"
grep -qE "\[warn\] .*(Git fetch failed|Git clone)" "$TMP/out.log" && ok_t "failure reported to console" || bad_t "failure hidden from user"
[ -s "$ERRLOG" ] && ok_t "error journal entry written" || bad_t "no error journal entry"
[ -f "$W6/old.js" ] && ok_t "installed code kept after failed sync" || bad_t "user code lost"
# same failure must surface on a fresh clone too
W6b="$TMP/s6b"; mkdir -p "$W6b"
GIT_REPO="https://127.0.0.1:1/potenfyr-invalid/does-not-exist.git" GIT_BRANCH=main GIT_AUTH_TOKEN="SECRETTOKEN123" run_sync_in "$W6b"
grep -qE "\[warn\] .*Could not clone repository" "$TMP/out.log" && ok_t "fresh-clone failure reported" || bad_t "fresh-clone failure hidden"

# ---------------------------------------------------------------- S7
echo "S7: archive rotation keeps newest 5"
mkdir -p "$W/.logs/code-archives"
for i in 1 2 3 4 5 6 7; do touch "$W/.logs/code-archives/codebase-2026010$i-000000.tar.gz"; done
touch -d "2026-01-01" "$W"/.logs/code-archives/*.tar.gz
GIT_REPO="$TMP/alpha.git" GIT_BRANCH=main GIT_AUTH_TOKEN="" run_sync_in "$W"
n=$(find "$W/.logs/code-archives" -name '*.tar.gz' | wc -l)
[ "$n" -le 6 ] && ok_t "archives capped ($n present incl. new one)" || bad_t "archives not pruned ($n)"

# ---------------------------------------------------------------- S8
echo "S8: untrimmed panel startup inputs"
W8="$TMP/s8"; mkdir -p "$W8"
GIT_REPO="$TMP/alpha.git " GIT_BRANCH=$'main\r\n' GIT_AUTH_TOKEN="" run_sync_in "$W8"
[ -f "$W8/index.js" ] && ok_t "trailing whitespace in GIT_REPO/GIT_BRANCH tolerated" || bad_t "untrimmed inputs broke clone"

# ---------------------------------------------------------------- S9
echo "S9: stale .git/index.lock from a killed run is cleared"
W9="$TMP/s9"; mkdir -p "$W9"
GIT_REPO="$TMP/alpha.git" GIT_BRANCH=main GIT_AUTH_TOKEN="" run_sync_in "$W9"
touch "$W9/.git/index.lock"          # simulate a previous run killed mid-reset
commit alpha index.js 'console.log(9)' 'alpha c9'
GIT_REPO="$TMP/alpha.git" GIT_BRANCH=main GIT_AUTH_TOKEN="" run_sync_in "$W9"
grep -q "console.log(9)" "$W9/index.js" && ok_t "sync works despite stale index.lock" || bad_t "stale lock blocked sync"
grep -q "Removed stale git lock" "$TMP/out.log" && ok_t "stale lock removal reported" || bad_t "lock removal silent"

# ---------------------------------------------------------------- S10
echo "S10: pinned entry point removed upstream -> pins dropped, re-detection"
W10="$TMP/s10"; mkdir -p "$W10"
commit alpha old-entry.js 'old' 'alpha add old-entry'
GIT_REPO="$TMP/alpha.git" GIT_BRANCH=main GIT_AUTH_TOKEN="" run_sync_in "$W10"
printf 'MAIN_FILE=old-entry.js\nLANGUAGE=nodejs\nRUNNER=node\n' > "$W10/.multi-prog.conf"
git $GITCFG -C "$TMP/alpha-wt" rm -q old-entry.js >/dev/null 2>&1
commit alpha new-entry.js 'new' 'alpha replace entry'
# a real boot re-syncs after the upstream change, THEN re-evaluates the pins
GIT_REPO="$TMP/alpha.git" GIT_BRANCH=main GIT_AUTH_TOKEN="" run_sync_in "$W10"
( cd "$W10" && WORK_DIR="$W10" CONF_FILE="$W10/.multi-prog.conf" GIT_REPO="$TMP/alpha.git" GIT_BRANCH=main GIT_AUTH_TOKEN="" _git_unpin_stale ) > "$TMP/out.log" 2>&1
grep -q '^MAIN_FILE=' "$W10/.multi-prog.conf" && bad_t "stale MAIN_FILE pin kept" || ok_t "stale MAIN_FILE pin dropped"
grep -q '^LANGUAGE=' "$W10/.multi-prog.conf" && bad_t "LANGUAGE pin kept" || ok_t "LANGUAGE pin dropped with it"
grep -q "re-running auto-detection" "$TMP/out.log" && ok_t "re-detection reported" || bad_t "re-detection silent"

# ---------------------------------------------------------------- S11
echo "S11: sync messaging on clone path and loud failure for empty workspaces"
W11="$TMP/s11"; mkdir -p "$W11"
GIT_REPO="$TMP/alpha.git" GIT_BRANCH=main GIT_AUTH_TOKEN="" run_sync_in "$W11"
grep -q "successfully cloned" "$TMP/out.log" && ok_t "clone messaging present" || bad_t "no clone messaging"
# unreachable repo on an empty workspace -> loud clone failure (no starter will mask it)
W11b="$TMP/s11b"; mkdir -p "$W11b"
GIT_REPO="https://127.0.0.1:1/potenfyr-invalid/does-not-exist.git" GIT_BRANCH=main GIT_AUTH_TOKEN="SECRETTOKEN123" run_sync_in "$W11b"
grep -q "Could not clone repository" "$TMP/out.log" && ok_t "failed clone surfaces loud warning" || bad_t "failed clone not surfaced"
grep -q "SECRETTOKEN123" "$TMP/out.log" && bad_t "TOKEN LEAKED to console" || ok_t "token still not printed on clone path"

echo
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
