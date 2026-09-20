import { useEffect, useMemo, useRef, useState } from "react";
import {
  Search,
  Menu,
  X,
  Terminal,
  Layers,
  Code2,
  FlaskConical,
  Info,
  Github,
} from "lucide-react";
import { Home } from "./pages/Home";
import { Docs } from "./pages/Docs";
import { Eggs } from "./pages/Eggs";
import { Languages } from "./pages/Languages";
import { Examples } from "./pages/Examples";
import { About } from "./pages/About";
import { License } from "./pages/License";
import { catalog } from "./data/catalog";
import { withBase } from "./routes";

const REPO = "https://github.com/PotenFYR-Studios/Prog-Language-Eggs";
const ORG = "https://github.com/PotenFYR-Studios";
const WEBSITE = "https://potenfyr.in";
const NEST = "https://nest.potenfyr.in";

const NAV = [
  { href: "/docs", label: "Docs", icon: Terminal },
  { href: "/docs/eggs", label: "Egg Catalog", icon: Layers },
  { href: "/docs/languages", label: "Languages", icon: Code2 },
  { href: "/examples", label: "Examples", icon: FlaskConical },
  { href: "/about", label: "About", icon: Info },
];

/** Header link active rule: exact or prefix (so /docs matches /docs/eggs). */
function isActive(href: string, route: string): boolean {
  if (href === "/docs") {
    return route === "/docs" || route === "/docs/eggs" || route === "/docs/languages";
  }
  return route === href;
}

function Header({ route }: { route: string }) {
  const [open, setOpen] = useState(false);
  const [paletteOpen, setPaletteOpen] = useState(false);
  // ⌘K / Ctrl+K opens the palette from anywhere.
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key.toLowerCase() === "k") {
        e.preventDefault();
        setPaletteOpen(true);
      }
    };
    document.addEventListener("keydown", onKey);
    return () => document.removeEventListener("keydown", onKey);
  }, []);
  return (
    <>
      <header className="site-header">
        <a href={withBase("/")} className="flex items-center gap-[9px] no-underline hover:no-underline shrink-0">
          <img
            src={withBase("/favicon.png")}
            alt=""
            width={24}
            height={24}
            className="brand-mark h-6 w-6 rounded-full"
          />
          <span className="text-[0.95em] font-[650] text-white">
            Prog-Language<span className="grad-text"> Eggs</span>
          </span>
          <span className="mono-label hidden sm:inline">docs</span>
        </a>
        <nav className="ml-2 hidden items-center gap-1 md:flex" aria-label="Primary">
          {NAV.map(({ href, label }) => (
            <a
              key={href}
              href={withBase(href)}
              className={`nav-link${isActive(href, route) ? " active" : ""}`}
              aria-current={isActive(href, route) ? "page" : undefined}
            >
              {label}
            </a>
          ))}
        </nav>
        <div className="ml-auto flex items-center gap-3">
          <button
            type="button"
            onClick={() => setPaletteOpen(true)}
            className="hidden items-center gap-2 rounded-lg border border-line-light bg-white/[0.03] px-3 py-1.5 text-xs text-muted transition-colors hover:border-brand-violet/50 sm:flex"
            aria-label="Search documentation"
          >
            <Search className="h-3.5 w-3.5" />
            Search
            <kbd className="font-mono text-[10px] text-faint">⌘K</kbd>
          </button>
          <a href={WEBSITE} target="_blank" rel="noopener" className="header-ext hidden lg:inline">
            Website
          </a>
          <a href={NEST} target="_blank" rel="noopener" className="header-ext hidden lg:inline">
            Nest
          </a>
          <a href={REPO} target="_blank" rel="noopener" aria-label="GitHub repository" className="header-ext">
            <Github className="h-4 w-4" />
          </a>
          <button
            type="button"
            className="text-muted md:hidden"
            aria-expanded={open}
            aria-label="Toggle navigation menu"
            onClick={() => setOpen((v) => !v)}
          >
            {open ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
          </button>
        </div>
      </header>
      {open && (
        <div
          className="fixed inset-x-0 top-[56px] z-40 border-b border-line-light bg-[#0b0d14]/98 p-3 md:hidden"
          style={{ backdropFilter: "blur(8px)" }}
        >
          {NAV.map(({ href, label }) => (
            <a
              key={href}
              href={withBase(href)}
              className={`nav-link block${isActive(href, route) ? " active" : ""}`}
            >
              {label}
            </a>
          ))}
        </div>
      )}
      {paletteOpen && <Palette onClose={() => setPaletteOpen(false)} />}
    </>
  );
}

interface PaletteEntry {
  label: string;
  hint: string;
  href: string;
}

function Palette({ onClose }: { onClose: () => void }) {
  const [q, setQ] = useState("");
  const [sel, setSel] = useState(0);
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    inputRef.current?.focus();
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };
    document.addEventListener("keydown", onKey);
    return () => document.removeEventListener("keydown", onKey);
  }, [onClose]);

  const entries: PaletteEntry[] = useMemo(() => {
    const pages: PaletteEntry[] = [
      { label: "Docs: panel import, versions & startup", hint: "→ page", href: "/docs" },
      { label: "Egg Catalog: the real egg JSON", hint: "→ page", href: "/docs/eggs" },
      { label: "Supported Languages: all 54", hint: "→ page", href: "/docs/languages" },
      { label: "Examples: FastAPI, binaries, Git deploy", hint: "→ page", href: "/examples" },
      { label: "About: project & studio", hint: "→ page", href: "/about" },
      { label: "License: Apache-2.0 + Commons Clause", hint: "→ page", href: "/license" },
    ];
    const langs: PaletteEntry[] = catalog.languages.map((l) => ({
      label: l.name,
      hint: "§ language",
      href: "/docs/languages",
    }));
    const vars: PaletteEntry[] = catalog.egg.variables.map((v) => ({
      label: v.env_variable,
      hint: "§ variable",
      href: "/docs",
    }));
    const all = [...pages, ...langs, ...vars];
    if (!q.trim()) return all.slice(0, 14);
    const needle = q.toLowerCase();
    return all
      .filter((e) => e.label.toLowerCase().includes(needle))
      .slice(0, 14);
  }, [q]);

  const onKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === "ArrowDown") {
      e.preventDefault();
      setSel((s) => Math.min(s + 1, entries.length - 1));
    } else if (e.key === "ArrowUp") {
      e.preventDefault();
      setSel((s) => Math.max(s - 1, 0));
    } else if (e.key === "Enter" && entries[sel]) {
      window.location.assign(withBase(entries[sel].href));
    }
  };

  return (
    <div
      className="fixed inset-0 z-50 bg-black/60 pt-28"
      style={{ backdropFilter: "blur(4px)" }}
      onClick={onClose}
    >
      <div
        className="mx-auto w-full max-w-lg rounded-2xl border border-line bg-bg2 shadow-2xl"
        onClick={(e) => e.stopPropagation()}
      >
        <input
          ref={inputRef}
          value={q}
          onChange={(e) => {
            setQ(e.target.value);
            setSel(0);
          }}
          onKeyDown={onKeyDown}
          placeholder="Search pages, languages, variables…"
          className="w-full rounded-t-2xl border-b border-line-light bg-transparent px-4 py-3.5 text-sm text-ink outline-none placeholder:text-faint"
        />
        <ul className="max-h-80 overflow-y-auto p-1.5">
          {entries.length === 0 && (
            <li className="px-3 py-6 text-center text-sm text-faint">No matches</li>
          )}
          {entries.map((e, i) => (
            <li key={`${e.hint}-${e.label}`}>
              <a
                href={withBase(e.href)}
                onClick={onClose}
                className={`flex items-center justify-between rounded-lg px-3 py-2 text-[13px] no-underline hover:no-underline ${
                  i === sel ? "bg-brand-violet/15 text-white" : "text-ink-2 hover:bg-white/5"
                }`}
              >
                <span className="truncate">{e.label}</span>
                <span className="ml-3 shrink-0 font-mono text-[10px] text-faint">{e.hint}</span>
              </a>
            </li>
          ))}
        </ul>
        <div className="border-t border-line-light px-4 py-2 font-mono text-[10px] text-faint">
          ↑↓ navigate · Enter open · Esc close
        </div>
      </div>
    </div>
  );
}

function Footer() {
  return (
    <footer className="site-footer mt-24">
      <div className="mx-auto max-w-[1280px] px-6 py-10">
        <div className="flex flex-col gap-8 md:flex-row md:items-start md:justify-between">
          <div className="max-w-[420px]">
            <div className="flex items-center gap-2">
              <img src={withBase("/favicon.png")} alt="" className="h-8 w-8 rounded-full ring-1 ring-line" />
              <span className="font-mono text-[0.95em] font-bold text-white">
                Prog-Language<span className="grad-text"> Eggs</span>
              </span>
            </div>
            <p className="mt-3 text-[0.8em] leading-relaxed text-muted">
              One egg. One image. Every language. A production-grade hosting
              runtime for 54 programming languages across every major panel.
            </p>
          </div>
          <div className="flex flex-wrap items-center gap-5">
            <a href={ORG} target="_blank" rel="noopener" className="footer-link">
              GitHub Org
            </a>
            <a href={WEBSITE} target="_blank" rel="noopener" className="footer-link">
              potenfyr.in
            </a>
            <a href="https://discord.com/invite/zUaN2FPBec" target="_blank" rel="noopener" className="footer-link">
              Support Discord
            </a>
            <a href={NEST} target="_blank" rel="noopener" className="footer-link">
              Unified Catalog
            </a>
            <a href={withBase("/docs")} className="footer-link accent">
              Docs
            </a>
            <a href={withBase("/license")} className="footer-link">
              License
            </a>
          </div>
        </div>
        <div className="mt-6 flex flex-col gap-2 border-t border-line-light pt-4 text-[0.75em] text-faint md:flex-row md:items-center md:justify-between">
          <span>© 2026 PotenFYR Studios. Released under Apache-2.0 with the Commons Clause.</span>
          <span>Crafted with ♥ for panel hosters.</span>
        </div>
      </div>
    </footer>
  );
}

export function App({ route }: { route: string }) {
  let page: React.ReactNode;
  switch (route) {
    case "/docs":
      page = <Docs route={route} />;
      break;
    case "/docs/eggs":
      page = <Eggs />;
      break;
    case "/docs/languages":
      page = <Languages />;
      break;
    case "/examples":
      page = <Examples />;
      break;
    case "/about":
      page = <About />;
      break;
    case "/license":
      page = <License />;
      break;
    case "/":
      page = <Home />;
      break;
    default:
      page = <Home />;
  }

  return (
    <div className="flex min-h-screen flex-col">
      <Header route={route} />
      <main className="flex-1">{page}</main>
      <Footer />
    </div>
  );
}

export { REPO, ORG, WEBSITE, NEST };
