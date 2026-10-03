#!/usr/bin/env bash
# Baut den OpenTTD-Android-Fan-Port (pelya/commandergenius, App "openttd") in WSL/Ubuntu.
# Folgt .github/workflows/openttd.yml aus commandergenius, aber nur arm64-v8a (Quest).
#
# Aufruf in WSL:  bash /mnt/<laufwerk>/<XR-Ordner>/XR-OpenTTD/tools/build-fanport-wsl.sh
# Ergebnis:       <Repo>/fanport/apk/openttd-fanport-arm64-<datum>.apk
#
# Der Build läuft im Linux-Dateisystem (~/xr-openttd), weil das Repo Symlinks nutzt
# und NTFS unter /mnt sehr langsam ist. Erster Lauf: ICU/Boost-Build, rechne mit 1-2 h.
set -euo pipefail

WORK="$HOME/xr-openttd"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="$ROOT/fanport/apk"
SDK="$WORK/android-sdk"
NDK_VER="27.2.12479018"          # Ubuntu-Runner-Standard-NDK (ANDROID_NDK_HOME), CI nutzt nicht "latest"
BUILD_TOOLS="35.0.0"
PLATFORM="android-35"

echo "== Pakete"
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  openjdk-17-jdk-headless git build-essential autoconf automake libtool pkg-config \
  cmake ninja-build python3 unzip zip wget curl xz-utils liblzma-dev file bison flex gettext

mkdir -p "$WORK" "$SDK"
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

echo "== Android SDK/NDK (Linux)"
if [ ! -x "$SDK/cmdline-tools/latest/bin/sdkmanager" ]; then
  wget -q -O /tmp/cmdtools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
  unzip -q /tmp/cmdtools.zip -d "$SDK/cmdline-tools-tmp"
  mkdir -p "$SDK/cmdline-tools"
  mv "$SDK/cmdline-tools-tmp/cmdline-tools" "$SDK/cmdline-tools/latest"
  rm -rf "$SDK/cmdline-tools-tmp" /tmp/cmdtools.zip
fi
yes | "$SDK/cmdline-tools/latest/bin/sdkmanager" --sdk_root="$SDK" --licenses > /dev/null || true
"$SDK/cmdline-tools/latest/bin/sdkmanager" --sdk_root="$SDK" \
  "platform-tools" "build-tools;$BUILD_TOOLS" "platforms;$PLATFORM" "ndk;$NDK_VER"

export ANDROID_SDK_ROOT="$SDK" ANDROID_HOME="$SDK"
export ANDROID_NDK_HOME="$SDK/ndk/$NDK_VER" ANDROID_NDK="$SDK/ndk/$NDK_VER" ANDROID_NDK_ROOT="$SDK/ndk/$NDK_VER"
export PATH="$ANDROID_NDK_HOME:$SDK/build-tools/$BUILD_TOOLS:$PATH"

echo "== Quellen"
cd "$WORK"
if [ ! -d commandergenius ]; then
  git clone --depth 1 https://github.com/pelya/commandergenius.git
fi
cd commandergenius
git submodule update --init --recursive --depth=1 \
  project/jni/application/openttd project/jni/iconv/src \
  project/jni/sdl2 project/jni/sdl2_image project/jni/sdl2_mixer project/jni/sdl2_ttf
[ -e project/jni/application/src ] || ln -s openttd project/jni/application/src
sed -i "s/MultiABI=.*/MultiABI='arm64-v8a'/g" project/jni/application/src/AndroidAppSettings.cfg

echo "== changeAppSettings (Java-Patches, Boost/ICU/OpenSSL)"
./changeAppSettings.sh

echo "== Gradle/Keystore"
( cd project
  mkdir -p "$HOME/.android"
  [ -f "$HOME/.android/debug.keystore" ] || keytool -genkey -v -keystore "$HOME/.android/debug.keystore" \
    -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 \
    -dname "CN=Debug, OU=Debug, O=Debug, L=Debug, ST=Debug, C=Debug"
  echo "sdk.dir=$SDK" > local.properties
  echo "proguard.config=proguard.cfg;proguard-local.cfg" >> local.properties )

echo "== Build"
./build.sh

echo "== APK einsammeln"
mkdir -p "$OUT"
APK=$(find project -name "*.apk" -newer project/jni/application/src/AndroidAppSettings.cfg | head -1)
[ -n "$APK" ] || { echo "Keine APK gefunden"; exit 1; }
cp "$APK" "$OUT/openttd-fanport-arm64-$(date +%Y%m%d).apk"
ls -la "$OUT"
