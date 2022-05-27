# Author: Joaquin Koller & Manuel Schumacher
# Datum: 16.05.2022
# Version: 1.4
# Funktionsbeschreibung: Konfigurationsdatei für statische Werte
# Parameter: keine
# Bemerkungen: Relative Pfade werden in absoulte Pfade umgewandelt
# Bemerkungen: Implementiert Log Methode
#-----

# Konfigurations Variablen
$Config = @{
    XML_PFAD              = ("assets\schueler.xml" |  Resolve-Path); # Pfad zur XML-Datei 
    CSV_PFAD              = ("assets\schueler.csv" |  Resolve-Path); # Pfad in welcher die CSV-Werte gespeichert werden sollen
    LOG_PFAD              = ""; # Pfad in welcher die Logs gespeichert werden sollen
    DELIMITER             = ";"; # Trennzeichen für CSV-Datei
    DOMAIN                = "DC=bztf,DC=local";
    SCHULE_OU             = "BZTF";
    KLASSE_OU             = "Klassengruppen";
    LERNENDE_OU           = "Lernende"; 
    STANDARD_PW           = ConvertTo-SecureString "bztf.001" -AsPlainText -Force; # Standard Passwort
    ChangePasswordAtLogon = $false; # Passwort beim ersten Login ändern
}

. $PSScriptRoot\Write-Log.ps1
