# Author: Joaquin koller & Manuel Schumacher
# Datum: 09.05.2022
# Version: 1.5
# Funktionsbeschreibung: Konvertiert CSV zu XML.
# Parameter: keine
# Bemerkungen: XML hat bereits CSV Format
#-----

# Konfigurationen und Methoden laden
. $PSScriptRoot\config.ps1

# XML auslesen
[xml] $SchuelerXML = Get-Content -Path $Config.XML_PFAD
Write-Log "XML aus Pfad $($Config.XML_PFAD) ausgelesen"

# CSV-Headers hinzufügen
$SchuelerXML.Objs.Obj.MS.S.N.GetValue(0) | Out-File -Encoding utf8 -FilePath  $Config.CSV_PFAD
Write-Log "CSV-Headers zu $($Config.CSV_PFAD) hinzugefügt" -Level "DEBUG"

# Liste in die CSV-Datei schreiben
## Hinweis: XML hat bereits ein CSV Format
foreach ($Linie in $SchuelerXML.Objs.Obj.MS.S.InnerXML) {
    # Umlaute ersetzen und der Datei hinzufügen
    Remove-Umlaute -Value $Linie | Out-File -Encoding utf8 -FilePath $Config.CSV_PFAD -Append
    Write-Log "Schüler $($Linie) in CSV-Datei geschrieben" -Level "DEBUG"
}

# Status Meldung anzeigen
Write-Log "XML erfolgreich zu CSV konvertiert Pfad: $($Config.CSV_PFAD)"