# Author: {{ author }}
# Datum: {{ date }}
# Version: 1.1
# Funktionsbeschreibung: Gibt aus wann das letzte Mal das Password geändert wurde
# Parameter: keine
# Bemerkungen: Mithilfe von https://techexpert.tips/powershell/powershell-find-last-password-change-date/
#-----

# Konfiguration importieren
. .\Config.ps1

function Get-LastChanged {    
    process {
        try {            
            # Lernende aus Active Directory auslesen
            $ZuletztGesetzt = Get-AdUser -Filter '*' -Properties PasswordLastSet -SearchBase "OU=$($Config.OU_LERNENDE),$($Config.DOMAIN)"
            
            # Logs schreiben
            Write-Log "Es wurden $($ZuletztGesetzt.Count) Lernende aus dem Active Directory ausgelesen" -Level DEBUG
            
            # Ausgabe
            $ZuletztGesetzt | Sort-Object PasswordLastSet, SamAccountName -Descending | Select-Object Name, SamAccountName, PasswordLastSet | Format-Table -AutoSize
        }
        catch {
            # Fehler beim auslesen
            Write-Log -Meldung "Fehler beim auslesen der letzten Passwortänderung: $($_.Exception.Message)" -Level FEHLER
            return $null;
        }   
    }
}

