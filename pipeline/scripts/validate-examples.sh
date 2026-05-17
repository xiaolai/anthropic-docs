#!/usr/bin/env bash
# validate-examples.sh — Two-pass validator for SKILL-*.md content:
#
# PASS 1 (failing): Extract every fenced JSON block from each SKILL-*.md
# whose surface has an associated JSONSchema and validate it against that
# schema using ajv. Fails the build on any schema violation.
#
# PASS 2 (informational): For each schema, check whether the top-level
# property keys it declares appear in the committed docs snapshot
# (docs-snapshot/code.claude.com/). Surfaces schemas that have drifted
# from upstream. Informational only — does not fail the build, because
# the snapshot may legitimately lag upstream by a refresh cycle.
# Run scripts/check-docs-drift.sh as the strict gate for snapshot freshness.
#
# Mapping (surface file → schema file):
#   SKILL-settings.md   → schema/settings.schema.json
#   SKILL-mcp.md        → schema/mcp.schema.json
#   SKILL-plugins.md    → schema/plugin.schema.json
#   SKILL-hooks.md      → schema/hook-input.schema.json
#
# SKILL-slash-commands.md, SKILL-cli.md, SKILL-known-issues.md are skipped
# in pass 1 (no associated schema). To enforce a schema on those, add a
# mapping below AND ensure the file's ```json blocks are of that schema's
# type.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Multi-skill: SKILL_NAME selects which skills/<name>/ payload to validate.
SKILL_NAME="${SKILL_NAME:-claude-code}"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL_ROOT="$REPO_ROOT/skills/$SKILL_NAME"

if [[ ! -d "$REPO_ROOT/node_modules/ajv" ]]; then
  echo "ERROR: ajv not installed. Run 'npm install' at the repo root first." >&2
  exit 2
fi
if [[ ! -d "$SKILL_ROOT" ]]; then
  echo "ERROR: SKILL_NAME=$SKILL_NAME but $SKILL_ROOT does not exist" >&2
  exit 2
fi

# Make context available to the inline node script via env.
export SKILL_NAME SKILL_ROOT REPO_ROOT
cd "$REPO_ROOT"

exec node -e '
const fs = require("fs");
const path = require("path");
const Ajv = require("ajv");
const addFormats = require("ajv-formats");

const REPO_ROOT = process.env.REPO_ROOT || process.cwd();
const SKILL_NAME = process.env.SKILL_NAME || "claude-code";
const SKILL_ROOT = process.env.SKILL_ROOT || path.join(REPO_ROOT, "skills", SKILL_NAME);

// Load the skill MAP (schemas dict) from the skill config — single source
// of truth. Map keys: SKILL-*.md filenames relative to SKILL_ROOT.
// Map values: schema paths relative to REPO_ROOT.
let MAP = {};
try {
  const config = JSON.parse(fs.readFileSync(path.join(SKILL_ROOT, "config.json"), "utf8"));
  MAP = config.schemas || {};
} catch (e) {
  console.error("ERROR loading skill config: " + e.message);
  process.exit(2);
}

// Snapshot lives per-skill: skills/<name>/docs-snapshot/<host>/...
const SNAPSHOT_BASE = path.join(SKILL_ROOT, "docs-snapshot");
const MANIFEST_PATH = path.join(SNAPSHOT_BASE, "MANIFEST.json");
const SNAPSHOT_AVAILABLE = fs.existsSync(MANIFEST_PATH) && fs.existsSync(SNAPSHOT_BASE);

// Load only the pages listed in MANIFEST.json. Walking the snapshot dir
// directly would pull in stale orphan files (pages removed upstream that
// the refresh script forgot to prune) — those would inflate the
// "key found in snapshot" hit rate with content that no longer exists
// upstream, producing false negatives in the drift check.
function loadSnapshotCorpus() {
  if (!SNAPSHOT_AVAILABLE) return "";
  let manifest;
  try {
    manifest = JSON.parse(fs.readFileSync(MANIFEST_PATH, "utf8"));
  } catch {
    return "";
  }
  const pages = Array.isArray(manifest.pages) ? manifest.pages : [];
  const parts = [];
  for (const entry of pages) {
    if (!entry || typeof entry.path !== "string") continue;
    const full = path.join(SNAPSHOT_BASE, entry.path);
    try {
      parts.push(fs.readFileSync(full, "utf8"));
    } catch {
      // Page listed in manifest but missing on disk — surface as a warning
      // line in the corpus so a maintainer notices, but do not fail PASS 2.
      parts.push(`[missing snapshot page: ${entry.path}]`);
    }
  }
  return parts.join("\n\n");
}

const snapshotCorpus = loadSnapshotCorpus();

const ajv = new Ajv({ allErrors: true, strict: false });
addFormats(ajv);

// ---------------------------------------------------------------------------
// PASS 1: schema-bound example validation (failing)
// ---------------------------------------------------------------------------

console.log("=".repeat(60));
console.log(" PASS 1: schema-bound example validation");
console.log("=".repeat(60));

let total = 0;
let failed = 0;
let skipped = 0;

for (const [src, schemaPath] of Object.entries(MAP)) {
  const srcAbs    = path.join(SKILL_ROOT, src);
  const schemaAbs = path.join(REPO_ROOT, schemaPath);

  if (!fs.existsSync(srcAbs)) {
    console.log(`SKIP ${src} (file missing)`);
    skipped++;
    continue;
  }
  if (!fs.existsSync(schemaAbs)) {
    console.log(`SKIP ${src} (schema ${schemaPath} missing)`);
    skipped++;
    continue;
  }

  let validate;
  try {
    const schema = JSON.parse(fs.readFileSync(schemaAbs, "utf8"));
    validate = ajv.compile(schema);
  } catch (e) {
    console.error(`ERROR loading schema ${schemaPath}: ${e.message}`);
    failed++;
    continue;
  }

  const md = fs.readFileSync(srcAbs, "utf8");
  // Match ```json … ``` blocks. Multiline, non-greedy.
  const re = /^```json\s*\n([\s\S]*?)\n^```\s*$/gm;
  let m, idx = 0;
  let blocksInFile = 0;

  while ((m = re.exec(md)) !== null) {
    idx++;
    blocksInFile++;
    total++;
    const body = m[1];

    let data;
    try {
      data = JSON.parse(body);
    } catch (e) {
      console.error(`FAIL ${src} block #${idx}: JSON parse error — ${e.message}`);
      failed++;
      continue;
    }

    const ok = validate(data);
    if (ok) {
      console.log(`PASS ${src} block #${idx} (against ${schemaPath})`);
    } else {
      console.error(`FAIL ${src} block #${idx} (against ${schemaPath}):`);
      for (const err of validate.errors || []) {
        console.error(`  ${err.instancePath || "/"} ${err.message}`);
      }
      failed++;
    }
  }

  if (blocksInFile === 0) {
    console.log("NOTE " + src + " contains 0 json fenced blocks (acceptable on a stub-only surface)");
  }
}

console.log("");
console.log("PASS 1 result: " + (total - failed) + "/" + total + " blocks valid (" + skipped + " files skipped)");

// ---------------------------------------------------------------------------
// PASS 2: schema-coverage cross-check against snapshot (informational)
// ---------------------------------------------------------------------------

console.log("");
console.log("=".repeat(60));
console.log(" PASS 2: schema-coverage in docs-snapshot/ (informational)");
console.log("=".repeat(60));

if (!SNAPSHOT_AVAILABLE) {
  console.log("NOTE no docs-snapshot/code.claude.com/ — run scripts/refresh-docs-snapshot.sh first to enable cross-checks.");
} else {
  // For each schema, walk its top-level "properties" map, grep the snapshot
  // for each key. We use a word-boundary match on the literal key. False
  // positives are acceptable (e.g., "model" appears everywhere) — this is
  // a "did upstream ever mention this key" smell check, not a strict gate.
  let totalKeys = 0;
  let unmatched = 0;

  for (const [src, schemaPath] of Object.entries(MAP)) {
    const schemaAbs = path.join(REPO_ROOT, schemaPath);
    if (!fs.existsSync(schemaAbs)) continue;

    let schema;
    try {
      schema = JSON.parse(fs.readFileSync(schemaAbs, "utf8"));
    } catch {
      continue;
    }
    const props = (schema.properties && typeof schema.properties === "object") ? schema.properties : {};
    const keys = Object.keys(props);
    if (keys.length === 0) {
      console.log("NOTE " + schemaPath + " declares 0 top-level properties; no cross-check possible.");
      continue;
    }

    const missing = [];
    for (const key of keys) {
      totalKeys++;
      // Word-boundary match on the literal key. Anchored by either backtick
      // (markdown code-span), JSON-style quote, or YAML colon.
      const re = new RegExp("(?:`|\")" + key.replace(/[.*+?^${}()|[\\]\\\\]/g, "\\\\$&") + "(?:`|\"|:)");
      if (!re.test(snapshotCorpus)) {
        missing.push(key);
        unmatched++;
      }
    }

    if (missing.length === 0) {
      console.log("OK   " + schemaPath + " — all " + keys.length + " top-level keys appear in snapshot");
    } else {
      console.log("WARN " + schemaPath + " — " + missing.length + "/" + keys.length + " keys not found in snapshot: " + missing.join(", "));
    }
  }

  console.log("");
  console.log("PASS 2 result: " + (totalKeys - unmatched) + "/" + totalKeys + " schema keys found in snapshot (" + unmatched + " unmatched — informational only)");
}

console.log("");
console.log("=".repeat(60));
console.log(" Overall: PASS 1 " + (failed > 0 ? "FAIL" : "OK") + "   PASS 2 informational");
console.log("=".repeat(60));

process.exit(failed > 0 ? 1 : 0);
'
