# Author: {{ author }}
# Datum: {{ date }}
# Version: 1.2
# Funktionsbeschreibung: Erstellt die AD-Gruppen aus der CSV-Datei im Active Directory
# Parameter: 
# Bemerkungen:
#-----

# Konfiguration und Funktionen importieren
. .\Config.ps1
. .\Klassen\Read-CSVKlassen.ps1
. .\Klassen\Read-ADKlassen.ps1
. .\Verzeichnisse\New-KlasseVerzeichnis.ps1

function Add-ADKlassen {
    begin {
        # Klassen aus CSV-Datei auslesen
        $CSVKlassen = Read-CSVKlassen
        
        # Klassennamen aus AD auslesen
        $ADKlassenNamen = New-Object System.Collections.Generic.HashSet[string];
        Read-ADKlassen | ForEach-Object {
            # In HashSet einfügen (keine Duplikate) 
            $ADKlassenNamen.Add($_.Name) | Out-Null
        }
        Write-Log "Es wurden $($ADKlassenNamen.Count) einzigartige AD-Klassen gefunden" -Level DEBUG
    }
    
    process {
        try {
            # Neue Klassen heraussuchen, falls es bestehende gibt
            $NeueKlassen = $CSVKlassen
            if ($ADKlassenNamen.Count -gt 0) {
                # AD-Objekte anhand der zu erstellenden Namen suchen
                $NeueKlassen = $CSVKlassen | Where-Object { -not ($ADKlassenNamen.Contains($_)) }
            }

            # Gruppen für neue Klassen erstellen
            $NeueKlassen | ForEach-Object {
                Write-Log "Die Gruppe für $($_) wird erstellt" -Level DEBUG

                New-AdGroup -Name $_ `
                    -GroupCategory Security `
                    -GroupScope Global `
                    -Path "OU=$($Config.OU_KLASSE),$($Config.DOMAIN)" `
                    -Description "Klassengruppe für $($_)"

                Write-Log "Die Gruppe für $($_) wurde erstellt" -Level INFO

                # Verzeichnis erstellen, wenn diese gewollt ist
                if ($Config.WANT_VERZEICHNIS) {
                    New-KlasseVerzeichnis -Klasse $_
                }
            }
        }
        catch {
            # Fehler beim erstellen
            Write-Log "Fehler beim erstellen der AD-Klassen: $($_.Exception.Message)" -Level FEHLER
        }
    }

    end {
        Write-Log "Es wurden $($NeueKlassen.Count) neue Klassen erstellt" -Level INFO
    }
}