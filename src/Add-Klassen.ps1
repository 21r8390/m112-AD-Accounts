# Author: Joaquin Koller & Manuel Schumacher
# Datum: 22.05.2022
# Version: 1.4
# Funktionsbeschreibung: Erstellt pro Klasse eine AD-Groupe 
# Parameter: keine
# Bemerkungen: OUs müssen zuerst erstellt werden
#-----

# Konfigurationen und Methoden laden
. $PSScriptRoot\Config.ps1
. $PSScriptRoot\Get-Lernende.ps1

# Erstellt eine neue Klasse
Function Add-Klasse {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Klasse # Name der Klasse
    )
    process {
        # Klasse erstellen
        New-AdGroup -Name $Klasse `
            -GroupCategory Security `
            -GroupScope Global `
            -Path "OU=$($Config.KLASSE_OU),OU=$($Config.SCHULE_OU),$($Config.DOMAIN)" `
            -Description "Klassengruppe für $Klasse"
            
        Write-Log "Klasse $Klasse wurde zum AD hinzugefügt" -Level DEBUG

        # Verzeichniss erstellen
        [string]$KlassenVerzeichnis = "$($Config.BASE_HOME_PFAD)$($Config.KLASSE_OU)\$($Klasse)"
        New-Item -Path $KlassenVerzeichnis -ItemType Directory -Force | Out-Null
        if (Test-Path $KlassenVerzeichnis) {
            # Zugriffsrechte setzen
            $Acl = Get-Acl $KlassenVerzeichnis
            $Acl.SetAccessRule($(New-Object System.Security.AccessControl.FileSystemAccessRule("$($Config.SCHULE_OU)\$Klasse", "FullControl", "Allow")))
            Set-Acl $KlassenVerzeichnis $Acl

            Write-Log "Klassen Verzeichnis $KlassenVerzeichnis erstellt" -Level DEBUG
        }
        else {
            Write-Log "Klassen Verzeichnis $KlassenVerzeichnis konnte nicht erstellt werden" -Level ERROR
        }
    }
}

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

# Synchronisiert die Klassen mit dem CSV
Function Add-Klassen {
    begin {
        # HashSet erstellen, damit keine Dupplikate
        $Klassen = New-Object System.Collections.Generic.HashSet[String]

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

        # Klassen aus AD auslesen
        $AdKlassen = Get-AdGroup -Filter '*'  -SearchBase "OU=$($Config.KLASSE_OU),OU=$($Config.SCHULE_OU), $($Config.DOMAIN)"
        Write-Log "Es wurden $($AdKlassen.Count) Klassen im AD gefunden" -Level DEBUG
    }
    
    process {
        # Wenn Klasse nicht in AD vorhanden, dann erstellen
        $Klassen | Where-Object { ! ($AdKlassen.Name -Contains $_) } | ForEach-Object {
            Add-Klasse $_
        }
        Write-Log "Klassen wurden mit dem AD synchronisiert" -Level INFO

        # Wenn Klasse nicht in CSV vorhanden, aus AD löschen
        $AdKlassen | Where-Object { ! ($Klassen -Contains $_.Name) } | ForEach-Object {
            Remove-Klasse $_
        }
    }
}
