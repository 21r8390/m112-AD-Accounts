# Author: Joaquin Koller & Manuel Schumacher
# Datum: 22.06.2022
# Version: 1.0
# Funktionsbeschreibung: Benennt das Klassenverzeichnise um.
# Parameter: keine
# Bemerkungen:
#-----

# Konfigurationen und Methoden laden
. $PSScriptRoot\Config.ps1

# Benennt das Klassenverzeichnisse um.
Function Set-Klassenverzeichnis {
    begin{
        # Fragt den Benutzer ab
        $oldName = Read-Host "Alter Verzeichnisname: "
        $newName = Read-Host "Neuer Verzeichnisname: "
        Write-Log "Benutzereingaben: Alter Verzeichnisname: $($oldName) / Neuer Verzeichnisname $($newName)" -Level INFO

        # Pfad zum Verzeichnis das umbenannt wird
        [string]$oldDirectory = "$($Config.BASE_HOME_PFAD)$($Config.KLASSE_OU)\$($oldName)"
        # Pfad mit neuem Verzeichnisname
        [string]$newDirectory = "$($Config.BASE_HOME_PFAD)$($Config.KLASSE_OU)\$($newName)"
    }
    process {
        # Testet ob das Verzeichnis bereits existiert
        if(!Test-Path -Path $newDirectory){
            # Nennt das Verzeichnis um
            Rename-Item -Path $oldDirectory -NewName $newDirectory
        }else{
            Write-Log "Das Verzeichnis existiert bereits" -Level WARN
            Write-Host "Das Verzeichnis existiert bereits!" -ForegroundColor Yellow
        }
        
    }
}