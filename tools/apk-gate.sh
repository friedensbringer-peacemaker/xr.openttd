#!/usr/bin/env bash
# APK-Gate für XR-OpenTTD: prüft eine gebaute APK, bevor sie weitergegeben oder installiert wird.
#
#   tools/apk-gate.sh [android/build/outputs/apk/debug/XR-OpenTTD-<version>-debug.apk]
#
# Prüft: Paket xr.openttd, Version = version.properties, OpenXR-Rechte, Quest-/VR-Manifest,
# native Bibliotheken, Spieldaten-Liste + freie Basis-Sets + SoundFont, keine Originaldaten,
# Signatur. Legt bei Erfolg eine Kopie mit SHA-256 unter .build/releases/ ab.
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
XR_TOOLS="${XR_TOOLS:-$(cd "$ROOT/.." && pwd)/_tools}"   # Repo liegt direkt unter <XR-Ordner>
SDK="${ANDROID_HOME:-$XR_TOOLS/android-sdk}"
BT="$SDK/build-tools/34.0.0"
AAPT2="$BT/aapt2"; [ -x "$AAPT2.exe" ] && AAPT2="$AAPT2.exe"
NAME=$(grep '^versionName=' "$ROOT/version.properties" | cut -d= -f2 | tr -d '\r')
CODE=$(grep '^versionCode=' "$ROOT/version.properties" | cut -d= -f2 | tr -d '\r')
APK="${1:-$ROOT/android/build/outputs/apk/debug/XR-OpenTTD-$NAME-debug.apk}"
FAIL=0
ok()   { echo "  ok    $1"; }
bad()  { echo "  FEHLT $1"; FAIL=1; }
need() { if grep -q -- "$2" <<<"$3"; then ok "$1"; else bad "$1"; fi; }

[ -f "$APK" ] || { echo "APK nicht gefunden: $APK"; exit 1; }
echo "APK-Gate: $APK"

BADGING=$("$AAPT2" dump badging "$APK" 2>/dev/null)
need "Paket xr.openttd" "package: name='xr.openttd'" "$BADGING"
need "versionName $NAME" "versionName='$NAME'" "$BADGING"
need "versionCode $CODE" "versionCode='$CODE'" "$BADGING"
need "Recht org.khronos.openxr.permission.OPENXR" "org.khronos.openxr.permission.OPENXR'" "$BADGING"
need "Label xr.openttd" "application-label:'xr.openttd'" "$BADGING"

MANIFEST=$("$AAPT2" dump xmltree --file AndroidManifest.xml "$APK" 2>/dev/null)
need "Kategorie com.oculus.intent.category.VR" "com.oculus.intent.category.VR" "$MANIFEST"
need "Kategorie IMMERSIVE_HMD" "org.khronos.openxr.intent.category.IMMERSIVE_HMD" "$MANIFEST"
need "Feature vr.headtracking" "android.hardware.vr.headtracking" "$MANIFEST"
need "vr_only" "vr_only" "$MANIFEST"
need "Activity OpenTTDActivity" "OpenTTDActivity" "$MANIFEST"

FILES=$(unzip -Z1 "$APK")
for lib in libmain.so libSDL2.so libopenxr_loader.so libc++_shared.so; do
  need "lib/arm64-v8a/$lib" "^lib/arm64-v8a/$lib$" "$FILES"
done
need "Spieldaten-Liste xr_data.lst" "^assets/xr_data.lst$" "$FILES"
need "OpenGFX" "^assets/xr_data/baseset/opengfx-.*\.tar$" "$FILES"
need "OpenSFX" "^assets/xr_data/baseset/opensfx-.*\.tar$" "$FILES"
need "OpenMSX" "^assets/xr_data/baseset/openmsx-.*\.tar$" "$FILES"
need "SoundFont + Lizenz" "^assets/xr_data/soundfont/LICENSE" "$FILES"
need "Sprachdatei deutsch" "^assets/xr_data/lang/german.lng$" "$FILES"
# Originaldaten von Transport Tycoon dürfen nie in der APK stecken (nur eigene Kopie des Spielers).
if grep -qiE "trg1r?\.grf|trgir\.grf|trgcr\.grf|trghr\.grf|trgtr\.grf|sample\.cat|\.iso$|setup.*\.exe$" <<<"$FILES"; then
  bad "keine Originaldaten in der APK"
else
  ok "keine Originaldaten in der APK"
fi

# Ohne MSYS_NO_PATHCONV: nur so kommt "//c" als "/c" bei cmd.exe an (sonst ist die Prüfung immer grün).
if [ -f "$APK" ] && cmd.exe //c "$(cygpath -w "$BT/apksigner.bat")" verify "$(cygpath -w "$APK")" </dev/null >/dev/null 2>&1; then
  ok "Signatur"
else
  bad "Signatur (apksigner verify)"
fi

if [ $FAIL -ne 0 ]; then echo "APK-Gate: NICHT bestanden"; exit 1; fi
mkdir -p "$ROOT/.build/releases"
cp "$APK" "$ROOT/.build/releases/"
( cd "$ROOT/.build/releases" && sha256sum "$(basename "$APK")" >> SHA256SUMS.txt && tail -1 SHA256SUMS.txt )
echo "APK-Gate: bestanden"
