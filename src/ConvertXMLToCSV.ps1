# Author: Joaquin Koller & Manuel Schumacher
# Datum: 09.05.2022
# Version: 1.5
# Funktionsbeschreibung: Konvertiert CSV zu XML.
# Parameter: keine
# Bemerkungen: XML hat bereits CSV Format
#-----

# Konfigurationen und Methoden laden
. $PSScriptRoot\Config.ps1

# Umlaute ersetzten
# Src: https://www.reddit.com/r/PowerShell/comments/a5hfcw/three_ways_in_powershell_to_replace_diacritics_%C3%AB/
Function Remove-Umlaute {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [String]
        $Value  # String der ersetzt werden soll
    )

    process {
        # Sonderzeichen mithilfe von Encoding übersetzen
        return [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($Value))
    }
}

Function ConvertXMLToCSV() {
    # Try-Catch um Fehler beim auslesen abzufangen
    try {
        # XML auslesen
        [xml] $SchuelerXML = Get-Content -Path $Config.XML_PFAD
        Write-Log "XML aus Pfad $($Config.XML_PFAD) ausgelesen"

        # CSV-Headers hinzufügen
        $SchuelerXML.Objs.Obj.MS.S.N.GetValue(0) | Out-File -Encoding utf8 -FilePath  $Config.CSV_PFAD
        Write-Log "CSV-Headers zu $($Config.CSV_PFAD) hinzugefügt" -Level DEBUG

        # Liste in die CSV-Datei schreiben
        ## Hinweis: XML hat bereits ein CSV Format
        foreach ($Linie in $SchuelerXML.Objs.Obj.MS.S.InnerXML) {
            # Umlaute ersetzen und der Datei hinzufügen
            Remove-Umlaute -Value $Linie | Out-File -Encoding utf8 -FilePath $Config.CSV_PFAD -Append
            Write-Log "Schüler $($Linie) in CSV-Datei geschrieben" -Level DEBUG
        }

        # Status Meldung anzeigen
        Write-Log "XML erfolgreich zu CSV konvertiert Pfad: $($Config.CSV_PFAD)"
    }
    catch {
        # Fehler loggen
        Write-Log -Meldung "Fehler beim Konvertieren der XML Datei ($($Config.XML_PFAD)): $($_.Exception.Message)"
    }
}