# Author: Joaquin Koller & Manuel Schumacher
# Datum: 22.05.2022
# Version: 1.6
# Funktionsbeschreibung: Benennt ein Home Verzeichnis eines Lernenden um
# Parameter: (Optional) Der Benutzername des Lernenden
#            (Optional) Das neue Home Verzeichnis des Lernenden
# Bemerkungen: Benutzereingaben werden erwartet
#-----

# Konfigurationen und Methoden laden
. $PSScriptRoot\Config.ps1


Function Set-HomeVerzeichnis {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$AdUsername, # Der Benutzername des Lernenden
        [Parameter(Mandatory = $false)]
        [string]$HomeVerzeichnis # Das neue Home Verzeichnis des Lernenden
    )
    
    begin {
        # Lernende aus AD auslesen
        $AdLernende = Get-AdUser -Filter '*' -Properties ProfilePath -SearchBase "OU=$($Config.LERNENDE_OU),OU=$($Config.SCHULE_OU), $($Config.DOMAIN)"
        Write-Log "Es wurden $($AdLernende.Count) Klassen im AD gefunden" -Level DEBUG
    }
    
    process {
        # Benutzername abfragen (Leer nicht erlaubt)
        while (-not $AdUsername ) {
            $AdUsername = Read-Host "Von welchem Lernenden sollte das Home Verzeichnis umbenannt werden? (Vorname.Nachname)"
        }
        Write-Log "Benutzer $AdUsername wird umbenannt" -Level DEBUG

        # Lernende aus AD auslesen
        $AdLernender = $AdLernende | Where-Object { $_.UserPrincipalName -eq "$AdUsername@$($Config.SCHULE_OU)" } | Select-Object -First 1

        if (-not $AdLernender) {
            # Unbekannter Lernender
            Write-Log "Der Benutzer $AdUsername wurde im AD nicht gefunden" -Level ERROR
            return;
        }

        # Neues Home Verzeichnis abfragen (Leer nicht erlaubt)
        while (-not $HomeVerzeichnis) {
            $HomeVerzeichnis = Read-Host "Wie sollte das neue Home Verzeichnis heissen? (Ordnername)"
        }

        # Testen, ob Verzeichnis bereits von einem anderen Lernenden verwendet wird
        $HomeVerzeichnis = "$($Config.BASE_HOME_PFAD)$($Config.LERNENDE_OU)\$HomeVerzeichnis"
        if (Test-Path $HomeVerzeichnis) {
            Write-Log "Das Home Verzeichnis $HomeVerzeichnis existiert bereits" -Level ERROR
            return;
        }

        # Wenn Pfad vorhanden, dann umbenennen, ansonsten neues Verzeichnis erstellen
        [string]$OldHomePfad = $AdLernender.ProfilePath
        if (Test-Path -Path $OldHomePfad) {
            # Home Verzeichnis umbenennen
            Rename-Item -Path $OldHomePfad -NewName $HomeVerzeichnis -Force
            Write-Log "Home Verzeichnis $OldHomePfad wurde zu $HomeVerzeichnis umbenannt" -Level DEBUG
        }
        else {
            # Neues Verzeichnis erstellen
            [string]$HomeVerzeichnis = "$($Config.BASE_HOME_PFAD)$($Config.LERNENDE_OU)\$($Lernender.SamAccountName)"
            New-Item -Path $HomeVerzeichnis -ItemType Directory -Force | Out-Null
            # Zugriffsrechte setzen
            $Acl = Get-Acl $HomeVerzeichnis
            $Acl.SetAccessRule($(New-Object System.Security.AccessControl.FileSystemAccessRule("$($Config.SCHULE_OU)\$($Lernender.SamAccountName)", "FullControl", "Allow")))
            # Vererbungsrechte deaktivieren
            $Acl.SetAccessRuleProtection($True, $False)
            Set-Acl $HomeVerzeichnis $Acl
    
            Write-Log "Home Verzeichnis $HomeVerzeichnis für $AdUsername erstellt" -Level DEBUG
        }

        # AD User aktualisieren
        Set-AdUser $AdLernender -ProfilePath $HomeVerzeichnis
        Write-Log "Home Verzeichnis $($AdLernender.ProfilePath) des Lernenden $($AdLernender.SamAccountName) wurde umbenannt zu $HomeVerzeichnis" -Level INFO
    }
}