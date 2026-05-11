#!/bin/bash
# Generates Resources/AppIcon.icns from scripts/make-icon.swift.
# Idempotent — safe to re-run after tweaking the Swift drawing.
set -euo pipefail

cd "$(dirname "$0")/.."

OUT_ICNS="Resources/AppIcon.icns"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

PNG="${TMP_DIR}/icon-1024.png"
ICONSET="${TMP_DIR}/AppIcon.iconset"
mkdir -p "${ICONSET}"

echo "==> Rendering 1024x1024 master PNG"
swift scripts/make-icon.swift "${PNG}"

echo "==> Generating iconset slices"
sips -z 16   16   "${PNG}" --out "${ICONSET}/icon_16x16.png"      >/dev/null
sips -z 32   32   "${PNG}" --out "${ICONSET}/icon_16x16@2x.png"   >/dev/null
sips -z 32   32   "${PNG}" --out "${ICONSET}/icon_32x32.png"      >/dev/null
sips -z 64   64   "${PNG}" --out "${ICONSET}/icon_32x32@2x.png"   >/dev/null
sips -z 128  128  "${PNG}" --out "${ICONSET}/icon_128x128.png"    >/dev/null
sips -z 256  256  "${PNG}" --out "${ICONSET}/icon_128x128@2x.png" >/dev/null
sips -z 256  256  "${PNG}" --out "${ICONSET}/icon_256x256.png"    >/dev/null
sips -z 512  512  "${PNG}" --out "${ICONSET}/icon_256x256@2x.png" >/dev/null
sips -z 512  512  "${PNG}" --out "${ICONSET}/icon_512x512.png"    >/dev/null
cp "${PNG}" "${ICONSET}/icon_512x512@2x.png"

echo "==> Packing AppIcon.icns"
mkdir -p Resources
iconutil -c icns "${ICONSET}" -o "${OUT_ICNS}"

echo "Done: ${OUT_ICNS}"
