#!/usr/bin/env bash
# fetch-anthropic-pulse.sh — Deterministic-render pipeline for the
# anthropic-pulse skill. Replaces the standard refresh-docs-snapshot +
# research-agent path for that one skill.
#
# Why bespoke: anthropic.com/news and anthropic.com/research are
# HTML-only (no llms.txt). The standard pipeline expects llms.txt with
# .md page URLs. Rather than generalize the whole pipeline, we
# special-case this single skill — see skills/anthropic-pulse/config.json
# pipelineOverrides.customRefreshScript.
#
# What it does:
#   1. Fetch the two index pages (news + research) via curl
#   2. Parse out the most recent ~20 items per page via perl regex
#   3. Cache items as JSON at skills/anthropic-pulse/.pulse-cache/
#   4. Render skills/anthropic-pulse/SKILL-{news,research}.md from the
#      cached JSON using a Markdown table template
#   5. Update state.json.pulse.{newsItemsTracked, researchItemsTracked,
#      lastFetchedAt}
#
# Zero LLM cost. Output is mechanical. No prompt-injection surface.
#
# Run manually with:
#   SKILL_NAME=anthropic-pulse bash pipeline/scripts/fetch-anthropic-pulse.sh
#
# Exit 0 = success. Exit 1 = parse / fetch failure. Exit 2 = setup error.

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL_NAME="${SKILL_NAME:-anthropic-pulse}"
SKILL_ROOT="$REPO_ROOT/skills/$SKILL_NAME"
CACHE_DIR="$SKILL_ROOT/.pulse-cache"

if [[ "$SKILL_NAME" != "anthropic-pulse" ]]; then
  echo "ERROR: this script only handles SKILL_NAME=anthropic-pulse (got: $SKILL_NAME)" >&2
  exit 2
fi
if [[ ! -d "$SKILL_ROOT" ]]; then
  echo "ERROR: $SKILL_ROOT does not exist" >&2
  exit 2
fi

mkdir -p "$CACHE_DIR"

for cmd in curl jq perl; do
  command -v "$cmd" &>/dev/null || { echo "ERROR: '$cmd' required" >&2; exit 2; }
done

CURL_OPTS=(--connect-timeout 10 --max-time 60 --retry 2 --retry-delay 3 \
  --user-agent "anthropic-docs/1.0 (+https://github.com/xiaolai/anthropic-docs)")
TODAY=$(date -u +%Y-%m-%d)
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# ---------------------------------------------------------------------------
# Helper: extract items from an Anthropic index page.
#
# Anthropic uses Next.js — the index pages embed item data in <a> tags
# with hrefs like /news/<slug> or /research/<slug>. The visible text of
# the <a> contains the title; a nearby <time> tag holds the date.
#
# We use a tolerant perl regex that handles whitespace + nested tags +
# absolute vs relative hrefs. It's NOT a full HTML parser (the project
# avoids adding deps) but the Anthropic pages have stable enough markup
# that this works in practice. If extraction goes sideways the script
# falls back to "no items" rather than writing garbage.
#
# Output: one JSON object per line on stdout, with keys: title, date, url, summary.
# ---------------------------------------------------------------------------
extract_items() {
  local HTML="$1" SECTION="$2"   # SECTION = "news" or "research"

  # Use perl to extract structured items from Anthropic index pages.
  # Each card has the shape:
  #   <a href="/news/SLUG" class="...">
  #     <span class="caption">CATEGORY</span>
  #     <time>HUMAN-DATE</time>
  #     <h3-or-h4>TITLE</h3-or-h4>
  #   </a>
  # We target the heading element specifically to avoid grabbing the
  # excerpt/lede. The date comes from the <time> tag, the category
  # from the <span class="caption">.
  # NOTE on encoding: STDIN gets the :encoding(UTF-8) layer so perl
  # decodes incoming UTF-8 bytes into Unicode characters internally.
  # JSON::PP encode_json wants Unicode-strings-in and emits UTF-8-bytes-
  # out, so STDOUT stays :raw — encode_json'\''s bytes pass through
  # untouched. With this layering, "Claude'\''s" (U+2019 apostrophe)
  # round-trips correctly: 3 UTF-8 input bytes → 1 Unicode char → 3
  # UTF-8 output bytes. Earlier attempts using -CSD double-encoded; a
  # plain :raw stdin left perl interpreting bytes as Latin-1.
  echo "$HTML" | perl -e '
    use strict; use warnings;
    use JSON::PP;
    binmode(STDIN,  ":encoding(UTF-8)");
    binmode(STDOUT, ":raw");
    local $/;  my $html = <STDIN>;
    my $section = $ARGV[0];

    # Whitelist: which path prefixes count as items per section.
    # /research has many subkinds (papers, features); /news is mostly
    # /news/SLUG but a few special pages live at /SLUG (e.g. /glasswing).
    my %allowed_prefix;
    if ($section eq "news") {
      %allowed_prefix = (news => 1, glasswing => 1, "81k-interviews" => 1);
    } else {
      %allowed_prefix = (research => 1, features => 1, "81k-interviews" => 1);
    }
    # Deny-list: pages we skip (team pages, product pages, navigation).
    my %deny = (
      "research/team" => 1, product => 1, careers => 1, jobs => 1,
      pricing => 1, contact => 1, login => 1, customers => 1,
      legal => 1, policy => 1, transparency => 1,
    );

    my %seen;
    my @items;

    # Match anchor + inner block (everything until matching </a>).
    # We then target the <h2-h6> element INSIDE the anchor as the title
    # (avoids grabbing the excerpt/lede which sits in a <p>).
    while ($html =~ m{
      <a[^>]+href="(/[^"#?]+?)"   # capture href ($1)
      [^>]*>
      (.*?)                        # inner ($2)
      </a>
    }gsx) {
      my $href = $1;
      my $inner = $2;

      $href =~ s{/$}{};
      next unless length $href;

      # Allow / deny by first path segment(s)
      $href =~ m{^/([^/]+)(?:/([^/]+))?};
      my $prefix1 = $1 // "";
      my $prefix2 = $2 // "";
      my $two_seg = "$prefix1" . ($prefix2 ne "" ? "/$prefix2" : "");
      next if $deny{$prefix1} || $deny{$two_seg};
      next unless $allowed_prefix{$prefix1};
      next if $href =~ m{^/(news|research|features)/?$};
      next if $href =~ m{^/research/team/};
      next if $seen{$href}++;

      # Extract title from the first heading-like element inside the
      # anchor. Anthropic uses two card variants:
      #   (a) <h2>..</h6>TITLE</h[2-6]>   — "feature" cards
      #   (b) <span class="..title..">TITLE</span>  — "publication list" cards
      my $title = "";
      if ($inner =~ m{<h[2-6][^>]*>(.*?)</h[2-6]>}s) {
        $title = $1;
      } elsif ($inner =~ m{<span[^>]+class="[^"]*title[^"]*"[^>]*>(.*?)</span>}s) {
        # Note: no \b around "title" — Anthropic uses class names like
        # "PublicationList-module-scss-module__KxYrHG__title body-3"
        # where \b would fail at the underscore-letter boundary.
        $title = $1;
      } else {
        $title = $inner;
      }

      # Strip nested HTML + decode common entities
      $title =~ s{<[^>]+>}{ }g;
      $title =~ s{&amp;}{&}g;
      $title =~ s{&#x27;|&#39;|&rsquo;|&lsquo;}{\x{2019}}g;   # → ’
      $title =~ s{&quot;|&ldquo;|&rdquo;}{"}g;
      $title =~ s{&nbsp;}{ }g;
      $title =~ s{&hellip;}{...}g;
      $title =~ s{\s+}{ }g;
      $title =~ s{^\s+|\s+$}{}g;

      next if length($title) < 5;
      next if length($title) > 200;
      next if $title =~ /^(View all|Read more|See more|Explore|Learn more|Latest|All news|All research|Inside Claude.*|Read|Watch|Skip to.*)$/i;

      # Extract date from the first <time> element inside the anchor.
      # Falls back to looking in the surrounding context.
      my %mon = (Jan=>"01",Feb=>"02",Mar=>"03",Apr=>"04",May=>"05",Jun=>"06",
                 Jul=>"07",Aug=>"08",Sep=>"09",Oct=>"10",Nov=>"11",Dec=>"12");
      my $date = "";
      if ($inner =~ m{<time[^>]*datetime="(\d{4}-\d{2}-\d{2})}i) {
        $date = $1;
      } elsif ($inner =~ m{<time[^>]*>([^<]+)</time>}) {
        my $human = $1;
        $human =~ s{\s+}{ }g; $human =~ s{^\s+|\s+$}{}g;
        if ($human =~ m{(\w{3})\w*\s+(\d{1,2}),\s+(\d{4})}) {
          my ($m,$d,$y) = ($mon{ucfirst lc $1} // "01", sprintf("%02d",$2), $3);
          $date = "$y-$m-$d";
        }
      }

      # Extract category. Two card variants:
      #   feature cards:        <span class="caption bold">CATEGORY</span>
      #   publication-list cards: <span class="...__subject body-3">CATEGORY</span>
      my $category = "";
      if ($inner =~ m{<span[^>]+class="[^"]*(?:caption|subject)[^"]*"[^>]*>([^<]+)</span>}i) {
        $category = $1;
        $category =~ s{^\s+|\s+$}{}g;
      }

      my $url = "https://www.anthropic.com" . $href;
      push @items, {
        title => $title,
        date => $date,
        category => $category,
        url => $url,
      };
    }

    for my $item (@items) {
      print encode_json($item) . "\n";
    }
  ' "$SECTION"
}

# ---------------------------------------------------------------------------
# Fetch + extract: news
# ---------------------------------------------------------------------------
echo "Fetching anthropic.com/news ..."
NEWS_HTML=$(curl -sfL "${CURL_OPTS[@]}" "https://www.anthropic.com/news") || {
  echo "ERROR: failed to fetch /news" >&2; exit 1;
}
NEWS_ITEMS=$(extract_items "$NEWS_HTML" "news" | head -25)
NEWS_COUNT=$(printf '%s\n' "$NEWS_ITEMS" | grep -c . || echo 0)
echo "  extracted: $NEWS_COUNT items"

# Convert NDJSON to JSON array + cache
NEWS_JSON=$(printf '%s\n' "$NEWS_ITEMS" | jq -s '.')
echo "$NEWS_JSON" > "$CACHE_DIR/news.json"

# ---------------------------------------------------------------------------
# Fetch + extract: research
# ---------------------------------------------------------------------------
echo "Fetching anthropic.com/research ..."
RES_HTML=$(curl -sfL "${CURL_OPTS[@]}" "https://www.anthropic.com/research") || {
  echo "ERROR: failed to fetch /research" >&2; exit 1;
}
RES_ITEMS=$(extract_items "$RES_HTML" "research" | head -25)
RES_COUNT=$(printf '%s\n' "$RES_ITEMS" | grep -c . || echo 0)
echo "  extracted: $RES_COUNT items"
RES_JSON=$(printf '%s\n' "$RES_ITEMS" | jq -s '.')
echo "$RES_JSON" > "$CACHE_DIR/research.json"

# ---------------------------------------------------------------------------
# Sanity check: refuse to overwrite SKILL-*.md with empty digests
# ---------------------------------------------------------------------------
if (( NEWS_COUNT < 3 || RES_COUNT < 3 )); then
  echo "WARN: extraction yielded suspiciously few items (news=$NEWS_COUNT, research=$RES_COUNT)" >&2
  echo "      Skipping SKILL-*.md rewrite to preserve last-known-good content." >&2
  echo "      (If this is the first run, set ALLOW_PARTIAL_PULSE_RENDER=1 to override.)" >&2
  if [[ "${ALLOW_PARTIAL_PULSE_RENDER:-0}" != "1" ]]; then
    exit 1
  fi
fi

# ---------------------------------------------------------------------------
# Render SKILL-news.md + SKILL-research.md
# ---------------------------------------------------------------------------
render_surface() {
  local TITLE="$1" SOURCE_URL="$2" JSON_FILE="$3" OUT_FILE="$4" SLUG="$5"

  local FRONTMATTER_DESC
  if [[ "$SLUG" == "news" ]]; then
    FRONTMATTER_DESC="Digest of the most recent ~15-20 Anthropic news posts — product launches, partnerships, region openings, model releases, policy updates, business announcements. Auto-refreshed every 30 minutes from anthropic.com/news. Use when the user asks: \"did X just launch?\", \"what did Anthropic announce?\", \"is model Y out yet?\", \"any partnership news?\". Skip: deep technical content (digest only has title + URL + summary; for body, WebFetch the linked URL)."
  else
    FRONTMATTER_DESC="Digest of the most recent ~15-20 Anthropic research papers/posts — alignment research, evaluations, benchmarks, interpretability, the Anthropic Institute, the Anthropic Economic Index. Auto-refreshed every 30 minutes from anthropic.com/research. Use when the user asks: \"any recent Anthropic research on X?\", \"is there a paper on Y?\". Skip: production model docs (use anthropic-api etc.); deep paper content (digest only — Claude WebFetches the paper for depth)."
  fi

  {
    echo "---"
    echo "name: anthropic-pulse-$SLUG"
    echo "description: |"
    # Wrap at 78 cols, prefix every line with 2 spaces (YAML block scalar)
    printf '%s' "$FRONTMATTER_DESC" | fold -s -w 78 | awk '{print "  " $0}'
    echo "source: $SOURCE_URL"
    echo "---"
    echo ""
    echo "# Anthropic — Recent $TITLE"
    echo ""
    echo "> *Auto-refreshed every 30 minutes.* This is a rolling digest of the"
    echo "> most recent items from [$SOURCE_URL]($SOURCE_URL). For the full"
    echo "> body of any item, WebFetch its URL — that's the design."
    echo ""
    echo "**Last refreshed**: $TODAY"
    echo ""
    echo "| # | Date | Category | Title | Link |"
    echo "|---|---|---|---|---|"
    jq -r --arg today "$TODAY" '
      to_entries[]
      | .key as $i
      | .value
      | "| \($i + 1) | \(.date // "—") | \(.category // "—") | **\(.title)** | [open](\(.url)) |"
    ' "$JSON_FILE"
    echo ""
    echo "## How to use this digest"
    echo ""
    if [[ "$SLUG" == "news" ]]; then
      echo "1. **\"Did X just launch?\"** — scan the date column; latest items appear within ~30 min of going live."
      echo "2. **\"What's Anthropic's recent thinking on Y?\"** — scan titles; for depth, WebFetch the linked URL."
      echo "3. **Looking for OLDER items** — anthropic.com/news has the full archive; this digest only carries the most recent."
    else
      echo "1. **\"Any recent research on X?\"** — scan titles for keywords; for the paper's abstract / methods / findings, WebFetch the URL."
      echo "2. **Long-term lineage (interpretability, alignment, scalable oversight)** — this digest only carries recent items; older foundational work lives at [anthropic.com/research](https://www.anthropic.com/research)."
    fi
    echo ""
    echo "---"
    echo ""
    echo "*Auto-updated every 30 minutes from $SOURCE_URL. If a digest entry"
    echo "doesn't answer the question, WebFetch the linked URL.*"
  } > "$OUT_FILE"

  echo "  rendered: $OUT_FILE"
}

render_surface "News" "https://www.anthropic.com/news" "$CACHE_DIR/news.json" "$SKILL_ROOT/SKILL-news.md" "news"
render_surface "Research" "https://www.anthropic.com/research" "$CACHE_DIR/research.json" "$SKILL_ROOT/SKILL-research.md" "research"

# ---------------------------------------------------------------------------
# Update state.json
# ---------------------------------------------------------------------------
STATE_FILE="$SKILL_ROOT/state.json"
jq --argjson news_count "$NEWS_COUNT" \
   --argjson res_count "$RES_COUNT" \
   --arg now "$NOW" \
   '.pulse = { newsItemsTracked: $news_count, researchItemsTracked: $res_count, lastFetchedAt: $now } | .lastUpdated = $now' \
   "$STATE_FILE" > /tmp/_state.json && mv /tmp/_state.json "$STATE_FILE"

echo ""
echo "============================================"
echo "  anthropic-pulse refresh complete"
echo "============================================"
echo "  news items:     $NEWS_COUNT"
echo "  research items: $RES_COUNT"
echo "  state updated:  $NOW"
echo "  cache dir:      $CACHE_DIR"
echo ""
echo "Next: review skills/anthropic-pulse/SKILL-{news,research}.md"
echo "      and commit if the rendered diff looks correct."
