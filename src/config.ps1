# Author: Joaquin koller & Manuel Schumacher
# Datum: 16.05.2022
# Version: 1.1
# Funktionsbeschreibung: Konfigurationsdatei für statische Werte & Methoden
# Parameter: keine
# Bemerkungen: Relative Pfade werden in absoulte Pfade umgewandelt
#-----

# Konfigurations Variablen
$Config = @{
    XML_PFAD = ("src\assets\schueler.xml" |  Resolve-Path); # Pfad zur XML-Datei 
    CSV_PFAD = ("src\assets\schueler.csv" |  Resolve-Path); # Pfad in welcher die CSV-Werte gespeichert werden sollen
    LOG_PFAD = ""#("src\assets\logs.log" |  Resolve-Path); # Pfad in welcher die Logs gespeichert werden sollen
}

# Log Methode 
# Stackoverflow: https://stackoverflow.com/a/38738942/16632604
Function Write-Log {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [string]
        $Meldung, # Meldung, welche geloggt werden sollte

        [Parameter(Mandatory = $False)]
        [ValidateSet("INFO", "WARN", "ERROR", "FATAL", "DEBUG")] # Gültige Log-Levels
        [String]
        $Level = "INFO" # Level der aktuellen Meldung, Standard ist INFO
    )

    process {
        # Aktueller Timestamp
        $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
        
        # Log Meldung mit allen Infos
        $Line = "$Stamp $Level $Meldung"

        If ($Config.LOG_PFAD -ne "") {
            # Logfile wurde angegeben => schreibe in die Datei
            Add-Content -Path $Config.LOG_PFAD -Value $Line
        }
        Else {
            # Kein Logfile angegeben => schreibe in die Konsole
            Write-Output $Line
        }
    }
}

# Nicht ASCII Werte ersetzen
function Remove-Umlaute {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [String]
        $Value
    )

    process {
        # Sonderzeichen mithilfe von Encoding übersetzen
        $sb = [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($Value))
     
        # Alles was nicht übersetze wurde ersetzen mit ASCII validen Zeichen
        return ($sb -replace '[^a-zA-Z0-9 ]', '')
    }
}