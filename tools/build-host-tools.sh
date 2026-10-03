#!/usr/bin/env bash
# Baut die OpenTTD-Hilfsprogramme (strgen, settingsgen) für den Entwicklungsrechner.
# Der Android-Build bindet sie über -DHOST_BINARY_DIR=.build/host-tools ein.
# Windows: llvm-mingw unter <XR-Ordner>/_tools/llvm-mingw (oder $XR_TOOLS/llvm-mingw) (portabel, statisch gelinkt).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
if [[ "$(uname -s)" == MINGW* || "$(uname -s)" == MSYS* ]]; then
  XR_TOOLS="${XR_TOOLS:-$(cd "$ROOT/.." && pwd)/_tools}"   # Repo liegt direkt unter <XR-Ordner>
  SDK="${ANDROID_HOME:-$XR_TOOLS/android-sdk}"
  command -v cygpath >/dev/null && { XR_TOOLS="$(cygpath -u "$XR_TOOLS")"; SDK="$(cygpath -u "$SDK")"; }
  export PATH="$XR_TOOLS/llvm-mingw/bin:$SDK/cmake/3.31.6/bin:$PATH"
  EXTRA=(-DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_EXE_LINKER_FLAGS=-static)
else
  EXTRA=()
fi
cmake -S "$ROOT/engine/OpenTTD" -B "$ROOT/.build/host-tools" -G Ninja -DOPTION_TOOLS_ONLY=ON -DCMAKE_BUILD_TYPE=Release "${EXTRA[@]}"
cmake --build "$ROOT/.build/host-tools" -j8
