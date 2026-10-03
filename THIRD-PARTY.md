# Komponenten und Lizenzen in der APK `xr.openttd`

| Komponente | Version | Lizenz | Quelle | In der APK |
|---|---|---|---|---|
| OpenTTD (mit XR-Treiber) | 15.3 + Zweig `xr-quest` | GPL-2.0 | github.com/OpenTTD/OpenTTD | `libmain.so`, Sprach-/Skriptdateien |
| SDL | 2.32.10 | zlib | github.com/libsdl-org/SDL | `libSDL2.so`, Java-Activity |
| XZ Utils (liblzma) | 5.8.4 | 0BSD (liblzma) | github.com/tukaani-project/xz | statisch in `libmain.so` |
| FluidSynth | 2.6.1 | LGPL-2.1-or-later | github.com/FluidSynth/fluidsynth | statisch in `libmain.so` |
| Khronos OpenXR-Loader + Header | SDK `f2448a8797c8` | Apache-2.0 (Teile MIT) | github.com/KhronosGroup/OpenXR-SDK-Source | `libopenxr_loader.so` |
| OpenGFX | 8.0 | GPL-2.0 | cdn.openttd.org | Grafik-Basisset |
| OpenSFX | 1.0.3 | CC Sampling Plus 1.0 | cdn.openttd.org | Sound-Basisset |
| OpenMSX | 0.4.2 | GPL-2.0 | cdn.openttd.org | Musik-Basisset (MIDI) |
| GeneralUser GS | 2.0.3 | eigene freie Lizenz (Einbau in Software erlaubt, Lizenztext liegt bei) | github.com/mrbumpy409/GeneralUser-GS | SoundFont für die Musik |
| Panel-/Eingabe-Logik | – | GPL-2.0-or-later | eigener Code aus XR-Settlers2.5 | in `libmain.so` |

## Pflichten und offene Punkte

- **GPL-2.0:** Wer die APK weitergibt, muss den vollständigen Quellcode dieses Stands anbieten (Repo inkl.
  Engine-Fork und Submodule).
- **LGPL-2.1 (FluidSynth, statisch gelinkt):** Quellcode + Möglichkeit zum Neulinken sind über das offene
  Gesamtprojekt gegeben.
- **Offen (REL-001):** Apache-2.0 (OpenXR-Loader) gilt laut FSF als nicht GPLv2-kompatibel. Vor einer
  öffentlichen Veröffentlichung klären (Systembibliotheks-Ausnahme / Loader getrennt).
- **Keine Originaldaten:** Die APK enthält nur die freien Basissets; eigene Transport-Tycoon-Dateien legt der
  Spieler selbst nach `baseset/`. `tools/apk-gate.sh` prüft das bei jedem Build.
- **Name:** App heißt `xr.openttd`; kein „Transport Tycoon“ im Namen, kein offizielles Logo.
