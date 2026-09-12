/** Shared docs-page chrome: collapsible sidebar, right-rail TOC, breadcrumbs,
 *  prev/next pagination and lightweight code tabs. Pure client React so the
 *  prerendered markup hydrates without extra dependencies. */
import { useEffect, useState } from "react";
import { ChevronDown } from "lucide-react";
import { CodeBlock } from "./CodeBlock";
import { withBase } from "../routes";

export interface SidebarItem {
  href: string;
  label: string;
}

export interface SidebarGroup {
  head: string;
  items: SidebarItem[];
}

export interface TocItem {
  id: string;
  label: string;
  sub?: boolean;
}

/** Left navigation. Groups stay open by default and collapse independently. */
export function Sidebar({
  groups,
  route,
}: {
  groups: SidebarGroup[];
  route: string;
}) {
  const [open, setOpen] = useState<Record<string, boolean>>(() =>
    Object.fromEntries(groups.map((g) => [g.head, true])),
  );

  return (
    <aside className="hidden lg:block">
      <nav
        className="sticky space-y-5 border-r border-line-light/60 pr-4"
        style={{ top: "calc(var(--header-h) + 28px)" }}
        aria-label="Docs sections"
      >
        {groups.map((g) => {
          const expanded = open[g.head] ?? true;
          return (
            <div key={g.head}>
              <button
                type="button"
                className="sidebar-toggle"
                aria-expanded={expanded}
                onClick={() => setOpen((prev) => ({ ...prev, [g.head]: !expanded }))}
              >
                <span>{g.head}</span>
                <ChevronDown
                  className={`h-3.5 w-3.5 transition-transform${expanded ? "" : " -rotate-90"}`}
                />
              </button>
              {expanded && (
                <div className="mt-1 space-y-0.5">
                  {g.items.map((it) => (
                    <a
                      key={it.href}
                      href={withBase(it.href)}
                      className={`sidebar-link${route === it.href ? " active" : ""}`}
                      aria-current={route === it.href ? "page" : undefined}
                    >
                      {it.label}
                    </a>
                  ))}
                </div>
              )}
            </div>
          );
        })}
      </nav>
    </aside>
  );
}

/** Right-rail table of contents. Renders only for substantive pages and is
 *  hidden below the xl breakpoint. */
export function Toc({ items }: { items: TocItem[] }) {
  const [active, setActive] = useState(items[0]?.id ?? "");

  useEffect(() => {
    const obs = new IntersectionObserver(
      (entries) => {
        for (const e of entries) {
          if (e.isIntersecting) setActive(e.target.id);
        }
      },
      { rootMargin: "-80px 0px -65% 0px" },
    );
    for (const t of items) {
      const el = document.getElementById(t.id);
      if (el) obs.observe(el);
    }
    return () => obs.disconnect();
  }, [items]);

  if (items.length < 3) return null;

  return (
    <aside className="hidden w-64 shrink-0 xl:block">
      <div
        className="sticky max-h-[calc(100vh-56px-56px)] overflow-y-auto"
        style={{ top: "calc(var(--header-h) + 28px)" }}
      >
        <div className="grad-text mono-label">On this page</div>
        <nav className="mt-3 space-y-0.5" aria-label="Table of contents">
          {items.map((t) => (
            <a
              key={t.id}
              href={`#${t.id}`}
              className={`toc-link${t.sub ? " sub" : ""}${active === t.id ? " active" : ""}`}
              aria-current={active === t.id ? "true" : undefined}
            >
              {t.label}
            </a>
          ))}
        </nav>
      </div>
    </aside>
  );
}

/** Breadcrumb trail for nested docs routes. */
export function Breadcrumb({
  trail,
}: {
  trail: { href: string; label: string }[];
}) {
  return (
    <nav className="breadcrumb" aria-label="Breadcrumb">
      {trail.map((item, i) => (
        <span key={item.href} className="inline-flex items-center gap-2">
          {i > 0 && <span aria-hidden>/</span>}
          <a href={withBase(item.href)}>{item.label}</a>
        </span>
      ))}
    </nav>
  );
}

/** Previous/next navigation ordered by the sidebar sequence. */
export function Pager({
  prev,
  next,
}: {
  prev?: { href: string; label: string };
  next?: { href: string; label: string };
}) {
  if (!prev && !next) return null;
  return (
    <div className="mt-16 flex justify-between gap-4">
      {prev ? (
        <a
          href={withBase(prev.href)}
          className="flex-1 rounded-xl border border-line-light bg-white/[0.02] p-4 no-underline transition-transform hover:-translate-y-0.5 hover:border-brand-violet/50 hover:no-underline"
        >
          <div className="mono-label">Previous</div>
          <div className="mt-1 text-sm text-muted">← {prev.label}</div>
        </a>
      ) : (
        <span className="flex-1" />
      )}
      {next ? (
        <a
          href={withBase(next.href)}
          className="flex-1 rounded-xl border border-line-light bg-white/[0.02] p-4 text-right no-underline transition-transform hover:-translate-y-0.5 hover:border-brand-pink/50 hover:no-underline"
        >
          <div className="mono-label">Next</div>
          <div className="mt-1 text-sm text-muted">{next.label} →</div>
        </a>
      ) : (
        <span className="flex-1" />
      )}
    </div>
  );
}

export interface TabSpec {
  id: string;
  label: string;
  code: string;
}

/** Minimal client-side tabs for two or more equivalent code alternatives. */
export function Tabs({ tabs, lang }: { tabs: TabSpec[]; lang: string }) {
  const [active, setActive] = useState(tabs[0]?.id ?? "");
  const current = tabs.find((t) => t.id === active) ?? tabs[0];
  if (!current) return null;

  return (
    <div>
      <div className="tabs" role="tablist" aria-label="Code alternatives">
        {tabs.map((t) => (
          <button
            key={t.id}
            type="button"
            role="tab"
            aria-selected={t.id === current.id}
            className={`tab${t.id === current.id ? " active" : ""}`}
            onClick={() => setActive(t.id)}
          >
            {t.label}
          </button>
        ))}
      </div>
      <CodeBlock lang={lang} code={current.code} />
    </div>
  );
}
