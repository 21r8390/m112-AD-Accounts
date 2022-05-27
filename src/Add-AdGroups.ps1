# Author: Joaquin Koller & Manuel Schumacher
# Datum: 22.05.2022
# Version: 1.1
# Funktionsbeschreibung: Erstellt pro Klasse eine AD-Groupe 
# Parameter: keine
# Bemerkungen: OUs müssen zuerst erstellt werden
#-----

# Konfigurationen und Methoden laden
. $PSScriptRoot\Config.ps1
. $PSScriptRoot\Get-Schueler.ps1

Function Add-AdGroups {
    begin {
        # HashSet erstellen, damit keine Dupplikate
        $Gruppen = New-Object System.Collections.Generic.HashSet[String]

        # Alle Schüler und Klassen aus CSV
        Get-Schueler | ForEach-Object {
            # Zur HashSet hinzugügen, wenn nicht leer
            if (! [string]::IsNullOrEmpty($_.Klasse)) {
                $Gruppen.Add($Config.SCHULE_OU + "_" + $_.Klasse) | Out-Null # Ausgabemeldung verhindern
            }
            if (! [string]::IsNullOrEmpty($_.Klasse2)) {
                $Gruppen.Add($Config.SCHULE_OU + "_" + $_.Klasse2) | Out-Null # Ausgabemeldung verhindern
            }
        }
        Write-Log "Es wurden $($Gruppen.Count) Gruppen im CSV gefunden" -Level DEBUG
    }
    
    process {
        # Gruppen auslesen
        $AdGruppen = Get-AdGroup -Filter '*'  -SearchBase "OU=$($Config.KLASSE_OU),OU=$($Config.SCHULE_OU), $($Config.DOMAIN)"
        Write-Log "Es wurden $($AdGruppen.Count) Gruppen im AD gefunden" -Level DEBUG

        # Wenn Gruppe nicht in AD vorhanden, erstellen
        $Gruppen | Where-Object { ! ($AdGruppen.Name -contains $_) } | ForEach-Object {
            New-AdGroup -Name $_ -GroupCategory Security  -GroupScope Global -Path "OU=$($Config.KLASSE_OU),OU=$($Config.SCHULE_OU), $($Config.DOMAIN)" -Description "Klassengruppe für $_"
            Write-Log "Gruppe $_ wird zum AD hinzugefügt" -Level DEBUG
        }
        Write-Log "Gruppen mit dem AD synchronisiert" -Level INFO

        # Wenn Gruppe nicht in CSV vorhanden, aus AD löschen
        $AdGruppen | Where-Object { ! ($Gruppen -contains $_.Name) } | ForEach-Object {
            # Gruppe ohne Bestätigung löschen
            $_ | Remove-ADGroup -Confirm:$false
            Write-Log "Gruppe $($_.Name) wird aus AD gelöscht" -Level WARN
        }
    }
}