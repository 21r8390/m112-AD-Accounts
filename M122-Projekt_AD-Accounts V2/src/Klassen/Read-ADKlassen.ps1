# Author: {{ author }}
# Datum: {{ date }}
# Version: 1.1
# Funktionsbeschreibung: Liest die Klassen aus dem Active Directory aus 
# Parameter: keine
# Bemerkungen:
#-----

# Konfiguration importieren
. .\Config.ps1

function Read-ADKlassen {    
    process {
        try {
            # Klassen aus Active Directory auslesen
            $ADKlassen = Get-AdGroup -Filter '*'  -SearchBase "OU=$($Config.OU_KLASSE),$($Config.DOMAIN)"

            # Logs schreiben
            Write-Log "Es wurden $($ADKlassen.Count) Klassen aus dem Active Directory geladen" -Level INFO

            # Klassen zurückgeben
            return $ADKlassen
        }
        catch {
            # Fehler beim auslesen
            Write-Log -Meldung "Fehler beim auslesen der AD-Klassen: $($_.Exception.Message)" -Level FEHLER
            return $null;
        }
    }
}