# Author: Joaquin Koller & Manuel Schumacher
# Datum: 22.05.2022
# Version: 1.3
# Funktionsbeschreibung: Importiert CSV Datei
# Parameter: keine
# Bemerkungen:
#-----

# Konfigurationen und Methoden laden
. $PSScriptRoot\Config.ps1

Function Get-Lernende {
    # Try-Catch falls es einen Fehler beim Konvertieren gibt
    try {
        # Felder des CSV definieren, damit Spalten immer gleich sind
        $SyncFelder = @{
            Name         = "LastName"
            Vorname      = "FirstName"
            Benutzername = "Username"
            Klasse       = "Klasse"
            Klasse2      = "Klasse2"
        };

        # Für jedes Feld ein Property erstellen
        $Properties = foreach ($Property in $SyncFelder.GetEnumerator()) {
            # Property erstellen
            @{
                Name       = $Property.Value; # Feld in CSV
                Expression = [scriptblock]::Create("`$_.$($Property.Key)"); # Feld in Sync
            }
        }
        
        # CSV Importieren und Spalten umbenennen (Ohne Dupplikate)
        return (Import-Csv -Path $Config.CSV_PFAD -Delimiter $Config.DELIMITER | Select-Object -Property $Properties -Unique)
    }
    catch {
        # Fehler beim Konvertieren loggen
        Write-Log -Meldung "Fehler beim Konvertieren: $($_.Exception.Message)"
        
        # Leere Liste zurück geben
        return @()
    }
}