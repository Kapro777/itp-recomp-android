#!/bin/bash
# macOS release disk image: build/dist/ITPRecomp-<release tag>-macOS.dmg holding "ITPRecomp.app" next to an
# Applications shortcut (drag the app onto it to install - how Mac users expect to install). Run after `make app`.
set -e
cd "$(dirname "$0")/.."
APP="build/ITPRecomp.app"
[ -d "$APP" ] || { echo "no $APP - run make app first" >&2; exit 1; }
VERSION=$(sed -n 's/^#define ITPRECOMP_VERSION "\(.*\)"/\1/p' runtime/ui/launcher.mm)  # (the release tag)
OUT="build/dist/ITPRecomp-$VERSION-macOS.dmg"
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT
ditto "$APP" "$STAGE/ITPRecomp.app"
ln -s /Applications "$STAGE/Applications"
mkdir -p build/dist
rm -f "$OUT"
hdiutil create -volname "ITPRecomp $VERSION" -srcfolder "$STAGE" -fs HFS+ -format UDZO -imagekey zlib-level=9 \
    -ov "$OUT" >/dev/null
echo "$OUT ($(du -h "$OUT" | cut -f1))"
