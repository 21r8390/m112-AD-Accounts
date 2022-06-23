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

# Einzigartier UPN erstellen
function Get-UniqueUPN {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $Lernender, # Lernender, der den UPN erstellen möchte
        [Parameter(Mandatory = $true)]
        $ExistierendeUPN # UPNs, die bereits existieren
    )
    process {
        # UserPrincipalName erstellen
        [string]$Upn = "@"
        ($Config.DOMAIN | Select-String -Pattern "(DC=)[\w]+" -AllMatches).Matches | ForEach-Object {
            # Domain Teil
            if (!$Upn.EndsWith("@")) {
                $Upn += "."
            }
            $Upn += $_.Value.Substring(3, $_.Value.Length - 3) 
        } 

        # Einzigartigkeit gewährleisten
        [string]$beginning = $Lernender.GivenName + "." + $Lernender.Surname
        if ($ExistierendeUPN.Contains($beginning + $Upn)) {
            [int]$index = 1
            while ($ExistierendeUPN.Contains("$beginning-$index$Upn")) {
                $index++
            }
            $Upn = "$beginning-$index$Upn"
        }
        else {
            $Upn = $beginning + $Upn
        }
        # Zu existierende UPNs hinzufügen
        $ExistierendeUPN.Add($Upn) | Out-Null
        Write-Log "Einzigartiger UPN $Upn wurde erstellt!" -Level DEBUG

        return $Upn
    }
}

# Erstellt ein Home-Verzeichnis für den Lernender
Function New-HomeVerzeichnis {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $Lernender # Lernenden für den das Home-Verzeichnis erstellt werden soll
    )
    
    begin {
        [string]$HomeVerzeichnis = "$($Config.BASE_HOME_PFAD)$($Config.LERNENDE_OU)\$($Lernender.SamAccountName)"
    }
    
    process {
        if (Test-Path $HomeVerzeichnis) {
            # Home Verzeichnis existiert bereits
            Write-Log "Home Verzeichnis $HomeVerzeichnis existiert bereits. Keines wird hinterlegt!" -Level ERROR
            return
        }
        else {
            # Home Verzeichnis erstellen
            New-Item -Path $HomeVerzeichnis -ItemType Directory -Force | Out-Null
            Write-Log "Home Verzeichnis $HomeVerzeichnis wurde erstellt!" -Level DEBUG
        }

        # Berechtigungen setzen
        if (Test-Path $HomeVerzeichnis) {
            # Zugriffsrechte setzen
            $Acl = Get-Acl $HomeVerzeichnis
            $Acl.SetAccessRule($(New-Object System.Security.AccessControl.FileSystemAccessRule("$($Config.SCHULE_OU)\$($Lernender.SamAccountName)", "FullControl", "Allow")))
            # Vererbungsrechte deaktivieren
            $Acl.SetAccessRuleProtection($True, $False)
            Set-Acl $HomeVerzeichnis $Acl
    
            Write-Log "Berechtigungen für Home Verzeichnis $HomeVerzeichnis wurden erstellt" -Level DEBUG
        }
        else {
            Write-Log "Berechtigungen für Home Verzeichnis $HomeVerzeichnis konnten nicht gesetzt werden" -Level WARN
        }

        # Home Verzeichnis setzen
        Set-AdUser $Lernender -HomeDrive "H:" -HomeDirectory "H:\$($Lernender.SamAccountName)" -ProfilePath $HomeVerzeichnis
    }
}

# Fügt einen AD-Account hinzu
Function Add-Lernender {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $Lernender, # Lernender, welcher zum Ad hinzufügt werden soll
        [Parameter(Mandatory = $true)]
        [System.Collections.Generic.HashSet[string]]$ExistierendeUPN # Lernende aus dem AD
    )    
    process {
        [string]$Upn = Get-UniqueUPN $Lernender $ExistierendeUPN

        # Lernender hinzufügen
        New-ADUser -GivenName $Lernender.GivenName `
            -Surname $Lernender.Surname `
            -Initials ($Lernender.GivenName.Substring(0, 1) + $Lernender.Surname.Substring(0, 2)).ToUpper() `
            -DisplayName ($Lernender.GivenName + " " + $Lernender.Surname) `
            -Name $Lernender.SamAccountName `
            -SamAccountName $Lernender.SamAccountName `
            -UserPrincipalName $Upn `
            -Office $Config.SCHULE_OU `
            -AccountPassword $Config.STANDARD_PW `
            -ChangePasswordAtLogon $Config.CHANGE_PASSWORD_AT_LOGON `
            -Path "OU=$($Config.LERNENDE_OU),OU=$($Config.SCHULE_OU), $($Config.DOMAIN)" `
            -Enabled $Config.USER_ENABLED
            
        # Home Verzeichnis erstellen
        New-HomeVerzeichnis (Get-ADUser -Identity $Lernender.SamAccountName)

        Write-Log "Lernender $($Lernender.SamAccountName) wurde zum AD hinzugefügt" -Level INFO
    }
}

# Fügt einen AD-Account hinzu 
Function Add-Lernende {
    begin {
        # Alle Lernende und Klassen aus CSV
        $Lernende = Get-Lernende
        Write-Log "Es wurden $($Lernende.Count) Lernende im CSV gefunden" -Level DEBUG

        # Lernende aus AD auslesen
        $AdLernende = Get-AdUser -Filter '*' -SearchBase "OU=$($Config.LERNENDE_OU),OU=$($Config.SCHULE_OU), $($Config.DOMAIN)"
        if ($AdLernende) {
            Write-Log "Es wurden $($AdLernende.Count) Klassen im AD gefunden" -Level DEBUG
        }
        else {
            $AdLernende = @()
            Write-Log "Es wurden keine Lernende im AD gefunden" -Level DEBUG
        }
    }
    
    process {
        # Sucht lernende aus dem AD heraus
        $ComparedLernende = Compare-Object -ReferenceObject $AdLernende -DifferenceObject $Lernende -Property SamAccountName -IncludeEqual

        # Lernende, welche neu im CSV sind
        $NeueLernende = $ComparedLernende | Where-Object { $_.SideIndicator -eq '=>' }

        # Existierende UserPrincipalNames auslesen (Keine Dupplikate)
        [System.Collections.Generic.HashSet[string]]$ExistierendeUPN = New-Object System.Collections.Generic.HashSet[string]
        $AdLernende | ForEach-Object {
            $ExistierendeUPN.Add($_.UserPrincipalName) | Out-Null
        }
        # Wenn Leer, dann leer setzen
        if ($ExistierendeUPN.Count -le 0) {
            $ExistierendeUPN.Add(" ")
            Write-Log "Es existieren keine bisherigen AD Lernende" -Level DEBUG
        }

        # Neue Lernende hinzufügen
        foreach ($Lernender in $Lernende | Where-Object { $_.SamAccountName -in $NeueLernende.SamAccountName } ) {
            Add-Lernender $Lernender $ExistierendeUPN
        }
        Write-Log "$($NeueLernende.Count) Lernende wurden zum AD hinzugefügt" -Level INFO
    }
}