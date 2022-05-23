# Author: Joaquin Koller & Manuel Schumacher
# Datum: 16.05.2022
# Version: 1.3
# Funktionsbeschreibung: Konfigurationsdatei für statische Werte & Methoden
# Parameter: keine
# Bemerkungen: Relative Pfade werden in absoulte Pfade umgewandelt
#-----

# Konfigurations Variablen
$Config = @{
    XML_PFAD  = ("assets\schueler.xml" |  Resolve-Path); # Pfad zur XML-Datei 
    CSV_PFAD  = ("assets\schueler.csv" |  Resolve-Path); # Pfad in welcher die CSV-Werte gespeichert werden sollen
    LOG_PFAD  = ""; # Pfad in welcher die Logs gespeichert werden sollen
    DELIMITER = ";"; # Trennzeichen für CSV-Datei
    DOMAIN    = "DC=bztf, DC=local";
    USER_OU   = "OU=lernende,OU=bzt"; 
    USER_PW   = ConvertTo-SecureString "bztf.001" -AsPlainText -Force; # Standard Passwort
}

# Log Methode 
# Stackoverflow: https://stackoverflow.com/a/38738942/16632604
Function Write-Log {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [String]
        $Meldung, # Meldung, welche geloggt werden sollte

        [Parameter(Mandatory = $False)]
        [ValidateSet("INFO", "WARN", "ERROR", "FATAL", "DEBUG")] # Gültige Log-Levels
        [String]
        $Level = "INFO" # Level der aktuellen Meldung, Standard ist INFO
    )

    process {
        # Aktueller Timestamp
        [String] $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
        
        If ($Config.LOG_PFAD) {
            # Log Meldung mit allen Infos
            [String] $Line = "$Stamp [$Level] $Meldung"

            # Logfile wurde angegeben => schreibe in die Datei
            Add-Content -Path $Config.LOG_PFAD -Value $Line
        }
        Else {
            # Kein Logfile angegeben => schreibe in die Konsole
            Write-Host "$Stamp" -NoNewline -ForegroundColor Green
            Write-Host $(" [$Level]").PadRight(10, ' ') -NoNewline -ForegroundColor Blue
            Write-Host "$Meldung"
        }
    }
}
