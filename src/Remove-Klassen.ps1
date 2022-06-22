# Author: Joaquin Koller & Manuel Schumacher
# Datum: 22.06.2022
# Version: 1.4
# Funktionsbeschreibung: Löscht die Klassen, welche nicht mehr im XML sind  
# Parameter: keine
# Bemerkungen: OUs müssen zuerst erstellt werden
#-----

# Konfigurationen und Methoden laden
. $PSScriptRoot\Config.ps1
. $PSScriptRoot\Get-Lernende.ps1

function Remove-Klasse {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $AdKlasse  # Name der AD Klasse
    )
    process {
        # Klasse ohne Bestätigung löschen
        Remove-ADGroup $AdKlasse -Confirm:$false

        # Verzeichniss löschen
        [string]$KlassenVerzeichnis = "$($Config.BASE_HOME_PFAD)$($Config.KLASSE_OU)\$($Klasse.Name)"
        Remove-Item $KlassenVerzeichnis -Force -Recurse -ErrorAction SilentlyContinue | Out-Null
        if (Test-Path -Path $KlassenVerzeichnis) {
            Write-Log "Verzeichnis '$KlassenVerzeichnis' der Klasse $($Klasse.Name) wurde gelöscht" -Level DEBUG
        }
        else {
            Write-Log "Verzeichnis '$KlassenVerzeichnis' der Klasse $($Klasse.Name) konnte nicht gelöscht werden" -Level ERROR
        }

        # Warnung ausgeben
        Write-Log "Klasse $($AdKlasse.Name) wurde aus dem AD gelöscht" -Level WARN
    }
}

# Löscht Klassen, die nicht mehr im CSV sind aus dem AD 
Function Remove-Klassen {
    begin {
        # HashSet erstellen, damit keine Dupplikate
        $Klassen = New-Object System.Collections.Generic.HashSet[String]

        # Klassen aus AD auslesen
        $AdKlassen = Get-AdGroup -Filter '*'  -SearchBase "OU=$($Config.KLASSE_OU),OU=$($Config.SCHULE_OU), $($Config.DOMAIN)"
        Write-Log "Es wurden $($AdKlassen.Count) Klassen im AD gefunden" -Level DEBUG
    }
    
    process {
        # Alle Klassen aus CSV
        Get-Lernende | ForEach-Object {
            # Zur HashSet hinzugügen, wenn nicht leer
            if (! [string]::IsNullOrEmpty($_.Klasse)) {
                $Klassen.Add($Config.SCHULE_OU + "_" + $_.Klasse) | Out-Null # Ausgabemeldung verhindern
            }
            if (! [string]::IsNullOrEmpty($_.Klasse2)) {
                $Klassen.Add($Config.SCHULE_OU + "_" + $_.Klasse2) | Out-Null # Ausgabemeldung verhindern
            }
        }
        Write-Log "Es wurden $($Klassen.Count) Klassen im CSV gefunden" -Level DEBUG

        # Klassen filtern
        $AdKlassen = $AdKlassen | Where-Object { ! ($Klassen -Contains $_.Name) }

        # Wenn Klasse nicht in CSV vorhanden, aus AD löschen
        foreach ($AdKlasse in $AdKlassen) {
            Remove-Klasse $AdKlasse
        }
        Write-Log "$($AdKlassen.Count) Klassen wurden vom AD gelöscht" -Level INFO
    }
}
