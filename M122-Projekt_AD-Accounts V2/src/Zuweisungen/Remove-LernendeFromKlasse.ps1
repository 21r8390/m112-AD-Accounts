# Author: {{ author }}
# Datum: {{ date }}
# Version: 1.1
# Funktionsbeschreibung: Nicht mehr zugewiesene Benutzer aus den Gruppen entfernen
# Parameter: keine
# Bemerkungen: 
#-----

# Konfiguration und Funktionen importieren
. .\Config.ps1
. .\Lernende\Read-CSVLernende.ps1
. .\Lernende\Read-ADLernende.ps1
. .\Klassen\Read-ADKlassen.ps1

function Remove-LernendeFromKlasse {
    begin {
        # Lernende aus AD auslesen
        $ADLernende = Read-ADLernende;
        if ($null -eq $ADLernende) {
            Write-Log "Lernende zu Klassen verbinden wird abgebrochen, da keine AD-Lernende existieren" -Level DEBUG
            return;
        }

        # Klassen aus AD auslesen
        $ADKlassen = Read-ADKlassen
        if ($null -eq $ADKlassen) {
            Write-Log "Lernende zu Klassen verbinden wird abgebrochen, da keine AD-Klassen existieren" -Level DEBUG
            return
        }
    }
    
    process {
        try {
            foreach ($Klasse in $ADKlassen) {
                # Bestehende Member auslesen
                $ZuEntfernende = Get-ADGroupMember -Identity $Klasse | Where-Object { ! ($ADLernende.SamAccountName -Contains $_.SamAccountName) }
            
                if ($ZuEntfernende.Count -gt 0) {
                    # Lernende aus der Klasse entfernen
                    Remove-ADGroupMember -Identity $Klasse -Members $ZuEntfernende -Confirm:$false

                    # Log Meldung
                    Write-Log "Es wurde $($ZuEntfernende.SamAccountName -join ', ') von der Klasse '$($Klasse.Name)' entfernt" -Level WARNUNG
                }
            }
        }
        catch {
            # Fehler beim entfernen
            Write-Log "Fehler beim entfernen der Lernenden aus den Klassen : $($_.Exception.Message)" -Level FEHLER
        }
    }
    
    end {
        Write-Log "Nicht mehr zugewiesene Lernende wurden aus den Klassen entfernen" -Level INFO
    }
}