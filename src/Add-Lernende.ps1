# Author: Joaquin Koller & Manuel Schumacher
# Datum: 22.05.2022
# Version: 1.6
# Funktionsbeschreibung: Erstellt pro Lernende/Lernender einen AD-Account in die OU **BZTF/Lernende** 
# Parameter: keine
# Bemerkungen: OUs müssen zuerst erstellt werden
#-----

# Konfigurationen und Methoden laden
. $PSScriptRoot\Config.ps1
. $PSScriptRoot\Get-Lernende.ps1

# Fügt einen AD-Account hinzu
Function Add-NewAdLernender {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $Lernender # Lernender, welcher zum Ad hinzufügt werden soll
    )    
    process {
        # Home Verzeichnis erstellen
        [string]$HomeVerzeichnis = "$($Config.BASE_HOME_PFAD)$($Config.LERNENDE_OU)\$($Lernender.SamAccountName)"
        New-Item -Path $HomeVerzeichnis -ItemType Directory -Force | Out-Null
        if (Test-Path $HomeVerzeichnis) {
            # Zugriffsrechte setzen
            $Acl = Get-Acl $HomeVerzeichnis
            $Acl.SetAccessRule($(New-Object System.Security.AccessControl.FileSystemAccessRule("$($Config.SCHULE_OU)\$($Lernender.SamAccountName)", "FullControl", "Allow")))
            Set-Acl $HomeVerzeichnis $Acl

            Write-Log "Home Verzeichnis $HomeVerzeichnis erstellt" -Level DEBUG
        }
        else {
            Write-Log "Home Verzeichnis $HomeVerzeichnis konnte nicht erstellt werden" -Level ERROR
        }

        # Lernender hinzufügen
        New-ADUser -GivenName $Lernender.GivenName `
            -Surname $Lernender.Surname `
            -Initials ($Lernender.GivenName.Substring(0, 1) + $Lernender.Surname.Substring(0, 2)).ToUpper() `
            -DisplayName ($Lernender.GivenName + " " + $Lernender.Surname) `
            -Name $Lernender.SamAccountName `
            -SamAccountName $Lernender.SamAccountName `
            -UserPrincipalName "$($Lernender.GivenName + "." + $Lernender.Surname)@$($Config.SCHULE_OU)" `
            -Office $Config.SCHULE_OU `
            -AccountPassword $Config.STANDARD_PW `
            -ChangePasswordAtLogon $Config.CHANGE_PASSWORD_AT_LOGON `
            -HomeDrive "H:" `
            -HomeDirectory $HomeVerzeichnis `
            -Path "OU=$($Config.LERNENDE_OU),OU=$($Config.SCHULE_OU), $($Config.DOMAIN)" `
            -Enabled $Config.USER_ENABLED
            
        Write-Log "Lernender $_ wurde zum AD hinzugefügt" -Level DEBUG
    }
}

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
        # Sucht lernende aus dem AD heraus
        $ComparedLernende = Compare-Object -ReferenceObject $AdLernende -DifferenceObject $Lernende -Property SamAccountName -IncludeEqual

        $NeueLernende = $ComparedLernende | Where-Object { $_.SideIndicator -eq '=>' }
        $Synchronisierte = $ComparedLernende | Where-Object { $_.SideIndicator -eq '==' }

        # Neue Lernende hinzufügen
        foreach ($Lernender in $Lernende | Where-Object { $_.SamAccountName -in $NeueLernende.SamAccountName } ) {
            Add-NewAdLernender $Lernender
        }
        Write-Log "$($NeueLernende.Count) Lernende wurden zum AD hinzugefügt" -Level INFO

        # Aktive Benutzer aktivieren
        foreach ($Lernender in $AdLernende | Where-Object { $_.SamAccountName -in $Synchronisierte.SamAccountName } ) {
            Set-ADUser $Lernender -Enabled $true
            Write-Log "Lernender $($Lernender.SamAccountName) wurde aktiviert" -Level DEBUG
        }
        Write-Log "$($Synchronisierte.Count) Lernende wurden aktiviert" -Level INFO
    }
}