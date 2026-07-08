#!/bin/bash
set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Target either a specific DMG passed as an argument, or default to the newly built one
DMG="$1"
if [ -z "$DMG" ]; then
    DMG=$(ls "$REPO_ROOT/builddir-x64"/EiskaltDC++-*.dmg 2>/dev/null | sort -V | tail -n1 || true)
fi

if [ -z "$DMG" ] || [ ! -f "$DMG" ]; then
    echo "Error: Could not find any DMG to deploy. Please build it first or pass the path to the DMG as an argument."
    exit 1
fi

echo "==> Deploying $DMG to /Applications..."
TARGET="/Applications/EiskaltDC++.app"

hdiutil attach "$DMG" -nobrowse -mountpoint /tmp/eiskalt_x64
trap 'hdiutil detach /tmp/eiskalt_x64 2>/dev/null || true' EXIT

# Suppress errors if not running
pkill -f "EiskaltDC\+\+.app/Contents/MacOS" || true

rm -rf "$TARGET"
cp -a "/tmp/eiskalt_x64/EiskaltDC++.app" "$TARGET"

# Clear any Gatekeeper quarantine attributes
xattr -cr "$TARGET"

echo "==> Success! Application deployed to $TARGET"
