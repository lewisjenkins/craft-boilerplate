#!/usr/bin/env bash
#
# craft-boilerplate installer
# Overlays the boilerplate's src/, templates/, package.json, and
# web/dist/fonts/ onto a fresh Craft CMS install, drops in CLAUDE.dist.md
# as CLAUDE.md (only if one doesn't already exist), then builds the CSS.
# Run from the project root after `php craft install`.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/lewisjenkins/craft-boilerplate/main/install.sh | bash

set -euo pipefail

REPO="https://github.com/lewisjenkins/craft-boilerplate.git"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

# Sanity check: must be in a Craft project root
if [[ ! -f "craft" || ! -d "config" || ! -d "templates" ]]; then
    echo "✗ Run from a Craft project root (no 'craft' binary or 'config/' here)." >&2
    exit 1
fi

echo "→ Fetching boilerplate…"
git clone --quiet --depth 1 "$REPO" "$TMP"

echo "→ Overlaying files…"
cp -R "$TMP/src" .
cp -R "$TMP/templates/." templates/
cp "$TMP/package.json" .

# CLAUDE.dist.md is the consuming-project version of CLAUDE.md (boilerplate-meta
# stripped). The boilerplate's own CLAUDE.md is intentionally NOT copied — it
# documents this boilerplate's own architecture, not your project's.
# Don't clobber an existing CLAUDE.md if the project already has one.
if [[ -f CLAUDE.md ]]; then
    echo "  ↳ CLAUDE.md already exists — leaving it alone (boilerplate version: CLAUDE.dist.md in the repo)"
else
    cp "$TMP/CLAUDE.dist.md" CLAUDE.md
fi

# Self-hosted woff2 font files referenced by fonts.css and preloaded in base.twig.
mkdir -p web/dist/fonts
cp -R "$TMP/web/dist/fonts/." web/dist/fonts/

# Append boilerplate's required .gitignore lines (idempotent).
# Don't copy the boilerplate's own .gitignore — it's a whitelist for
# this repo's own tracking, not for new projects.
for line in '/node_modules'; do
    grep -qxF "$line" .gitignore 2>/dev/null || echo "$line" >> .gitignore
done

echo "→ Installing npm deps…"
npm install --silent

echo "→ Building CSS…"
npm run css --silent

echo ""
echo "✓ Boilerplate applied."
echo "  • Visit /kitchen-sink in dev to see the typography system"
echo "  • Run 'npm run css:dev' for watch mode"

# Self-delete when the script was run as a file in the project
# (e.g. `bash install.sh`). When piped via `curl … | bash`, BASH_SOURCE[0]
# isn't a real path so the test fails and this is a no-op.
[[ -f "${BASH_SOURCE[0]:-}" ]] && rm -- "${BASH_SOURCE[0]}"
