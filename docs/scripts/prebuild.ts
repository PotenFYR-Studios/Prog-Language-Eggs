/**
 * Prebuild: generate src/data/catalog.json from the REAL repo sources.
 *
 * Sources of truth (never invent data):
 *   - ../egg-programming-multi.json  → egg metadata, docker image, startup,
 *     config, install container, file denylist and every startup variable.
 *   - ../README.md                   → the 54-language support matrix table.
 */
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const repo = resolve(here, "..", "..");

interface EggVariable {
  name: string;
  env_variable: string;
  default_value: string;
  description: string;
  rules: string;
  user_viewable: boolean;
  user_editable: boolean;
  field_type: string;
}

interface Egg {
  meta: { version: string; update_url: string };
  exported_at: string;
  name: string;
  author: string;
  description: string;
  features: string[];
  docker_images: Record<string, string>;
  file_denylist: string[];
  startup: string;
  config: { stop?: string; startup?: string };
  scripts: {
    installation: { container?: string; entrypoint?: string };
  };
  variables: EggVariable[];
}

const egg: Egg = JSON.parse(
  readFileSync(resolve(repo, "egg-programming-multi.json"), "utf8"),
);

// --- Language matrix: parsed from the real README support table ------------
interface Language {
  n: number;
  name: string;
  runners: string;
  managers: string;
  triggers: string;
}

const readme = readFileSync(resolve(repo, "README.md"), "utf8");
const languages: Language[] = [];
for (const line of readme.split("\n")) {
  const m = line.match(/^\|\s*\*\*(\d+)\*\*\s*\|\s*\*\*(.+?)\*\*\s*\|(.+)\|$/);
  if (!m) continue;
  const cells = m[3].split("|").map((c: string) => c.trim());
  if (cells.length < 3) continue;
  languages.push({
    n: Number(m[1]),
    name: m[2].trim(),
    runners: cells[0],
    managers: cells[1],
    triggers: cells[2],
  });
}
if (languages.length < 50) {
  throw new Error(
    `prebuild: expected the 50+ language matrix in README.md, found ${languages.length} rows`,
  );
}

// Panel startup "done" matchers live in the egg config blob (real strings).
let startupDone: string[] = [];
try {
  startupDone = JSON.parse(egg.config.startup ?? "{}").done ?? [];
} catch {
  /* config blob optional */
}

const catalog = {
  generated_at: new Date().toISOString(),
  sources: [
    "egg-programming-multi.json",
    "README.md (Supported Languages table)",
  ],
  egg: {
    name: egg.name,
    author: egg.author,
    description: egg.description,
    ptdl_version: egg.meta.version,
    update_url: egg.meta.update_url,
    exported_at: egg.exported_at,
    features: egg.features,
    docker_images: egg.docker_images,
    startup: egg.startup,
    stop: egg.config.stop ?? "^C",
    startup_done_matchers: startupDone,
    install_container: egg.scripts.installation.container ?? "",
    install_entrypoint: egg.scripts.installation.entrypoint ?? "",
    file_denylist: egg.file_denylist,
    variables: egg.variables,
    variable_count: egg.variables.length,
  },
  languages,
  language_count: languages.length,
};

const outDir = resolve(here, "..", "src", "data");
mkdirSync(outDir, { recursive: true });
writeFileSync(
  resolve(outDir, "catalog.json"),
  JSON.stringify(catalog, null, 2) + "\n",
);
console.log(
  `prebuild: catalog.json written, ${catalog.language_count} languages, ${catalog.egg.variable_count} variables`,
);
