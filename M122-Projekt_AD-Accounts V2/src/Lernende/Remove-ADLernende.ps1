# Author: {{ author }}
# Datum: {{ date }}
# Version: 1.1
# Funktionsbeschreibung: Deaktiviert die AD-Lernende, welche nicht mehr in der CSV-Datei existieren
# Parameter: 
# Bemerkungen: 
#-----

# Konfiguration und Funktionen importieren
. .\Config.ps1
. .\Lernende\Read-CSVLernende.ps1
. .\Lernende\Read-ADLernende.ps1

function Remove-ADLernende {    
    begin {
        # Lernende aus CSV Datei auslesen
        $CSVLernende = Read-CSVLernende

        # Lernende aus AD auslesen
        $ADLernende = Read-ADLernende | Where-Object { $_.Enabled -eq $true };
    }
    
    process {
        # Wenn die CSV-Datei leer ist, dann werden alle Lernende deaktiviert
        $EntfernteLernende = $ADLernende
        if ($null -ne $CSVLernende) {
            # Entfernte Lernende heraussuchen
            $LernendeNamen = Compare-Object $CSVLernende $ADLernende -Property SamAccountName | Where-Object { $_.SideIndicator -eq "=>" };

            # AD-Objekte anhand der zu deaktivierenden Namen suchen
            $EntfernteLernende = $ADLernende | Where-Object { $LernendeNamen.SamAccountName -contains $_.SamAccountName };
        }

        # Lernende deaktivieren
        $EntfernteLernende | ForEach-Object {
            $_ | Disable-ADAccount -Confirm:$false;
            Write-Log "Der Lernende $($_.Name) wurde deaktiviert" -Level WARNUNG
        }
    }
    
    end {
        Write-Log "Es wurden $($EntfernteLernende.Count) Lernende deaktiviert" -Level INFO
    }
}