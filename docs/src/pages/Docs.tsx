import { catalog, eggVar } from "../data/catalog";
import { VarTable } from "../components/VarTable";
import { CodeBlock } from "../components/CodeBlock";
import { Pager, Sidebar, Toc } from "../components/DocsChrome";

const REPO = "https://github.com/PotenFYR-Studios/Prog-Language-Eggs";

const SIDEBAR = [
  {
    head: "Get started",
    items: [
      { href: "/docs", label: "Setup & startup" },
      { href: "/docs/eggs", label: "Egg catalog" },
      { href: "/docs/languages", label: "Supported languages" },
    ],
  },
  {
    head: "Developers",
    items: [
      { href: "/examples", label: "Examples" },
      { href: "/about", label: "About" },
      { href: "/license", label: "License" },
    ],
  },
];

const TOC = [
  { id: "import", label: "Import into your panel" },
  { id: "versions", label: "Version selection" },
  { id: "channels", label: "Version channels", sub: true },
  { id: "pinning", label: "First-boot pinning", sub: true },
  { id: "custom-runtime", label: "Custom runtime URL", sub: true },
  { id: "startup", label: "Startup command customization" },
  { id: "lifecycle", label: "Build & lifecycle hooks", sub: true },
  { id: "git", label: "Deploy from Git" },
  { id: "variables", label: "Variable reference" },
];

export function Docs({ route }: { route: string }) {
  const egg = catalog.egg;
  const firstImage = Object.values(egg.docker_images)[0];

  const groups: { title: string; vars: string[] }[] = [
    {
      title: "Core language selection",
      vars: ["LANGUAGE", "RUNNER", "MAIN_FILE", "PACKAGE_MANAGER", "RUNTIME_VERSION", "LANGUAGE_VERSION", "CUSTOM_COMMAND", "CUSTOM_INSTALL_COMMAND", "BUILD_COMMAND", "EXTRA_ARGS"],
    },
    {
      title: "Runtimes & companions",
      vars: ["EXTRA_RUNTIMES", "SKIP_RUNTIMES", "NODE_GYP_SUPPORT", "SKIP_PYTHON", "AUTO_INSTALL_DEPS", "STARTER_TEMPLATE"],
    },
    {
      title: "Process supervision & lifecycle",
      vars: ["SUPERVISOR", "PROCFILE_RESTART", "PROCFILE_LOGS", "AUTO_RESTART", "RESTART_DELAY", "DEV_MODE", "PRE_RUN_COMMAND", "POST_RUN_COMMAND", "CLEAN_BUILD_CACHE", "MEMORY_AUTO_TUNE"],
    },
    {
      title: "Git & networking",
      vars: ["SERVER_PORT", "AUTO_ENV_INJECT", "GIT_REPO", "GIT_BRANCH", "GIT_AUTH_TOKEN", "EXTRA_URLS"],
    },
    {
      title: "Health checks & console",
      vars: ["HEALTH_CHECK_PATH", "HEALTH_STRICT", "PANEL_STOP_WATCHER", "CLI_THEME", "CLI_BANNER_GRADIENT", "DEBUG", "EGG_UPDATE_URL", "AUTO_UPDATE_EGG", "CUSTOM_RUNTIME_URL"],
    },
  ];

  return (
    <div className="mx-auto grid max-w-[1720px] grid-cols-1 gap-10 px-4 pb-20 pt-9 sm:px-7 lg:grid-cols-[240px_minmax(0,1fr)] xl:grid-cols-[240px_minmax(0,1fr)_260px]">
      {/* Sidebar */}
      <Sidebar groups={SIDEBAR} route={route} />

      {/* Article */}
      <article className="doc-content max-w-6xl">
        <div className="eyebrow">
          Prog-Language Eggs docs · PTDL_{egg.ptdl_version.replace("PTDL_", "")} · exported {egg.exported_at.slice(0, 10)}
        </div>
        <h1 className="doc-h1 grad-text mt-3">Panel setup &amp; startup</h1>
        <p className="mt-4 text-[15px] leading-[1.75] text-ink-2">
          Everything on this page is generated from the real egg JSON -
          {egg.variable_count} variables, the multi-language docker image and the
          launcher startup command. No invented defaults.
        </p>

        <h2 id="import">Import into your panel</h2>
        <p>
          The egg is a single PTDL_v2 JSON file that imports into every
          Wings-family panel (Pterodactyl, Pelican, Jexactyl, Wisp, Emerald)
          plus Feather Panel and PufferPanel template flows.
        </p>
        <ol className="my-4 list-decimal space-y-2 pl-6 text-[0.95em] text-ink-2">
          <li>
            Download{" "}
            <a href={`${REPO}/blob/master/egg-programming-multi.json`}>
              <code className="inline-code">egg-programming-multi.json</code>
            </a>{" "}
            from the <code className="inline-code">master</code> branch.
          </li>
          <li>
            In your panel admin area open <strong>Nests / Templates</strong> →{" "}
            <strong>Import Egg</strong> and select the file.
          </li>
          <li>
            Create a server on the egg. The docker image{" "}
            <code className="inline-code">{firstImage}</code> is selected
            automatically.
          </li>
          <li>
            Start the server. The startup command{" "}
            <code className="inline-code">{egg.startup}</code> launches the
            launcher, which auto-detects your code or pulls it from Git.
          </li>
        </ol>
        <div className="doc-card my-5">
          <h3 className="!mt-0">Self-updating egg</h3>
          <p className="text-[0.85em] leading-relaxed text-muted">
            The egg ships with <code className="inline-code">EGG_UPDATE_URL</code>{" "}
            pointing at this repository's raw JSON (<span className="font-mono text-[0.9em]">{egg.update_url}</span>).
            With <code className="inline-code">AUTO_UPDATE_EGG=1</code> (default) the
            launcher checks it on every boot and refreshes its scripts when the
            upstream egg changes, you import once and stay current.
          </p>
        </div>

        <h2 id="versions">Version selection</h2>
        <p>
          <code className="inline-code">RUNTIME_VERSION</code> controls the primary
          runtime version. Values are validated and resolved from live upstream
          feeds at boot, exact versions (<code className="inline-code">22</code>,{" "}
          <code className="inline-code">22.1</code>, <code className="inline-code">22.1.4</code>) or the
          keyword channels below.
        </p>
        <VarTable
          rows={[
            eggVar("RUNTIME_VERSION"),
            eggVar("LANGUAGE_VERSION"),
          ]}
        />

        <h3 id="channels">Version channels</h3>
        <div className="var-table-wrap my-4">
          <table className="var-table">
            <thead>
              <tr>
                <th>Channel</th>
                <th>Resolves to</th>
              </tr>
            </thead>
            <tbody>
              {[
                ["latest", "Newest stable GA release, resolves once, then pins"],
                ["stable", "Production stable branch"],
                ["lts", "Long-Term Support release line"],
                ["beta / rc / alpha / preview", "Pre-release channels where the vendor publishes them"],
                ["nightly", "Canary/nightly builds (Node, Rust, Zig master, Bun canary)"],
                ["22 · 22.1 · 22.1.4", "Highest release matching the exact version prefix"],
              ].map(([k, v]) => (
                <tr key={k}>
                  <td className="whitespace-nowrap font-mono text-[0.82em] text-[#d8ccfe]">{k}</td>
                  <td>{v}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
        <CodeBlock
          lang="startup variables"
          code={`RUNTIME_VERSION=lts        # or 22, 3.12, nightly, stable
LANGUAGE_VERSION=          # optional DB_VERSION-style alias fallback
EXTRA_RUNTIMES=python@3.12,bun@latest,java@21   # companion toolchains`}
        />

        <h3 id="pinning">First-boot pinning</h3>
        <p>
          To protect production containers from upstream major bumps,{" "}
          <code className="inline-code">auto</code> and{" "}
          <code className="inline-code">latest</code> resolve <em>once</em>: the
          concrete version (e.g. <code className="inline-code">v22.14.0</code>) is pinned
          into <code className="inline-code">.multi-prog.conf</code> and reused on every
          cold start. Set the variable to{" "}
          <code className="inline-code">auto-detect</code> in the Startup tab to
          clear the pin and re-resolve.
        </p>

        <h3 id="custom-runtime">Custom runtime URL</h3>
        <p>
          Need a fork or an internal build?{" "}
          <code className="inline-code">CUSTOM_RUNTIME_URL</code> downloads a{" "}
          <code className="inline-code">.tar.gz</code>, <code className="inline-code">.zip</code> or
          standalone binary into the container on boot and uses it as the
          runtime.
        </p>

        <h2 id="startup">Startup command customization</h2>
        <p>
          The panel startup command stays fixed at{" "}
          <code className="inline-code">{egg.startup}</code>, the launcher is the
          stable interface. You customize what runs through variables, which
          the panel exposes in the Startup tab:
        </p>
        <VarTable rows={[eggVar("CUSTOM_COMMAND"), eggVar("RUNNER"), eggVar("MAIN_FILE"), eggVar("PACKAGE_MANAGER")]} />
        <p>
          Override the runner entirely with{" "}
          <code className="inline-code">CUSTOM_COMMAND</code>, or nudge the
          detection: <code className="inline-code">RUNNER=uvicorn</code> forces the
          FastAPI path, <code className="inline-code">MAIN_FILE</code> picks the
          entry point, <code className="inline-code">PACKAGE_MANAGER</code> pins{" "}
          <code className="inline-code">pnpm</code>/<code className="inline-code">uv</code>/
          <code className="inline-code">poetry</code>/… The launcher announces the
          resolved command line in the console before exec.
        </p>

        <h3 id="lifecycle">Build &amp; lifecycle hooks</h3>
        <VarTable
          rows={[
            eggVar("BUILD_COMMAND"),
            eggVar("PRE_RUN_COMMAND"),
            eggVar("POST_RUN_COMMAND"),
            eggVar("EXTRA_ARGS"),
            eggVar("DEV_MODE"),
          ]}
        />

        <h2 id="git">Deploy from Git</h2>
        <p>
          Set <code className="inline-code">GIT_REPO</code> and the installer clones
          your repository on the install pass, then re-syncs it on every boot -
          fetching <em>over</em> a non-empty workspace instead of wiping, and
          printing the installed commit so latest-vs-old is verifiable in the
          console.
        </p>
        <VarTable rows={[eggVar("GIT_REPO"), eggVar("GIT_BRANCH"), eggVar("GIT_AUTH_TOKEN"), eggVar("GIT_PRESERVE_ENV")]} />
        <div className="doc-card my-5">
          <h3 className="!mt-0">Token safety</h3>
          <p className="text-[0.85em] leading-relaxed text-muted">
            <code className="inline-code">GIT_AUTH_TOKEN</code> is injected into the
            fetch URL server-side and redacted from console output and logs.
            Reinstall semantics: only committed, pushed files survive, a
            reinstall re-clones the branch.
          </p>
        </div>
        <div className="doc-card my-5">
          <h3 className="!mt-0">.env preservation</h3>
          <p className="text-[0.85em] leading-relaxed text-muted">
            With <code className="inline-code">GIT_PRESERVE_ENV=1</code> (default),
            every <code className="inline-code">.env</code> in the workspace is
            snapshotted before <code className="inline-code">git reset --hard</code>{" "}
            applies new commits and copied back to its original location
            afterwards - a repo-shipped <code className="inline-code">.env</code>{" "}
            can never clobber or wipe your live credentials. Set it to{" "}
            <code className="inline-code">0</code> to let the repository win.
          </p>
        </div>

        <h2 id="browser">Browser Automation</h2>
        <p>
          Chromium and chromedriver ship <strong>inside the image</strong>, so
          Playwright, Puppeteer, nodriver and Selenium work out of the box - no
          browser downloads inside the server container. The launcher exports{" "}
          <code className="inline-code">CHROME_PATH</code>,{" "}
          <code className="inline-code">CHROMEDRIVER_PATH</code>,{" "}
          <code className="inline-code">PUPPETEER_EXECUTABLE_PATH</code> and a
          writable <code className="inline-code">PLAYWRIGHT_BROWSERS_PATH</code>{" "}
          on the server volume, and applies container-safe flags via{" "}
          <code className="inline-code">CHROMIUM_FLAGS</code>.
        </p>
        <VarTable
          rows={[
            eggVar("BROWSER_SUPPORT"),
            eggVar("BROWSER_EXTRA_ARGS"),
            eggVar("BROWSER_HEADFUL"),
            eggVar("BROWSER_PROFILE_DIR"),
          ]}
        />
        <div className="doc-card my-5">
          <h3 className="!mt-0">Quick usage</h3>
          <p className="text-[0.85em] leading-relaxed text-muted">
            <strong>Playwright (Python):</strong>{" "}
            <code className="inline-code">p.chromium.launch(headless=True)</code>{" "}
            - works immediately. If a pinned Playwright wants its own browser
            build, run <code className="inline-code">playwright install chromium</code>{" "}
            once in the console; it lands in the writable browsers path on your
            volume. <strong>Puppeteer (Node):</strong> just{" "}
            <code className="inline-code">puppeteer.launch()</code> - it reads{" "}
            <code className="inline-code">PUPPETEER_EXECUTABLE_PATH</code>.{" "}
            <strong>nodriver:</strong> auto-detects{" "}
            <code className="inline-code">/usr/bin/chromium</code>.{" "}
            <strong>Selenium:</strong>{" "}
            <code className="inline-code">webdriver.Chrome()</code> uses the
            baked matching chromedriver. For headed automation set{" "}
            <code className="inline-code">BROWSER_HEADFUL=1</code> - the launcher
            starts an Xvfb display on{" "}
            <code className="inline-code">:99</code>.
          </p>
        </div>

        <h2 id="variables">Variable reference</h2>
        <p>
          All {egg.variable_count} startup variables from{" "}
          <code className="inline-code">egg-programming-multi.json</code>, grouped
          by role. “Editable = panel” rows are managed by the panel (port
          allocation) and not user-editable.
        </p>
        {groups.map((g) => (
          <div key={g.title}>
            <h3>{g.title}</h3>
            <VarTable rows={g.vars.map(eggVar)} />
          </div>
        ))}

        <Pager
          prev={{ href: "/", label: "Landing" }}
          next={{ href: "/docs/eggs", label: "Egg Catalog" }}
        />
      </article>

      <Toc items={TOC} />
    </div>
  );
}
