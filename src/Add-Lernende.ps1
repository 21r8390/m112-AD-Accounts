# Author: Joaquin Koller & Manuel Schumacher
# Datum: 22.05.2022
# Version: 1.4
# Funktionsbeschreibung: Erstellt pro Lernende/Lernender einen AD-Account in die OU **BZTF/Lernende** 
# Parameter: keine
# Bemerkungen: OUs müssen zuerst erstellt werden
#-----

# Konfigurationen und Methoden laden
. $PSScriptRoot\Config.ps1
. $PSScriptRoot\Get-Lernende.ps1

Function Add-Lernende {
    begin {
        # Alle Lernende und Klassen aus CSV
        $Lernende = Get-Lernende
        Write-Log "Es wurden $($Lernende.Count) Lernende im CSV gefunden" -Level DEBUG

        # Lernende aus AD auslesen
        $AdLernende = Get-AdUser -Filter '*'  -SearchBase "OU=$($Config.LERNENDE_OU),OU=$($Config.SCHULE_OU), $($Config.DOMAIN)"
        Write-Log "Es wurden $($AdLernende.Count) Klassen im AD gefunden" -Level DEBUG
    }
    
    process {
        # Wenn Lerndende nicht in AD vorhanden, dann erstellen
        $Lernende | Where-Object { !($AdLernende.SamAccountName -Contains $_.SamAccountName) } | ForEach-Object {
            # TODO: Lernende aktivieren, wenn vorhanden ❗

            # Lernende erstellen
            New-AdUser -Name $_.SamAccountName -GivenName $_.GivenName -Surname $_.Surname -DisplayName ($_.GivenName + " " + $_.Surname) -SamAccountName $_.SamAccountName -UserPrincipalName "$($_.SamAccountName)@$($Config.DOMAIN)"
            -Office $Config.SCHULE_OU -AccountPassword  $Config.STANDARD_PW -ChangePasswordAtLogon $Config.ChangePasswordAtLogon -Path "OU=$($Config.LERNENDE_OU),OU=$($Config.SCHULE_OU), $($Config.DOMAIN)" -Enabled $True
            Write-Log "Lernender $_ wurde zum AD hinzugefügt" -Level DEBUG
        }
        Write-Log "Lernende wurden mit dem AD synchronisiert" -Level INFO

        # Wenn Lernende in AD vorhanden, dann überprüfen, ob sie aktiviert sind
        $AdLernende | Where-Object { ($_.Enabled -eq $False) -and ($Lernende.SamAccountName -Contains $_.SamAccountName) } | ForEach-Object {
            # Lernende aktivieren
            $_ | Set-ADUser -Enabled $True 
            Write-Log "Lernender $_ wurde aktiviert" -Level INFO
        }

        # Wenn Lerndende nicht in CSV vorhanden, dann deaktivieren
        $AdLernende | Where-Object { ($_.Enabled -eq $True) -and (!($Lernende.SamAccountName -Contains $_.SamAccountName)) } | ForEach-Object {
            # Lernender deaktivieren
            $_ | Set-ADUser -Enabled $False
            Write-Log "Lernender $_ wurde im AD deaktiviert" -Level WARN
        }
    }
}