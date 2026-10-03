# Warnungsprüfung des eigenen Quest-Codes: kompiliert die angegebenen Quellen mit den Flags aus
# compile_commands.json des letzten Gradle-Builds erneut (-fsyntax-only -Wall -Wextra).
#
#   powershell -File tools\warn-check.ps1 [datei.cpp ...]
#   (Standard: alle Quest-Dateien + die gepatchten Engine-Dateien)
# Exitcode 1, wenn eine Warnung oder ein Fehler auftritt.
param([string[]]$Files)

$root = Split-Path -Parent $PSScriptRoot
$json = Get-ChildItem "$root\android\.cxx\Debug\*\arm64-v8a\compile_commands.json" | Select-Object -First 1
if (-not $json) { Write-Output "compile_commands.json fehlt - zuerst gradlew assembleDebug"; exit 1 }
if (-not $Files) {
    $Files = @('xr_v.cpp', 'xr_autotest.cpp', 'xr_android_main.cpp', 'xr_settings_gui.cpp', 'xr_config.cpp',
               'xr_gl.cpp', 'settings_gui.cpp', 'toolbar_gui.cpp', 'gfx.cpp', 'ini.cpp', 'console_cmds.cpp')
}
$entries = Get-Content $json.FullName -Raw | ConvertFrom-Json
$fail = 0
foreach ($f in $Files) {
    $e = $entries | Where-Object { $_.file -match "[\\/]$([regex]::Escape($f))$" } | Select-Object -First 1
    if (-not $e) { Write-Output "  ?     $f (nicht im Build)"; continue }
    # Nur prüfen: Objekt-Ausgabe entfernen, Warnungen erzwingen.
    $cmd = $e.command -replace ' -o \S+ ', ' '
    $cmd += ' -fsyntax-only -Wall -Wextra -Wno-missing-field-initializers -Wno-unused-command-line-argument'
    Push-Location $e.directory
    $out = cmd.exe /c "$cmd 2>&1"
    $rc = $LASTEXITCODE
    Pop-Location
    $problems = $out | Where-Object { $_ -match 'warning:|error:' }
    if ($rc -eq 0 -and -not $problems) {
        Write-Output "  ok    $f"
    } else {
        Write-Output "  WARN  $f (rc=$rc)"
        $problems | Select-Object -First 5 | ForEach-Object { Write-Output "        $_" }
        $fail = 1
    }
}
exit $fail
