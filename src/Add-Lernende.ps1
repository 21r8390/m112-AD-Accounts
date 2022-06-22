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
        Write-Log "Home Verzeichnis $HomeVerzeichnis erstellt" -Level DEBUG

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

# Aktiviert einen Lernenden aus dem AD
Function Set-Lernender {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $AdLernender, # Der aus dem AD Lernender, welcher aktiviert werden soll
        [Parameter(Mandatory = $true)]
        [boolean]$Aktivieren # Ob der Lernender aktiviert werden soll
    )
    process {
        # Account aktivieren
        Set-ADUser $AdLernender -Enabled $Aktivieren

        # Aktivität Loggen
        if ($Aktivieren) {
            Write-Log "Lernender $_ wurde aktiviert" -Level DEBUG
        }
        else {
            Write-Log "Lernender $_ wurde deaktiviert" -Level DEBUG
        }
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
        $ComparedLernende = Compare-Object -ReferenceObject $AdLernende -DifferenceObject $Lernende -Property SamAccountName -IncludeEqual

        $NeueLernende = $ComparedLernende | Where-Object { $_.SideIndicator -eq '=>' }
        $Synchronisierte = $ComparedLernende | Where-Object { $_.SideIndicator -eq '==' }
        $EntfernteLernende = $ComparedLernende | Where-Object { $_.SideIndicator -eq '<=' }

        # Neue Lernende hinzufügen
        foreach ($Lernender in $Lernende | Where-Object { $_.SamAccountName -in $NeueLernende.SamAccountName } ) {
            Add-NewAdLernender $Lernender
        }
        Write-Log "$($NeueLernende.Count) Lernende wurden zum AD hinzugefügt" -Level INFO

        # Aktive Benutzer aktivieren
        foreach ($Lernender in $AdLernende | Where-Object { $_.SamAccountName -in $Synchronisierte.SamAccountName } ) {
            Set-Lernender $Lernender $true
        }
        Write-Log "$($Synchronisierte.Count) Lernende wurden aktiviert" -Level INFO

        # Entfernte Lernende deaktivieren
        foreach ($Lernender in $AdLernende | Where-Object { $_.SamAccountName -in $EntfernteLernende.SamAccountName } ) {
            Set-Lernender $Lernender $false
        }
        Write-Log "$($EntfernteLernende.Count) Lernende wurden deaktiviert" -Level INFO
    }
}