// Static body prerendering: renders every route from src/routes.ts with
// react-dom/server and injects the full markup into the emitted dist HTML,
// so crawlers see real content while the client hydrates the same tree.
//
// Runs after `vite build` (see package.json "build"); react-dom only.

import { mkdir, readFile, writeFile } from "node:fs/promises";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { createElement } from "react";
import { renderToString } from "react-dom/server";
import { App } from "../src/App";
import { PAGES, reactRouteFor } from "../src/routes";

const __dir = dirname(fileURLToPath(import.meta.url));
const distDir = resolve(__dir, "../dist");
const ROOT_OPEN = '<div id="root">';
const ROOT_CLOSE = "</div>";

/** Rough crawler-visible text length: strip scripts/styles, then tags. */
function staticTextLen(html: string): number {
  return html
    .replace(/<script[\s\S]*?<\/script>/g, " ")
    .replace(/<style[\s\S]*?<\/style>/g, " ")
    .replace(/<[^>]+>/g, " ")
    .replace(/\s+/g, " ").trim().length;
}

try {
  let failures = 0;
  for (const p of PAGES) {
    const relDir = p.path;
    const outFile =
      relDir === ""
        ? resolve(distDir, "index.html")
        : resolve(distDir, relDir, "index.html");

    const shell = await readFile(outFile, "utf8");
    const start = shell.indexOf(ROOT_OPEN);
    if (start === -1) {
      throw new Error(`root div placeholder not found in ${outFile}`);
    }
    if (shell.slice(start, start + ROOT_OPEN.length + ROOT_CLOSE.length) !==
        `${ROOT_OPEN}${ROOT_CLOSE}`) {
      throw new Error(`root div in ${outFile} is not the expected empty shell`);
    }

    const body = renderToString(createElement(App, { route: reactRouteFor(p) }));
    const html =
      shell.slice(0, start) +
      `${ROOT_OPEN}${body}${ROOT_CLOSE}` +
      shell.slice(start + `${ROOT_OPEN}${ROOT_CLOSE}`.length);

    if (relDir) await mkdir(dirname(outFile), { recursive: true });
    await writeFile(outFile, html);
    console.log(
      `[prerender] /${relDir} → ${outFile} (${html.length} bytes, ${staticTextLen(html)} chars static text)`,
    );
    if (staticTextLen(html) < 500) failures += 1;
  }
  if (failures > 0) {
    throw new Error(`${failures} page(s) under 500 chars of static text`);
  }
  console.log(`[prerender] ${PAGES.length} routes prerendered`);
} catch (err) {
  console.error("[prerender] ERROR:", err);
  process.exit(1);
}
