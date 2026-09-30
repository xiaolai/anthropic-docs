// End-to-end tests for pipeline/scripts/refresh-docs-snapshot.sh's per-page
// outcome contract (fetched / skipped / failed). The real script runs
// against a throwaway repo tree with a stub `curl` first on PATH, so no
// network is touched. Run from pipeline/agent: `npx tsx ../scripts/tests/refresh-docs-snapshot.test.ts`.

import { strict as assert } from "node:assert";
import { describe, it } from "node:test";
import { spawnSync } from "node:child_process";
import {
  chmodSync, copyFileSync, existsSync, mkdirSync, mkdtempSync, readFileSync, writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const SCRIPT = resolve(dirname(fileURLToPath(import.meta.url)), "..", "refresh-docs-snapshot.sh");
const HOST = "docs.example.test";
const INDEX_URL = `https://${HOST}/llms.txt`;

// One upstream response: what the stub curl reports for a URL.
interface Response {
  status: number;       // HTTP status of the last response
  finalUrl?: string;    // url_effective (defaults to the requested URL)
  curlExit?: number;    // curl's exit code (default 0)
  body?: string;
}

// Stub curl: honours -o FILE, -w FORMAT (only %{http_code} and
// %{url_effective}), -f, and takes the URL as its last argument. Responses
// come from $STUB_RESPONSES (JSON keyed by URL).
const STUB_CURL = `#!/usr/bin/env node
const fs = require("fs");
const args = process.argv.slice(2);
let out = null, fmt = null, fail = false;
for (let i = 0; i < args.length; i++) {
  if (args[i] === "-o") out = args[++i];
  else if (args[i] === "-w") fmt = args[++i];
  else if (/^-[a-zA-Z]*f[a-zA-Z]*$/.test(args[i])) fail = true;
}
const url = args[args.length - 1];
const r = JSON.parse(fs.readFileSync(process.env.STUB_RESPONSES, "utf8"))[url];
if (!r) { process.stderr.write("stub: no response for " + url + "\\n"); process.exit(7); }
const exit = r.curlExit || (fail && r.status >= 400 ? 22 : 0);
if (r.body !== undefined && exit === 0) {
  if (out) fs.writeFileSync(out, r.body); else process.stdout.write(r.body);
}
if (fmt) process.stdout.write(fmt.replace("%{http_code}", String(r.status)).replace("%{url_effective}", r.finalUrl || url).replace("\\\\t", "\\t"));
if (exit) process.stderr.write("curl: (" + exit + ") stub failure\\n");
process.exit(exit);
`;

function page(path: string): string {
  return `https://${HOST}/docs/${path}`;
}

// Build a repo tree containing the real script and one skill, run it,
// and return the exit code, output and (when written) the manifest.
function runRefresh(pages: Record<string, Response>, env: Record<string, string> = {}) {
  const root = mkdtempSync(join(tmpdir(), "refresh-test-"));
  mkdirSync(join(root, "pipeline", "scripts"), { recursive: true });
  copyFileSync(SCRIPT, join(root, "pipeline", "scripts", "refresh-docs-snapshot.sh"));
  mkdirSync(join(root, "skills", "t", "docs-snapshot"), { recursive: true });
  writeFileSync(join(root, "skills", "t", "config.json"), JSON.stringify({ upstream: { docsIndexUrl: INDEX_URL } }));

  const index = Object.keys(pages).map((u) => `- [p](${u}): page`).join("\n") + "\n";
  const responses: Record<string, Response> = { [INDEX_URL]: { status: 200, body: index }, ...pages };
  writeFileSync(join(root, "responses.json"), JSON.stringify(responses));
  mkdirSync(join(root, "bin"));
  writeFileSync(join(root, "bin", "curl"), STUB_CURL);
  chmodSync(join(root, "bin", "curl"), 0o755);

  const res = spawnSync("bash", [join(root, "pipeline", "scripts", "refresh-docs-snapshot.sh")], {
    encoding: "utf8",
    env: {
      ...process.env,
      PATH: `${join(root, "bin")}:${process.env.PATH}`,
      SKILL_NAME: "t",
      STUB_RESPONSES: join(root, "responses.json"),
      ...env,
    },
  });
  const manifestPath = join(root, "skills", "t", "docs-snapshot", "MANIFEST.json");
  const manifest = existsSync(manifestPath) ? JSON.parse(readFileSync(manifestPath, "utf8")) : null;
  return { code: res.status, output: `${res.stdout}${res.stderr}`, manifest, root };
}

// Ten healthy pages, so one skip stays inside the default 10% bound.
function healthy(n = 10): Record<string, Response> {
  const out: Record<string, Response> = {};
  for (let i = 0; i < n; i++) out[page(`en/p${i}.md`)] = { status: 200, body: `# page ${i}\n` };
  return out;
}

describe("refresh-docs-snapshot.sh: per-page outcomes", () => {
  it("snapshots every page when all return 200", () => {
    const r = runRefresh(healthy());
    assert.equal(r.code, 0, r.output);
    assert.equal(r.manifest.pageCount, 10);
    assert.deepEqual(r.manifest.skippedPages, []);
    assert.ok(existsSync(join(r.root, "skills", "t", "docs-snapshot", HOST, "en", "p0.md")));
  });

  it("skips a page that redirects off the docs host (the claude-tag.md case) and records it", () => {
    const moved = page("en/claude-tag.md");
    const r = runRefresh({
      ...healthy(),
      [moved]: { status: 200, finalUrl: "https://other.example.test/docs/claude-tag/overview", body: "<!DOCTYPE html>" },
    });
    assert.equal(r.code, 0, r.output);
    assert.match(r.output, /WARN skip en\/claude-tag\.md \(redirected off-host/);
    assert.equal(r.manifest.pageCount, 10);
    assert.equal(r.manifest.skippedPages.length, 1);
    assert.equal(r.manifest.skippedPages[0].url, moved);
    assert.equal(r.manifest.skippedPages[0].reason, "redirected off-host");
    assert.ok(!existsSync(join(r.root, "skills", "t", "docs-snapshot", HOST, "en", "claude-tag.md")),
      "off-host content must not be written into the snapshot");
  });

  it("skips an off-host redirect even when the off-host hop fails", () => {
    const r = runRefresh({
      ...healthy(),
      [page("en/moved.md")]: { status: 302, finalUrl: "https://other.example.test/x", curlExit: 6 },
    });
    assert.equal(r.code, 0, r.output);
    assert.equal(r.manifest.skippedPages[0].finalUrl, "https://other.example.test/x");
  });

  for (const status of [404, 410]) {
    it(`skips a page that returns ${status} on the docs host`, () => {
      const r = runRefresh({ ...healthy(), [page("en/retired.md")]: { status } });
      assert.equal(r.code, 0, r.output);
      assert.match(r.output, /WARN skip en\/retired\.md \(gone upstream: HTTP \d+/);
      assert.equal(r.manifest.skippedPages[0].reason, "gone upstream");
    });
  }

  for (const [label, resp] of [
    ["a transport error on the docs host", { status: 0, curlExit: 28 }],
    ["HTTP 500", { status: 500 }],
    ["HTTP 429", { status: 429 }],
    ["HTTP 403 on the docs host", { status: 403 }],
  ] as const) {
    it(`fails loud on ${label} and writes no manifest`, () => {
      const r = runRefresh({ ...healthy(), [page("en/flaky.md")]: resp });
      assert.equal(r.code, 1, r.output);
      assert.match(r.output, /FAIL en\/flaky\.md/);
      assert.match(r.output, /snapshot is incomplete; aborting/);
      assert.equal(r.manifest, null);
    });
  }

  it("fails when skips exceed MAX_SKIPPED_PCT (systemic change, not retired pages)", () => {
    const pages = healthy(8);
    pages[page("en/a.md")] = { status: 404 };
    pages[page("en/b.md")] = { status: 404 };
    const r = runRefresh(pages);
    assert.equal(r.code, 1, r.output);
    assert.match(r.output, /2 of 10 pages were skipped \(limit 10%\)/);
    assert.equal(r.manifest, null);
    assert.equal(runRefresh(pages, { MAX_SKIPPED_PCT: "20" }).code, 0);
  });
});
