#!/usr/bin/env bash
set -euo pipefail

PACKAGE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$PACKAGE_DIR/.build/CaptureImage.app"
DESKTOP_LINK="$HOME/Desktop/CaptureImage"

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Library/Developer/CommandLineTools}"

bash "$PACKAGE_DIR/scripts/build-app.sh"

pkill -x CaptureImage 2>/dev/null || true
ln -sfn "$APP_DIR" "$DESKTOP_LINK"
open "$APP_DIR"

echo "Opened $APP_DIR"
echo "Desktop shortcut points to $APP_DIR"
