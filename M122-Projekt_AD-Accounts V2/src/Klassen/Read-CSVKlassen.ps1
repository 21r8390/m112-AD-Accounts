# Author: {{ author }}
# Datum: {{ date }}
# Version: 1.0
# Funktionsbeschreibung: Liesst die Klassen aus der CSV Datei aus 
# Parameter: keine
# Bemerkungen: Collections https://www.red-gate.com/simple-talk/sysadmin/powershell/powershell-one-liners-collections-hashtables-arrays-and-strings/
#-----

# Konfiguration importieren
. .\Config.ps1

# Klassen aus CSV Datei auslesen
function Read-CSVKlassen {
    process {
        try {
            # HashSet für Klassen erstellen
            $KlassenSet = New-Object System.Collections.Generic.HashSet[string];

            # Klassen aus CSV Datei auslesen
            $Klassen = Import-Csv -Path $Config.CSV_PFAD -Delimiter $Config.DELIMITER | Select-Object -Property Klasse, Klasse2 -Unique;

            # Klassen in HashSet einfügen
            foreach ($Klasse in $Klassen) {
                if (!([string]::IsNullOrWhiteSpace($Klasse.Klasse))) {
                    $KlassenSet.Add("$($Config.KLASSE_PREFIX)$($Klasse.Klasse)") | Out-Null;
                }
                if (!([string]::IsNullOrWhiteSpace($Klasse.Klasse2))) {
                    $KlassenSet.Add("$($Config.KLASSE_PREFIX)$($Klasse.Klasse2)") | Out-Null;
                }
            }
            
            # Logs schreiben
            Write-Log "Es wurden $($Klassen.Count) Klassen aus dem CSV geladen" -Level INFO
            If ($KlassenSet.Count -ne $Klassen.Count) {
                Write-Log "Von den $($Klassen.Count) Klassen sind $($KlassenSet.Count) Klassen einzigartig" -Level DEBUG
            }

            # Klassen zurückgeben
            return $KlassenSet
        }
        catch {
            # Fehler beim auslesen
            Write-Log "Fehler beim auslesen der CSV-Klassen : $($_.Exception.Message)" -Level FEHLER
            return $null;
        }   
    }
}