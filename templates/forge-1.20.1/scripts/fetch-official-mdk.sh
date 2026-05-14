#!/usr/bin/env bash
set -euo pipefail

VERSION="1.20.1-47.4.10"
SHA1_EXPECTED="31133abd261aa4d23672d1820db06ccec80326ad"
URL="https://maven.minecraftforge.net/net/minecraftforge/forge/${VERSION}/forge-${VERSION}-mdk.zip"
OUT_DIR="${1:-./_forge-mdk-${VERSION}}"
ZIP="${OUT_DIR}/forge-${VERSION}-mdk.zip"

mkdir -p "$OUT_DIR"
curl -L "$URL" -o "$ZIP"
SHA1_ACTUAL="$(sha1sum "$ZIP" | awk '{print $1}')"
if [ "$SHA1_ACTUAL" != "$SHA1_EXPECTED" ]; then
  echo "SHA1 mismatch: expected $SHA1_EXPECTED, got $SHA1_ACTUAL" >&2
  exit 1
fi
unzip -o "$ZIP" -d "$OUT_DIR/extracted"
echo "MDK downloaded and verified: $OUT_DIR/extracted"
