# craft-boilerplate

Conventions, templates, and Tailwind 4 setup for new Craft CMS 5 projects.

## Install

```bash
composer create-project craftcms/craft .
php craft install
curl -fsSL https://raw.githubusercontent.com/lewisjenkins/craft-boilerplate/main/install.sh | bash
```

The final command overlays `src/`, `templates/`, `package.json`, and `CLAUDE.md`, then runs `npm install` and `npm run css`. The new project is ready to develop against — visit `/kitchen-sink` in dev to see the typography system rendered (light and dark side-by-side).

## What's inside

- **`src/css/`** — Tailwind 4 CLI setup, layout system, typography module (`.nice`), vertical-rhythm module (`.flow`), project design tokens.
- **`templates/`** — Base layout, header/footer chrome, 404, kitchen-sink demo.
- **`CLAUDE.md`** — Architectural conventions (Tailwind config, layout cap, `.nice`/`.flow` module rules).

## Development of the boilerplate itself

This repo doubles as a working Craft install for testing. The `.gitignore` whitelists only the boilerplate-relevant files; everything else (vendor, node_modules, Craft scaffolding, build output) stays untracked.

To iterate: edit files, `npm run css:dev` to see changes locally, push to publish.
