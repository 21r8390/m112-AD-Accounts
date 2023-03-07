# Author: {{ author }}
# Datum: {{ date }}
# Version: 1.1
# Funktionsbeschreibung: Aktiviert die AD-Benutzer welche wieder im CSV sind
# Parameter: 
# Bemerkungen:
#-----


# Konfiguration und Funktionen importieren
. .\Config.ps1
. .\Lernende\Read-CSVLernende.ps1
. .\Lernende\Read-ADLernende.ps1

function Enable-ADLernende {    
    begin {
        # Lernende aus CSV Datei auslesen
        $CSVLernende = Read-CSVLernende

        # Deaktivierte Lernende aus AD auslesen
        $ADLernende = Read-ADLernende | Where-Object { $_.Enabled -eq $false }
    }
    
    process {
        try {
            if ($null -eq $ADLernende -or $null -eq $CSVLernende) {
                # Wenn eine der Listen leer ist, dann gibt es nichts zu aktivieren
                return
            }

            # Zu aktivierende Lernende heraussuchen
            $LernendeNamen = Compare-Object $ADLernende $CSVLernende -Property SamAccountName -IncludeEqual | Where-Object { $_.SideIndicator -eq "==" }
                
            # AD-Objekte anhand der zu aktivierenden Namen suchen
            $LernendeZurAktivierung = $ADLernende | Where-Object { $LernendeNamen.SamAccountName -contains $_.SamAccountName }
            
            Write-Log "Es wurden $($LernendeZurAktivierung.Count) Lernende zum aktivieren gefunden" -Level DEBUG

            # Lernende aktivieren
            $LernendeZurAktivierung | ForEach-Object {
                $_ | Enable-ADAccount -Confirm:$false
                Write-Log "Der Lernende $($_.SamAccountName) wurde aktiviert" -Level INFO
            }
        }
        catch {
            # Fehler beim aktivieren
            Write-Log "Fehler beim aktivieren der AD-Benutzer: $($_.Exception.Message)" -Level FEHLER
        }
    }

    end {
        Write-Log "Es wurden $($LernendeZurAktivierung.Count) Lernende aktiviert" -Level INFO
    }
}