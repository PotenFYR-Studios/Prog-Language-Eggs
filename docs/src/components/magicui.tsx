/**
 * Local Magic UI patterns for the Prog-Language Eggs docs.
 * Vendored from potenfyr-nest src/components/magicui.tsx patterns, adapted
 * to pure CSS motion (no external animation dependency). Landing/hero only -
 * never inside docs article content (SPEC §7).
 */
import { useEffect, useRef, useState } from "react";

/** Magic UI · Number Ticker, counts up to `value` (rAF). */
export function NumberTicker({
  value,
  className,
}: {
  value: number;
  className?: string;
}) {
  const [display, setDisplay] = useState(0);
  const prev = useRef(0);

  useEffect(() => {
    if (
      typeof document !== "undefined" &&
      (document.hidden ||
        window.matchMedia("(prefers-reduced-motion: reduce)").matches)
    ) {
      prev.current = value;
      setDisplay(value);
      return;
    }
    const from = prev.current;
    const start = performance.now();
    const duration = 900;
    let raf = 0;
    const step = (t: number) => {
      const p = Math.min(1, (t - start) / duration);
      const eased = 1 - Math.pow(1 - p, 3);
      setDisplay(Math.round(from + (value - from) * eased));
      if (p < 1) raf = requestAnimationFrame(step);
      else prev.current = value;
    };
    raf = requestAnimationFrame(step);
    return () => cancelAnimationFrame(raf);
  }, [value]);

  return (
    <span className={className} aria-label={String(value)}>
      {display}
    </span>
  );
}

/** Magic UI · Marquee, seamless infinite scroller (pauses on hover). */
export function Marquee({
  children,
  reverse = false,
  pause = true,
  duration = 35,
  gap = "3rem",
  className,
}: {
  children: React.ReactNode;
  reverse?: boolean;
  pause?: boolean;
  duration?: number;
  gap?: string;
  className?: string;
}) {
  return (
    <div
      className={`group flex w-full overflow-hidden ${className ?? ""}`}
      style={
        {
          "--duration": `${duration}s`,
          "--gap": gap,
          gap: "var(--gap)",
        } as React.CSSProperties
      }
    >
      {[0, 1].map((i) => (
        <div
          key={i}
          aria-hidden={i === 1}
          style={{
            animation: `pleMarqueeScroll var(--duration) linear infinite`,
            animationDirection: reverse ? "reverse" : "normal",
          }}
          className={`flex shrink-0 items-center justify-around gap-[var(--gap)] min-w-full ${
            pause ? "group-hover:[animation-play-state:paused]" : ""
          }`}
        >
          {children}
        </div>
      ))}
      <style>{`
        @keyframes pleMarqueeScroll {
          from { transform: translateX(0); }
          to { transform: translateX(calc(-100% - var(--gap))); }
        }
      `}</style>
    </div>
  );
}

/** Magic UI · Meteors, streaking comets confined to the hero. */
export function Meteors({ number = 14 }: { number?: number }) {
  const meteors = Array.from({ length: number }, (_, i) => ({
    id: i,
    left: (i * 137) % 100,
    delay: ((i * 2.3) % 8).toFixed(1),
    dur: (4.5 + ((i * 1.1) % 4)).toFixed(1),
  }));
  return (
    <div
      aria-hidden
      className="pointer-events-none absolute inset-0 overflow-hidden"
    >
      {meteors.map((m) => (
        <span
          key={m.id}
          className="absolute h-0.5 w-0.5 rotate-[215deg] rounded-full bg-brand-pink before:absolute before:top-1/2 before:h-px before:w-20 before:-translate-y-1/2 before:bg-gradient-to-r before:from-[#ec4899] before:to-transparent"
          style={{
            left: `${m.left}%`,
            top: "-8%",
            animation: `pleMeteor ${m.dur}s linear ${m.delay}s infinite`,
          }}
        />
      ))}
      <style>{`
        @keyframes pleMeteor {
          0% { transform: translate3d(0, 0, 0) rotate(215deg); opacity: 0; }
          8% { opacity: 1; }
          100% { transform: translate3d(-420px, 640px, 0) rotate(215deg); opacity: 0; }
        }
      `}</style>
    </div>
  );
}

/** Magic UI · Dot Pattern, decorative dotted backdrop (hero-only variant). */
export function DotPattern({ className }: { className?: string }) {
  return (
    <svg
      aria-hidden
      className={`pointer-events-none absolute inset-0 h-full w-full ${className ?? ""}`}
    >
      <defs>
        <pattern
          id="ple-dots"
          width="28"
          height="28"
          patternUnits="userSpaceOnUse"
        >
          <circle cx="2" cy="2" r="1.2" fill="rgba(139,92,246,0.18)" />
        </pattern>
      </defs>
      <rect width="100%" height="100%" fill="url(#ple-dots)" />
    </svg>
  );
}
