# Author: Joaquin Koller & Manuel Schumacher
# Datum: 16.05.2022
# Version: 1.6
# Funktionsbeschreibung: Konfigurationsdatei für statische Werte
# Parameter: keine
# Bemerkungen: Relative Pfade werden in absoulte Pfade umgewandelt
# Bemerkungen: Implementiert Log Methode
#-----

# Konfigurations Variablen
[Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    <#Category#>'PSUseDeclaredVarsMoreThanAssignments', <#CheckId#>$null,
    Justification = 'HashTable wird in in den anderen Dateien verwendet'
)]
$Config = @{
    # Files
    BASE_HOME_PFAD           = "C:\Freigaben\"; # Pfad wo die Verzeichnisse erstellt werden
    XML_PFAD                 = "schueler.xml"; # Pfad zur XML-Datei 
    CSV_PFAD                 = "schueler.csv" ; # Pfad in welcher die CSV-Werte gespeichert werden sollen
    DELIMITER                = ";"; # Trennzeichen für CSV-Datei
    # Logging
    LOG_PFAD                 = "C:\logs.log"; # Pfad in welcher die Logs gespeichert werden sollen
    LOG_LEVEL                = "INFO"; # Level für Logs
    # AD
    DOMAIN                   = "DC=bztf,DC=local";
    SCHULE_OU                = "BZTF";
    KLASSE_OU                = "Klassengruppen";
    LERNENDE_OU              = "Lernende";
    # Default values 
    STANDARD_PW              = ConvertTo-SecureString "bztf.001" -AsPlainText -Force; # Standard Passwort
    CHANGE_PASSWORD_AT_LOGON = $false; # Passwort beim ersten Login ändern
    USER_ENABLED             = $true; # Ob Benutzer standardmässig aktiviert ist
}

. $PSScriptRoot\Write-Log.ps1
