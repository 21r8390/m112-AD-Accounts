# Author: Joaquin Koller & Manuel Schumacher
# Datum: 27.05.2022
# Version: 1.4
# Funktionsbeschreibung: Logt eine Meldung in eine Datei oder Konsole
# Parameter: Meldung, welche geloggt werden sollte
# Parameter: Level, welche die aktuelle Meldung hat, wenn nicht angegeben wird der Default-Wert "INFO" verwendet
# Bemerkungen: Sollte nicht direkt implementiert werden, sondern über die Config-Datei 
# Bemerkungen: Log-Datei muss angegeben werden um in Datei zu speichern
#-----

# Log Methode
# Stackoverflow: https://stackoverflow.com/a/38738942/16632604
Function Write-Log {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [String]
        $Meldung, # Meldung, welche geloggt werden sollte

        [Parameter(Mandatory = $False)]
        [ValidateSet("INFO", "WARN", "ERROR", "DEBUG")] # Gültige Log-Levels
        [String]
        $Level = "INFO" # Level der aktuellen Meldung, Standard ist INFO
    )

    process {
        # Aktueller Timestamp
        [String] $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss.fff")
        
        If ($Config.LOG_PFAD) {
            # Log Meldung mit allen Infos
            [String] $Line = "$Stamp $("[$Level]".PadRight(10, ' ')) $Meldung"

            # Logfile wurde angegeben => schreibe in die Datei
            Add-Content -Path $Config.LOG_PFAD -Value $Line -Encoding UTF8
        }
        Else {
            [ConsoleColor]$Color = switch ($Level) {
                DEBUG { "Magenta" }
                ERROR { "Red" }
                WARN { "Yellow" }
                INFO { "Blue" }
                Default { "Blue" }
            }

            # Kein Logfile angegeben => schreibe in die Konsole
            Write-Host "$Stamp" -NoNewline -ForegroundColor Green
            Write-Host $(" [$Level]").PadRight(10, ' ') -NoNewline -ForegroundColor $Color
            Write-Host "$Meldung"
        }
    }
}