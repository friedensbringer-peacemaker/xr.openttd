#!/usr/bin/env bash
# PC-Test der VR-Oberfläche ohne Headset und ohne sichtbares Spiel:
# baut OpenTTD für Windows mit dem VR-Reiter (XR_DESKTOP_PREVIEW, llvm-mingw) und öffnet über den
# Konsolenbefehl `xr_selftest` die Spieleinstellungen (Reiter „Allgemein“ und „VR“) bei 100/200/300 %
# Menügröße – mit Videotreiber null, ohne Ton/Musik, nur im Build-Ordner (kein Eintrag in „Dokumente“).
#
#   tools/desktop-selftest.sh            Ergebnis: .build/desktop/xr_selftest.log
#
# Fand den Absturz „String 0xFFFF is invalid“ beim Öffnen der Spieleinstellungen (preview.5–8).
set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
XR_TOOLS="${XR_TOOLS:-$(cd "$ROOT/.." && pwd)/_tools}"   # Repo liegt direkt unter <XR-Ordner>
SDK="${ANDROID_HOME:-$XR_TOOLS/android-sdk}"
command -v cygpath >/dev/null && { XR_TOOLS="$(cygpath -u "$XR_TOOLS")"; SDK="$(cygpath -u "$SDK")"; }
export PATH="$XR_TOOLS/llvm-mingw/bin:$SDK/cmake/3.31.6/bin:$PATH"
OUT="$ROOT/.build/desktop"

if [ ! -f "$OUT/build.ninja" ]; then
  cmake -S "$ROOT/engine/OpenTTD" -B "$OUT" -G Ninja -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_EXE_LINKER_FLAGS=-static \
    -DXR_DESKTOP_PREVIEW=ON -DOPTION_USE_ASSERTS=ON "-DPERSONAL_DIR=(not set)" > "$OUT.configure.log" 2>&1 \
    || { echo "CMake fehlgeschlagen, siehe $OUT.configure.log"; exit 1; }
fi
cmake --build "$OUT" --target openttd -j8 > "$OUT.build.log" 2>&1 || { echo "Build fehlgeschlagen, siehe $OUT.build.log"; exit 1; }

cd "$OUT"
cp -n "$ROOT"/original-data/baseset/*.tar baseset/ 2>/dev/null
mkdir -p scripts
printf 'script xr_selftest.log\nxr_selftest\nscript\n' > scripts/autoexec.scr
printf '[misc]\ngraphicsset = OpenGFX\nsoundset = OpenSFX\nmusicset = OpenMSX\nlanguage = german.lng\n' > xr-test.cfg
rm -f xr_selftest.log crash*
timeout 120 ./openttd.exe -c xr-test.cfg -r 1920x1080 -v null:ticks=1 -s null -m null > run.out 2>&1
rc=$?

if ls crash*.log >/dev/null 2>&1; then
  echo "ABSTURZ:"; grep -m1 '"reason"' crash*.json.log; exit 1
fi
if grep -q "xr_selftest OK" xr_selftest.log 2>/dev/null; then
  grep -E "general tab|VR tab" xr_selftest.log
  echo "Desktop-Selbsttest: bestanden (Exitcode OpenTTD $rc)"
else
  echo "Desktop-Selbsttest: NICHT bestanden (Exitcode $rc), siehe $OUT/run.out"; exit 1
fi
