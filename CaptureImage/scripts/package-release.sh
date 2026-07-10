#!/usr/bin/env bash
set -euo pipefail

VERSION="${1:?Usage: package-release.sh <version>}"
PACKAGE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$PACKAGE_DIR/.build/CaptureImage.app"
DIST_DIR="$PACKAGE_DIR/dist"
ARCHIVE="$DIST_DIR/CaptureImage-$VERSION.zip"

bash "$PACKAGE_DIR/scripts/build-app.sh"
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"
ditto -c -k --sequesterRsrc --keepParent "$APP_DIR" "$ARCHIVE"

echo "Built $ARCHIVE"
shasum -a 256 "$ARCHIVE"
