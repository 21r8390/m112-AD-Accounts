# Author: Joaquin Koller & Manuel Schumacher
# Datum: 27.05.2022
# Version: 1.3
# Funktionsbeschreibung: Setzt die Klassen der Benutzer
# Parameter: keine
# Bemerkungen: Benutzer und Klassen müssen zuerst erstellt werden
#-----

# Konfigurationen und Methoden laden
. $PSScriptRoot\Config.ps1
. $PSScriptRoot\Get-Lernende.ps1

Function Set-LernendeZuKlassen {
    begin {
        # Alle Lernende und Klassen aus CSV
        $Lernende = Get-Lernende
        Write-Log "Es wurden $($Lernende.Count) Lernende im CSV gefunden" -Level DEBUG

        # Lernende aus AD lesen
        $AdLernende = Get-AdUser -Filter '*'  -SearchBase "OU=$($Config.LERNENDE_OU),OU=$($Config.SCHULE_OU), $($Config.DOMAIN)"

        # Klassen aus AD auslesen
        $AdKlassen = Get-AdGroup -Filter '*'  -SearchBase "OU=$($Config.KLASSE_OU),OU=$($Config.SCHULE_OU), $($Config.DOMAIN)"
        Write-Log "Es wurden $($AdKlassen.Count) Klassen im AD gefunden" -Level DEBUG
    }
    process {
        foreach ($Klasse in $AdKlassen) {
            # Lernende, welche zur Klasse gehören auslesen
            $Members = $AdLernende | Where-Object { 
                ($Lernende | Where-Object { 
                    # Alle Lernende (CSV) anhand der Klasse (AD) herausfiltern
                    ($Klasse.Name -eq ($Config.SCHULE_OU + "_" + $_.Klasse)) -or ($Klasse.Name -eq ($Config.SCHULE_OU + "_" + $_.Klasse2))
                    
                    # Herausgefilterte Lernende (CSV) auf AdLernende (AD) mappen
                } | Select-Object -Property SamAccountName).SamAccountName -Contains $_.SamAccountName
            }

            # Lernende die nicht mehr in Klasse sein sollten herausfiltern
            $NichtMehrInKlasse = Get-ADGroupMember -Identity $Klasse | Where-Object { ! ($Members.SamAccountName -Contains $_.SamAccountName) }
            if ($NichtMehrInKlasse) {
                # Lernende aus Klasse entfernen
                Remove-ADGroupMember -Identity $Klasse -Members $NichtMehrInKlasse -Confirm:$false
                Write-Log "Es wurden $($NichtMehrInKlasse.SamAccountName -join ', ') von der $($Klasse.Name) entfernt" -Level WARN
            }

            # Alle Lernende zur Klasse hinzufügen
            Add-ADGroupMember -Identity $Klasse -Members $Members 

            # Log Meldungen
            Write-Log "Es wurden $($Members.SamAccountName -join ', ') zur Klasse $($Klasse.Name) hinzugefügt" -Level INFO
        }
    }
}
