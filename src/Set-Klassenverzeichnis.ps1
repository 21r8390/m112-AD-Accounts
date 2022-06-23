# Author: Joaquin Koller & Manuel Schumacher
# Datum: 22.06.2022
# Version: 1.0
# Funktionsbeschreibung: Benennt das Klassenverzeichnis um
# Parameter: keine
# Bemerkungen: Benutzereingaben werden erwartet
#-----

# Konfigurationen und Methoden laden
. $PSScriptRoot\Config.ps1

# Benennt das Klassenverzeichnisse um.
Function Set-KlassenVerzeichnis {
    begin {
        # Fragt den Benutzer ab
        [string]$OldName = Read-Host "Alter Verzeichnisname: "
        [string]$NewName = Read-Host "Neuer Verzeichnisname: "
        Write-Log "Benutzereingaben: Alter Verzeichnisname: $OldName / Neuer Verzeichnisname $NewName" -Level DEBUG

        # Pfad zum Verzeichnis das umbenannt wird
        [string]$OldDirectory = "$($Config.BASE_HOME_PFAD)$($Config.KLASSE_OU)\$($OldName)"
        # Pfad mit neuem Verzeichnisname
        [string]$NewDirectory = "$($Config.BASE_HOME_PFAD)$($Config.KLASSE_OU)\$($NewName)"
    }
    process {
        if (!Test-Path -Path $OldDirectory) {
            Write-Log "Altes Verzeichnis $OldDirectory existiert nicht" -Level ERROR
            return
        }

        # Testet ob das Verzeichnis bereits existiert
        if (Test-Path -Path $NewDirectory) {
            Write-Log "Das Verzeichnis existiert bereits" -Level WARN
        }
        else {
            # Nennt das Verzeichnis um
            Rename-Item -Path $OldDirectory -NewName $NewName
            Write-Log "Verzeichnis $OldDirectory wurde umbenannt in $NewDirectory" -Level INFO
        }
        
    }
}