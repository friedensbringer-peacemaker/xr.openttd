#!/usr/bin/env bash
# Unbeaufsichtigter Gerätetest von XR-OpenTTD auf der Quest (ohne dass jemand die Brille trägt).
#
#   tools/quest-smoke-test.sh [--install <apk>] [--force]
#
# Ablauf: optional installieren → Näherungssensor simulieren (prox_close) → Steuerdatei
# "xr_autotest" ablegen → App starten → Selbsttest (xr_autotest.cpp) läuft ~45 s:
# VR-Reiter, Einstellungen ändern/zurücksetzen, neues Spiel, Musik prüfen, Screenshots →
# Kompositor-Screenshots, Rohscreenshots und Log einsammeln → Sensor-Automatik zurücksetzen.
#
# Ergebnis: "<XR-Ordner>/Meta Quest 3/Tests/xr.openttd/<Zeit>/" (oder $XR_QUEST_DIR/Tests/…) mit summary.txt.
# Bricht ab, wenn die App schon läuft (jemand spielt), außer mit --force.
set -uo pipefail

XR_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"   # <XR-Ordner>: Repo liegt direkt darunter
XR_TOOLS="${XR_TOOLS:-$XR_ROOT/_tools}"
XR_QUEST_DIR="${XR_QUEST_DIR:-$XR_ROOT/Meta Quest 3}"
SDK="${ANDROID_HOME:-$XR_TOOLS/android-sdk}"
ADB="${ADB:-$SDK/platform-tools/adb.exe}"
[ -x "$ADB" ] || ADB="$SDK/platform-tools/adb"
APP=xr.openttd
FILES=/sdcard/Android/data/$APP/files
STAMP=$(date +%Y%m%d-%H%M%S)
OUT="$XR_QUEST_DIR/Tests/$APP/$STAMP"
APK=""
FORCE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --install) APK="$2"; shift 2 ;;
    --force) FORCE=1; shift ;;
    *) echo "Unbekannte Option: $1"; exit 2 ;;
  esac
done

adb() { MSYS_NO_PATHCONV=1 "$ADB" "$@"; }

adb get-state >/dev/null 2>&1 || { echo "Keine Quest verbunden."; exit 1; }
mkdir -p "$OUT"

if [ -n "$(adb shell pidof $APP 2>/dev/null)" ] && [ $FORCE -eq 0 ]; then
  echo "$APP läuft gerade (jemand spielt?) – Test abgebrochen. Mit --force trotzdem."; exit 3
fi

if [ -n "$APK" ]; then
  echo "== Installiere $APK"
  adb install -r "$(cygpath -m "$APK")" | tail -1 || exit 4
fi
adb shell dumpsys package $APP | grep -m1 versionName | tee "$OUT/version.txt"

echo "== Start"
# Als ein Argument übergeben: adb shell hängt Argumente ungequotet aneinander.
START=$(adb shell "date '+%m-%d %H:%M:%S.000'" | tr -d '\r')
[ -n "$START" ] || { echo "Gerätezeit nicht lesbar – Test abgebrochen."; exit 5; }
adb shell am broadcast -a com.oculus.vrpowermanager.prox_close >/dev/null
# Sensor-Automatik auch bei Abbruch (Strg+C, Fehler) wieder zurücksetzen.
trap 'adb shell am broadcast -a com.oculus.vrpowermanager.automation_disable >/dev/null 2>&1' EXIT
adb shell "mkdir -p $FILES && touch $FILES/xr_autotest"
adb shell am force-stop $APP
adb shell am start -n $APP/.OpenTTDActivity >/dev/null

# Kompositor-Screenshots während des Laufs (Stereo, wie in der Brille).
for i in $(seq 1 10); do
  sleep 6
  adb exec-out screencap -p > "$OUT/compositor-$(printf %02d $i).png" 2>/dev/null
  [ -z "$(adb shell pidof $APP 2>/dev/null)" ] && [ $i -gt 2 ] && break
done
# Auf das Ende des Selbsttests warten (max. 40 s zusätzlich).
for i in $(seq 1 20); do
  [ -z "$(adb shell pidof $APP 2>/dev/null)" ] && break
  sleep 2
done

echo "== Einsammeln"
adb logcat -d -T "$START" > "$OUT/logcat-full.txt" 2>/dev/null
grep -E " (OpenTTD|SDL|AndroidRuntime|DEBUG|libc)\b|xr\.openttd|F DEBUG|Fatal signal" "$OUT/logcat-full.txt" > "$OUT/logcat-app.txt"
# Rohscreenshots (SC_CRASHLOG) landen im Personal-Dir, also im Datenordner selbst.
for f in $(adb shell "ls $FILES/ 2>/dev/null" | tr -d '\r' | grep -E '^xr_autotest_.*\.(png|bmp)$'); do
  adb pull "$FILES/$f" "$OUT/$f" >/dev/null && adb shell rm "$FILES/$f"
done

adb shell am broadcast -a com.oculus.vrpowermanager.automation_disable >/dev/null
if [ -n "$(adb shell pidof $APP 2>/dev/null)" ]; then
  echo "App lief nach dem Test noch – beendet."; adb shell am force-stop $APP
fi

{
  echo "XR-OpenTTD Gerätetest $STAMP"; cat "$OUT/version.txt"
  echo; echo "--- Selbsttest ---"; grep "XR-AUTOTEST" "$OUT/logcat-app.txt" | sed 's/.*XR-AUTOTEST/XR-AUTOTEST/'
  echo; echo "--- Treiber ---"; grep -E "dbg: \[driver" "$OUT/logcat-app.txt" | sed 's/.*dbg: //' | sort -u
  echo; echo "--- Fehler/Warnungen ---"
  grep -iE "error|fail|fatal|crash|signal |exception|abort" "$OUT/logcat-app.txt" | grep -v "XR-AUTOTEST screenshot .*: ok" | head -40
  echo; echo "--- Dateien ---"; ls "$OUT"
} > "$OUT/summary.txt"
cat "$OUT/summary.txt"
