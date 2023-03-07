# Author: {{ author }}
# Datum: {{ date }}
# Version: 1.1
# Funktionsbeschreibung: Liest die Lernenden aus dem Active Directory aus 
# Parameter: keine
# Bemerkungen:
#-----

# Konfiguration importieren
. .\Config.ps1
 
function Read-ADLernende {
    process {
        try {            
            # Lernende aus Active Directory auslesen
            $ADLernende = Get-AdUser -Filter '*' -SearchBase "OU=$($Config.OU_LERNENDE),$($Config.DOMAIN)"
            
            # Logs schreiben
            Write-Log "Es wurden $($ADLernende.Count) Lernende aus dem Active Directory geladen" -Level INFO
            
            # Lernende zurückgeben
            return $ADLernende
        }
        catch {
            # Fehler beim auslesen
            Write-Log -Meldung "Fehler beim auslesen der AD-Benutzer: $($_.Exception.Message)" -Level FEHLER
            return $null;
        }
    }
}