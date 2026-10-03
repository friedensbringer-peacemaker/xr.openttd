# Changelog xr.openttd

## Unveröffentlicht

## 0.1.0-preview.10 — 2026-10-02

### Neu (Pflichtumfang VR-Menü P1–P7)
- UX-005 VR-Schnellmenü im Spiel-Look (linke Menütaste): Weiter, Bildschirm zentrieren, Strahl An/Aus, Passthrough
  An/Aus, Spiel speichern, VR-Einstellungen, **Beenden** (rot; 1. Klick „Sicher? Nochmal klicken“ + Doppelpuls,
  2. Klick in 3 s speichert Einstellungen und Spiel, dann Ende). Bedienbar per Strahl **oder** Stick-Fokus + A;
  pausiert das Einzelspiel und löst alle gehaltenen Eingaben
- VR-005 Passthrough (XR_FB_passthrough) Aus/25–100 %, ausgegraut, wenn das Gerät es nicht kann
- UX-006 „Strahl: Aus“ (im offenen Menü bleiben Strahl und Zielpunkt sichtbar); VR-Reiter endet mit „Schließen“
- TEST-006 PC-Selbsttest `tools/desktop-selftest.sh` (Konsolenbefehl `xr_selftest`, Windows-Build ohne Headset)
- SETUP-001 Handtracking optional im Manifest: Start ohne aktive Controller möglich

### Nachweis
- **Gebaut:** versionCode 10, SHA-256 `ca57539fdc4573f3967796d948d313067b8c11e23581a6a564216365764cafdb`; APK-Gate
  bestanden (inkl. Signatur), Host-Tests 1350/180/0, `warn-check.ps1` 11/11, PC-Selbsttest bestanden
  (Allgemein- und VR-Reiter bei 100/200/300 %, Schnellmenü öffnen/navigieren/schließen). Commits `337934d` / `fa296a8`.
- **Installiert:** 2026-10-02 19:37 (`dumpsys` versionName 0.1.0-preview.10), nicht gestartet.
- **Im Headset:** offen (`TEST.md`, Punkte 3–3e).

## 0.1.0-preview.9 — 2026-10-02

### Behoben
- STAB-003 **Absturz beim Öffnen der Einstellungen bzw. des VR-Menüs** (preview.5–8) – Ursache: die Größenberechnung
  des VR-Reiters holte für die Knöpfe „Zentrieren“/„Standardgröße“ einen Text mit der ungültigen ID 0xFFFF;
  OpenTTD bricht dann ab („String 0xFFFF is invalid“). Fix: Knöpfe ohne Bezeichnung überspringen.
  Am PC reproduziert und nach dem Fix bei 100/200/300 % Menügröße ohne Absturz geprüft.

### Nachweis
- **Gebaut:** versionCode 9, APK-Gate bestanden, Host-Tests 1350/180/0, `warn-check.ps1` 11/11.
- **Installiert:** 2026-10-02 00:18 (`dumpsys` versionName 0.1.0-preview.9).
- **Gerätetest:** Start blockiert durch Systemdialoge „Zu Controllern wechseln“ und Guardian (Brille lag) – nicht
  aussagekräftig. **Im Headset:** offen.

## 0.1.0-preview.8 — 2026-09-30

### Neu
- PERF-001 CPU-Leistungsstufe „sustained high“ (XR_EXT_performance_settings) direkt nach Session-Start
- VR-004 Bildschärfe im VR-Reiter: Aus / Supersampling (Standard) / Schärfen (Compositor-Ebene)
- TEST-002 Leistungszeile alle 10 s im Log: Headset-fps, `xrWaitFrame`-Mittel, Bildkopien/s, Upload MB/s
- TEST-005 `tools/warn-check.ps1`: Warnungsprüfung des eigenen Codes mit den echten Build-Flags

### Behoben (unabhängige QS-Prüfung 2026-09-30)
- STAB-002 Beenden über das Quest-Menü verwarf den Spielstand seit dem letzten Autosave – Ursache: bei SDL_QUIT
  und Session-Ende wurde nur `_exit_game` gesetzt; Fix: Kennzeichen, im gesperrten Eingabeschritt `DoExitSave()`
  (wenn „Autosave beim Beenden“ an), dann Beenden
- TEST-003 Selbsttest schrieb `autosave_on_exit = false` dauerhaft in `openttd.cfg` – Fix: `_save_config = false`;
  Bildschirmbreite wurde nach dem Test nicht zurückgesetzt – Fix: neue Größenanforderung; Schritte jetzt relativ getimt
- TEST-002 erste Leistungszeile nach Brille ab/auf zu hoch – Fix: Zähler beim Session-Start nullen
- REL-002 APK-Gate: Signaturprüfung war immer grün (`MSYS_NO_PATHCONV` machte aus `//c` kein `/c`) – Fix, mit
  echter APK rc 0 und abgeschnittener APK rc 1 gegengeprüft. **Die Angabe „Signatur ok“ bei preview.6 war unbelegt.**
- TEST-003 Smoke-Skript: Rohscreenshots liegen im Datenordner (nicht `screenshot/`), Gerätezeit-Befehl gequotet,
  `trap` setzt den Näherungssensor auch bei Abbruch zurück, APK-Pfad per `cygpath`

### Nachweis
- **Gebaut:** `XR-OpenTTD-0.1.0-preview.8-debug.apk`, versionCode 8,
  SHA-256 `335284620a994b1b0ac8cbb9e2f66d860ed4bdf9934602e3f5eee65cbe0be4b9`; APK-Gate bestanden (22/22 inkl.
  Signatur); Host-Tests 1350 Treffer / 180 Fehlschüsse / 0 Fehler (`-Werror`); `warn-check.ps1` 10/10 Dateien ohne
  Warnung (Prüfung mit absichtlicher Testwarnung gegengeprüft); `git diff --check` sauber; keine Schlüssel/Tokens.
- **preview.7:** gebaut, aber verworfen – Quellen wurden während des Builds geändert, Inhalt nicht eindeutig.
- **Installiert / im Headset bestätigt:** offen – Quest nicht verbunden. Selbsttest auf dem Gerät noch nie gelaufen.

## 0.1.0-preview.6 — 2026-09-30

### Neu
- TEST-003 Unbeaufsichtigter Gerätetest: Steuerdatei `xr_autotest` → VR-Reiter, Einstellungen ändern und
  zurücksetzen, neues Spiel, Musikstatus, Rohscreenshots, Beenden ohne Speichern (`tools/quest-smoke-test.sh`)
- TEST-004 Host-Tests (`tools/tests/run.sh`): 1350 Strahltreffer + 180 Fehlschüsse über Seitenverhältnis ×
  Wölbung × Pose × Handposition, Stick/Zoom/Tastengesten
- REL-002 APK-Gate (`tools/apk-gate.sh`)

### Nachweis
- **Gebaut:** `XR-OpenTTD-0.1.0-preview.6-debug.apk`, versionCode 6, SHA-256 `fa24cefe…0f38`, APK-Gate bestanden,
  Host-Tests 1350/180/0.
- **Installiert / im Headset bestätigt:** nein.

## 0.1.0-preview.5 — 2026-09-30

### Neu
- UX-003 VR-Einstellungen als sechster Reiter „VR“ in den Spieleinstellungen (Spiel-Optik); Menütaste und
  Einstellungsmenü öffnen diesen Reiter

### Nachweis
- **Gebaut:** versionCode 5, Commit `8267bb4`. **Im Headset:** nein.

## 0.1.0-preview.4 — 2026-09-28

### Neu
- AUDIO-001 Musik: FluidSynth 2.6.1 spielt OpenMSX mit der SoundFont GeneralUser GS
- UX-002 Mauspfeil Aus / Klein / Normal / Groß
- VR-003 Bildschirmbreite, Abstand, Höhe im VR-Menü

### Behoben
- UX-001 VR-Menü: Werte standen eine Zeile versetzt – Ursache: Text- und Dropdown-Spalten getrennt ausgerichtet;
  Fix: jede Einstellung ein Knopf „Bezeichnung: Wert“

### Nachweis
- **Gebaut:** versionCode 4, Commit `bcd59ab`. **Im Headset:** nein.

## 0.1.0-preview.3 — 2026-09-28

### Behoben
- STAB-001 App beendete sich sofort – Ursache: komprimierte APK-Assets wurden nur einmal gelesen, alle Spieldaten
  „fehlten“; Fix: vollständiges Lesen, Versionsstempel nur nach kompletter Kopie (preview.2)
- Review-Befunde: Bildkopie per `texelFetch`, VSync fest an, fixierter Cursor, Swapchain-Freigabe,
  XR_KHR_android_create_instance, Pause bei Fokusverlust mit „Weiterspielen?“, Supersampling

### Nachweis
- **Gebaut und installiert:** 2026-09-28 00:18, `dumpsys` versionName 0.1.0-preview.3.
- **Im Headset bestätigt:** Start, Bildschirm, Strahl, Menüs, neues Spiel (Screenshots 00:19–00:21).
- **Nicht bestätigt:** Musik (fehlte), VR-Fenster-Layout (versetzt).
