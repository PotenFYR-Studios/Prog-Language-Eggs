import { StrictMode, useEffect, useState } from "react";
import { createRoot, hydrateRoot } from "react-dom/client";
import { App } from "./App";
import "./index.css";

/** Normalize a pathname to a route key: strip trailing slash except root. */
export function routeFromPath(pathname: string): string {
  if (pathname.length > 1 && pathname.endsWith("/")) {
    return pathname.slice(0, -1);
  }
  return pathname;
}

function useRoute(): string {
  const [route, setRoute] = useState(() =>
    routeFromPath(window.location.pathname),
  );
  useEffect(() => {
    const onPop = () => setRoute(routeFromPath(window.location.pathname));
    const onClick = (e: MouseEvent) => {
      // SPA-nav internal links; let modified clicks / targets through.
      if (e.defaultPrevented || e.button !== 0 || e.metaKey || e.ctrlKey || e.shiftKey || e.altKey)
        return;
      const a = (e.target as HTMLElement | null)?.closest("a");
      if (!a) return;
      const href = a.getAttribute("href");
      if (!href || a.target === "_blank" || a.hasAttribute("download")) return;
      const url = new URL(a.href, window.location.origin);
      if (url.origin !== window.location.origin) return;
      if (url.pathname === window.location.pathname && url.hash) return;
      e.preventDefault();
      window.history.pushState(null, "", url.pathname + url.hash);
      setRoute(routeFromPath(url.pathname));
      if (!url.hash) window.scrollTo({ top: 0 });
    };
    window.addEventListener("popstate", onPop);
    document.addEventListener("click", onClick);
    return () => {
      window.removeEventListener("popstate", onPop);
      document.removeEventListener("click", onClick);
    };
  }, []);
  return route;
}

function Shell() {
  const route = useRoute();
  return <App route={route} />;
}

// Prerendered dist pages carry the server-rendered tree: hydrate it. The dev
// server starts from an empty root div, so fall back to a normal client render.
const rootEl = document.getElementById("root")!;
const tree = (
  <StrictMode>
    <Shell />
  </StrictMode>
);
if (rootEl.hasChildNodes()) {
  hydrateRoot(rootEl, tree);
} else {
  createRoot(rootEl).render(tree);
}
