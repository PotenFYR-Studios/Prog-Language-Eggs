import { Server, Binary, GitBranch } from "lucide-react";
import { catalog, eggVar } from "../data/catalog";
import { VarTable } from "../components/VarTable";
import { CodeBlock } from "../components/CodeBlock";
import { Pager, Tabs, Toc } from "../components/DocsChrome";
import { REPO } from "../App";

const firstImage = Object.values(catalog.egg.docker_images)[0];

/** Real egg JSON excerpt rendered straight from catalog.json. */
function EggJsonExcerpt() {
  const languageVar = eggVar("LANGUAGE");
  const versionVar = eggVar("RUNTIME_VERSION");
  const excerpt = {
    name: catalog.egg.name,
    docker_images: catalog.egg.docker_images,
    startup: catalog.egg.startup,
    variables: [
      {
        name: languageVar.name,
        env_variable: languageVar.env_variable,
        default_value: languageVar.default_value,
        rules: languageVar.rules,
      },
      {
        name: versionVar.name,
        env_variable: versionVar.env_variable,
        default_value: versionVar.default_value,
        rules: versionVar.rules,
      },
    ],
  };
  return (
    <CodeBlock lang="egg-programming-multi.json (excerpt)">
      {JSON.stringify(excerpt, null, 2)}
    </CodeBlock>
  );
}

export function Examples() {
  const toc = [
    { id: "egg-json", label: "What you're importing" },
    { id: "fastapi", label: "Run a FastAPI app" },
    { id: "binary", label: "Compile and run a binary" },
    { id: "git", label: "Deploy from Git" },
    { id: "docker", label: "Docker equivalent" },
  ];
  return (
    <div className="mx-auto grid max-w-[1720px] grid-cols-1 gap-10 px-4 pb-20 pt-9 sm:px-7 xl:grid-cols-[minmax(0,1fr)_260px]">
      <article className="doc-content max-w-6xl">
      <div className="eyebrow">Real variables · real walkthroughs</div>
      <h1 className="doc-h1 grad-text mt-3">Examples</h1>
      <p className="mt-4 max-w-[720px] text-[15px] leading-[1.75] text-ink-2">
        Every variable, image and command on this page is taken from the actual
        egg JSON, the same values your panel shows in the Startup tab.
      </p>

      {/* ---------------- The egg file ---------------- */}
      <h2 id="egg-json" className="mt-14 text-[1.32em] font-bold text-white">
        What you're importing
      </h2>
      <p className="text-[0.95em] leading-relaxed text-ink-2">
        The egg is a PTDL_v2 JSON file. An excerpt of the real thing, image,
        startup command and the two variables every walkthrough below touches:
      </p>
      <div className="mt-4">
        <EggJsonExcerpt />
      </div>
      <p className="mt-3 text-[0.8em] text-faint">
        Full file:{" "}
        <a href={`${REPO}/blob/master/egg-programming-multi.json`}>
          egg-programming-multi.json
        </a>{" "}
        · {catalog.egg.variable_count} variables total.
      </p>

      {/* ---------------- FastAPI ---------------- */}
      <h2 id="fastapi" className="mt-16 flex items-center gap-2 text-[1.32em] font-bold text-white">
        <Server className="h-5 w-5 text-brand-cyan" /> Run a FastAPI app
      </h2>
      <p className="text-[0.95em] leading-relaxed text-ink-2">
        A minimal FastAPI service. The egg detects{" "}
        <code className="inline-code">requirements.txt</code>, installs{" "}
        <code className="inline-code">uv</code>/<code className="inline-code">pip</code>{" "}
        dependencies and launches uvicorn bound to{" "}
        <code className="inline-code">0.0.0.0:$SERVER_PORT</code>.
      </p>

      <div className="mt-5 grid gap-4 md:grid-cols-2">
        <div>
          <div className="mono-label mb-1.5">requirements.txt</div>
          <CodeBlock lang="text" code={"fastapi\nuvicorn"} />
        </div>
        <div>
          <div className="mono-label mb-1.5">main.py</div>
          <CodeBlock
            lang="python"
            code={`from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root():
    return {"status": "ok"}

@app.get("/healthz")
def healthz():
    return {"healthy": True}`}
          />
        </div>
      </div>

      <div className="mono-label mt-6 mb-1.5">Startup tab, panel variables</div>
      <CodeBlock
        lang="startup variables"
        code={`LANGUAGE=python            # or 'auto', requirements.txt triggers Python
RUNTIME_VERSION=3.12       # exact pin; 'latest' resolves once then pins
MAIN_FILE=auto             # detection finds main.py / app entry
AUTO_INSTALL_DEPS=1        # pip install -r requirements.txt on boot
HEALTH_CHECK_PATH=/healthz # probe http://127.0.0.1:$SERVER_PORT/healthz after boot`}
      />
      <p className="mt-3 text-[0.9em] leading-relaxed text-ink-2">
        On boot the launcher resolves Python{" "}
        <span className="font-mono text-[0.88em]">3.12.x</span>, syncs
        dependencies, and, when <code className="inline-code">RUNNER=uvicorn</code>{" "}
        is selected or detected, announces the effective command:
      </p>
      <div className="mt-3">
        <CodeBlock
          lang="console"
          code={"uvicorn main:app --host 0.0.0.0 --port $SERVER_PORT"}
        />
      </div>

      <VarTable
        rows={[
          eggVar("LANGUAGE"),
          eggVar("RUNTIME_VERSION"),
          eggVar("AUTO_INSTALL_DEPS"),
          eggVar("HEALTH_CHECK_PATH"),
        ]}
      />

      {/* ---------------- Compiled binary ---------------- */}
      <h2 id="binary" className="mt-16 flex items-center gap-2 text-[1.32em] font-bold text-white">
        <Binary className="h-5 w-5 text-brand-orange" /> Compile &amp; run a binary
      </h2>
      <p className="text-[0.95em] leading-relaxed text-ink-2">
        Compiled languages use the same pattern:{" "}
        <code className="inline-code">BUILD_COMMAND</code> compiles,{" "}
        <code className="inline-code">MAIN_FILE</code> points at the artifact.
        Detection fires on <code className="inline-code">go.mod</code>.
      </p>
      <div className="mono-label mt-5 mb-1.5">Startup tab, panel variables</div>
      <Tabs
        lang="startup variables"
        tabs={[
          {
            id: "go",
            label: "Go",
            code: `LANGUAGE=golang
RUNTIME_VERSION=stable     # Go SDK resolved from live upstream feeds
BUILD_COMMAND=go build -o server .
MAIN_FILE=./server         # execute the built artifact
CLEAN_BUILD_CACHE=1        # purge compiler caches after build to save disk`,
          },
          {
            id: "rust",
            label: "Rust",
            code: `LANGUAGE=rust
BUILD_COMMAND=cargo build --release
MAIN_FILE=./target/release/app`,
          },
        ]}
      />
      <VarTable rows={[eggVar("BUILD_COMMAND"), eggVar("MAIN_FILE"), eggVar("CLEAN_BUILD_CACHE")]} />

      {/* ---------------- Git deploy ---------------- */}
      <h2 id="git" className="mt-16 flex items-center gap-2 text-[1.32em] font-bold text-white">
        <GitBranch className="h-5 w-5 text-brand-violet" /> Deploy straight from Git
      </h2>
      <p className="text-[0.95em] leading-relaxed text-ink-2">
        Skip uploads entirely: point the egg at a repository and it clones on
        install, then re-syncs on every boot. Private repos use a token that is
        redacted from console output.
      </p>
      <div className="mono-label mt-5 mb-1.5">Startup tab, panel variables</div>
      <CodeBlock
        lang="startup variables"
        code={`GIT_REPO=https://github.com/you/your-app
GIT_BRANCH=main
GIT_AUTH_TOKEN=ghp_xxx      # optional, private repos only
LANGUAGE=auto               # detect the stack from the cloned files`}
      />
      <p className="mt-3 text-[0.9em] leading-relaxed text-ink-2">
        The console prints the installed commit after sync (
        <span className="font-mono text-[0.85em]">[PotenFYR][i] Repository at commit …</span>)
        so you can verify latest-vs-old at a glance. Only committed files
        survive a reinstall.
      </p>
      <VarTable rows={[eggVar("GIT_REPO"), eggVar("GIT_BRANCH"), eggVar("GIT_AUTH_TOKEN"), eggVar("AUTO_RESTART")]} />

      {/* ---------------- Docker equivalent ---------------- */}
      <h2 id="docker" className="mt-16 text-[1.32em] font-bold text-white">
        Same thing outside a panel
      </h2>
      <p className="text-[0.95em] leading-relaxed text-ink-2">
        No panel? The image runs anywhere docker runs, the FastAPI example
        again, standalone:
      </p>
      <div className="mt-4">
        <CodeBlock
          lang="bash"
          code={`docker run -d \\
  --name fastapi-app \\
  -p 8080:8080 \\
  -e SERVER_PORT=8080 \\
  -e LANGUAGE=python \\
  -e RUNTIME_VERSION=3.12 \\
  -e AUTO_INSTALL_DEPS=1 \\
  -v "$PWD:/home/container" \\
  ${firstImage}`}
        />
      </div>

      <Pager
        prev={{ href: "/docs/languages", label: "Supported Languages" }}
        next={{ href: "/about", label: "About" }}
      />
      </article>
      <Toc items={toc} />
    </div>
  );
}
