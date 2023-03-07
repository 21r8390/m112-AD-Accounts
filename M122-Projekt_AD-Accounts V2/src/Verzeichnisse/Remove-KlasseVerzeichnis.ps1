# Author: {{ author }}
# Datum: {{ date }}
# Version: 1.1
# Funktionsbeschreibung: Klassen Verzeichnis für Klasse entfernen
# Parameter: Klasse - Name der Klasse
# Bemerkungen: Wenn der Pfad im Config.ps1 geändert hat, dann wird das Verzeichnis nicht gelöscht
#-----

# Konfiguration importieren
. .\Config.ps1

function Remove-KlasseVerzeichnis {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Klasse # Name der Klasse
    )
    
    begin {
        # Parameter validieren
        if ([string]::IsNullOrWhiteSpace($Klasse)) {
            Write-Log "Klasse darf nicht null oder leer sein!" -Level FEHLER
        }

        # Basispfad für die Unterordner erstellen
        $BasisPfad = "$($Config.BASIS_FREIGABEN_PFAD.TrimEnd('\'))\$($Config.OU_KLASSE)\"
    }
    
    process {
        try {
            # Klassenordner entfernen
            $KlassePfad = $BasisPfad + $Klasse
            if (Test-Path $KlassePfad) {
                Remove-Item -Path $KlassePfad -Recurse -Force -Confirm:$false
            }
            else {
                Write-Log "Das Klassenverzeichnis für die Klasse '$Klasse' existiert nicht" -Level WARNUNG
            }
        }
        catch {
            # Fehler beim löschen des Verzeichnis
            Write-Log "Fehler beim löschen des Verzeichnis für die Klasse '$Klasse': $($_.Exception.Message)" -Level FEHLER
        }
    }

    end {
        # Testen ob Ordner wirklich gelöscht
        if (Test-Path $KlassePfad) {
            Write-Log "Das Klassenverzeichnis für die Klasse '$Klasse' konnte nicht gelöscht werden" -Level WARNUNG
        }
        else {
            Write-Log "Das Klassenverzeichnis für die Klasse '$Klasse' wurde gelöscht" -Level INFO            
        }
    }
}