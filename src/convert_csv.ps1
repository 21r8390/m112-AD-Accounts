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
# Zu Testszwecken wird die CSV Datei in ein XML umgeschrieben
# Import-CSV -Path "$($AssetsPath)\schueler.csv" | Export-CliXML -Path "$($AssetsPath)\schueler.xml" 

# Testen ob CSV-Datei bereits existiert
If (Test-Path "$($AssetsPath)\schueler.csv") {
    # CSV löschen, da eine neue generiert wird
    Remove-Item -Path "$($AssetsPath)\schueler.csv" -Force 
}

# XML auslesen
[xml] $SchuelerXML = Get-Content -Path "$($AssetsPath)\schueler.xml"

# CSV-Headers hinzufügen
$SchuelerXML.Objs.Obj.MS.S.N.GetValue(0) | Out-File -Encoding utf8 -FilePath "$($AssetsPath)\schueler.csv" -Append

# Liste in die CSV-Datei schreiben
# Hinweis: XML hat bereits ein CSV Format
foreach ($Linie in $SchuelerXML.Objs.Obj.MS.S.InnerXML) {
    # Jede Linie der Datei hinzufügen
    $Linie | Out-File -Encoding utf8 -FilePath "$($AssetsPath)\schueler.csv" -Append
}

# Status Meldung anzeigen
Write-Host "CSV-Datei erfolgreich erstellt" -ForegroundColor Green