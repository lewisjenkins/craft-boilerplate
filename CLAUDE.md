# CLAUDE.md

Guidance for Claude Code working *on* the **craft-boilerplate** repo itself — the canonical Craft CMS 5 boilerplate for new projects. It doubles as a working Craft install (for testing) and the source of truth installed onto fresh projects via `install.sh`.

> **For project / architectural conventions** — Tailwind 4 setup, layout system, typography modules (`.nice` / `.flow`), image macro, breadcrumbs partial, SEOmatic block pattern, design defaults, file layering — see [`CLAUDE.dist.md`](./CLAUDE.dist.md). That file is the canonical record for everything that survives into consuming projects, and is the file you should edit when adding or changing those conventions. This file (`CLAUDE.md`) only documents how the boilerplate itself is structured and distributed.

## Boilerplate-only files

```
install.sh              — overlay installer; clones this repo onto a fresh Craft install
CLAUDE.md               — this file (boilerplate-meta only)
CLAUDE.dist.md          — consuming-project CLAUDE.md (architectural conventions live here)
README.md               — public-facing repo readme + install instructions
```

Everything else (`src/`, `templates/`, `web/dist/fonts/`, `package.json`) is what gets overlaid onto consuming projects.

## Whitelist `.gitignore`

The `.gitignore` uses a whitelist pattern: only the boilerplate-relevant files are tracked. Everything else (Composer, npm, Craft scaffolding, build output) stays local-only — this repo doubles as a working Craft install for testing, but those files belong to the consuming project, not the boilerplate.

The one deliberate exception is `web/dist/fonts/`, which is whitelisted so the woff2 files travel with the boilerplate. `web/dist/build.css` is *not* tracked — both this repo and consuming projects build it via `npm run css`.

## `install.sh` mechanics

Run from a fresh Craft project root after `php craft install`. The script:

1. Sanity-checks it's in a Craft project root (looks for `craft` binary + `config/` + `templates/`).
2. Clones this repo into a tempdir (cleaned up on exit).
3. Overlays `src/`, `templates/`, `package.json`, and `web/dist/fonts/`.
4. Copies `CLAUDE.dist.md` to `CLAUDE.md` *only if* the project doesn't already have a `CLAUDE.md`.
5. Appends `/node_modules` to `.gitignore` if missing.
6. Installs SEOmatic via Composer (`nystudio107/craft-seomatic`) and runs `php craft plugin/install seomatic`.
7. Runs `npm install` + `npm run css`.
8. Self-deletes if invoked as a local file (no-op when piped via `curl … | bash`).

Things to know when editing the script:

- **CLAUDE.md is non-clobbering.** Existing project `CLAUDE.md` files are left alone — only the initial install gets the boilerplate version. This is deliberate: consuming projects accrue their own context over time.
- **SEOmatic install is non-interactive but assumes the DB is ready.** It must run after `php craft install`; there is no fallback if the DB isn't there.
- **The `.gitignore` append loop is idempotent.** Add new boilerplate-required ignore lines to the `for line in …` loop, not as bare `echo >> .gitignore`.

## Working on `CLAUDE.dist.md`

Edit `CLAUDE.dist.md` directly — that's the canonical doc for project / architectural conventions. There is **no** mirroring step: `CLAUDE.md` (this file) deliberately does not duplicate any of it. New PRESERVE conventions, new REPLACE FREELY knobs, new architectural notes all go into `CLAUDE.dist.md` only.

The trade-off: working on the boilerplate, you may want to load both files into context to see the full picture (boilerplate-meta + the conventions you're documenting). Most editing sessions only need one or the other.

## Testing locally

This repo is a working Craft install — visit `/kitchen-sink` in dev to exercise the typography system after CSS changes. `npm run css:dev` for watch mode. The site is reachable at the URL configured in `.env` (not committed).
