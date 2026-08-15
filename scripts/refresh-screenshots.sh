#!/usr/bin/env bash
# Refresh the home-page gameplay screenshots (index.html "See it in action") from the game repo.
#
# The store screenshots are GENERATED in the game repo (driftfire) — store/play/scripts/capture.sh
# renders them, and they are committed there as large 1080x1920 PNGs sized for the Play/App Store
# consoles. This site wants the opposite: a few small, display-sized WebPs. This script is the ONE
# step that keeps the site's copies in sync with the game repo, so they can't silently drift when
# the store set is regenerated. Mirrors scripts/render-asteroid-gallery.sh in the game repo.
#
# Usage:
#   scripts/refresh-screenshots.sh [PATH_TO_GAME_REPO]
#   GAME_REPO=/path/to/driftfire scripts/refresh-screenshots.sh
#
# PATH_TO_GAME_REPO is a checkout of driftfire (the game repo) on the branch/commit whose
# screenshots you want — normally its origin/main. Defaults to $GAME_REPO, else a sibling
# ../driftfire. Needs: cwebp (Google WebP tools: `brew install webp`).
#
# CURATION: only the marketing-worthy shots are published (brand + core gameplay + an action beat).
# The store set also has 04-how-to-play, 05-power-up-guide, and 06-settings — text-heavy guide
# screens and a weak settings shot that the marketing page's prose and terrain gallery already
# cover. To change what's shown, edit SHOTS below AND the <img> list in index.html.
set -euo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
GAME_REPO="${1:-${GAME_REPO:-$HERE/../driftfire}}"
SRC_DIR="$GAME_REPO/store/play/assets/screenshots/phone"
OUT_DIR="$HERE/assets/screenshots"

# The curated subset, in display order. (Filenames are the game repo's store screenshot names.)
SHOTS=(01-menu 02-battle-vs-ai 03-beam-strike)

WIDTH=540   # display width; source PNGs are 1080 wide, so this is a clean half-res downscale
QUALITY=80

command -v cwebp >/dev/null || { echo "cwebp not found — install it (brew install webp)" >&2; exit 1; }
[ -d "$SRC_DIR" ] || { echo "Game screenshots not found at: $SRC_DIR" >&2
  echo "Pass the game repo path: scripts/refresh-screenshots.sh /path/to/driftfire" >&2; exit 1; }

mkdir -p "$OUT_DIR"
echo "Source: $SRC_DIR"
echo "Output: $OUT_DIR  (WebP, ${WIDTH}px wide, q${QUALITY})"
for name in "${SHOTS[@]}"; do
  src="$SRC_DIR/$name.png"
  [ -f "$src" ] || { echo "  MISSING: $src" >&2; exit 1; }
  cwebp -quiet -q "$QUALITY" -resize "$WIDTH" 0 "$src" -o "$OUT_DIR/$name.webp"
  echo "  $name.webp  $(du -h "$OUT_DIR/$name.webp" | cut -f1)"
done
echo "Done. Review 'git diff', then commit assets/screenshots/*.webp."
