# Author: Joaquin Koller & Manuel Schumacher
# Datum: 10.05.2022
# Version: 1.2
# Funktionsbeschreibung: Aktiviert Accounts, welche im CSV sind 
# Parameter: keine
# Bemerkungen: OUs müssen zuerst erstellt werden
#-----

# Konfigurationen und Methoden laden
. $PSScriptRoot\Config.ps1
. $PSScriptRoot\Get-Lernende.ps1


# Aktiviert die Lernende aus dem CSV
Function Set-Lernende {
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

        # Lernende, welche bereits im AD sind
        $Synchronisierte = $ComparedLernende | Where-Object { $_.SideIndicator -eq '==' }

        # Aktiviert Lernende, welche im AD und nicht aktiviert sind
        $AdLernende = $AdLernende | Where-Object { $_.SamAccountName -in $Synchronisierte.SamAccountName -and (-not $_.Enabled) }

        # Existierende Benutzer aktivieren
        foreach ($Lernender in $AdLernende ) {
            Set-ADUser $Lernender -Enabled $true
            Write-Log "Lernender $($Lernender.SamAccountName) wurde aktiviert" -Level DEBUG
        }
        Write-Log "$($AdLernende.Count) Lernende wurden aktiviert" -Level INFO
    }
}