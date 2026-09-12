/**
 * Single source of truth for the emitted route table. Used by both
 * vite.config.ts (per-page head injection + sitemap) and
 * scripts/prerender.ts (renderToString body injection), so the emitted
 * pages can never drift apart.
 */

export const CANON = "https://prog-language-eggs.docs.potenfyr.in";

const envBase: unknown = import.meta.env?.BASE_URL;

/** Deploy base ("/" on a custom domain, "/Prog-Language-Eggs/" on github.io
 *  project pages): vite inlines BASE_URL in the client bundle; the process-env
 *  fallback covers the bun-run prerender, which imports this module directly. */
export const BASE: string =
  typeof envBase === "string" ? envBase
  : typeof process !== "undefined" ? process.env?.VITE_BASE ?? "/"
  : "/";

/** Prefix an in-site path with the deploy base. Idempotent, and a no-op for
 *  anything not site-rooted, so call sites can wrap unconditionally. */
export function withBase(p: string): string {
  if (BASE !== "/" && (p === BASE || p.startsWith(BASE))) return p;
  if (!p.startsWith("/")) return p;
  return `${BASE}${p.slice(1)}`;
}

export const OG_IMAGE = `${CANON}/og.png`;
export const OG_IMAGE_ALT =
  "Prog-Language Eggs social card: one egg, one image, every language.";

export interface RouteMeta {
  /** Path below the site root; "" is the landing page. */
  path: string;
  title: string;
  desc: string;
}

/** Canonical URL (with trailing slash) for a route. */
export function canonicalFor(p: RouteMeta): string {
  return p.path === "" ? `${CANON}/` : `${CANON}/${p.path}/`;
}

/** React route key ("", "/docs", ...) as consumed by App's switch. */
export function reactRouteFor(p: RouteMeta): string {
  return p.path === "" ? "/" : `/${p.path}`;
}

export const PAGES: RouteMeta[] = [
  {
    path: "",
    title: "Prog-Language Eggs: One egg. One image. Every language.",
    desc: "One multi-language Pterodactyl egg that installs, updates, compiles and runs 54 programming languages in one container, for panels, Kubernetes and Docker.",
  },
  {
    path: "docs",
    title: "Docs: Panel import, versions and startup",
    desc: "Import the multi-language egg into your panel, pick runtime versions from live upstream channels and customize the startup command with real egg variables.",
  },
  {
    path: "docs/eggs",
    title: "Egg Catalog: Prog-Language Eggs",
    desc: "Docker image, startup command, install container, file denylist and all startup variables from the actual egg-programming-multi.json. No invented defaults.",
  },
  {
    path: "docs/languages",
    title: "Supported Languages: Prog-Language Eggs",
    desc: "All 54 languages served by the single multi-language image: runners, package managers and auto-detect file triggers, searchable in one table.",
  },
  {
    path: "examples",
    title: "Examples: Prog-Language Eggs",
    desc: "Real walkthroughs built from actual egg variables: run a FastAPI app, compile and run a Go binary, and deploy straight from Git.",
  },
  {
    path: "about",
    title: "About: Prog-Language Eggs by PotenFYR Studios",
    desc: "About Prog-Language Eggs and PotenFYR Studios, the studio behind the egg ecosystem for Pterodactyl, Pelican and Feather Panel.",
  },
  {
    path: "license",
    title: "License: Prog-Language Eggs",
    desc: "Apache-2.0 with the Commons Clause: fork, modify, use and redistribute the egg freely. The LICENSE file defines the only limits.",
  },
];
