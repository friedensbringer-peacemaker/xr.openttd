# OpenXR (Khronos) für XR-OpenTTD

- `include/openxr/`: Khronos-OpenXR-Header (Apache-2.0), übernommen aus XR-Settlers2.5
  (`android/app/jni/openxr`, dort Commit `f2448a8797c8` des OpenXR-SDK, siehe `README-settlers.md`).
- `lib/arm64-v8a/libopenxr_loader.so`: arm64-Loader, **nicht versioniert** (gitignored). Einrichten mit
  `tools/fetch-openxr-loader.sh` – das Skript lädt den offiziellen Loader 1.1.58 von Khronos
  (Maven Central, `org.khronos.openxr:openxr_loader_for_android`, Apache-2.0), prüft die SHA-1 und legt
  die arm64-Datei hier ab. Ein schon vorhandenes AAR (z. B. aus dem Gradle-Cache) geht auch:
  `tools/fetch-openxr-loader.sh <datei.aar>`.
