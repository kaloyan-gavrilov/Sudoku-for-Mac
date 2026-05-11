#!/bin/bash
# Build Sudoku.app — a double-clickable macOS bundle wrapping the SwiftPM executable.
set -euo pipefail

cd "$(dirname "$0")"

APP_NAME="Sudoku"
DIST_DIR="dist"
APP_DIR="${DIST_DIR}/${APP_NAME}.app"

echo "==> Cleaning previous build"
rm -rf "${APP_DIR}"
mkdir -p "${APP_DIR}/Contents/MacOS"
mkdir -p "${APP_DIR}/Contents/Resources"

echo "==> Building universal release binary (arm64 + x86_64)"
swift build -c release --arch arm64 --arch x86_64

# Locate the executable produced by SwiftPM.
BIN_PATH="$(swift build -c release --arch arm64 --arch x86_64 --show-bin-path)/${APP_NAME}"
if [[ ! -f "${BIN_PATH}" ]]; then
    # Fallback for single-arch builds.
    BIN_PATH="$(swift build -c release --show-bin-path)/${APP_NAME}"
fi

echo "==> Assembling app bundle"
cp "${BIN_PATH}" "${APP_DIR}/Contents/MacOS/${APP_NAME}"
cp "Resources/Info.plist" "${APP_DIR}/Contents/Info.plist"

echo "==> Ad-hoc codesigning"
codesign --force --deep --sign - "${APP_DIR}"

echo ""
echo "Done. Built: ${APP_DIR}"
echo "Open it with:  open ${APP_DIR}"
