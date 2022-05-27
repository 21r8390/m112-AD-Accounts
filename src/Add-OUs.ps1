# Author: Joaquin Koller & Manuel Schumacher
# Datum: 22.05.2022
# Version: 1.1
# Funktionsbeschreibung: Erstellt alle OrganizationalUnits
# Parameter: 
# Bemerkungen:
#-----

# Konfigurationen und Methoden laden
. $PSScriptRoot\Config.ps1

Function Add-OUs {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [bool]
        $Protected  # Wenn true, dann wird die OU geschützt
    )


    process {
        # OUs erstellen, falls noch nicht vorhanden
        if (!(Get-ADOrganizationalUnit -Filter "Name -like '$($Config.SCHULE_OU)'" -SearchBase $($Config.DOMAIN))) {
            # Organizational Unit für Schule erstellen
            New-ADOrganizationalUnit -Name $Config.SCHULE_OU -Path $Config.DOMAIN -ProtectedFromAccidentalDeletion $Protected
            Write-Log "Organizational Unit $($Config.SCHULE_OU) erstellt" -Level INFO
        }
        else {
            Write-Log "Die Organizational Unit $($Config.SCHULE_OU) existiert bereits" -Level DEBUG
        }

        if (!(Get-ADOrganizationalUnit -Filter "Name -like '$($Config.KLASSE_OU)'" -SearchBase "OU=$($Config.SCHULE_OU),$($Config.DOMAIN)")) {
            # Organizational Unit für Klasse erstellen
            New-ADOrganizationalUnit -Name $Config.KLASSE_OU -Path "OU=$($Config.SCHULE_OU),$($Config.DOMAIN)" -ProtectedFromAccidentalDeletion $Protected
            Write-Log "Organizational Unit $($Config.KLASSE_OU) erstellt" -Level INFO
        }
        else {
            Write-Log "Die Organizational Unit $($Config.SCHULE_OU + "/" + $Config.KLASSE_OU) existiert bereits" -Level DEBUG
        }

        if (!(Get-ADOrganizationalUnit -Filter "Name -like '$($Config.LERNENDE_OU)'" -SearchBase "OU=$($Config.SCHULE_OU),$($Config.DOMAIN)")) {
            # Organizational Unit für Lernende erstellen
            New-ADOrganizationalUnit -Name $Config.LERNENDE_OU -Path "OU=$($Config.SCHULE_OU),$($Config.DOMAIN)" -ProtectedFromAccidentalDeletion $Protected
            Write-Log "Organizational Unit $($Config.LERNENDE_OU) erstellt" -Level INFO
        }
        else {
            Write-Log "Die Organizational Unit $($Config.SCHULE_OU + "/" + $Config.LERNENDE_OU) existiert bereits" -Level DEBUG
        }
    }
}