# Author: Joaquin Koller & Manuel Schumacher
# Datum: 22.05.2022
# Version: 1.4
# Funktionsbeschreibung: Erstellt pro Lernende/Lernender einen AD-Account in die OU **BZTF/Lernende** 
# Parameter: keine
# Bemerkungen: 
#-----

# Konfigurationen und Methoden laden
. $PSScriptRoot\Config.ps1
. $PSScriptRoot\Get-Schueler.ps1

Function New-AdAccounts {
    begin {
        # Importiert alle Schüler als Liste
        $users = Get-Schueler
    }
    
    process {
        # Erstellt die AD-Accounts wenn User nicht existiert
        $users | ForEach-Object {
            if ($null -eq ([ADSISearcher] "(sAMAccountName=$($_.Username))").FindOne()) {
                New-ADUser -Name $_.Username -path "OU=$($Config.USER_OU), $($Config.DOMAIN)" -AccountPassword ($Config.USER_PW) -Enabled $true
            }
            else {
                Write-Log "Der User: $($_.Username) existiert bereits." -Level INFO
            }
        }     
    }
}