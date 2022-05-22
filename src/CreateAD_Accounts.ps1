# Author: Joaquin koller & Manuel Schumacher
# Datum: 22.05.2022
# Version: 1.4
# Funktionsbeschreibung: Erstellt pro Lernende/Lernender einen AD-Account in die OU **BZTF/Lernende** 
# Parameter: keine
# Bemerkungen: 
#-----

# Konfigurationen und Methoden laden
. $PSScriptRoot\Config.ps1
. $PSScriptRoot\ImportUsers.ps1

function CreateAD_Accounts {
    # Methode aus "ImportUsers", Importiert alle Schüler als Liste
    $users = Get-SchulerFromCSV

    # Erstellt die AD-Accounts wenn User nicht existiert.
    $users | ForEach-Object {
        if ($null -eq ([ADSISearcher] "(sAMAccountName=$($_.Username))").FindOne()) {
            New-ADUser -Name $_.Username -path "$($Config.USER_OU), $($Config.DOMAIN)" -AccountPassword ($Config.USER_PW) -Enabled $true
        }
        else {
            Write-Log "Der User: $($_.Username) existiert bereits." -Level "INFO"
        }
    }
}