# Author: Joaquin Koller & Manuel Schumacher
# Datum: 22.05.2022
# Version: 1.1
# Funktionsbeschreibung: Erstellt alle OrganizationalUnits
# Parameter: 
# Bemerkungen:
#-----

# Konfigurationen und Methoden laden
. $PSScriptRoot\Config.ps1

# Erstellt die Basisverzeichnisse für die Freigaben
Function New-BasisVerzeichnis {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$Pfad # Der Pfad, welcher erstellt werden sollte
    )
    process {
        if (Test-Path -Path $Pfad) {
            Write-Log "Basis Verzeichnis existiert bereits" -Level DEBUG
        }
        else {
            New-Item -Path $Pfad -ItemType Directory -Force
            Write-Log "Verzeichnis $Pfad erstellt" -Level INFO
        }
    }
}

Function Add-OUs {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false)]
        [bool]
        $Protected = $false # Wenn true, dann wird die OU geschützt
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
        # Verzeichnis für Schule erstellen
        New-BasisVerzeichnis $Config.BASE_HOME_PFAD

        if (!(Get-ADOrganizationalUnit -Filter "Name -like '$($Config.KLASSE_OU)'" -SearchBase "OU=$($Config.SCHULE_OU),$($Config.DOMAIN)")) {
            # Organizational Unit für Klasse erstellen
            New-ADOrganizationalUnit -Name $Config.KLASSE_OU -Path "OU=$($Config.SCHULE_OU),$($Config.DOMAIN)" -ProtectedFromAccidentalDeletion $Protected
            Write-Log "Organizational Unit $($Config.KLASSE_OU) erstellt" -Level INFO
        }
        else {
            Write-Log "Die Organizational Unit $($Config.SCHULE_OU + "/" + $Config.KLASSE_OU) existiert bereits" -Level DEBUG
        }
        # Verzeichnis für Klassen erstellen
        New-BasisVerzeichnis ($Config.BASE_HOME_PFAD + $Config.KLASSE_OU)

        if (!(Get-ADOrganizationalUnit -Filter "Name -like '$($Config.LERNENDE_OU)'" -SearchBase "OU=$($Config.SCHULE_OU),$($Config.DOMAIN)")) {
            # Organizational Unit für Lernende erstellen
            New-ADOrganizationalUnit -Name $Config.LERNENDE_OU -Path "OU=$($Config.SCHULE_OU),$($Config.DOMAIN)" -ProtectedFromAccidentalDeletion $Protected
            Write-Log "Organizational Unit $($Config.LERNENDE_OU) erstellt" -Level INFO
        }
        else {
            Write-Log "Die Organizational Unit $($Config.SCHULE_OU + "/" + $Config.LERNENDE_OU) existiert bereits" -Level DEBUG
        }
        # Verzeichnis für Lernende erstellen
        New-BasisVerzeichnis ($Config.BASE_HOME_PFAD + $Config.LERNENDE_OU)
    }
}