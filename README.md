# XR-OpenTTD — Konzept-Notiz VR-Port Transport Tycoon Deluxe

Stand: 2026-09-27. Gehört zu XRShell (`../XR-Ports-Platform`), Meilenstein M2 (Issue #6).

## Quest-App `xr.openttd` (0.1.0-preview.1, 2026-09-27)

Eigenständige App nach dem Vorbild von XR-Settlers2.5: OpenTTD 15.3 läuft unverändert in 2D,
ein eigener OpenXR-Videotreiber zeigt das Bild als (gewölbten) Bildschirm im Raum und macht den
Controller-Strahl zur Maus. **Stand: gebaut und installiert, noch nicht im Headset getestet.**

| Pfad | Inhalt |
|---|---|
| `engine/OpenTTD/` | Fork von 15.3, Zweig `xr-quest` (Treiber in `src/video/xr/`, Build in `cmake/XRQuest.cmake`) |
| `android/` | Gradle-Projekt (Einzelmodul, AGP 8.7.3, NDK r30, CMake 3.31.6) |
| `third_party/` | SDL 2.32.10, xz 5.8.4, OpenXR-Header + arm64-Loader (aus XR-Settlers2.5) |
| `tools/build-host-tools.sh` | baut `strgen`/`settingsgen` für den PC (Windows: llvm-mingw in `_tools`) |
| `version.properties` | versionCode/versionName der APK |

Repo: `main` mit Submodulen (`git submodule update --init --depth 1`). `engine/OpenTTD` zeigt
auf Commit `xr-quest` im lokalen Fork; die URL ist vorerst Upstream-OpenTTD, bis ein eigener
GitHub-Fork existiert (die XR-Commits liegen bis dahin nur lokal). Den OpenXR-Loader siehe
`third_party/openxr/README.md`.

Build: `tools/build-host-tools.sh` (einmal), dann `cd android && ./gradlew assembleDebug`
→ `android/build/outputs/apk/debug/XR-OpenTTD-<version>-debug.apk`. Die freien Basis-Sets aus
`original-data/baseset/` kommen in die APK und werden beim ersten Start nach
`/sdcard/Android/data/xr.openttd/files/` entpackt (dort auch `openttd.cfg`, `xr.cfg`, Spielstände
unter `openttd/save/`; eigene Original-TTD-Dateien nach `baseset/`).

**Bedienung** (Standard, Zeigerhand rechts; auch im Spiel unter Einstellungen → VR-Einstellungen):

| Eingabe | Funktion |
|---|---|
| Strahl rechts | Mauszeiger (geglättet, Klickstabilisierung 85 ms) |
| Trigger | Linksklick (halten = ziehen) |
| Griff rechts | Rechtsklick (halten + bewegen = Karte ziehen) |
| A | Bestätigen (Enter) |
| B | Zurück: Bauwerkzeug abbrechen, sonst oberstes Fenster schließen |
| X halten | Strg (Strg-Klick) |
| Y halten | Vorspulen |
| Menütaste links | VR-Einstellungen öffnen/schließen |
| Rechter Stick | Karte scrollen; über Listen: Liste scrollen; drücken/Doppeltipp = schneller |
| Linker Stick vor/zurück | Zoom (am Zeiger) |
| Linker Griff + linker Stick | Bildschirmbreite / Abstand |
| Linken Stick drücken | Bildschirm vor dem Blick zentrieren (Standardgröße) |

Voreinstellungen beim ersten Start: Menügröße 200 %, 1920×1080, Bildschirmtastatur öffnet bei
Klick auf ein Textfeld, Autosave beim Beenden, Tooltips nach 1 s Verweilen.

## Inhalt dieses Ordners

| Pfad | Was | Stand |
|---|---|---|
| `upstream/OpenTTD-15.3/` | Original-Projekt OpenTTD, flacher Klon von Tag `15.3` | 14ec60f, 2026-04-03 (neueste stabile Version) |
| `fanport/openttd-android/` | Android-Fan-Port von pelya, Zweig `14` (neuester Quellstand) | a3163e0, 2025-04-23, basiert auf OpenTTD 14.1 |
| `fanport/commandergenius/` | Build-Umgebung des Fan-Ports (Sparse-Checkout: nur `project/jni/application/openttd`) | bdcaefe; Submodul `src` zeigt exakt auf a3163e0 |
| `fanport/apk/OpenTTD-1.9.1.77.apk` | Neueste APK, die auf GitHub veröffentlicht ist (2019, OpenTTD 1.9) | SHA-256 `48ad5e2c…eab58a4f` |

Hinweis zur APK: Die aktuelle Store-Version (14.1.rev128, `org.openttd.sdl`) wird
nur über Google Play verteilt. Auf GitHub gibt es nur 1.9.1.77, und Drittanbieter-Mirrors
sind bewusst nicht genutzt worden. Den neueren Stand baut man aus `fanport/` selbst.

### Spieldaten (`original-data/`, gitignored)

| Paket | Version | Quelle | Datei in `original-data/baseset/` |
|---|---|---|---|
| OpenGFX (Grafik, GPL-2) | 8.0 (2026-01-04) | `https://cdn.openttd.org/opengfx-releases/8.0/opengfx-8.0-all.zip` | `opengfx-8.0.tar` |
| OpenSFX (Sound, CC Sampling+) | 1.0.3 (2021-10-31) | `https://cdn.openttd.org/opensfx-releases/1.0.3/opensfx-1.0.3-all.zip` | `opensfx-1.0.3.tar` |
| OpenMSX (Musik/MIDI, GPL-2) | 0.4.2 (2021-10-31) | `https://cdn.openttd.org/openmsx-releases/0.4.2/openmsx-0.4.2-all.zip` | `openmsx-0.4.2.tar` |

Die ZIPs liegen unter `original-data/baseset/_downloads/`. OpenTTD liest die `.tar` direkt,
ohne sie zu entpacken; sie kommen auf dem Gerät ins Personal-Dir `baseset/`. Damit ist das
Spiel komplett ohne Originaldateien spielbar. Eigene Original-TTD-Dateien (z. B. GOG:
`TRG1R.GRF`, `TRGIR.GRF`, `TRGCR.GRF`, `TRGHR.GRF`, `TRGTR.GRF`, `SAMPLE.CAT`) kämen
optional nach `original-data/ttd/`. Stand 2026-09-27: keine Originaldateien vorhanden.

Die Spieldaten liegen nur in `original-data/`, sonst sind keine Spiele-Assets im Ordner.

## Original-Projekt OpenTTD (15.3)

- Kein offizieller Android-Build, aber saubere Treiber-Abstraktion:
  - Video `src/video/video_driver.hpp`: `MainLoop`, `MakeDirty`, `ChangeResolution`,
    `InputLoop`, `PollEvent`, `Paint`, `LockVideoBuffer`/`UnlockVideoBuffer`,
    `CheckPaletteAnim`, `GetScreenSize`, `EditBoxGainedFocus`/`LostFocus` …
  - Sound `src/sound/sound_driver.hpp` (Mixer liefert PCM), Musik `src/music/` (MIDI; `null_m`, `fluidsynth`).
- OpenTTD zeichnet jedes Bild selbst in einen Pixelspeicher (Blitter). Der Treiber
  zeigt diesen Speicher nur an → **eigener `xr_v.cpp`-Treiber statt SDL2** möglich.
- Cross-Compile: Hilfsprogramme (strgen, settingsgen …) werden zuerst für den PC gebaut
  (`-DOPTION_TOOLS_ONLY=ON`) und dann über `-DHOST_BINARY_DIR=…` beim Android-Build genutzt.
- Abhängigkeiten: Threads (Pflicht), zlib, liblzma, LZO, PNG (optional); Freetype, Harfbuzz, ICU,
  Fluidsynth, CURL, OpusFile optional. Für den Anfang reichen zlib + liblzma.
- Freie Spieldaten: OpenGFX (GPL-2), OpenSFX (CC Sampling+), OpenMSX (GPL-2) → das Spiel ist
  ohne Original-Dateien spielbar. Optional: Original-TTD-Dateien des Spielers (z. B. GOG) nach `baseset/`.

## Fan-Port (pelya/openttd-android)

- Basis: **SDL 1.2** über pelyas libSDL-Android („commandergenius“), altes Build-System mit
  eigener Java-Activity. `SwVideoMode=y` → Software-Framebuffer, also genau das Muster, das wir auch nutzen wollen.
- Eingabe laut `AndroidAppSettings.cfg`: Touch als Maus, **Rechtsklick = langes Drücken**,
  Zwei-Tasten-Maus erforderlich, Multitouch (Zoom), eigener Cursor aus.
- Daten werden beim ersten Start heruntergeladen: Datenpaket, Konfiguration, Timidity (MIDI),
  ICU, Fonts.
- Code-Änderungen: nur ~43 `__ANDROID__`-Stellen (u. a. `window.cpp`, `settings_gui.cpp`,
  `intro_gui.cpp`, `fios_gui.cpp`, `video/sdl_v.cpp`, `os/unix/*`) plus UI-Änderungen für
  grobe Eingabe: Regler für das Knopf-Seitenverhältnis, Schriftgrößen-Reiter, kompaktere
  Welterstellung, Aufklappmenüs passend zur Knopfgröße.
- Übernehmbar für VR: die **UI-Ideen** (ein Laserpointer ist ungefähr so ungenau wie ein Finger)
  und der Download der Daten beim ersten Start. Den Build/SDL-1.2-Unterbau nicht übernehmen.
- Aktivität: letzter Push 2025-04 („Fixed compilation“), liegt eine Hauptversion hinter 15.x.

## Was der VR-Port braucht

1. **Build**: OpenTTD als CMake-Teilprojekt für arm64/NDK r30; Host-Tools-Durchlauf zuerst (größtes Risiko).
2. **Video-Treiber `xr_v`**: 32bpp-Blitter, nur geänderte Bereiche (Dirty-Rects) →
   `glTexSubImage2D` in die Textur von `QuadRenderer`. Virtuelle Auflösung z. B. 1920×1080.
3. **Eigener Thread für das Spiel**: `MainLoop` blockiert → OpenTTD in eigenem Thread; Framebuffer
   doppelt gepuffert + Mutex; Eingabe über Queue, die `InputLoop`/`PollEvent` abarbeiten.
4. **Eingabe**:
   - Die Cursor-Position kommt aus `raycastToScreen()` (UV × Auflösung).
   - Trigger = Linksklick, zweite Taste = Rechtsklick (Karte ziehen, Tooltips).
   - Stick scrollt, Mausrad = Zoom.
   - **Ctrl auf eine eigene Taste** (Ctrl-Klick wird viel genutzt).
   - Namen und Chat laufen über das Tastatur-Overlay aus #5 (`EditBoxGainedFocus`).
5. **Audio**: Sound-Treiber an `core_audio`; Musik zuerst `null`, später FluidSynth + Soundfont.
6. **Dateien**: Personal-Dir im App-Speicher (`baseset/`, `save/`, `openttd.cfg`); OpenGFX & Co.
   mitliefern oder beim ersten Start laden.
7. **Lebenszyklus**: Pause bei Fokusverlust der XR-Session, Autosave beim Beenden.
8. **Später VR-typisch**: OpenTTD-Zusatz-Viewports als eigene, frei platzierbare Bildschirme im Raum.

## Lizenz — vor Veröffentlichung klären

Dieses Repo steht unter der GPL-2.0 (wie OpenTTD, Text in `COPYING`); Teile mit eigener Lizenz siehe `THIRD-PARTY.md`.

- OpenTTD ist GPLv2 → eine APK, die OpenTTD enthält, ist insgesamt GPLv2 (Quellcode veröffentlichen;
  XRShell selbst ist MIT, das ist vereinbar).
- Der mitgelieferte Khronos-OpenXR-Loader ist **Apache-2.0**; laut FSF **nicht GPLv2-kompatibel**.
  Prüfen (System-Library-Ausnahme? Loader dynamisch/vom System?).
- Keine Markennamen: „XR-OpenTTD“ ja, „Transport Tycoon VR“ nein.

## Einordnung

Erst M1.1-Fixes + Headset-Test (siehe `XR-Ports-Platform/AGENTS.md`), dann M2.
Vorschlag für M2: **OpenTTD mit eigenem Treiber zuerst** (prüft Bild, Eingabe und Ton ohne SDL-Risiko),
danach den SDL2-Umweg für CorsixTH. Aufwand OpenTTD: grob 2–4 Wochen, davon der größte Teil Build-Integration.

## Quellen

- https://github.com/OpenTTD/OpenTTD (Tag 15.3)
- https://github.com/pelya/openttd-android (Zweig 14, Releases)
- https://github.com/pelya/commandergenius (`project/jni/application/openttd`)
- https://wiki.openttd.org/en/Community/Patches/Compiling%20and%20installing%20the%20unofficial%20Android%20port
