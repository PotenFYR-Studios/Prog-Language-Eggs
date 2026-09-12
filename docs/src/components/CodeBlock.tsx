import { useState, type ReactNode } from "react";

/** Terminal-style code block with language tag + hover copy button
 *  (SPEC §5.8). `lang` renders as the top-left mono micro-label. */
export function CodeBlock({
  lang,
  code,
  children,
}: {
  lang: string;
  code?: string;
  children?: ReactNode;
}) {
  const [copied, setCopied] = useState(false);
  const body = code ?? "";
  const doCopy = () => {
    navigator.clipboard?.writeText(body).then(
      () => {
        setCopied(true);
        setTimeout(() => setCopied(false), 1400);
      },
      () => {},
    );
  };
  return (
    <pre className="codeblock" data-lang={lang}>
      <code>{children ?? body}</code>
      {(body || children) && (
        <button
          type="button"
          className={`copy-btn${copied ? " ok" : ""}`}
          onClick={doCopy}
        >
          {copied ? "Copied!" : "Copy"}
        </button>
      )}
    </pre>
  );
}
