# Author: Joaquin Koller & Manuel Schumacher
# Datum: 22.05.2022
# Version: 1.5
# Funktionsbeschreibung: Erstellt pro Klasse eine AD-Gruppe
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
            $Acl.SetAccessRuleProtection($True, $False)
            Set-Acl $KlassenVerzeichnis $Acl

            Write-Log "Klassen Verzeichnis $KlassenVerzeichnis erstellt" -Level DEBUG
        }
        else {
            Write-Log "Klassen Verzeichnis $KlassenVerzeichnis konnte nicht erstellt werden" -Level ERROR
        }
    }
}

# Fügt Klassen aus dem CSV zum AD hinzu
Function Add-Klassen {
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
        $Klassen = $Klassen | Where-Object { ! ($AdKlassen.Name -Contains $_) }

        # Wenn Klasse nicht in AD vorhanden, dann erstellen
        foreach ($Klasse in $Klassen) {
            Add-Klasse $Klasse
        }
        Write-Log "$($Klassen.Count) Klassen wurden zum AD hinzugefügt" -Level INFO
    }
}
