# Author: Joaquin Koller & Manuel Schumacher
# Datum: 22.05.2022
# Version: 1.1
# Funktionsbeschreibung: Erstellt pro Klasse eine AD-Groupe 
# Parameter: keine
# Bemerkungen: 
#-----

# Konfigurationen und Methoden laden
. $PSScriptRoot\Config.ps1
. $PSScriptRoot\Get-Schueler.ps1

function Add-AdGroups {
  
    begin {
        # HashSet erstellen, damit keine Dupplikate
        $Gruppen = New-Object System.Collections.Generic.HashSet[String]

        # Alle Schüler und Klassen aus CSV
        Get-Schueler | ForEach-Object {
            # Zur HashSet hinzugügen, damit eine Liste
            $Gruppen.Add($_.Klasse) | Out-Null # Ausgabemeldung verhindern
            $Gruppen.Add($_.Klasse2) | Out-Null
        }
    }
    
    process {
        # Gruppen ausgeben
        Write-Host $Gruppen

        # Gruppen auslesen
        $AdGruppen = Get-AdGroup -Filter '*'

        Write-Host "Gruppen aus AD:" $AdGruppen
        # Wenn Gruppe nicht in AD vorhanden, erstellen

        # Wenn Gruppe in AD aber nicht in CSV, löschen
    }
    
    end {
        
    }
}

Add-AdGroups