# Headset-Test xr.openttd — 0.1.0-preview.10

Vorher prüfen: `adb shell dumpsys package xr.openttd | grep versionName` zeigt **0.1.0-preview.10**
(versionCode 10, SHA-256 siehe `CHANGELOG.md`). Logger läuft (`<XR-Ordner>/_tools/quest/quest-log.sh`).
Bei Auffälligkeiten Screenshot (Meta-Taste + Trigger); die Uhrzeit reicht für die Zuordnung im Log.

## A. Automatisch, ohne Brille (vorab)

```bash
tools/quest-smoke-test.sh --install android/build/outputs/apk/debug/XR-OpenTTD-0.1.0-preview.10-debug.apk
```

Erwartet in `<XR-Ordner>/Meta Quest 3/Tests/xr.openttd/<Zeit>/summary.txt`:
`XR-AUTOTEST start … vr_tab_opened … settings_changed … settings_restored … new_game … in_game … DONE`,
`music_set=OpenMSX music_driver=fluidsynth`, im Spiel `song_playing=true`, 5 Rohscreenshots
`xr_autotest_*.bmp`, keine Zeile unter „Fehler/Warnungen“. Danach in `openttd.cfg` weiterhin
`autosave_on_exit = true`.

## B. Controller (Standard, Zeigerhand rechts)

| Eingabe | Funktion |
|---|---|
| Strahl rechts | Mauszeiger |
| Trigger | Linksklick (halten = ziehen) |
| Griff rechts | Rechtsklick, halten + bewegen = Karte ziehen |
| A / B | Bestätigen / Zurück (Werkzeug abbrechen, Fenster schließen) |
| X halten / Y halten | Strg / Vorspulen |
| Menütaste links | VR-Schnellmenü (erneut drücken = schließen); darin Stick hoch/runter = Fokus, A = auswählen |
| Rechter Stick | Karte scrollen, über Listen: Liste scrollen |
| Linker Stick vor/zurück | Zoom |
| Linker Griff + linker Stick | Bildschirmbreite / Abstand |
| Linken Stick drücken | Bildschirm zentrieren (Standardgröße) |

## C. Prüfpunkte

| # | Prüfen | Erwartet | BACKLOG |
|---|---|---|---|
| 1 | App starten | Titelbild nach wenigen Sekunden, Musik läuft; im Log **kein** „XR-AUTOTEST enabled“ | AUDIO-001 |
| 2 | Jukebox (Werkzeugleiste → Lautsprecher) | Set „OpenMSX“, Titel wechseln hörbar | AUDIO-002 |
| 3 | Menütaste | Schnellmenü in Spieloptik öffnet, Spiel pausiert; erneut drücken schließt, Spiel läuft weiter | UX-005 |
| 3a | Schnellmenü per Stick + A | weißer Fokusrahmen wandert, A löst den Knopf aus; ausgegraute Knöpfe werden übersprungen | UX-005 |
| 3b | Schnellmenü → Beenden | 1. Klick: Knopf wird rot gedrückt „Sicher? Nochmal klicken“ + Doppelvibration, nach 3 s zurück; 2. Klick in 3 s beendet (Spiel gespeichert) | UX-005 |
| 3c | Schnellmenü → Strahl Aus / Passthrough An | Strahl im Spiel weg, im Menü weiter sichtbar; Raum als Hintergrund | UX-006, VR-005 |
| 3d | Werkzeugleiste → Einstellungen | öffnet **ohne Absturz** (preview.5–8 stürzten ab) | STAB-003 |
| 3e | Schnellmenü → VR-Einstellungen | Reiter „VR“, Optik wie die anderen Reiter, endet mit „Schließen“; Schnellmenü bleibt dahinter | UX-003 |
| 4 | VR → Mauspfeil Aus / Klein / Normal / Groß | Pfeil verschwindet bzw. ändert die Größe; Tooltips erscheinen auch bei „Aus“ | UX-002 |
| 5 | VR → Bildschirmbreite, Abstand, Höhe | Bildschirm ändert sich sofort; Strahl trifft danach noch genau | VR-003 |
| 6 | VR → Bildschärfe Aus / Supersampling / Schärfen | kleine Schrift sichtbar unterschiedlich, kein Schwarzbild | VR-004 |
| 7 | VR → Menügröße 200 % und 300 % | Reiter passt auf den Bildschirm, alle Knöpfe erreichbar | UX-003 |
| 8 | Neues Spiel, 5 Min. spielen (Bahn bauen, Zug kaufen) | flüssig; Log `xr perf:` ≈ 72 fps, `xrWaitFrame` ⌀ ≈ 13 ms | PERF-001 |
| 9 | Brille ab (10 s) und wieder auf | „Weiterspielen?“ erscheint, Spiel war pausiert; erste `xr perf:`-Zeile plausibel | STAB |
| 10 | App über das Quest-Menü beenden, neu starten | Speichern → Laden zeigt „exit“-Autosave mit dem Stand vor dem Beenden | STAB-002 |
| 11 | Neustart | VR-Einstellungen (Mauspfeil, Breite, Schärfe) sind erhalten | VR-003 |
| 12 | Meta-Taste lang drücken | Bildschirm wieder vor dem Blick, Standardgröße | VR |

## D. Erwartete Logzeilen

```
dbg: [driver:1] xr: OpenXR ready (cylinder layer: true, sRGB: true)
dbg: [driver:1] Successfully loaded music driver 'fluidsynth'
dbg: [driver:0] xr perf: 72.0 fps, xrWaitFrame 13.x ms, … screen 1920x1080
```
