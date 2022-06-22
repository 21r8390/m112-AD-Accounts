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

# Home Verzeichnis erstellen
# StackOverflow: https://stackoverflow.com/questions/39384502/create-and-map-home-directory-for-ad-users-using-powershell
Function New-HomeVerzeichnis {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$SamAccountName # Accountname des Lernenden
    )
    process {
        # Home Verzeichnis erstellen
        [string]$HomeDir = "$($Config.BASE_HOME_PFAD)/$($Config.LERNENDE_OU)/$($Lernender.SamAccountName)"
        New-Item -Path $HomeDir -ItemType Directory -Force

        # Berechtigungen setzen
        $AclOb = New-Object System.Security.AccessControl.FileSystemAccessRule("$($Config.SCHULE_OU)\$($Lernender.SamAccountName)", 'FullAccess', 'ContainerInherit,ObjectInherit', 'None', 'Allow')   
        Set-Acl $HomeDir $AclOb

        # Home Verzeichnis zurückgeben
        return $HomeDir
    }
}

# Fügt einen AD-Account hinzu
Function Add-NewAdLernender {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $Lernender # Die Lernenden, welche noch nicht im AD vorhanden sind
    )    
    process {
        # Properties erstellen
        $AdUserProps = @{
            GivenName             = $Lernender.GivenName
            Surname               = $Lernender.Surname
            DisplayName           = ($Lernender.GivenName + " " + $Lernender.Surname)
            Name                  = $Lernender.SamAccountName
            SamAccountName        = $Lernender.SamAccountName
            UserPrincipalName     = "$($Lernender.GivenName + "." + $Lernender.Surname)@$($Config.SCHULE_OU)"
            Departement           = $Config.SCHULE_OU
            Office                = $Config.SCHULE_OU
            AccountPassword       = $Config.STANDARD_PW
            ChangePasswordAtLogon = $Config.CHANGE_PASSWORD_AT_LOGON
            HomeDrive             = "H:"
            HomeDirectory         = (New-HomeVerzeichnis $Lernender.SamAccountName)
            Path                  = "OU=$($Config.LERNENDE_OU),OU=$($Config.SCHULE_OU), $($Config.DOMAIN)"
            Enabled               = $Config.USER_ENABLED
            Confirm               = $false
        }

        # Lernender hinzufügen
        New-AdUser $AdUserProps
        Write-Log "Lernender $_ wurde zum AD hinzugefügt" -Level DEBUG
    }
}

# Aktiviert einen lernenden
Function Set-Lernender {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $Lernender, # Der Lernender, welcher aktiviert werden soll
        [Parameter(Mandatory = $true)]
        [boolean]$Aktivieren # Ob der Lernender aktiviert werden soll
    )
    process {
        # Account aktivieren
        Set-ADUser -SamAccountName $Lernender.SamAccountName -Enabled $Aktivieren

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
        $ComparedLernende = Compare-Object -ReferenceObject $AdLernende -DifferenceObject $Lernende -IncludeEqual

        $NeueLernende = $ComparedLernende | Where-Object { $_.SideIndicator -eq '=>' }
        $Synchronisierte = $ComparedLernende | Where-Object { $_.SideIndicator -eq '==' }
        $EntfernteLernende = $ComparedLernende | Where-Object { $_.SideIndicator -eq '<=' }

        # Neue Lernende hinzufügen
        foreach ($Lernender in $NeueLernende) {
            Add-NewAdLernender $Lernender.InputObject
        }
        Write-Log "$($NeueLernende.Count) Lernende wurden zum AD hinzugefügt" -Level INFO

        # Aktive Benutzer aktivieren
        foreach ($Lernender in $Synchronisierte) {
            Set-Lernender $Lernender.InputObject $true
        }
        Write-Log "$($NeueLernende.Count) Lernende wurden aktiviert" -Level INFO

        # Entfernte Lernende deaktivieren
        foreach ($Lernender in $EntfernteLernende) {
            Set-Lernender $Lernender.InputObject $false
        }
        Write-Log "$($NeueLernende.Count) Lernende wurden deaktiviert" -Level INFO
    }
}

Add-Lernende