#!/bin/bash
set -euo pipefail

REPO="yiningz308-prog/codex-display-pro-downloads"
ASSET="CodexDisplayPro-macOS-arm64.zip"
DOWNLOAD_BASE="https://github.com/$REPO/releases/latest/download"
INSTALL_DIR="${HOME}/Applications"
APP_NAME="Codex Display Pro.app"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "正在下载 Codex Display…"
CACHE_BUST="$(date +%s)"
curl --fail --location --retry 3 --silent --show-error "$DOWNLOAD_BASE/$ASSET?cb=$CACHE_BUST" --output "$TMP_DIR/$ASSET"
curl --fail --location --retry 3 --silent --show-error "$DOWNLOAD_BASE/$ASSET.sha256?cb=$CACHE_BUST" --output "$TMP_DIR/$ASSET.sha256"

EXPECTED="$(awk '{print $1}' "$TMP_DIR/$ASSET.sha256")"
ACTUAL="$(shasum -a 256 "$TMP_DIR/$ASSET" | awk '{print $1}')"
if [[ "$EXPECTED" != "$ACTUAL" ]]; then
  echo "校验失败，安装已取消。" >&2
  exit 1
fi

ditto -x -k "$TMP_DIR/$ASSET" "$TMP_DIR/unpacked"
mkdir -p "$INSTALL_DIR"
pkill -x CodexQuotaBar 2>/dev/null || true
rm -rf "$INSTALL_DIR/$APP_NAME"
ditto "$TMP_DIR/unpacked/$APP_NAME" "$INSTALL_DIR/$APP_NAME"
xattr -dr com.apple.quarantine "$INSTALL_DIR/$APP_NAME" 2>/dev/null || true
open "$INSTALL_DIR/$APP_NAME"

echo "安装完成：$INSTALL_DIR/$APP_NAME"
