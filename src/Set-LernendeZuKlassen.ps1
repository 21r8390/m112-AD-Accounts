# Author: Joaquin Koller & Manuel Schumacher
# Datum: 27.05.2022
# Version: 1.1
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
    }
    
    process {
        # Zu Gruppe hinzufügen
        $Lernende | ForEach-Object {
            # $AdLernender = Get-AdUser 

            # Klassen auslesen
            $Klassen = Get-AdGroup -SearchBase "OU=$($Config.KLASSE_OU),OU=$($Config.SCHULE_OU),$($Config.DOMAIN)" -Filter "(Name -eq '$($Config.SCHULE_OU)_$($_.Klasse)') -or (Name -eq '$($Config.SCHULE_OU)_$($_.Klasse2)')"
        
            # Aktuelle Klassen auslesen
            # $AktuelleKlassen = Get-ADPrincipalGroupMembership -Identity "CN=$($_.SamAccountName ),OU=$($Config.LERNENDE_OU),OU=$($Config.SCHULE_OU), $($Config.DOMAIN)"

            # Zu Klassen hinzufügen
            $Klassen | ForEach-Object {
                Add-ADGroupMember -Identity $_ -Member "CN=$($_.Name),OU=$($Config.KLASSE_OU),OU=$($Config.SCHULE_OU),$($Config.DOMAIN)"
                Write-Log "Füge $($_.Name) zu $($_.SamAccountName) hinzu" -Level DEBUG
            }
        }
    }
}
Set-LernendeZuKlassen