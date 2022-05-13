# Author: Joaquin koller & Manuel Schumacher
# Datum: 09.05.2022
# Version: 1.5
# Funktionsbeschreibung: Konvertiert CSV zu XML.
# Parameter: keine
# Bemerkungen: XML hat bereits CSV Format
#-----

# Set Assets Path
$AssetsPath = ".\src\assets"

# CSV in XML Konvertieren, da XML anscheinend kaputt
Import-CSV -Path "$($AssetsPath)\schueler.csv" | Export-CliXML -Path "$($AssetsPath)\schueler.xml" 

# XML auslesen
[xml] $SchuelerXML = Get-Content -Path "$($AssetsPath)\schueler.xml"

# Liste erstellen und bereits CSV-Headers hinzufügen
[System.Collections.ArrayList] $CSV_Data = @($SchuelerXML.Objs.Obj.MS.S.N.GetValue(0))

# CSV der Liste hinzufügen
# Hinweis: XML hat bereits ein CSV Format
$CSV_Data.AddRange($SchuelerXML.Objs.Obj.MS.S.InnerXML)

# Testen ob CSV-Datei bereits existiert
If (Test-Path "$($AssetsPath)\schueler.csv") {
    # CSV löschen, da eine neue generiert wird
    Remove-Item -Path "$($AssetsPath)\schueler.csv" -Force 
}

# Liste in die CSV-Datei schreiben
foreach ($Linie in $CSV_Data) {
    # Jede Linie der Datei hinzufügen
    $Linie | Out-File -Encoding utf8 -FilePath "$($AssetsPath)\schueler.csv" -Append
}

# Status Meldung anzeigen
Write-Host "CSV-Datei erfolgreich erstellt" -ForegroundColor Green