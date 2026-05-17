// sanitize.ts — Defang untrusted content before embedding into LLM prompts.
//
// Threat model: this pipeline reads GitHub issue bodies, GitHub release bodies,
// and arbitrary docs pages from code.claude.com. An attacker who controls any
// of those surfaces (public issue posting, CDN compromise, planted upstream
// content) could embed prompt-injection payloads. This module is the
// content-ingestion defense layer; the system-prompt "Security Boundary"
// section is the in-context refusal layer; together they provide defense in
// depth. Neither alone is sufficient.

// Tag names that an injection commonly impersonates to look like a system
// instruction. Case-insensitive match on the tag name (not the full element).
const DANGEROUS_TAGS = [
  "system",
  "instruction",
  "instructions",
  "important",
  "priority",
  "override",
  "admin",
  "role",
  "persona",
  "task",
  "directive",
  "command",
  "prompt",
  "developer",
  "assistant",
];

// Imperative line-leading markers that mimic system-prompt phrasing.
const DANGEROUS_LINE_LEADERS = [
  /^\s*(important|system|instruction|note to assistant|attention|priority|override|admin|directive)\s*:\s*/im,
  /^\s*(ignore|disregard|forget|override)\s+(all\s+|the\s+)?(prior|previous|above|earlier|preceding|prior\s+system)\s+(instructions?|prompts?|messages?|rules?)/im,
  /^\s*you\s+(must|will|shall|are\s+(now|required|instructed))/im,
];

const DEFAULT_MAX_LEN = 8000;
const TRUNCATION_MARKER = "\n…[truncated — content exceeded sanitisation limit]";

/**
 * Strip patterns that commonly carry prompt-injection payloads. The output is
 * still untrusted content (a determined adversary may use formats this filter
 * doesn't recognise) — the in-context Security Boundary instructions in the
 * system prompts remain load-bearing. This is one layer, not a guarantee.
 */
export function defangUntrustedContent(
  raw: string,
  options: { maxLen?: number } = {},
): string {
  const maxLen = options.maxLen ?? DEFAULT_MAX_LEN;

  let s = raw ?? "";

  // 1. Remove HTML / XML comments. Prompt-injection payloads sometimes hide
  //    inside comments hoping a parser will strip them before display while
  //    the LLM still reads them.
  s = s.replace(/<!--[\s\S]*?-->/g, "");

  // 2. Strip dangerous tag pairs and standalone tags. We replace with the
  //    inner text in parentheses so the reader knows something was there.
  for (const tag of DANGEROUS_TAGS) {
    const open = new RegExp(`<\\s*${tag}(\\s[^>]*)?>`, "gi");
    const close = new RegExp(`<\\s*/\\s*${tag}\\s*>`, "gi");
    s = s.replace(open, `[stripped-${tag}-open]`);
    s = s.replace(close, `[stripped-${tag}-close]`);
  }

  // 3. Neutralise imperative line-leading markers. Prefix them with a marker
  //    so a reader can tell the original line started with such a phrase.
  for (const re of DANGEROUS_LINE_LEADERS) {
    s = s.replace(re, "[neutralised-imperative] ");
  }

  // 4. Collapse any sequence of fenced code-block markers the adversary might
  //    use to break out of the wrapper fence. Replace ``` with ʼʼʼ (similar
  //    glyphs) so the original intent is visible without enabling escape.
  s = s.replace(/```/g, "ʼʼʼ");

  // 5. Truncate if oversized.
  if (s.length > maxLen) {
    s = s.slice(0, maxLen) + TRUNCATION_MARKER;
  }

  return s;
}

/**
 * Recursively walk a JSON value and defang every string. Useful for change
 * reports that mix structural fields (safe) with body / title fields (unsafe).
 * Pass a `fieldFilter` to limit defanging to specific JSON paths.
 */
export function defangJsonValue(value: unknown, maxLen?: number): unknown {
  if (typeof value === "string") {
    return defangUntrustedContent(value, { maxLen });
  }
  if (Array.isArray(value)) {
    return value.map((v) => defangJsonValue(v, maxLen));
  }
  if (value && typeof value === "object") {
    const out: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(value as Record<string, unknown>)) {
      out[k] = defangJsonValue(v, maxLen);
    }
    return out;
  }
  return value;
}

/**
 * Wrap content in delimiters that make the boundary obvious in the prompt.
 * The nonce is regenerated per run, so an adversary cannot pre-craft content
 * whose own delimiter matches and tricks the model into reading injected
 * content as trusted.
 */
export function wrapUntrustedContent(label: string, content: string): {
  wrapped: string;
  nonce: string;
} {
  // Adversary writes upstream content before the pipeline runs and cannot
  // observe this value at write time. Math.random + time is unpredictable
  // enough for that threat model; we are not protecting against a chosen-
  // prefix collision attack on a hash.
  const nonce =
    Date.now().toString(36) +
    Math.floor(Math.random() * 1e12).toString(36);
  const open = `<UNTRUSTED_EXTERNAL_CONTENT label="${label}" nonce="${nonce}">`;
  const close = `</UNTRUSTED_EXTERNAL_CONTENT label="${label}" nonce="${nonce}">`;
  const wrapped = `${open}\n${content}\n${close}`;
  return { wrapped, nonce };
}

/**
 * Convenience: defang AND wrap in one call. Returns the wrapped string ready
 * for embedding into a user message, plus the nonce so the caller can name
 * the boundary in their security-rules preamble.
 */
export function defangAndWrap(
  label: string,
  raw: string,
  options: { maxLen?: number } = {},
): { wrapped: string; nonce: string } {
  const defanged = defangUntrustedContent(raw, options);
  return wrapUntrustedContent(label, defanged);
}
