#!/usr/bin/env bash
# validate-examples.sh — Extract every fenced JSON block from each SKILL-*.md
# whose surface has an associated JSONSchema, and validate it against that
# schema using ajv. Exit 0 if all blocks pass, exit 1 on any failure.
#
# Mapping (surface file → schema file):
#   SKILL-settings.md   → schema/settings.schema.json
#   SKILL-mcp.md        → schema/mcp.schema.json
#   SKILL-plugins.md    → schema/plugin.schema.json
#   SKILL-hooks.md      → schema/hook-input.schema.json
#
# SKILL-slash-commands.md, SKILL-cli.md, SKILL-known-issues.md are skipped
# (no associated schema). To enforce a schema on those, add a mapping below
# AND ensure the file's ```json blocks are of that schema's type.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ ! -d "$ROOT/node_modules/ajv" ]]; then
  echo "ERROR: ajv not installed. Run 'npm install' at the repo root first." >&2
  exit 2
fi

cd "$ROOT"

exec node -e '
const fs = require("fs");
const path = require("path");
const Ajv = require("ajv");
const addFormats = require("ajv-formats");

const ROOT = process.cwd();
const MAP = {
  "SKILL-settings.md": "schema/settings.schema.json",
  "SKILL-mcp.md":      "schema/mcp.schema.json",
  "SKILL-plugins.md":  "schema/plugin.schema.json",
  "SKILL-hooks.md":    "schema/hook-input.schema.json",
};

const ajv = new Ajv({ allErrors: true, strict: false });
addFormats(ajv);

let total = 0;
let failed = 0;
let skipped = 0;

for (const [src, schemaPath] of Object.entries(MAP)) {
  const srcAbs    = path.join(ROOT, src);
  const schemaAbs = path.join(ROOT, schemaPath);

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
console.log("=".repeat(50));
console.log(`Total blocks: ${total}   Passed: ${total - failed}   Failed: ${failed}   Files skipped: ${skipped}`);
console.log("=".repeat(50));

process.exit(failed > 0 ? 1 : 0);
'
