#!/usr/bin/env bash
# Baut und startet die Rechnertests der VR-Logik (Windows: llvm-mingw, sonst System-Compiler).
set -euo pipefail
cd "$(dirname "$0")"
CXX=clang++
XR_TOOLS="${XR_TOOLS:-$(cd ../../.. && pwd)/_tools}"   # Repo liegt direkt unter <XR-Ordner>
[ -x "$XR_TOOLS/llvm-mingw/bin/clang++.exe" ] && CXX="$XR_TOOLS/llvm-mingw/bin/clang++.exe"
mkdir -p ../../.build/tests
"$CXX" -std=c++20 -O1 -Wall -Wextra -Werror -static xr_logic_test.cpp -o ../../.build/tests/xr_logic_test.exe
../../.build/tests/xr_logic_test.exe
