# Author: {{ author }}
# Datum: {{ date }}
# Version: 1.1
# Funktionsbeschreibung: Schreibt eine Meldung in die Konsole oder in eine Log-Datei
# Parameter: Level, Meldung
# Bemerkungen: Code teilweise kopiert von: https://stackoverflow.com/a/38738942/16632604
#-----

# Mögliche Log-Level
Enum LogLevel {
    DEBUG
    INFO
    WARNUNG
    FEHLER
}

Function Write-Log {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [String]
        $Meldung, # Meldung, welche geloggt werden sollte
        [Parameter(Mandatory = $True)]
        [ValidateSet(
            "DEBUG", "INFO", "WARNUNG", "FEHLER"
        )] # Validierung des Log-Level
        [LogLevel]
        $Level # Log-Level
    )
    process {
        # Prüfen, ob das Log-Level niedriger ist als das minimale Log-Level (aus der Config)
        if ($Config.LOG_LEVEL -and $Level -lt $Config.LOG_LEVEL) {
            # Log-Level ist niedriger als das minimale Log-Level => Meldung wird nicht geloggt
            return;
        }

        # Aktueller Zeitstempel
        $Zeitstempel = (Get-Date).toString("yyyy/MM/dd HH:mm:ss.fff")
        $LevelText = "[$Level]".PadRight(10, ' ');
        
        If ($Config.LOG_DATEI_PFAD) {
            # Logfile wurde angegeben => schreibe in die Datei
            Add-Content -Path $Config.LOG_PFAD -Value "$Zeitstempel $LevelText $Meldung" -Encoding UTF8
        }
        Else {
            # Farbe für die Log-Level
            [ConsoleColor]$Color = switch ($Level) {
                FEHLER { "Red" }
                WARNUNG { "Yellow" }
                INFO { "Blue" }
                default { "Magenta" }
            }

            # Logfile wurde nicht angegeben => schreibe in die Konsole
            Write-Host $Zeitstempel -NoNewline -ForegroundColor Green
            Write-Host  " $LevelText" -NoNewline -ForegroundColor $Color
            Write-Host $Meldung
        }
    }
}