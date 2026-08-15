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
| `assets/screenshots/` | Home-page gameplay screenshots (generated — see below) |
| `scripts/refresh-screenshots.sh` | Regenerates `assets/screenshots/` from the game repo |
| `.github/ISSUE_TEMPLATE/` | Bug report + feature request templates |

## Updating assets (cache-busting)

GitHub Pages caches static assets by **filename**, so editing `hero.png` / `style.css` / a font in
place can leave visitors (and the CDN) on the **old** version. When you change a committed asset,
**bump the `?v=N` query** on its references in the HTML (and CSS `@font-face`) — a new URL forces
browsers and the CDN to refetch. (Bumping the number is the whole trick; any new value works.)

## Refreshing the gameplay screenshots

The home-page screenshots (`index.html` → "See it in action") are **generated from the game repo**,
not hand-copied. The game repo (`driftfire`) renders the Play/App Store screenshots as large
1080×1920 PNGs; this site publishes a curated few of them as small, display-sized WebP. One command
rebuilds the site's copies so they can't silently drift when the store set is regenerated:

```sh
scripts/refresh-screenshots.sh /path/to/driftfire   # a checkout of the game repo (its origin/main)
```

It reads `store/play/assets/screenshots/phone/*.png` from the game repo, downscales to 540px-wide
WebP, and writes `assets/screenshots/*.webp`. Needs [`cwebp`](https://developers.google.com/speed/webp/download)
(`brew install webp`). Which shots are published — and their order — is the `SHOTS` list in the
script; changing it means editing both the script **and** the `<img>` list in `index.html`. The
WebP files are new filenames when they change, so they don't need the `?v=` cache-buster; a shot
kept at the same name after a re-render would (bump `?v=` on its `<img>` in `index.html`).

## Custom domain (later)

When `driftfire.app` is registered, add it under **Settings → Pages → Custom domain** (and a `CNAME`
file). GitHub Pages provisions HTTPS automatically — no other hosting needed.
