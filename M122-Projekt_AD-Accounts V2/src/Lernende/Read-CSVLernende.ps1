# Author: {{ author }}
# Datum: {{ date }}
# Version: 1.1
# Funktionsbeschreibung: Liesst die Lernenden aus der CSV Datei aus 
# Parameter: keine
# Bemerkungen: Erstellt mithilfe von JackedProgrammer https://youtu.be/-dot-2GDYTs
# Bemerkungen: Klassen haben noch kein Prefix (Config.KLASSE_PREFIX)
#-----

# Konfiguration importieren
. .\Config.ps1

function Get-NormalizedName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Name # Name der normalisiert werden soll
    )
    
    begin {
        # Regex zum normalisieren
        [regex]$ReplaceRegex = "[^a-zA-Z0-9\.]"
    }
    
    process {
        # Name normalisieren
        $Name = $Name -replace $ReplaceRegex, ""

        # Name in Kleinbuchstaben umwandeln
        $Name = $Name.ToLower()

        # Zeichenlänge begrenzen
        if ($Name.Length -gt 20) {
            $Name = $Name.Substring(0, 20)
        }
    }
    
    end {
        # Name zurückgeben
        return $Name        
    }
}

# Lernende aus CSV Datei auslesen
Function Read-CSVLernende {
    process {
        try {
            # Felder die synchronisiert werden sollen
            $SyncFelder = @{
                Name         = "Surname"
                Vorname      = "GivenName"
                Benutzername = "SamAccountName"
                Klasse       = "Klasse"
                Klasse2      = "Klasse2"
            };

            # Felder aus CSV Datei auslesen
            $Properties = foreach ($Property in $SyncFelder.GetEnumerator()) {
                @{
                    Name       = $Property.Value; # Feld in CSV
                    Expression = [scriptblock]::Create("`$_.$($Property.Key)"); # Feld in Sync
                }
            };

            # CSV Importieren und Spalten umbenennen (Ohne Dupplikate)
            $Lernende = Import-Csv -Path $Config.CSV_PFAD -Delimiter $Config.DELIMITER | Select-Object -Property $Properties -Unique

            # Logs schreiben
            Write-Log "Es wurden $($Lernende.Count) Lernende aus dem CSV geladen" -Level INFO

            $Lernende | ForEach-Object {
                # Normalisierung des SamAccountNames
                $_.SamAccountName = Get-NormalizedName $_.SamAccountName
                
                # Klassenprefix hinzufügen
                if (!([string]::IsNullOrWhiteSpace($_.Klasse))) {
                    $_.Klasse = $Config.KLASSE_PREFIX + $_.Klasse
                }
                if (!([string]::IsNullOrWhiteSpace($_.Klasse2))) {
                    $_.Klasse2 = $Config.KLASSE_PREFIX + $_.Klasse2
                }
            }

            # Lernende zurückgeben
            return $Lernende
        }
        catch {
            # Fehler beim auslesen
            Write-Log -Meldung "Fehler beim auslesen der CSV-Lernenden : $($_.Exception.Message)" -Level FEHLER
            return $null;
        }
    }
}