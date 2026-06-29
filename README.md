# driftfire-app.github.io

The public website and **support / issue tracker** for **Driftfire** — a two-player, hot-seat space
duel through a drifting asteroid field.

- 🌐 **Site:** https://driftfire-app.github.io/ — privacy policy + support
- 🐞 **Found a bug or have an idea?** [Open an issue](https://github.com/driftfire-app/driftfire-app.github.io/issues/new/choose)
- ✉️ driftfire.app@gmail.com

The game's source code lives in a separate, private repository. This repo only hosts the
public-facing site (served via **GitHub Pages**) and the community issue tracker.

## Structure

| File | Purpose |
| --- | --- |
| `index.html` | Landing page |
| `privacy.html` | Privacy policy (Apple **Privacy Policy URL**) |
| `support.html` | Support page (Apple **Support URL**) |
| `assets/hero.png` | App-icon artwork |
| `.github/ISSUE_TEMPLATE/` | Bug report + feature request templates |

## Updating assets (cache-busting)

GitHub Pages caches static assets by **filename**, so editing `hero.png` / `style.css` / a font in
place can leave visitors (and the CDN) on the **old** version. When you change a committed asset,
**bump the `?v=N` query** on its references in the HTML (and CSS `@font-face`) — a new URL forces
browsers and the CDN to refetch. (Bumping the number is the whole trick; any new value works.)

## Custom domain (later)

When `driftfire.app` is registered, add it under **Settings → Pages → Custom domain** (and a `CNAME`
file). GitHub Pages provisions HTTPS automatically — no other hosting needed.
