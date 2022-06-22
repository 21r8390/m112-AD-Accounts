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

        $EntfernteLernende = $ComparedLernende | Where-Object { $_.SideIndicator -eq '<=' }

        # Entfernte Lernende deaktivieren
        foreach ($Lernender in $AdLernende | Where-Object { $_.SamAccountName -in $EntfernteLernende.SamAccountName } ) {
            Set-ADUser $Lernender -Enabled $Aktivieren
            Write-Log "Lernender $($Lernende.SamAccountName) wurde aktiviert" -Level DEBUG
        }
        Write-Log "$($EntfernteLernende.Count) Lernende wurden deaktiviert" -Level INFO
    }
}