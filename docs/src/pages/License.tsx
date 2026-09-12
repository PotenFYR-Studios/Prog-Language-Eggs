import { Scale, CircleCheck, CircleX } from "lucide-react";
import { Breadcrumb, Pager, Toc } from "../components/DocsChrome";

const REPO = "https://github.com/PotenFYR-Studios/Prog-Language-Eggs";
const LICENSE_URL = `${REPO}/blob/master/LICENSE`;

export function License() {
  const toc = [
    { id: "plain-summary", label: "Plain-language summary" },
    { id: "you-can", label: "What you can do" },
    { id: "limits", label: "The limits" },
    { id: "notices", label: "Notices and attribution" },
  ];

  return (
    <div className="mx-auto grid max-w-[1720px] grid-cols-1 gap-10 px-4 pb-20 pt-9 sm:px-7 xl:grid-cols-[minmax(0,1fr)_260px]">
      <article className="doc-content max-w-6xl">
        <Breadcrumb trail={[{ href: "/", label: "Home" }, { href: "/license", label: "License" }]} />
        <div className="eyebrow mt-4">Apache-2.0 with Commons Clause</div>
        <h1 className="doc-h1 grad-text mt-3">License</h1>
        <p className="mt-4 text-[15px] leading-[1.75] text-ink-2">
          Prog-Language Eggs is free software with one commercial boundary. The
          repository <a href={LICENSE_URL}>LICENSE file</a> is authoritative;
          this page is a plain-language guide, not a replacement for it.
        </p>

        <h2 id="plain-summary">Plain-language summary</h2>
        <p>
          The project uses the Apache License 2.0 plus the Commons Clause
          condition. Apache-2.0 gives you a broad, perpetual license to use the
          egg and its launcher. The Commons Clause adds a single restriction to
          that grant: you may not sell the software itself.
        </p>

        <h2 id="you-can">What you can do</h2>
        <ul className="doc-list">
          <li><CircleCheck className="mr-2 inline h-4 w-4 text-brand-emerald" />Use it for personal, internal and commercial workloads.</li>
          <li><CircleCheck className="mr-2 inline h-4 w-4 text-brand-emerald" />Fork it, modify it, self-host it and redistribute it.</li>
          <li><CircleCheck className="mr-2 inline h-4 w-4 text-brand-emerald" />Build products or services around it, including paid hosting, setup and support.</li>
          <li><CircleCheck className="mr-2 inline h-4 w-4 text-brand-emerald" />Bundle it with your own panel, image, platform or service.</li>
        </ul>

        <h2 id="limits">The limits</h2>
        <ul className="doc-list">
          <li><CircleX className="mr-2 inline h-4 w-4 text-brand-orange" />Do not sell the software itself as a product.</li>
          <li><CircleX className="mr-2 inline h-4 w-4 text-brand-orange" />Do not offer a paid product or service whose value derives entirely or substantially from the software's functionality.</li>
          <li><CircleX className="mr-2 inline h-4 w-4 text-brand-orange" />Do not use PotenFYR names or trademarks to imply endorsement.</li>
        </ul>

        <h2 id="notices">Notices and attribution</h2>
        <p>
          Keep license notices intact in copies and substantial redistributions.
          Those notices must carry the Commons Clause attribution. If you fork
          the project, keep the license condition with the code.
        </p>
        <div className="doc-card my-5">
          <h3 className="!mt-0"><Scale className="mr-2 inline h-4 w-4 text-brand-violet" />Authoritative source</h3>
          <p className="text-[0.85em] leading-relaxed text-muted">
            This summary cannot cover every legal situation. Read the{" "}
            <a href={LICENSE_URL}>LICENSE file</a> for the actual grant and
            conditions.
          </p>
        </div>

        <Pager
          prev={{ href: "/about", label: "About" }}
        />
      </article>
      <Toc items={toc} />
    </div>
  );
}
