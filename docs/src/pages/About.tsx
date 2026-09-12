import { Egg, Github, Globe, Database, ScrollText } from "lucide-react";
import { catalog } from "../data/catalog";
import { Pager, Toc } from "../components/DocsChrome";

const REPO = "https://github.com/PotenFYR-Studios/Prog-Language-Eggs";
const ORG = "https://github.com/PotenFYR-Studios";
const WEBSITE = "https://potenfyr.in";
const NEST = "https://nest.potenfyr.in";

export function About() {
  const toc = [
    { id: "studio", label: "PotenFYR Studios" },
    { id: "siblings", label: "Sibling collections" },
    { id: "license", label: "License" },
  ];
  return (
    <div className="mx-auto grid max-w-[1720px] grid-cols-1 gap-10 px-4 pb-20 pt-9 sm:px-7 xl:grid-cols-[minmax(0,1fr)_260px]">
      <article className="doc-content max-w-6xl">
      <div className="eyebrow">PotenFYR Studios</div>
      <h1 className="doc-h1 grad-text mt-3">About the project</h1>
      <p className="mt-4 text-[15px] leading-[1.75] text-ink-2">
        <strong>Prog-Language Eggs</strong> started from a simple panel
        frustration: hosting a polyglot stack meant maintaining one egg, and
        one docker image, per language. This project collapses all of them
        into <strong>one egg, one image</strong> that installs, updates,
        compiles and runs {catalog.language_count} programming languages inside
        your container, with the language chosen at startup, not build time.
      </p>
      <p className="mt-4 text-[15px] leading-[1.75] text-ink-2">
        The runtime ships as a PTDL_v2 egg JSON plus a launcher suite
        (<code className="inline-code">run.sh</code>,{" "}
        <code className="inline-code">entrypoint.sh</code>,{" "}
        <code className="inline-code">install-runtime.sh</code>,{" "}
        <code className="inline-code">resolve-version.sh</code>) inside a
        multi-arch container. It detects the panel family on boot, Wings,
        Feather, Puffer, Kubernetes, PaaS or plain Docker, and adapts ports,
        working directory and stop semantics automatically.
      </p>

      <h2 id="studio" className="mt-12 text-[1.32em] font-bold text-white">PotenFYR Studios</h2>
      <p className="text-[0.95em] leading-relaxed text-ink-2">
        PotenFYR Studios is a creative hub for game development, hosting
        infrastructure, automation tools and community-driven projects -
        Minecraft plugins and Fabric frameworks, Pterodactyl/Pelican eggs, API
        security tooling and the platforms around them, all built in the open.
      </p>
      <div className="mt-5 grid gap-4 sm:grid-cols-2">
        <a href={WEBSITE} target="_blank" rel="noopener" className="doc-card no-underline hover:no-underline">
          <span className="icon-tile"><Globe className="h-5 w-5 text-brand-violet" /></span>
          <h3 className="text-[0.98em] font-[640] text-white">potenfyr.in</h3>
          <p className="text-[0.83em] leading-[1.55] text-muted">
            The studio's home base, projects, news and the Command Deck.
          </p>
        </a>
        <a href={ORG} target="_blank" rel="noopener" className="doc-card no-underline hover:no-underline">
          <span className="icon-tile"><Github className="h-5 w-5 text-brand-pink" /></span>
          <h3 className="text-[0.98em] font-[640] text-white">GitHub organization</h3>
          <p className="text-[0.83em] leading-[1.55] text-muted">
            Every repository, from eggs and plugins to security tooling.
          </p>
        </a>
        <a href={NEST} target="_blank" rel="noopener" className="doc-card no-underline hover:no-underline">
          <span className="icon-tile"><Database className="h-5 w-5 text-brand-cyan" /></span>
          <h3 className="text-[0.98em] font-[640] text-white">nest.potenfyr.in</h3>
          <p className="text-[0.83em] leading-[1.55] text-muted">
            The unified catalog of every egg collection, MC, databases,
            shells and languages.
          </p>
        </a>
        <a href={`${REPO}`} target="_blank" rel="noopener" className="doc-card no-underline hover:no-underline">
          <span className="icon-tile"><Egg className="h-5 w-5 text-brand-orange" /></span>
          <h3 className="text-[0.98em] font-[640] text-white">This repository</h3>
          <p className="text-[0.83em] leading-[1.55] text-muted">
            The egg JSON, the launcher scripts, the CI and these docs.
          </p>
        </a>
      </div>

      <h2 id="siblings" className="mt-12 text-[1.32em] font-bold text-white">Sibling egg collections</h2>
      <p className="text-[0.95em] leading-relaxed text-ink-2">
        Prog-Language-Eggs is the languages arm of the PotenFYR egg ecosystem.
        Siblings cover the rest of the panel world:
      </p>
      <ul className="mt-3 space-y-2 text-[0.95em] text-ink-2">
        <li>
          <a href="https://github.com/PotenFYR-Studios/Minecraft-Eggs" target="_blank" rel="noopener">Minecraft-Eggs</a>{" "}
         : universal Minecraft egg: Vanilla, Paper, Purpur, Fabric, Forge, NeoForge, Velocity, Bedrock &amp; 18+ server types.
        </li>
        <li>
          <a href="https://github.com/PotenFYR-Studios/Database-Eggs" target="_blank" rel="noopener">Database-Eggs</a>{" "}
         : one egg for every database, every version, every panel.
        </li>
        <li>
          <a href="https://github.com/PotenFYR-Studios/Shell-Eggs" target="_blank" rel="noopener">Shell-Eggs</a>{" "}
         : host any shell flavour from one panel egg.
        </li>
      </ul>
      <p className="mt-3 text-[0.9em] text-muted">
        Browse all collections in the unified catalog:{" "}
        <a href={NEST} target="_blank" rel="noopener">nest.potenfyr.in</a>.
      </p>

      <h2 id="license" className="mt-12 flex items-center gap-2 text-[1.32em] font-bold text-white">
        <ScrollText className="h-5 w-5 text-brand-violet" /> License
      </h2>
      <p className="text-[0.95em] leading-relaxed text-ink-2">
        Released under the <strong>Apache License 2.0 with the Commons
        Clause</strong>, free to fork, modify and use, and to build products
        or services around, but not to sell the software itself as a product.
        The <a href={`${REPO}/blob/master/LICENSE`}>LICENSE file in the repository</a>{" "}
        is authoritative.
      </p>

      <div className="doc-card mt-10 text-center">
        <p className="text-[0.9em] text-ink-2">
          Made with ❤️ by <a href={WEBSITE} target="_blank" rel="noopener">PotenFYR Studios</a>.
        </p>
        <p className="mt-1 text-[0.78em] text-faint">
          Docs generated from the real egg JSON · {catalog.language_count} languages · {catalog.egg.variable_count} variables
        </p>
      </div>

      <Pager
        prev={{ href: "/examples", label: "Examples" }}
        next={{ href: "/license", label: "License" }}
      />
      </article>
      <Toc items={toc} />
    </div>
  );
}
