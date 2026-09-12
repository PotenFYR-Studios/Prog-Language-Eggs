import {
  ScanSearch,
  PackageSearch,
  Gauge,
  Blocks,
  ShieldCheck,
  HeartPulse,
  ArrowRight,
  Download,
  ListFilter,
} from "lucide-react";
import { Marquee, NumberTicker, Meteors } from "../components/magicui";
import { CodeBlock } from "../components/CodeBlock";
import { catalog } from "../data/catalog";
import { REPO } from "../App";
import { withBase } from "../routes";

const PLATFORMS = [
  "Pterodactyl",
  "Pelican",
  "Feather Panel",
  "PufferPanel",
  "Jexactyl",
  "Wisp",
  "Emerald",
  "Kubernetes",
  "Fly.io",
  "Railway",
  "Render",
];

const FEATURES = [
  {
    icon: ScanSearch,
    color: "text-brand-violet",
    title: "Zero-config auto-detection",
    desc: "LANGUAGE=auto inspects workspace files, package.json, requirements.txt, Cargo.toml, go.mod, *.csproj, and boots the exact stack. First-boot results pin for predictable cold starts; set auto-detect to re-arm.",
  },
  {
    icon: PackageSearch,
    color: "text-brand-pink",
    title: "On-demand toolchains",
    desc: "Runtimes install when needed from official vendor feeds with SHA256 checksum verification, then cache in .environments/, no pre-baked bloat, no abandoned versions.",
  },
  {
    icon: Gauge,
    color: "text-brand-cyan",
    title: "Memory auto-tune",
    desc: "MEMORY_AUTO_TUNE unifies panel memory limits and sets safe heap ceilings for V8, Go GOMEMLIMIT, the JVM and .NET, plus glibc malloc trimming to stop container OOM crashes.",
  },
  {
    icon: Blocks,
    color: "text-brand-orange",
    title: "Procfile supervisor",
    desc: "Commit a Procfile to run web, worker and API processes in one container with wait_port ordering, linear-backoff crash recovery and per-process log streams.",
  },
  {
    icon: ShieldCheck,
    color: "text-brand-violet",
    title: "Panel stop watcher",
    desc: "PANEL_STOP_WATCHER handles every daemon's idea of stopping, POSIX signal traps for Wings, console-text ^C interception for Feather-style daemons, graceful drains everywhere.",
  },
  {
    icon: HeartPulse,
    color: "text-brand-emerald",
    title: "Health checks & self-update",
    desc: "HEALTH_CHECK_PATH probes your app after boot; the launcher checks EGG_UPDATE_URL on every start and refreshes itself when the upstream egg changes.",
  },
];

function MarqueeRow({ reverse }: { reverse?: boolean }) {
  const names = reverse
    ? [...catalog.languages].reverse()
    : catalog.languages;
  const half = Math.ceil(names.length / 2);
  const items = reverse ? names.slice(0, half) : names.slice(half);
  return (
    <Marquee reverse={reverse} duration={reverse ? 48 : 42}>
      {items.map((l) => (
        <a key={l.n} href={withBase("/docs/languages")} className="lang-chip">
          <span className="mr-2 text-brand-violet">◆</span>
          {l.name}
        </a>
      ))}
    </Marquee>
  );
}

export function Home() {
  const langs = catalog.languages;
  const notable = [
    "Node.js (JavaScript)",
    "TypeScript",
    "Python",
    "Go",
    "Rust",
    "Java",
    "C# / .NET",
    "PHP",
    "Ruby",
    "Swift",
  ];
  const highlights = langs.filter((l) => notable.includes(l.name));
  const firstImage = Object.values(catalog.egg.docker_images)[0];

  return (
    <div>
      {/* ---------------- Hero ---------------- */}
      <section className="relative overflow-hidden px-6 pt-[72px] pb-10">
        <div
          className="glow-orb -top-48 left-[8%] h-[30rem] w-[52rem] opacity-70"
          style={{ background: "rgba(139,92,246,0.18)" }}
        />
        <div
          className="glow-orb -top-40 right-[4%] h-[26rem] w-[34rem] opacity-70"
          style={{ background: "rgba(236,72,153,0.15)" }}
        />
        <div
          className="glow-orb top-24 left-1/2 h-[22rem] w-[28rem] opacity-60"
          style={{ background: "rgba(6,182,212,0.12)" }}
        />
        <Meteors number={14} />
        <div className="relative mx-auto max-w-5xl text-center">
          <div className="hero-enter">
            <span className="hero-badge">
              <span className="pulse-dot" />
              PTDL_v2 · one egg · {firstImage.split("/")[1] && "one docker image"}
            </span>
          </div>
          <h1
            className="hero-h1 grad-text hero-enter mt-6"
            style={{ animationDelay: "0.08s" }}
          >
            One egg. One image.
            <br />
            Every language.
          </h1>
          <p
            className="hero-enter mx-auto mt-6 max-w-[720px] text-[1.04em] leading-[1.75] text-muted"
            style={{ animationDelay: "0.16s" }}
          >
            {catalog.egg.description} Built natively for Pterodactyl, Pelican,
            Feather Panel, PufferPanel, Jexactyl, Wisp, Emerald, Kubernetes,
            Fly.io, Railway and Render.
          </p>
          <div
            className="hero-enter mt-8 flex flex-wrap items-center justify-center gap-3"
            style={{ animationDelay: "0.24s" }}
          >
            <a href={withBase("/docs")} className="btn btn-primary">
              Read the docs <ArrowRight className="h-4 w-4" />
            </a>
            <a href={withBase("/docs/languages")} className="btn btn-ghost">
              <ListFilter className="h-4 w-4" /> Browse {catalog.language_count} languages
            </a>
            <a href={`${REPO}/blob/master/egg-programming-multi.json`} className="btn btn-ghost">
              <Download className="h-4 w-4" /> Import the egg
            </a>
          </div>

          {/* Stats, real counts from the egg data */}
          <div
            className="hero-enter mx-auto mt-12 grid max-w-3xl grid-cols-2 gap-3.5 sm:grid-cols-4"
            style={{ animationDelay: "0.32s" }}
          >
            <div className="stat-tile">
              <NumberTicker value={catalog.language_count} className="grad-text font-mono text-3xl font-extrabold" />
              <div className="mt-1 text-[11.5px] uppercase tracking-[1.4px] text-muted">Languages</div>
            </div>
            <div className="stat-tile">
              <NumberTicker value={catalog.egg.variable_count} className="grad-text font-mono text-3xl font-extrabold" />
              <div className="mt-1 text-[11.5px] uppercase tracking-[1.4px] text-muted">Startup variables</div>
            </div>
            <div className="stat-tile">
              <NumberTicker value={PLATFORMS.length} className="grad-text font-mono text-3xl font-extrabold" />
              <div className="mt-1 text-[11.5px] uppercase tracking-[1.4px] text-muted">Panels &amp; platforms</div>
            </div>
            <div className="stat-tile">
              <NumberTicker value={3} className="grad-text font-mono text-3xl font-extrabold" />
              <div className="mt-1 text-[11.5px] uppercase tracking-[1.4px] text-muted">Arch tiers</div>
            </div>
          </div>
        </div>

        {/* Marquee of real language names, landing only (SPEC §7) */}
        <div className="relative mt-16 space-y-3">
          <MarqueeRow />
          <MarqueeRow reverse />
        </div>
      </section>

      {/* ---------------- Features ---------------- */}
      <section className="mx-auto max-w-[1080px] px-6 py-16">
        <div className="mb-10 text-center">
          <div className="eyebrow">The runtime</div>
          <h2 className="mt-2 text-[1.7em] font-bold tracking-tight text-white">
            Everything a polyglot container needs, in one boot
          </h2>
        </div>
        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {FEATURES.map((f) => (
            <article key={f.title} className="doc-card">
              <div className="flex items-start justify-between">
                <span className="icon-tile">
                  <f.icon className={`h-5 w-5 ${f.color}`} />
                </span>
                <span className="text-[#f9a8d4] opacity-0 transition-opacity duration-200 [.doc-card:hover_&]:opacity-100">
                  →
                </span>
              </div>
              <h3 className="mt-2 text-[0.98em] font-[640] text-white">{f.title}</h3>
              <p className="text-[0.83em] leading-[1.55] text-muted">{f.desc}</p>
            </article>
          ))}
        </div>
      </section>

      {/* ---------------- Quick start ---------------- */}
      <section className="mx-auto max-w-[1080px] px-6 py-10">
        <div className="grid items-center gap-10 lg:grid-cols-2">
          <div>
            <div className="eyebrow">Quick start</div>
            <h2 className="mt-2 text-[1.7em] font-bold tracking-tight text-white">
              Import once. Ship any stack.
            </h2>
            <p className="mt-4 text-[0.95em] leading-relaxed text-ink-2">
              Import <code className="inline-code">egg-programming-multi.json</code> into your
              panel's nest, create a server on{" "}
              <code className="inline-code">{firstImage}</code>, and start it.
              Detection, dependency install and health wiring happen on boot -
              driven by {catalog.egg.variable_count} documented startup variables.
            </p>
            <ol className="mt-5 space-y-2.5 text-[0.9em] text-ink-2">
              <li className="flex gap-3">
                <span className="tag">1</span> Download the egg JSON from the repository.
              </li>
              <li className="flex gap-3">
                <span className="tag">2</span> Panel → Nests → Import Egg → select the JSON.
              </li>
              <li className="flex gap-3">
                <span className="tag">3</span> Create a server on the multi-language image.
              </li>
              <li className="flex gap-3">
                <span className="tag">4</span> Upload code or set <code className="inline-code">GIT_REPO</code>, start.
              </li>
            </ol>
            <a href={withBase("/docs")} className="btn btn-ghost btn-sm mt-6">
              Full setup guide <ArrowRight className="h-3.5 w-3.5" />
            </a>
          </div>
          <div>
            <CodeBlock
              lang="docker"
              code={`docker run -d \\
  --name my-app \\
  -p 8080:8080 \\
  -e SERVER_PORT=8080 \\
  -e LANGUAGE=nodejs \\
  -e RUNTIME_VERSION=lts \\
  -v "$PWD/my-project:/home/container" \\
  ${firstImage}`}
            />
            <p className="mt-3 text-[0.8em] leading-relaxed text-faint">
              The same image runs Python, Go, Rust, Java and 50 more, the
              language is a startup variable, not a build.
            </p>
          </div>
        </div>
      </section>

      {/* ---------------- Notable languages ---------------- */}
      <section className="mx-auto max-w-[1080px] px-6 py-16">
        <div className="mb-8 flex flex-col items-start justify-between gap-4 sm:flex-row sm:items-end">
          <div>
            <div className="eyebrow">Language coverage</div>
            <h2 className="mt-2 text-[1.7em] font-bold tracking-tight text-white">
              {catalog.language_count} languages, from Node.js to GnuCOBOL
            </h2>
            <p className="mt-3 max-w-[620px] text-[0.92em] leading-relaxed text-muted">
              Mainstream stacks and the long tail, {highlights.map((l) => l.name.split(" (")[0]).join(", ")} -
              plus Fortran, Ada, COBOL, Prolog, Smalltalk, Vala and more. Every
              entry in the matrix is detected by real file triggers and served
              by real runners.
            </p>
          </div>
          <a href={withBase("/docs/languages")} className="btn btn-ghost btn-sm shrink-0">
            Full matrix <ArrowRight className="h-3.5 w-3.5" />
          </a>
        </div>
        <div className="flex flex-wrap gap-2">
          {langs.map((l) => (
            <span key={l.n} className="chip">
              {l.name}
            </span>
          ))}
        </div>
      </section>

      {/* ---------------- Platforms ---------------- */}
      <section className="mx-auto max-w-[1080px] px-6 pb-20 pt-4">
        <div className="doc-card flex flex-col items-start gap-5 p-8 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <div className="eyebrow">Runs anywhere</div>
            <h3 className="mt-1 text-[1.15em] font-bold text-white">
              Every panel family, one egg file
            </h3>
            <p className="mt-2 max-w-[560px] text-[0.85em] leading-relaxed text-muted">
              The launcher detects the host daemon on boot and adapts working
              directory, port variables and stop semantics automatically.
            </p>
          </div>
          <div className="flex flex-wrap gap-2">
            {PLATFORMS.map((p) => (
              <span key={p} className="chip">
                {p}
              </span>
            ))}
          </div>
        </div>
      </section>
    </div>
  );
}
