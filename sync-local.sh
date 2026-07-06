#!/usr/bin/env bash
#
# Sync the shared parts of this repo (index.html + bracket data + actual results)
# into the sibling "world-cup-local" repo, then commit & push it.
#
# The local repo keeps its OWN brackets/manifest.json (the local roster that
# includes Julius, Max, Heloise), so manifest files are never overwritten.
#
# Usage: ./sync-local.sh ["optional commit message"]

set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="${WORLD_CUP_LOCAL_DIR:-$SRC/../world-cup-local}"

if [ ! -d "$DEST/.git" ]; then
  echo "Error: local repo not found at: $DEST" >&2
  echo "Set WORLD_CUP_LOCAL_DIR to override its location." >&2
  exit 1
fi

echo "Syncing $SRC -> $DEST"

# 1) App shell + assets
cp "$SRC/index.html" "$DEST/index.html"
if [ -d "$SRC/assets" ]; then
  mkdir -p "$DEST/assets"
  cp -R "$SRC/assets/." "$DEST/assets/"
fi

# 2) Bracket data + actual results (skip manifest files; they differ per site)
mkdir -p "$DEST/brackets"
for f in "$SRC"/brackets/*; do
  name="$(basename "$f")"
  case "$name" in
    manifest.json|manifest.local.json) continue ;;      # keep local roster manifest
    heloise) cp "$f" "$DEST/brackets/Heloise" ;;         # case fix for GitHub Pages
    *) cp "$f" "$DEST/brackets/$name" ;;
  esac
done

# 3) Commit & push if anything changed
cd "$DEST"
if [ -z "$(git status --porcelain)" ]; then
  echo "No changes to sync."
  exit 0
fi

MSG="${1:-Sync from world-cup ($(date +%Y-%m-%d\ %H:%M))}"
git add -A
git commit -q -m "$MSG"
git push -q origin main
echo "Pushed to world-cup-local: $MSG"
echo "Live: https://etr217.github.io/world-cup-local/"
