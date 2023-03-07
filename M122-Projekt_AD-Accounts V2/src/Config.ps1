# Author: {{ author }}
# Datum: {{ date }}
# Version: 1.0
# Funktionsbeschreibung: Konfigurationen für die anderen Skripte
# Parameter: keine
# Bemerkungen: 
#-----

# Konfigurationsvariablen
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    <#Category#>'PSUseDeclaredVarsMoreThanAssignments', <#CheckId#>$null,
    Justification = 'Konfigurationsvariablen werden in anderen Skripten verwendet'
)]
$Config = @{
    # Files
    CSV_PFAD             = "Z:\schueler.csv"; # Pfad zur CSV-Datei
    DELIMITER            = ";"; # Trennzeichen der CSV-Datei
    WANT_VERZEICHNIS     = $true; # Sollten Verzeichnisse erstellt werden?
    # AD Pfade
    DOMAIN               = "OU=BZTF,DC=local,DC=bztf"; # Domain in welcher die Benutzer erstellt werden sollen
    OU_KLASSE            = "Klassengruppen"; # Organisatorische Einheit in welcher die Klassen erstellt werden sollen
    OU_LERNENDE          = "Lernende"; # Organisatorische Einheit in welcher die Lernenden erstellt werden sollen
    # Standardwerte für die Benutzer
    STANDARD_PW          = ConvertTo-SecureString "bztf.001" -AsPlainText -Force; # Standard Passwort für die Benutzer
    ANDERE_PW            = $false; # Muss das Passwort beim ersten Login geändert werden?
    BENUTZER_AKTIV       = $true; # Sind die Benutzer standardmässig aktiviert?
    BASIS_FREIGABEN_PFAD = "C:\Freigaben\"; # Basispfad für die Freigaben
    # Standardwerte für die Klassen
    KLASSE_PREFIX        = "BZTF_"; # Prefix für die Klassen
    # Logs
    LOG_DATEI_PFAD       = ""; # Dateipfad in welcher die Logs gespeichert werden sollen
    LOG_LEVEL            = "DEBUG"; # Minimum Log-Level, welches geloggt werden soll
}

# Logging importieren
. .\Write-Log.ps1
