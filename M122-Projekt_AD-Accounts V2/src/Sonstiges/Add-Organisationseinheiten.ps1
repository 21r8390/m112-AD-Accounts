# Author: {{ author }}
# Datum: {{ date }}
# Version: 1.3
# Funktionsbeschreibung: Erstellt alle Organisationseinheiten
# Parameter: ProtectedFromAccidentalDeletion - sollten die OUs vor dem Löschen geschützt sein
# Bemerkungen:
#-----

# Konfigurationen laden
. .\Config.ps1

function Add-OU {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $OUName, # Name der OU
        [Parameter(Mandatory = $false)]
        [string]
        $BaseOU = $Config.DOMAIN, # Name der OU
        [Parameter(Mandatory = $false)]
        [bool]
        $Protected = $false # Sollten die OUs geschützt sein
    )

    begin {
        # Parameter validieren
        if ([string]::IsNullOrWhiteSpace($OUName)) {
            Write-Log "OU-Name darf nicht null oder leer sein!" -Level FEHLER
            return;
        }

        Write-Log "Erstelle Organisationseinheit '$OUName' in '$BaseOU'" -Level DEBUG
    }
    
    process {
        # OU nur erstellen, wenn sie nicht bereits existiert
        if (!(Get-ADOrganizationalUnit -Filter "Name -like '$OUName'" -SearchBase $BaseOU)) {
            New-ADOrganizationalUnit -Name $OUName -Path $BaseOU -ProtectedFromAccidentalDeletion $Protected
            Write-Log "Organisationseinheit '$OUName' erstellt" -Level INFO
        }
        else {
            Write-Log "Die Organisationseinheit '$OUName' existiert bereits" -Level DEBUG
        }   
    }
}

function Add-Organisationseinheiten {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false)]
        [bool]
        $ProtectedFromAccidentalDeletion = $false # Sollten die OUs geschützt sein
    )

    process {
        # OUs aus Basisdomäne erstellen
        $Domain = $Config.DOMAIN
        [regex]::Matches($Config.DOMAIN, 'OU=\w+', 'RightToLeft') | ForEach-Object {
            $Name = $_.Value -replace 'OU=', ''
            $Domain = $Domain -replace "$($_.Value),", ''
            Add-OU $Name -BaseOU $Domain -Protected $ProtectedFromAccidentalDeletion
        }
        
        # Klassen OU erstellen
        Add-OU $Config.OU_KLASSE -Protected $ProtectedFromAccidentalDeletion
        
        # Lernende OU erstellen
        Add-OU $Config.OU_LERNENDE -Protected $ProtectedFromAccidentalDeletion
    }
}