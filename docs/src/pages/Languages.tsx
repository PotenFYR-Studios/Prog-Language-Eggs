import { useMemo, useState } from "react";
import { Search } from "lucide-react";
import { catalog } from "../data/catalog";
import { Breadcrumb, Pager } from "../components/DocsChrome";

/** Searchable matrix of the real 54-language support table. */
export function Languages() {
  const [q, setQ] = useState("");
  const langs = catalog.languages;

  const filtered = useMemo(() => {
    const needle = q.trim().toLowerCase();
    if (!needle) return langs;
    return langs.filter((l) =>
      `${l.name} ${l.runners} ${l.managers} ${l.triggers}`
        .toLowerCase()
        .includes(needle),
    );
  }, [q, langs]);

  return (
    <div className="mx-auto max-w-6xl px-6 pb-20 pt-9 sm:px-7">
      <Breadcrumb trail={[{ href: "/docs", label: "Docs" }, { href: "/docs/languages", label: "Supported Languages" }]} />
      <div className="eyebrow mt-4 text-brand-cyan">Generated from the README support matrix</div>
      <h1 className="doc-h1 grad-text mt-3">Supported languages</h1>
      <p className="mt-4 max-w-[720px] text-[15px] leading-[1.75] text-ink-2">
        All {catalog.language_count} languages served by the single multi-language
        image. Runtimes install on demand with SHA256 verification and cache in{" "}
        <code className="inline-code">.environments/</code>; switching languages
        never deletes your files. Set{" "}
        <code className="inline-code">LANGUAGE</code> to any entry below, or
        leave it <code className="inline-code">auto</code> and let the file
        triggers decide.
      </p>

      <div className="sticky top-[56px] z-10 -mx-6 mt-8 bg-[#0b0d14]/85 px-6 py-3" style={{ backdropFilter: "blur(10px)" }}>
        <label className="relative block max-w-md">
          <Search className="pointer-events-none absolute left-3.5 top-1/2 h-4 w-4 -translate-y-1/2 text-faint" />
          <input
            value={q}
            onChange={(e) => setQ(e.target.value)}
            placeholder="Filter by language, runner, package manager or trigger…"
            className="w-full rounded-lg border border-line-light bg-white/[0.03] py-2.5 pl-10 pr-3 text-sm text-ink outline-none transition-colors placeholder:text-faint focus:border-brand-violet"
          />
        </label>
        <div className="mono-label mt-2">
          {filtered.length} / {langs.length} languages
        </div>
      </div>

      <div className="var-table-wrap mt-4">
        <table className="var-table">
          <thead>
            <tr>
              <th className="w-10">#</th>
              <th>Language / stack</th>
              <th>Runners / engines</th>
              <th>Package managers</th>
              <th>Auto-detect triggers</th>
            </tr>
          </thead>
          <tbody>
            {filtered.map((l) => (
              <tr key={l.n}>
                <td className="font-mono text-[0.78em] text-faint">{l.n}</td>
                <td className="whitespace-nowrap font-semibold text-white">{l.name}</td>
                <td className="font-mono text-[0.8em] text-[#d8ccfe]">{l.runners}</td>
                <td className="font-mono text-[0.8em] text-ink-2">{l.managers}</td>
                <td className="font-mono text-[0.78em] text-muted">{l.triggers}</td>
              </tr>
            ))}
            {filtered.length === 0 && (
              <tr>
                <td colSpan={5} className="py-8 text-center text-sm text-faint">
                  No languages match “{q}”.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      <Pager
        prev={{ href: "/docs/eggs", label: "Egg Catalog" }}
        next={{ href: "/examples", label: "Examples" }}
      />
    </div>
  );
}
