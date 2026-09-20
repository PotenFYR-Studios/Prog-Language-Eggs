#!/usr/bin/env bash
# =============================================================================
#  Prog-Language-Eggs - Real-World Runtime Battery
#
#  Executes actual programs in every pre-baked language runtime inside the
#  built image: compile + run for compiled languages, real package installs
#  for ecosystems (pip/venv), and one-liners for interpreters. A runtime only
#  passes when the program's output appears. Run inside the container:
#      bash /usr/local/bin/runtime-battery.sh
#  (the Dockerfile-less CI path mounts the repo copy at that path instead).
# =============================================================================
set -uo pipefail

PASS=0
FAIL=0
FAILED_NAMES=""

check() {
    local name="$1"
    shift
    if "$@" >/tmp/battery-last.log 2>&1; then
        printf '  \033[32m✓ PASS:\033[0m %s\n' "${name}"
        PASS=$((PASS + 1))
    else
        printf '  \033[31m✗ FAIL:\033[0m %s\n' "${name}"
        sed 's/^/      /' /tmp/battery-last.log | tail -n 8
        FAIL=$((FAIL + 1))
        FAILED_NAMES="${FAILED_NAMES} ${name}"
    fi
}

cd "$(mktemp -d)" || exit 1

# --- Compiled languages: real compile + execute ------------------------------
mkdir -p c && cd c
printf '#include <stdio.h>\nint main(void){puts("C_OK");return 0;}\n' > hello.c
check "C (gcc compile + run)" bash -c 'gcc hello.c -o hello && ./hello | grep -q C_OK'
check "C++ (g++ compile + run)" bash -c "printf '#include <iostream>\nint main(){std::cout<<\"CPP_OK\"<<std::endl;return 0;}' > hello.cpp && g++ hello.cpp -o hellocpp && ./hellocpp | grep -q CPP_OK"
printf 'program hello\n  print *, "FORTRAN_OK"\nend program hello\n' > hello.f90
check "Fortran (gfortran compile + run)" bash -c 'gfortran hello.f90 -o hf && ./hf | grep -q FORTRAN_OK'
printf 'program Hello;\nbegin\n  writeln('"'"'PASCAL_OK'"'"');\nend.\n' > hello.pas
check "Pascal (fpc compile + run)" bash -c 'fpc hello.pas >/dev/null 2>&1 && ./hello | grep -q PASCAL_OK'
cd ..

# --- Go: full module build (validates the baked GOROOT after image trimming) --
mkdir -p go && cd go
check "Go (module init + build + run)" bash -c 'go mod init batterymod >/dev/null 2>&1; printf "package main\nimport \"fmt\"\nfunc main(){fmt.Println(\"GO_OK\")}\n" > main.go && go build -o hello . && ./hello | grep -q GO_OK'
cd ..

# --- Rust: real cargo package build ------------------------------------------
check "Rust (cargo new + build + run)" bash -c 'export CARGO_HOME="${CARGO_HOME:-$HOME/.cargo}"; cargo new rtest -q 2>/dev/null; cd rtest && cargo run -q 2>/dev/null | grep -qi hello'

# --- Java: compile + run on the baked JDK ------------------------------------
mkdir -p java && cd java
check "Java (javac + java)" bash -c 'printf "public class H{public static void main(String[] a){System.out.println(\"JAVA_OK\");}}\n" > H.java && javac H.java && java H | grep -q JAVA_OK'
check "Java build tool (maven)" bash -c 'mvn -version >/tmp/mvn-ver.log 2>&1 && grep -q "Apache Maven" /tmp/mvn-ver.log'
cd ..

# --- .NET: real SDK project create + restore + run ---------------------------
check ".NET (new console + restore + run)" bash -c 'dotnet new console -o dnapp --force >/dev/null 2>&1 && dotnet run --project dnapp 2>/dev/null | grep -qi hello'

# --- JavaScript/TypeScript runtimes ------------------------------------------
check "Node.js" bash -c 'node -e "console.log(process.version)" | grep -q ^v'
check "Bun" bash -c 'printf "console.log(\"BUN_OK\")\n" > b.js && bun b.js | grep -q BUN_OK'
check "Deno" bash -c 'deno eval "console.log(\"DENO_OK\")" | grep -q DENO_OK'
check "TypeScript (tsc compile + node run)" bash -c 'printf "const m: string = \"TS_OK\"; console.log(m);\n" > t.ts && tsc t.ts >/dev/null 2>&1 && node t.js | grep -q TS_OK'
check "PHP (composer present)" bash -c 'php -r "echo \"PHP_OK\\n\";" | grep -q PHP_OK && composer --version | grep -q Composer'

# --- Python: interpreter + real venv + real pip install ----------------------
check "Python (venv + pip install)" bash -c 'python3 -c "print(\"PY_OK\")" | grep -q PY_OK && python3 -m venv /tmp/battery-venv && /tmp/battery-venv/bin/pip install -q packaging && /tmp/battery-venv/bin/python -c "import packaging; print(\"PIP_OK\")" | grep -q PIP_OK'

# --- Interpreters -------------------------------------------------------------
check "Ruby" bash -c 'ruby -e "puts \"RUBY_OK\"" | grep -q RUBY_OK'
check "Lua 5.4" bash -c 'lua5.4 -e "print(\"LUA_OK\")" | grep -q LUA_OK'
check "LuaJIT" bash -c 'luajit -e "print(\"LUAJIT_OK\")" | grep -q LUAJIT_OK'
check "Perl" bash -c 'perl -E "say \"PERL_OK\"" | grep -q PERL_OK'
check "Tcl" bash -c 'echo "puts \"TCL_OK\"" | tclsh | grep -q TCL_OK'
check "SWI-Prolog" bash -c 'swipl --quiet -g "writeln(prolog_ok), halt." 2>/dev/null | grep -q prolog_ok'

printf '\nBattery summary: %s passed, %s failed (of %s)\n' "${PASS}" "${FAIL}" "$((PASS + FAIL))"
[ "${FAIL}" -eq 0 ] || { printf 'Failed:%s\n' "${FAILED_NAMES}"; exit 1; }
exit 0
