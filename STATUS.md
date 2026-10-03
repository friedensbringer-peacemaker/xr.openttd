# Status xr.openttd

Zuletzt aktualisiert: 2026-09-30 · Gerät: Meta Quest 3

**Geprüft** heißt: im Headset beobachtet (Screenshot, Video oder Rückmeldung des Nutzers) – nicht nur gebaut
oder per Log bestätigt. Drei Stände werden getrennt: **gebaut** (APK-Gate bestanden) → **installiert**
(`dumpsys` zeigt die Version) → **im Headset bestätigt**.

## Rückroll-Punkte (Git-Tags)

| Tag | Commit | Inhalt | Zustand |
|---|---|---|---|
| `headset-ok-2026-09-28` | `d32a25e` (Engine `bf6f26a`) | preview.3: Bild, Strahl, Menüs, neues Spiel | im Headset geprüft |

## App

| Label/App-ID | Inhalt | Daten auf dem Gerät |
|---|---|---|
| `xr.openttd` | OpenTTD 15.3 mit OpenXR-Videotreiber, OpenGFX/OpenSFX/OpenMSX, SoundFont GeneralUser GS | `/sdcard/Android/data/xr.openttd/files/` (`openttd.cfg`, `xr.cfg`, `openttd/save/`, eigene TTD-Dateien nach `baseset/`) |

## Geprüft im Headset (Stand 2026-09-28, Version 0.1.0-preview.3)

- Start ohne Absturz, Spieldaten werden entpackt – Log 00:19:07 „Successfully loaded video driver 'xr'“, Session FOCUSED
- Gewölbter Bildschirm, Strahl mit Mauspfeil, Spieloptionen-Dropdown per Trigger – Screenshot `xr.openttd-20260928-001919.jpg`
- VR-Einstellungsfenster öffnet (Menütaste) – `xr.openttd-20260928-002016.jpg` (Werte damals um eine Zeile versetzt, behoben in preview.4)
- Neues Spiel, Werkzeugleiste, Jukebox-Fenster – `xr.openttd-20260928-002121.jpg` (keine Musik, behoben in preview.4)

## Gebaut, noch nicht im Headset geprüft

- preview.4: Musik (FluidSynth + GeneralUser GS), Mauspfeil Aus/Klein/Normal/Groß, Bildschirmbreite/Abstand/Höhe im Menü, Menüzeilen „Bezeichnung: Wert“
- preview.5: VR-Einstellungen als Reiter „VR“ in den Spieleinstellungen; Menütaste öffnet diesen Reiter
- preview.6: unbeaufsichtigter Selbsttest (`tools/quest-smoke-test.sh`)
- preview.8 (aktuell, APK-Gate bestanden, SHA-256 `33528462…0be4b9`): CPU-Leistungsstufe, Bildschärfe
  Aus/Supersampling/Schärfen, Leistungszeile im Log, Speichern beim Beenden über das Quest-Menü, QS-Fixes am Selbsttest
- Prüfablauf: `TEST.md` (A = automatisch ohne Brille, C = 12 Prüfpunkte im Headset)

## Bekannt offen

- Musik-Set: Nach preview.3 stand im Jukebox-Fenster „NoMusic“, obwohl `musicset = OpenMSX` konfiguriert ist; Ursache ungeklärt (BACKLOG AUDIO-002)
- GPLv2 (OpenTTD) vs. Apache-2.0 (OpenXR-Loader) vor einer Veröffentlichung klären (REL-001)

## Headset-Rückmeldung 2026-09-28

- „Pfeil soll man verkleinern, vergrößern oder ausschalten können“ → UX-002, umgesetzt in preview.4
- „es gibt keine Musik“ → AUDIO-001, umgesetzt in preview.4
- „Bildgröße soll man im Menü einstellen können“ → VR-003, umgesetzt in preview.4
- „VR-Menü in Spielgrafik integrieren“ (2026-09-30) → UX-003, umgesetzt in preview.5
