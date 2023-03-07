# Author: {{ author }}
# Datum: {{ date }}
# Version: 1.1
# Funktionsbeschreibung: AD-Benutzer den entsprechenden Klassengruppen zuweisen
# Parameter: keine
# Bemerkungen: Nur Lernende, welche im AD sind werden zur Klasse hinzugefügt
#-----

# Konfiguration und Funktionen importieren
. .\Config.ps1
. .\Lernende\Read-CSVLernende.ps1
. .\Lernende\Read-ADLernende.ps1
. .\Klassen\Read-ADKlassen.ps1

function Add-LernendeToKlasse {    
    begin {
        # Lernende aus CSV Datei auslesen
        $CSVLernende = Read-CSVLernende;
        if ($null -eq $CSVLernende) {
            Write-Log "Lernende zu Klassen verbinden wird abgebrochen, da keine CSV-Lernende existieren" -Level DEBUG
            return;
        }

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

        Write-Log "Es werden $($CSVLernende.Count) Lernende aus der CSV-Datei und $($ADLernende.Count) Lernende aus dem AD verarbeitet" -Level INFO
    }
    
    process {
        try {
            # Lernende, welche im AD sind heraussuchen
            $LernendeNamen = Compare-Object $ADLernende $CSVLernende -Property SamAccountName -IncludeEqual | Where-Object { $_.SideIndicator -eq "==" }

            # AD-Objekte anhand der existierenden Namen suchen
            $LernendeInAD = $ADLernende | Where-Object { $LernendeNamen.SamAccountName -contains $_.SamAccountName }

            foreach ($Klasse in $ADKlassen) {
                # CSV Lernende heraussuchen, welche zur Klasse gehören
                $ZuHinzufuegen = $CSVLernende | Where-Object { $Klasse.Name -eq $_.Klasse -or $Klasse.Name -eq $_.Klasse2 }

                # AD-Lernende heraussuchen, welche zur Klasse gehören
                $ZuHinzufuegen = $LernendeInAD | Where-Object { $ZuHinzufuegen.SamAccountName -contains $_.SamAccountName }

                # Alle Lernende zur Klasse hinzufügen
                if ($ZuHinzufuegen.Count -gt 0) {
                    Add-ADGroupMember -Identity $Klasse -Members $ZuHinzufuegen
                }

                # Log Meldung
                Write-Log "Es wurde $($ZuHinzufuegen.SamAccountName -join ', ') zur Klasse '$($Klasse.Name)' hinzugefügt" -Level INFO
            }
        }
        catch {
            # Fehler beim verbinden
            Write-Log "Fehler beim verbinden der Lernenden zu den Klassen : $($_.Exception.Message)" -Level FEHLER
        }
    }
    
    end {
        Write-Log "Die Lernenden wurden zu den Klassen hinzugefügt" -Level INFO
    }
}