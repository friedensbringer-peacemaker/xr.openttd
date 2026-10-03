# Backlog xr.openttd

Prio: **P0** blockiert Spielen · **P1** wichtig · **P2** später.
Status: Offen → Implementiert (x.y.z) → Quest-Abnahme offen → Im Headset bestätigt
(daneben: Teilweise, Zurückgestellt, Recherche).

## Als Nächstes

| ID | Prio | Status | Aufgabe und Abnahmekriterium |
|---|---|---|---|
| STAB-003 | P0 | Quest-Abnahme offen | Absturz beim Öffnen der Einstellungen/des VR-Menüs behoben (preview.9). **Abnahme:** Menütaste und Einstellungen öffnen ohne Absturz |
| UX-005 | P0 | Quest-Abnahme offen | VR-Schnellmenü (Pflichtumfang P1–P7), preview.10. **Abnahme:** alle 7 Knöpfe per Strahl und per Stick+A, Beenden erst nach 2. Klick, Spiel pausiert während offen |
| VR-005 | P1 | Quest-Abnahme offen | Passthrough Aus/25–100 %. **Abnahme:** Raum sichtbar, Bildschirm unverändert |
| TEST-001 | P0 | Quest-Abnahme offen | Headset-Prüfung von preview.10 nach `TEST.md` (A automatisch, C Prüfpunkte). **Abnahme:** alle Punkte beobachtet, Log ohne Fehler |
| TEST-003 | P0 | Implementiert (preview.6) | Unbeaufsichtigter Gerätetest läuft durch. **Abnahme:** `summary.txt` mit „XR-AUTOTEST DONE“, 5 Rohscreenshots, `song_playing=true` im Spiel |
| STAB-002 | P0 | Quest-Abnahme offen | Beenden über das Quest-Menü speichert (Autosave beim Beenden). **Abnahme:** nach Neustart lädt „exit“-Spielstand mit dem letzten Stand |
| AUDIO-001 | P1 | Quest-Abnahme offen | Musik im Titelbildschirm und im Spiel. **Abnahme:** Musik hörbar, Jukebox zeigt „OpenMSX“ |
| AUDIO-002 | P1 | Recherche | preview.3 zeigte „NoMusic“ trotz `musicset = OpenMSX`. **Abnahme:** Selbsttest meldet `music_set=OpenMSX` |
| UX-002 | P1 | Quest-Abnahme offen | Mauspfeil Aus/Klein/Normal/Groß. **Abnahme:** jede Stufe sichtbar anders, Tooltips funktionieren bei „Aus“ |
| VR-003 | P1 | Quest-Abnahme offen | Breite/Abstand/Höhe im VR-Reiter. **Abnahme:** Bildschirm ändert sich sofort, Treffer bleiben genau |
| UX-003 | P1 | Quest-Abnahme offen | VR-Reiter in den Spieleinstellungen. **Abnahme:** Menütaste öffnet/schließt ihn, alle Knöpfe bedienbar bei 200 % und 300 % |
| PERF-001 | P1 | Quest-Abnahme offen | CPU-Stufe hoch. **Abnahme:** Leistungszeile ≈ 72 fps, `xrWaitFrame` ⌀ ≈ 13 ms, großes Spiel flüssig |
| VR-004 | P2 | Quest-Abnahme offen | Bildschärfe Aus/Supersampling/Schärfen. **Abnahme:** Unterschied bei kleiner Schrift sichtbar |

## Danach

| ID | Prio | Status | Aufgabe und Abnahmekriterium |
|---|---|---|---|
| INPUT-001 | P1 | Offen | Vorgemerkte Aktionen auf X/Y/A/B wählbar (wie Siedler: Kurz/Lang). **Abnahme:** Belegung im VR-Reiter änderbar |
| UX-004 | P2 | Offen | Tischansicht (geneigter Bildschirm) wie bei Siedler. **Abnahme:** Neigung 30–75°, Treffer genau |

| REL-001 | P1 | Recherche | Lizenz GPLv2 (OpenTTD) ↔ Apache-2.0 (OpenXR-Loader) klären, `THIRD-PARTY.md` prüfen lassen |
| REPO-001 | P2 | Offen | GitHub-Repo + OpenTTD-Fork anlegen (nur nach Freigabe), Submodul-URL umstellen |

## Arbeitsregeln

1. Eine kleine Änderung pro Schritt, protokolliert.
2. Tests + Build mit exakter Version notieren (`tools/tests/run.sh`, `tools/apk-gate.sh`).
3. Gebaut / installiert / bestätigt getrennt dokumentieren (`STATUS.md`, `CHANGELOG.md`).
4. „Bestätigt“ erst nach Rückmeldung des Nutzers oder eigener Beobachtung im Headset.
5. Neue versionCode für jede APK; alte APKs liegen mit SHA-256 in `.build/releases/`.
