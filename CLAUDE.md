# CLAUDE.md

Guidance for Claude Code working in this repository. This is the **canonical Craft CMS 5 boilerplate** for new projects — it doubles as a working Craft install (for testing) and the source of truth installed onto fresh projects via `install.sh`. The `.gitignore` uses a whitelist pattern so only the boilerplate-relevant files are tracked; everything else (Composer, npm, Craft scaffolding, build output) stays local-only.

## Project layout

```
install.sh              — overlay installer; clones this repo onto a fresh Craft install
README.md               — public-facing repo readme + install instructions
src/css/
    tailwind.css        — entry/manifest: tailwindcss import, @imports, @source globs
    layout.css          — layout system: breakpoint, .contain, fluid root
    fonts.css           — self-hosted @font-face declarations (Work Sans, Prompt, Quicksand, Material Symbols)
    nice.css            — typography module (.nice, .nice-sm/lg/xl variants)
    flow.css             — vertical rhythm module (.flow)
    highlight.css        — inline text highlight chip (.highlight)
    button.css           — CTA-style .btn (uppercase, brand colour, optional inline icon)
    design.css           — project tokens (fonts, colours, brand palette, per-font content-area) + .nice-white variant
templates/
    _layouts/
        base.twig       — base layout: inlines build.css, skip link, orchestrates chrome + main
        header.twig     — site header landmark
        footer.twig     — site footer landmark
    _build.css          — symlink → ../web/dist/build.css (so Twig's source() can read the build output)
    index.twig          — homepage; redirects to /kitchen-sink in dev, empty in prod
    kitchen-sink.twig   — typography showcase (light + dark side-by-side)
    404.twig            — page-not-found template
web/dist/
    build.css           — compiled output (inlined into HTML head via {% css %}{{ source('_build.css') }}{% endcss %})
    fonts/              — self-hosted woff2 font files referenced by fonts.css
```

## Build

```bash
npm run css        # one-shot, minified
npm run css:dev    # watch
```

Output goes to `web/dist/build.css`. `base.twig` inlines its contents into the HTML head via the `templates/_build.css` symlink — eliminating the render-blocking external CSS request. Two consequences worth knowing:

- **CSP**: a strict `style-src` policy will block the inline `<style>`. Projects with a tight CSP need `'unsafe-inline'` on `style-src`, or a nonce/hash-based rule.
- **Symlink fragility**: `templates/_build.css → ../web/dist/build.css` works through git (symlinks are stored portably) and through normal deploy tools, but some pipelines (older rsync configs, certain zip-based deploys, Windows checkouts) don't preserve symlinks. If `source('_build.css')` can't resolve, Twig throws a fatal — there's no graceful no-CSS fallback.

---

## ⚠ PRESERVE — architectural conventions

These are fixed. Changes here should be rare and deliberate.

### Tailwind 4 (not Tailwind 3)

- Config is declarative CSS in `src/css/tailwind.css` — `@theme { … }`, `@utility … { … }`, `@source …`. **No `tailwind.config.js`.**
- Source scanning is opt-in: `@import "tailwindcss" source(none)` disables auto-scan. Two `@source` directives add the templates and the `src/` CSS files explicitly. Add new source directories (JS, additional templates) to that list.
- The `@source "../../src/**/*.css"` line also makes `--watch` mode pick up changes to `@import`'d files like `nice.css`, `flow.css`, and `design.css` — `@source` registers files with both the scanner *and* the watcher. Without it, only `tailwind.css` itself triggers rebuilds.
- All CSS files are pulled in via `@import` *inside* `tailwind.css`, not loaded separately by the browser. This matters: Tailwind scans imported CSS for `var(--color-*)` references and auto-emits the matching palette tokens. Reference any default-palette colour from `design.css` and it just works — no safelist needed.

### Layout system — three interlocking rules, one cap

All three live in `layout.css` and use **1536px** as the layout cap. Change one, update the others.

1. **Fluid root font-size** — `1rem` scales from ~10.8px at 768px to 21.6px at 1536px, then locks. Everything sized in `rem` or `em` scales for free. Hardcoded in `@media` blocks because `@media` can't use `var()`.
2. **`.contain` utility** — outer cap at 1536px. Use on full-width sections. Reading-measure containers inside use Tailwind `max-w-*` (which rescale with the fluid root).
3. **Single `sm: 768px` breakpoint** — `--breakpoint-*: initial` wipes the defaults. Below 768px, phone layout (use `sm:` utilities). Above 768px, fluid zone (no further breakpoints). Above 1536px, layout is locked.

**There is a deliberate cliff at 768px.** Below the breakpoint, `1rem` is the browser default (≈16px). At exactly 768px, `1rem` snaps to 10.8px and then scales up. Type and spacing visibly shrink as the viewport *grows* past 768px. This is intentional — phone and fluid-zone layouts are two separate designs sharing a boundary, not one continuous layout. Do not remove the cliff.

**Do not reach for `md:` / `lg:` / `xl:` utilities.** They don't exist here. Use `sm:` for the phone/non-phone split, and trust `rem`/`em` to scale in the fluid zone.

### Typography: `.nice` + `.flow` (two modules, composable)

The typography system is split into two concerns that can be used independently or together:

- **`.nice`** (`nice.css`) — element typography: font family, sizes, line-heights, colours, link treatment, blockquote border, code/kbd treatment, table borders, etc. No vertical spacing. List styling (ul/ol/dl) is opt-in via `.nice-lists` — see below.
- **`.flow`** (`flow.css`) — vertical rhythm: direct children sit `--flow-spacing` apart via flex + gap; headings get extra top-margin when they follow another element; block elements (blockquote, pre, hr, table, figure) get additional breathing room on both sides.

The typical usage for long-form / CMS-rendered content is all three together:

```twig
<div class="nice nice-lists flow">
    {{ entry.body|raw }}
</div>
```

For hand-authored sections where you're managing rhythm yourself (flex+gap containers, landing pages), use `.nice` alone and drive spacing with Tailwind utilities on the parent.

**`.nice-lists` is opt-in by design.** Plain `.nice` leaves `<ul>`, `<ol>`, and `<dl>` unstyled — no markers, no indent, no flex rhythm — so you can use semantic lists for nav, breadcrumbs, card grids, etc. without override-fighting. Add `.nice-lists` only when the lists inside are prose (CMS body content, kitchen-sink demo).

**Lead paragraphs** use `<p class="lead">` inside `.nice`. Size defaults to `--text-xl`, colour to `--nice-lead-color`. Every knob in the module is exposed as `var(--nice-*, default)` at the use site — override at `:root` in `design.css` for global, or inside a variant class for scoped.

**Size variants** — `.nice-sm`, `.nice-lg`, `.nice-xl` remap `--nice-base`. Because `nice.css` redefines Tailwind's `--text-*` tokens as `em` values and derives heading sizes via `pow(var(--nice-ratio), …)`, everything inside — headings, lead, body, captions, list markers — rescales proportionally.

**Colour variants** — `.nice-white` is the built-in reversed-palette variant (see `design.css`). New variants follow the same pattern: override `--nice-color-*` tokens at the variant class, never re-declare selectors from `nice.css`.

### `nice.css`, `flow.css`, and `highlight.css` are modules — tune via tokens, not selectors

Every knob is exposed as a `--nice-*` / `--flow-*` / `--highlight-*` custom property with a fallback at the use site. Override those in `design.css` (`:root` for global, inside a variant class for scoped). Do not move core rules out of the module files into `design.css` — the module files stay focused on the rendering logic.

### Highlight component

`.highlight` (in `highlight.css`) is a translucent inline chip behind text — useful for white text on hero images or any pull-quote-ish prominence. It uses `box-decoration-break: clone` so the chip repeats cleanly across wrapped lines. Pair it with `.highlight-parent` on the surrounding block: the parent's line-height is set from `--content-area` (a font-bounding-box ratio per `.font-*` utility in `design.css`) plus `--highlight-py` (a per-font breathing-room nudge, also in `design.css`), and the chip inherits that line-height — so cloned chips on wrapped lines sit flush with no gap. Override `--highlight-bg` on the parent (cascades) or use a Tailwind `bg-*` utility on the span for non-default colour.

### Self-hosted fonts

`fonts.css` declares `@font-face` rules pointing at woff2 files in `web/dist/fonts/`. Variable fonts (Work Sans 100–900, Quicksand 300–700) cover their full weight range from a single file per subset. `unicode-range` subsetting means the browser only downloads the files it actually needs. Material Symbols Outlined is subsetted to the icons listed in the comment block at the top of that section — to add more icons, regenerate the subset via the Google Fonts API.

The `.gitignore` whitelists `web/dist/fonts/` specifically so the woff2 files travel with the boilerplate; everything else under `web/` (including `build.css`) stays local-only.

### File layering (do not blur)

| Layer | File | What goes here |
|---|---|---|
| Entry/manifest | `src/css/tailwind.css` | Tailwind import, `@import` the other files, `@source` globs |
| Layout system | `src/css/layout.css` (`@theme`, `@utility`, `@layer base`) | Breakpoint, `.contain`, fluid root — all interlocking on 1536px |
| Fonts | `src/css/fonts.css` | `@font-face` declarations + `.material-symbols-outlined` utility |
| Typography module | `src/css/nice.css` (`@layer components`) | `.nice` rules: element styling, no margins |
| Rhythm module | `src/css/flow.css` (`@layer components`) | `.flow` rules: vertical rhythm via flex + gap + additive margins |
| Highlight module | `src/css/highlight.css` (`@layer components`) | `.highlight` rule: inline translucent chip |
| Button module | `src/css/button.css` (`@layer components`) | `.btn` rule: uppercase CTA-style button, brand-coloured, optional inline icon nudge |
| Project tokens + variants | `src/css/design.css` (`@theme`, `:root`, `.nice-*`, `.font-*`) | Fonts, colour mappings, brand palette, per-font `--content-area` and `--highlight-py`, `--nice-*` / `--flow-*` overrides, colour variants |

New typography variants belong in `design.css`, following the `.nice-white` pattern — override `--nice-color-*` properties, never re-declare selectors from `nice.css`.

### Template chrome conventions

`_layouts/base.twig` establishes the document outline that every page extends from:

1. **Skip link first.** A `<a href="#main">Skip to main content</a>` is the first focusable element — invisible by default (`sr-only`), visible top-left when keyboard-focused. Required for keyboard accessibility once nav exists.
2. **`<main id="main" tabindex="-1">` wraps page content.** The `tabindex="-1"` lets focus actually land on `<main>` when the skip link is activated. The `id` matches the skip link target. Don't change either without changing both.
3. **Chrome via `_layouts/header.twig` and `_layouts/footer.twig`.** They live in `_layouts/` (not `_partials/`) because they're page-chrome that the layout orchestrates, not reusable content fragments. `_partials/` is reserved for content/component partials (icons, cards, image macros) when those exist.
4. **`index.twig` is intentionally minimal** — it's the production homepage placeholder. In dev, it redirects to `/kitchen-sink` (`{% if craft.app.config.general.devMode %}{% redirect 'kitchen-sink' 302 %}{% endif %}`) so a fresh install lands on the demo. Remove the conditional once real homepage content exists.

---

## ✎ REPLACE FREELY — design defaults

- **Fonts.** Self-hosted via `fonts.css`. Currently Work Sans (variable, body + display), Prompt 700 (`--font-hero-display`), Quicksand (variable, `--font-hero-sans`), and a Material Symbols subset. To swap fonts: add the woff2 files to `web/dist/fonts/`, add `@font-face` rules to `fonts.css`, update the `--font-*` values in `design.css`'s `@theme`, and update the `--content-area` value on the matching `.font-*` rule (measure via the DevTools snippet in `design.css`'s comment).
- **Colours.** `--nice-color-link: var(--color-blue-400)` by default. `.nice-white` variant inverts colour tokens for dark backgrounds. Change the `var(--color-*)` references in `design.css` freely — Tailwind picks them up automatically. Brand palette is declared in `design.css`'s `@theme`: `--color-primary`, `--color-secondary` (re-skin slots), `--color-success / -warning / -danger / -info` (semantic-status slots, ready for form validation, alerts, badges), `--color-button` and `--color-button-hover` (consumed by `.btn`). All `@theme` colours auto-emit Tailwind utility classes (`bg-primary`, `text-success`, etc.).
- **Scale ratio.** `--nice-ratio` defaults to `1.2` (Minor Third). Override on `:root` in `design.css` — the entire heading scale and line-height curve rescale together.
- **Lead treatment.** `--nice-lead-weight: 500` and `--nice-h1-weight: 900` are set in `design.css`'s `:root`. Per-heading `--nice-h<N>-weight` and `--nice-h<N>-size` knobs are wired up — override any individually without touching the module.
- **Sample content in `templates/kitchen-sink.twig`.** Demo only — useful for spotting regressions to the typography system (light and dark rendered side-by-side). Delete or move once real components are built. Keep the `<section>` + `<div class="contain …">` + inner `max-w-*` container pattern when building new sections.
- **New sections / components.** Build with Tailwind utilities directly, or register recurring patterns as `@utility` in `tailwind.css`.
