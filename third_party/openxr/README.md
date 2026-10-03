# OpenXR (Khronos) für XR-OpenTTD

- `include/openxr/`: Khronos-OpenXR-Header (Apache-2.0), übernommen aus XR-Settlers2.5
  (`android/app/jni/openxr`, dort Commit `f2448a8797c8` des OpenXR-SDK, siehe `README-settlers.md`).
- `lib/arm64-v8a/libopenxr_loader.so`: arm64-Loader, **nicht versioniert** (gitignored). Beim
  Einrichten aus XR-Settlers2.5 kopieren:
  `cp ../XR-Settlers2.5/android/app/src/main/jniLibs/arm64-v8a/libopenxr_loader.so third_party/openxr/lib/arm64-v8a/`
  (dort per `scripts/build-quest.py` aus den Khronos-Quellen gebaut).
