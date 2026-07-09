#!/usr/bin/env bash
set -euo pipefail

PACKAGE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$PACKAGE_DIR/.build/CaptureImage.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

export CLANG_MODULE_CACHE_PATH="${CLANG_MODULE_CACHE_PATH:-$PACKAGE_DIR/.build/clang-module-cache}"
swift build -c release --package-path "$PACKAGE_DIR"

rm -rf "$APP_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"
cp "$PACKAGE_DIR/.build/release/CaptureImage" "$MACOS_DIR/CaptureImage"
cp "$PACKAGE_DIR/Packaging/Info.plist" "$CONTENTS_DIR/Info.plist"

echo "Built $APP_DIR"
