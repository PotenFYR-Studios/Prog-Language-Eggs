import { FileJson, Container, Rocket, ShieldAlert, ArrowRight } from "lucide-react";
import { catalog } from "../data/catalog";
import { VarTable } from "../components/VarTable";
import { CodeBlock } from "../components/CodeBlock";
import { Breadcrumb, Pager, Toc } from "../components/DocsChrome";
import { withBase } from "../routes";

const REPO = "https://github.com/PotenFYR-Studios/Prog-Language-Eggs";
const NEST = "https://nest.potenfyr.in";

const KEY_VARS = [
  "LANGUAGE",
  "RUNTIME_VERSION",
  "EXTRA_RUNTIMES",
  "GIT_REPO",
  "BUILD_COMMAND",
  "CUSTOM_COMMAND",
  "SUPERVISOR",
  "HEALTH_CHECK_PATH",
  "MEMORY_AUTO_TUNE",
  "AUTO_UPDATE_EGG",
];

export function Eggs() {
  const toc = [
    { id: "languages", label: "Languages covered" },
    { id: "install-pass", label: "Install pass" },
    { id: "key-variables", label: "Key variables" },
    { id: "file-denylist", label: "File denylist" },
  ];
  const egg = catalog.egg;
  const firstImage = Object.values(egg.docker_images)[0];
  const imageLabel = Object.keys(egg.docker_images)[0];

  return (
    <div className="mx-auto grid max-w-[1720px] grid-cols-1 gap-10 px-4 pb-20 pt-9 sm:px-7 xl:grid-cols-[minmax(0,1fr)_260px]">
      <article className="doc-content max-w-6xl">
      <Breadcrumb trail={[{ href: "/docs", label: "Docs" }, { href: "/docs/eggs", label: "Egg Catalog" }]} />
      <div className="eyebrow mt-4">Unified catalog · prog-language-eggs</div>
      <h1 className="doc-h1 grad-text mt-3">Egg catalog</h1>
      <p className="mt-4 text-[15px] leading-[1.75] text-ink-2">
        This collection ships <strong>one egg</strong> covering{" "}
        {catalog.language_count} languages. Every field below is read from the
        actual <code className="inline-code">egg-programming-multi.json</code> at
        build time. The org-wide browsable catalog lives at{" "}
        <a href={NEST} target="_blank" rel="noopener">
          nest.potenfyr.in
        </a>
        .
      </p>

      {/* Egg header card */}
      <div className="doc-card mt-8 !p-7">
        <div className="flex flex-wrap items-center gap-3">
          <span className="icon-tile">
            <FileJson className="h-5 w-5 text-brand-violet" />
          </span>
          <div>
            <h2 className="!m-0 !border-none !p-0 text-[1.15em] font-bold text-white">
              {egg.name}
            </h2>
            <div className="mono-label mt-0.5">
              {egg.ptdl_version} · exported {egg.exported_at.slice(0, 10)} · author {egg.author}
            </div>
          </div>
          <span className="status-pill ml-auto">
            <span className="pulse-dot" /> Active
          </span>
        </div>
        <p className="mt-4 text-[0.9em] leading-relaxed text-ink-2">
          {egg.description}
        </p>
        <div className="mt-4 flex flex-wrap gap-2">
          {egg.features.map((f) => (
            <span key={f} className="tag">{f}</span>
          ))}
          <span className="tag">{egg.variable_count} variables</span>
          <span className="tag">{catalog.language_count} languages</span>
        </div>

        <div className="mt-6 grid gap-4 md:grid-cols-2">
          <div>
            <div className="mono-label mb-1.5 flex items-center gap-2">
              <Container className="h-3.5 w-3.5" /> Docker image
            </div>
            <CodeBlock lang="image" code={firstImage} />
            <div className="mono-label mt-1.5 text-faint">“{imageLabel}”</div>
          </div>
          <div>
            <div className="mono-label mb-1.5 flex items-center gap-2">
              <Rocket className="h-3.5 w-3.5" /> Startup / stop
            </div>
            <CodeBlock lang="startup" code={`${egg.startup}\n# stop: ${egg.stop}`} />
          </div>
        </div>

        <div className="mt-5 flex flex-wrap gap-3">
          <a href={`${REPO}/blob/master/egg-programming-multi.json`} className="btn btn-primary btn-sm">
            Raw egg JSON <ArrowRight className="h-3.5 w-3.5" />
          </a>
          <a href={withBase("/docs")} className="btn btn-ghost btn-sm">
            Setup guide
          </a>
        </div>
      </div>

      {/* Languages covered */}
      <h2 id="languages" className="mt-14 text-[1.32em] font-bold text-white">
        Languages covered
      </h2>
      <p className="text-[0.95em] text-ink-2">
        The single image covers {catalog.language_count} languages, the{" "}
        <a href={withBase("/docs/languages")}>full matrix</a> lists runners, package
        managers and auto-detect triggers for each.
      </p>
      <div className="mt-4 flex flex-wrap gap-2">
        {catalog.languages.map((l) => (
          <span key={l.n} className="chip">{l.name}</span>
        ))}
      </div>

      {/* Install container */}
      <h2 id="install-pass" className="mt-14 text-[1.32em] font-bold text-white">Install pass</h2>
      <p className="text-[0.95em] text-ink-2">
        On server creation the egg runs its install script inside{" "}
        <code className="inline-code">{egg.install_container}</code> (entrypoint{" "}
        <code className="inline-code">{egg.install_entrypoint}</code>): base
        tooling, then a git sync that trims stray whitespace from startup
        variables, re-points origin at the current repo/branch, and fetches
        over a non-empty workspace without wiping it.
      </p>

      {/* Key variables */}
      <h2 id="key-variables" className="mt-14 text-[1.32em] font-bold text-white">Key variables</h2>
      <p className="text-[0.95em] text-ink-2">
        The ten variables most servers touch, the complete set of{" "}
        {egg.variable_count} lives in the{" "}
        <a href={withBase("/docs")}>setup &amp; startup reference</a>.
      </p>
      <VarTable rows={KEY_VARS.map((v) => egg.variables.find((x) => x.env_variable === v)!)} />

      {/* File denylist */}
      <h2 id="file-denylist" className="mt-14 flex items-center gap-2 text-[1.32em] font-bold text-white">
        <ShieldAlert className="h-5 w-5 text-brand-orange" /> File denylist
      </h2>
      <p className="text-[0.95em] text-ink-2">
        The panel file manager refuses to serve these paths, protecting the
        launcher and its self-update machinery from tampering:
      </p>
      <div className="var-table-wrap mt-4">
        <table className="var-table">
          <thead>
            <tr><th>Pattern</th></tr>
          </thead>
          <tbody>
            {egg.file_denylist.map((f) => (
              <tr key={f}>
                <td className="font-mono text-[0.82em] text-[#d8ccfe]">{f}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

        <Pager
          prev={{ href: "/docs", label: "Setup and startup" }}
          next={{ href: "/docs/languages", label: "Supported Languages" }}
        />
      </article>
      <Toc items={toc} />
    </div>
  );
}
