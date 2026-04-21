#!/usr/bin/env bash
#
# craft-boilerplate installer
# Overlays the boilerplate's src/, templates/, package.json, CLAUDE.md
# onto a fresh Craft CMS install. Run from the project root after
# `php craft install`.
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
cp "$TMP/CLAUDE.md" .
cp "$TMP/package.json" .

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
