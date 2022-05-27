# Author: Joaquin Koller & Manuel Schumacher
# Datum: 22.05.2022
# Version: 1.4
# Funktionsbeschreibung: Erstellt pro Lernende/Lernender einen AD-Account in die OU **BZTF/Lernende** 
# Parameter: keine
# Bemerkungen: OUs müssen zuerst erstellt werden
#-----

# Konfigurationen und Methoden laden
. $PSScriptRoot\Config.ps1
. $PSScriptRoot\Get-Lernende.ps1

Function Add-Lernende {
    begin {
        # Importiert alle Schüler als Liste
        $Lernende = Get-Lernende
        Write-Log "Es wurden $($Lernende.Count) Lernende im CSV gefunden" -Level DEBUG
    }
    
    process {

    }
}