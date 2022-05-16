# Author: Joaquin koller & Manuel Schumacher
# Datum: 09.05.2022
# Version: 1.5
# Funktionsbeschreibung: Konvertiert CSV zu XML.
# Parameter: keine
# Bemerkungen: XML hat bereits CSV Format
#-----

# Konfigurationen und Methoden laden
. $PSScriptRoot\Config.ps1

function Get-SchulerFromCSV {
    [CmdletBinding()]
    param (
    )
    
    process {
        try {
            $SyncFieldMap = @{
                Name         = "LastName"
                Vorname      = "FirstName"
                Benutzername = "Username"
                Klasse       = "Klasse"
                Klasse2      = "Klasse2"
            };

            $SyncProperties = $SyncFieldMap.GetEnumerator()
            $Properties = foreach ($Property in $SyncProperties) {
                @{
                    Name       = $Property.Value;
                    Expression = [scriptblock]::Create("`$_.$($Property.Key)");
                }
            }
            
            Import-Csv -Path $Config.CSV_PFAD -Delimiter $Config.DELIMITER | Select-Object -Property $Properties

        }
        catch {
            Write-Log "Fehler beim Konvertieren: " + $_.Exception.Message 
        }
    }
}

Get-SchulerFromCSV