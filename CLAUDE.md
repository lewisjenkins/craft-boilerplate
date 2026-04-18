# CLAUDE.md

Guidance for Claude Code working in this repository. This is the **canonical Craft CMS 5 boilerplate** for new projects — it doubles as a working Craft install (for testing) and the source of truth installed onto fresh projects via `install.sh`. The `.gitignore` uses a whitelist pattern so only the boilerplate-relevant files are tracked; everything else (Composer, npm, Craft scaffolding, build output) stays local-only.

## Project layout

```
install.sh           — overlay installer; clones this repo onto a fresh Craft install
README.md            — public-facing repo readme + install instructions
src/css/
    tailwind.css     — entry/manifest: tailwindcss import, @import the rest, @source globs
    layout.css       — layout system: breakpoint, .contain, fluid root
    typography.css   — vendored .prose module (DO NOT EDIT — see below)
    design.css       — project design tokens (fonts, colours) + .prose variants
templates/
    _layouts/
        base.twig    — base layout: fonts, build.css link, skip link, orchestrates chrome + main
        header.twig  — site header landmark
        footer.twig  — site footer landmark
    index.twig       — homepage; redirects to /styleguide in dev, empty in prod
    styleguide.twig  — prose system showcase (the demo content)
    404.twig         — page-not-found template
web/dist/build.css   — compiled output (served via Craft's {% css %} tag from _layouts/base.twig)
```

## Build

```bash
npm run css        # one-shot, minified
npm run css:dev    # watch
```

Output goes to `web/dist/build.css`. The Twig layout links it as `/dist/build.css`.

---

## ⚠ PRESERVE — architectural conventions

These are fixed. Changes here should be rare and deliberate.

### Tailwind 4 (not Tailwind 3)

- Config is declarative CSS in `src/css/tailwind.css` — `@theme { … }`, `@utility … { … }`, `@source …`. **No `tailwind.config.js`.**
- Source scanning is opt-in: `@import "tailwindcss" source(none)` disables auto-scan. Two `@source` directives add the templates and the `src/` CSS files explicitly. Add new source directories (JS, additional templates) to that list.
- The `@source "../../src/**/*.{css}"` line also makes `--watch` mode pick up changes to `@import`'d files like `design.css` and `typography.css` — `@source` registers files with both the scanner *and* the watcher. Without it, only `tailwind.css` itself triggers rebuilds.
- `typography.css` and `design.css` are pulled in via `@import` *inside* `tailwind.css`, not loaded separately by the browser. This matters: Tailwind scans imported CSS for `var(--color-*)` references and auto-emits the matching palette tokens. Reference any default-palette colour from `design.css` and it just works — no safelist needed. (The boilerplate's `@source inline(…)` escape hatch is only required when `design.css` is loaded via a separate `<link>` tag, as in the original browser-build setup.)

### Layout system — three interlocking rules, one cap

All three live in `layout.css` and use **1536px** as the layout cap. Change one, update the others.

1. **Fluid root font-size** — `1rem` scales from ~10.8px at 768px to 21.6px at 1536px, then locks. Everything sized in `rem` or `em` scales for free. Hardcoded in `@media` blocks because `@media` can't use `var()`.
2. **`.contain` utility** — outer cap at 1536px. Use on full-width sections. Reading-measure containers inside use Tailwind `max-w-*` (which rescale with the fluid root).
3. **Single `sm: 768px` breakpoint** — `--breakpoint-*: initial` wipes the defaults. Below 768px, phone layout (use `sm:` utilities). Above 768px, fluid zone (no further breakpoints). Above 1536px, layout is locked.

**There is a deliberate cliff at 768px.** Below the breakpoint, `1rem` is the browser default (≈16px). At exactly 768px, `1rem` snaps to 10.8px and then scales up. Type and spacing visibly shrink as the viewport *grows* past 768px. This is intentional — phone and fluid-zone layouts are two separate designs sharing a boundary, not one continuous layout. Do not remove the cliff.

**Do not reach for `md:` / `lg:` / `xl:` utilities.** They don't exist here. Use `sm:` for the phone/non-phone split, and trust `rem`/`em` to scale in the fluid zone.

### `.prose` module for long-form content

Any block of CMS-rendered or long-form text goes inside `<div class="prose">`. This is how heading hierarchy, list styling, blockquote treatment, table borders, code blocks, and link styling all stay consistent. Don't re-invent these element treatments per page.

In Twig templates, the typical pattern is:

```twig
<div class="prose">
    {{ entry.body|raw }}
</div>
```

**Lead paragraphs** use `<p class="lead">` inside `.prose`. The `.lead` class lives in `typography.css` (so it's part of the vendored module, not a per-project addition) and exposes `--prose-lead-*` knobs (`size`, `line-height`, `color`, `margin`) for project overrides via `design.css`.

### `typography.css` is vendored — do not edit for per-project changes

Every knob is exposed as a `--prose-*` custom property. Override those in `design.css`. Editing `typography.css` means versioning the module itself and porting the change back to every project that uses it. Do not move core prose rules into `design.css` either — keep `typography.css` portable.

### File layering (do not blur)

| Layer | File | What goes here |
|---|---|---|
| Entry/manifest | `src/css/tailwind.css` | Tailwind import, `@import` the other files, `@source` globs |
| Layout system | `src/css/layout.css` (`@theme`, `@utility`, `@layer base`) | Breakpoint, `.contain`, fluid root — all interlocking on 1536px |
| Portable prose module | `src/css/typography.css` | Core `.prose` rules — same across projects (vendored) |
| Project design tokens + variants | `src/css/design.css` (`@theme`, `:root`, `.prose-*`) | Fonts, brand colours, `--prose-*` mappings, prose colour variants |

New typography variants belong in `design.css`, following the `.prose-white` pattern — override `--prose-*` properties, never re-declare selectors from `typography.css`.

### Template chrome conventions

`_layouts/base.twig` establishes the document outline that every page extends from:

1. **Skip link first.** A `<a href="#main">Skip to main content</a>` is the first focusable element — invisible by default (`sr-only`), visible top-left when keyboard-focused. Required for keyboard accessibility once nav exists.
2. **`<main id="main" tabindex="-1">` wraps page content.** The `tabindex="-1"` lets focus actually land on `<main>` when the skip link is activated. The `id` matches the skip link target. Don't change either without changing both.
3. **Chrome via `_layouts/header.twig` and `_layouts/footer.twig`.** They live in `_layouts/` (not `_partials/`) because they're page-chrome that the layout orchestrates, not reusable content fragments. `_partials/` is reserved for content/component partials (icons, cards, image macros) when those exist.
4. **`index.twig` is intentionally minimal** — it's the production homepage placeholder. In dev, it redirects to `/styleguide` (`{% if craft.app.config.general.devMode %}{% redirect 'styleguide' 302 %}{% endif %}`) so a fresh install lands on the demo. Remove the conditional once real homepage content exists.

---

## ✎ REPLACE FREELY — design defaults

- **Fonts.** Currently Fraunces (display) + Inter (body). Swap the Google Fonts `<link>` in `templates/_layouts/base.twig` and the `--font-sans` / `--font-display` values in `design.css`'s `@theme`.
- **Colours.** `--prose-color-link: var(--color-blue-400)` and a `.prose-white` variant on slate-* + white. Change the `var(--color-*)` references in `design.css` freely — Tailwind picks them up automatically. For brand colours, declare them in `design.css`'s `@theme` so they become both CSS variables and utility classes.
- **Scale ratio.** `--prose-ratio` defaults to `1.25` (Major Third). Override on `:root` in `design.css`.
- **Sample content in `templates/styleguide.twig`.** Demo only — useful for spotting regressions to the prose system, not a starting point for production templates. Delete or move once real components are built. Keep the `<section>` + `<div class="contain …">` + inner `max-w-*` container pattern when building new sections.
- **New sections / components.** Build with Tailwind utilities directly, or register recurring patterns as `@utility` in `tailwind.css`.
