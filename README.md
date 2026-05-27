# craft-boilerplate

Conventions, templates, and Tailwind 4 setup for new Craft CMS 5 projects.

## Install

```bash
composer create-project craftcms/craft .
php craft install
curl -fsSL https://raw.githubusercontent.com/lewisjenkins/craft-boilerplate/main/install.sh | bash
```

The final command overlays `src/`, `templates/`, `package.json`, and `web/dist/fonts/` (self-hosted woff2 files), then runs `npm install` and `npm run css`. install.sh self-deletes on success. The new project is ready to develop against — navigate to `/kitchen-sink` to see the typography system rendered (light and dark side-by-side).

## What's inside

- **`src/css/`** — Tailwind 4 CLI setup. Modules:
  - `layout.css` — fluid root + `.contain` + single `sm:` breakpoint, all on a 1536px cap
  - `fonts.css` — self-hosted `@font-face` rules (Work Sans, Material Symbols subset)
  - `nice.css` — typography module (`.nice`, with `.nice-sm/lg/xl/-white/-lists` variants)
  - `flow.css` — vertical-rhythm module (`.flow`)
  - `highlight.css` — translucent inline-text chip (`.highlight`, `.highlight-parent`)
  - `button.css` — uppercase CTA-style `.btn` with optional inline icon
  - `design.css` — project tokens: brand palette, semantic-status colours, per-font content-area
- **`templates/`** — Base layout (with font preloads + inlined CSS), header/footer chrome, 404, kitchen-sink demo, index placeholder.
- **`web/dist/fonts/`** — woff2 font files referenced by `fonts.css` and preloaded by `base.twig`.

`CLAUDE.md` documents this repo's own structure (install flow, whitelist `.gitignore`) and isn't copied into consuming projects. `CLAUDE.dist.md` holds the architectural conventions (Tailwind 4 setup, `.nice` / `.flow`, image macro, design defaults) — `install.sh` drops it into new projects as their `CLAUDE.md`, but only if one doesn't already exist.

## Development of the boilerplate itself

This repo doubles as a working Craft install for testing. The `.gitignore` whitelists only the boilerplate-relevant files; everything else (vendor, node_modules, Craft scaffolding, build output) stays untracked.

To iterate: edit files, `npm run css:dev` to see changes locally, push to publish.
