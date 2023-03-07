# Author: {{ author }}
# Datum: {{ date }}
# Version: 1.1
# Funktionsbeschreibung: Klassen Verzeichnis für Klasse erstellen
# Parameter: Klasse - Name der Klasse
# Bemerkungen: In der Config.ps1 muss der Basispfad definiert sein
#-----

# Konfiguration importieren
. .\Config.ps1

function New-KlasseVerzeichnis {
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
            # Basisordner erstellen, wenn nicht bereits vorhanden
            if (!(Test-Path $BasisPfad)) {
                New-Item -Path $BasisPfad -ItemType Directory | Out-Null
                Write-Log "Basisverzeichnis für die Klassen wurde erstellt: " + $BasisPfad -Level WARNUNG
            }
    
            # Klassenordner erstellen
            $KlassePfad = $BasisPfad + $Klasse
            New-Item -Path $KlassePfad -ItemType Directory -Force | Out-Null
            if (Test-Path $KlassePfad) {
                # Zugriffsrechte setzen
                $Acl = Get-Acl $KlassePfad
                $Acl.SetAccessRule($(New-Object System.Security.AccessControl.FileSystemAccessRule("$Klasse", "FullControl", "Allow")))
                # Vererbungsrechte deaktivieren
                $Acl.SetAccessRuleProtection($True, $False)
                Set-Acl $KlassePfad $Acl
    
                Write-Log "Klassenverzeichnis für '$Klasse' wurde erstellt: $KlassePfad" -Level INFO
            }
            else {
                Write-Log "Verzeichnis für die Klasse '$Klasse' wurde nicht erstellt" -Level FEHLER
            }
        }
        catch {
            # Fehler beim erstellen des Verzeichnis
            Write-Log "Fehler beim erstellen des Verzeichnis für die Klasse '$Klasse' : $($_.Exception.Message)" -Level FEHLER
        }
    }
}