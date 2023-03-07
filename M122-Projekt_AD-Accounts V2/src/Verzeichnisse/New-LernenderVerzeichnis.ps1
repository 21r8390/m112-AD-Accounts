# Author: {{ author }}
# Datum: {{ date }}
# Version: 1.1
# Funktionsbeschreibung: Home Verzeichnis für Lernender erstellen
# Parameter: Lernender - Name des Lernenden
# Bemerkungen: 
#-----

# Konfiguration importieren
. .\Config.ps1

function New-LernenderVerzeichnis {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Lernender # Name des Lernenden
    )
    
    begin {
        # Parameter überprüfen
        if ([string]::IsNullOrWhiteSpace($Lernender)) {
            Write-Log "Lernender darf nicht null oder leer sein!" -Level FEHLER
        }

        # Basispfad für die Unterordner
        $BasisPfad = "$($Config.BASIS_FREIGABEN_PFAD.TrimEnd('\'))\$($Config.OU_LERNENDE)\"
    }
    
    process {
        try {
            # Basisordner erstellen, wenn nicht bereits vorhanden
            if (!(Test-Path $BasisPfad)) {
                New-Item -Path $BasisPfad -ItemType Directory | Out-Null
                Write-Log "Basisverzeichnis für die Lernenden wurde erstellt: " + $BasisPfad -Level WARNUNG
            }
    
            # Home Verzeichnis erstellen
            $LernenderPfad = $BasisPfad + $Lernender
            New-Item -Path $LernenderPfad -ItemType Directory -Force | Out-Null
            if (Test-Path $LernenderPfad) {    
                # Zugriffsrechte setzen
                $Acl = Get-Acl $LernenderPfad
                $Acl.SetAccessRule($(New-Object System.Security.AccessControl.FileSystemAccessRule("$Lernender", "FullControl", "Allow")))
                # Vererbungsrechte deaktivieren
                $Acl.SetAccessRuleProtection($True, $False)
                Set-Acl $LernenderPfad $Acl

                Write-Log "Home Verzeichnis für '$Lernender' wurde erstellt: $LernenderPfad" -Level INFO
            }
            else {
                Write-Log "Verzeichnis für den Lernenden '$Lernender' wurde nicht erstellt" -Level FEHLER
            }
        }
        catch {
            # Fehler beim erstellen des Verzeichnis
            Write-Log "Fehler beim erstellen des Verzeichnis für den Lernenden '$Lernender' : $($_.Exception.Message)" -Level FEHLER
        }
    }

    end {
        # Pfad hinterlegen
        Set-AdUser -Identity $Lernender -HomeDrive "H:" -HomeDirectory "H:\$Lernender" -ProfilePath $LernenderPfad
    }
}