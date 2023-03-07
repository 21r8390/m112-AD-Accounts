# Author: {{ author }}
# Datum: {{ date }}
# Version: 1.1
# Funktionsbeschreibung: Löscht die AD-Klassen, welche nicht mehr in der CSV-Datei existieren
# Parameter: 
# Bemerkungen: Löschen kann nicht rückgängig gemacht werden
#-----

# Konfiguration und Funktionen importieren
. .\Config.ps1
. .\Klassen\Read-CSVKlassen.ps1
. .\Klassen\Read-ADKlassen.ps1
. .\Verzeichnisse\Remove-KlasseVerzeichnis.ps1

function Remove-ADKlassen {
    begin {
        # Klassen aus CSV Datei auslesen
        $CSVKlassen = Read-CSVKlassen
    
        # Klassen aus AD auslesen
        $ADKlassen = Read-ADKlassen
    }
    
    process {
        # Wenn die CSV-Datei leer ist, dann werden alle Klassen gelöscht
        $EntfernteKlassen = $ADKlassen
        if ($CSVKlassen.Count -gt 0) {
            # Liste der Klassennamen aus AD erstellen
            $KlassenNamen = New-Object System.Collections.Generic.HashSet[string];
            $CSVKlassen | ForEach-Object {
                # In HashSet einfügen (keine Duplikate) 
                $KlassenNamen.Add($_) | Out-Null
            }

            # Klassen aus AD, welche nicht in der CSV-Datei sind, herausfiltern
            $EntfernteKlassen = $ADKlassen | Where-Object { -not ($KlassenNamen.Contains($_.Name)) }
        }
    
        # Klassen löschen
        $EntfernteKlassen | ForEach-Object {
            $_ | Remove-ADObject -Confirm:$false
            Write-Log "Die Klasse $($_.Name) wurde gelöscht" -Level WARNUNG

            # Verzeichnis entfernen, wenn diese gewollt waren
            if ($Config.WANT_VERZEICHNIS) {
                Remove-KlasseVerzeichnis -Klasse $_.Name
            }
        }
    }
    
    end {
        Write-Log "Es wurden $($EntfernteKlassen.Count) Klassen gelöscht" -Level INFO
    }
}
