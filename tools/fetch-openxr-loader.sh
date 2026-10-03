#!/usr/bin/env bash
# Holt den offiziellen OpenXR-Loader von Khronos (Apache-2.0) aus Maven Central und legt die
# arm64-Bibliothek nach third_party/openxr/lib/arm64-v8a/ – dort erwartet sie android/build.gradle.
#
#   tools/fetch-openxr-loader.sh              # herunterladen (curl) und einrichten
#   tools/fetch-openxr-loader.sh <datei.aar>  # vorhandenes AAR verwenden (z. B. aus dem Gradle-Cache)
#
# Ziel änderbar über OPENXR_LOADER_DEST. Die Prüfsumme ist fest hinterlegt.
set -euo pipefail

VER=1.1.58
SHA1=53fec8cbef8ad380c905ceb49f7cb040d7d8e68f
URL="https://repo1.maven.org/maven2/org/khronos/openxr/openxr_loader_for_android/$VER/openxr_loader_for_android-$VER.aar"
ROOT=$(cd "$(dirname "$0")/.." && pwd)
DEST=${OPENXR_LOADER_DEST:-$ROOT/third_party/openxr/lib/arm64-v8a}

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

if [ $# -ge 1 ]; then
    AAR=$1
else
    AAR=$TMP/openxr_loader.aar
    echo "Lade OpenXR-Loader $VER von Maven Central …"
    curl -fL --progress-bar -o "$AAR" "$URL"
fi

sha1_of() {
    if command -v sha1sum >/dev/null 2>&1; then sha1sum "$1" | cut -d ' ' -f 1
    else shasum -a 1 "$1" | cut -d ' ' -f 1; fi
}
GOT=$(sha1_of "$AAR")
if [ "$GOT" != "$SHA1" ]; then
    echo "Fehler: Prüfsumme passt nicht (SHA-1 $GOT, erwartet $SHA1)." >&2
    exit 1
fi

unzip -q -o "$AAR" -d "$TMP/aar"
SO=$(find "$TMP/aar" -path '*arm64-v8a*' -name libopenxr_loader.so | head -n 1)
if [ -z "$SO" ]; then
    echo "Fehler: arm64-Loader nicht im AAR gefunden." >&2
    exit 1
fi
mkdir -p "$DEST"
cp "$SO" "$DEST/libopenxr_loader.so"
echo "OK: $DEST/libopenxr_loader.so (OpenXR-Loader $VER von Khronos, Apache-2.0)"
