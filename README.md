# craft-boilerplate

Conventions, templates, and Tailwind 4 setup for new Craft CMS 5 projects.

## Install

After `composer create-project craftcms/craft myproject` and `php craft install`, from the project root:

```bash
curl -fsSL https://raw.githubusercontent.com/lewisjenkins/craft-boilerplate/main/install.sh | bash
```

This overlays `src/`, `templates/`, `package.json`, and `CLAUDE.md`, then runs `npm install` and `npm run css`. The new project is ready to develop against — visit `/styleguide` in dev to see the prose system rendered.

## What's inside

- **`src/css/`** — Tailwind 4 CLI setup, layout system, vendored prose module, project design tokens.
- **`templates/`** — Base layout, header/footer chrome, 404, prose styleguide demo.
- **`CLAUDE.md`** — Architectural conventions (Tailwind config, layout cap, prose module rules).

## Development of the boilerplate itself

This repo doubles as a working Craft install for testing. The `.gitignore` whitelists only the boilerplate-relevant files; everything else (vendor, node_modules, Craft scaffolding, build output) stays untracked.

To iterate: edit files, `npm run css:dev` to see changes locally, push to publish.
