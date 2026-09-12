import { defineConfig, type Plugin } from "vite";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { resolve, dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { CANON, OG_IMAGE, OG_IMAGE_ALT, PAGES, canonicalFor } from "./src/routes";

const __dir = dirname(fileURLToPath(import.meta.url));

/** Static JSON-LD graph for the landing route, strictly factual values
 *  sourced from the egg JSON / org profiles (no marketing invention). */
const ORG_ID = "https://potenfyr.in/#organization";
const LANDING_JSONLD = {
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "WebSite",
      "@id": `${CANON}/#website`,
      name: "Prog-Language Eggs Docs",
      url: `${CANON}/`,
      inLanguage: "en",
      publisher: { "@id": ORG_ID },
    },
    {
      "@type": "Organization",
      "@id": ORG_ID,
      name: "PotenFYR Studios",
      url: "https://potenfyr.in/",
      sameAs: [
        "https://github.com/PotenFYR-Studios",
        "https://modrinth.com/organization/potenfyr",
      ],
    },
    {
      "@type": "SoftwareApplication",
      "@id": `${CANON}/#egg`,
      name: "Prog-Language Eggs",
      description:
        "One egg for 50+ programming languages with package managers, auto-detection, memory tuning, and Dev Watch mode.",
      applicationCategory: "DeveloperApplication",
      operatingSystem:
        "Linux (amd64, arm64, armv7) on Pterodactyl, Pelican, Feather Panel, PufferPanel, Jexactyl, Wisp, Emerald, Kubernetes, Fly.io, Railway, Render, Docker",
      offers: { "@type": "Offer", price: "0", priceCurrency: "USD" },
      codeRepository: "https://github.com/PotenFYR-Studios/Prog-Language-Eggs",
      license:
        "https://github.com/PotenFYR-Studios/Prog-Language-Eggs/blob/master/LICENSE",
      author: { "@id": ORG_ID },
    },
  ],
};

/** Emit per-route shell copies with per-page SEO meta + sitemap/robots. */
function multiPageEmit(): Plugin {
  return {
    name: "ple-multi-page",
    closeBundle() {
      const outDir = resolve(__dir, "dist");
      const shell = readFileSync(resolve(outDir, "index.html"), "utf8");
      for (const p of PAGES) {
        const dir = p.path === "" ? outDir : join(outDir, p.path);
        mkdirSync(dir, { recursive: true });
        const canon = canonicalFor(p);
        const ld =
          p.path === ""
            ? `  <script type="application/ld+json">${JSON.stringify(LANDING_JSONLD)}</script>\n`
            : "";
        const html = shell
          .replace(/<title>.*?<\/title>/, `<title>${p.title}</title>`)
          .replace(
            "</head>",
            `  <meta name="description" content="${p.desc}">\n` +
              `<link rel="canonical" href="${canon}">\n` +
              `<meta property="og:title" content="${p.title}">\n` +
              `<meta property="og:description" content="${p.desc}">\n` +
              `<meta property="og:url" content="${canon}">\n` +
              `<meta property="og:image" content="${OG_IMAGE}">\n` +
              `<meta property="og:image:alt" content="${OG_IMAGE_ALT}">\n` +
              `<meta property="og:image:width" content="1200">\n` +
              `<meta property="og:image:height" content="630">\n` +
              `<meta name="twitter:image" content="${OG_IMAGE}">\n` +
              ld +
              `</head>`,
          );
        writeFileSync(join(dir, "index.html"), html);
      }
      // sitemap generated from the same route table so it can never drift
      const urls = PAGES.map(
        (p) =>
          `  <url><loc>${p.path === "" ? `${CANON}/` : `${CANON}/${p.path}/`}</loc></url>`,
      ).join("\n");
      writeFileSync(
        join(outDir, "sitemap.xml"),
        `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${urls}\n</urlset>\n`,
      );
    },
  };
}

export default defineConfig({
  root: __dir,
  base: "/",
  plugins: [react(), tailwindcss(), multiPageEmit()],
  build: {
    outDir: "dist",
    emptyOutDir: true,
    sourcemap: false,
  },
  server: { port: 5184 },
});
