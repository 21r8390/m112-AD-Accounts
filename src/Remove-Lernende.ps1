# Author: Joaquin Koller & Manuel Schumacher
# Datum: 22.05.2022
# Version: 1.6
# Funktionsbeschreibung: Löscht alle Lerndende, welche nicht mehr im XML sind
# Parameter: keine
# Bemerkungen: OUs müssen zuerst erstellt werden
#-----

# Konfigurationen und Methoden laden
. $PSScriptRoot\Config.ps1
. $PSScriptRoot\Get-Lernende.ps1

Function Remove-Lernende {
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

        # Entfernt Lernende, welche nicht mehr im XML sind
        $EntfernteLernende = $ComparedLernende | Where-Object { $_.SideIndicator -eq '<=' }

        # Lernende heraussuchen, welche nicht mehr im AD sind und aktiv sind
        $AdLernende = $AdLernende | Where-Object { $_.SamAccountName -in $EntfernteLernende.SamAccountName -and $_.Enabled }
        
        # Entfernte Lernende deaktivieren
        foreach ($Lernender in  $AdLernende) {
            Set-ADUser $Lernender -Enabled $false
            Write-Log "Lernender $($Lernender.SamAccountName) wurde deaktiviert" -Level DEBUG
        }
        Write-Log "$($AdLernende.Count) Lernende wurden deaktiviert" -Level INFO
    }
}