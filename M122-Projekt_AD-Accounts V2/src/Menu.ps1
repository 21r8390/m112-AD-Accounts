# Author: {{ author }}
# Datum: {{ date }}
# Version: 1.2
# Funktionsbeschreibung: Zeit das Menü zum ausführen der Funktionen an
# Parameter: 
# Bemerkungen: Das AD-Modul wird neu installiert
#-----


# Konfigurationen und Methoden laden
. $PSScriptRoot\Config.ps1

. $PSScriptRoot\Klassen\Add-ADKlassen.ps1
. $PSScriptRoot\Klassen\Read-ADKlassen.ps1
. $PSScriptRoot\Klassen\Read-CSVKlassen.ps1
. $PSScriptRoot\Klassen\Remove-ADKlassen.ps1

. $PSScriptRoot\Lernende\Add-ADLernende.ps1
. $PSScriptRoot\Lernende\Enable-ADLernende.ps1
. $PSScriptRoot\Lernende\Read-ADLernende.ps1
. $PSScriptRoot\Lernende\Read-CSVLernende.ps1
. $PSScriptRoot\Lernende\Remove-ADLernende.ps1

. $PSScriptRoot\Sonstiges\Add-Organisationseinheiten.ps1
. $PSScriptRoot\Sonstiges\Get-LastChanged.ps1

. $PSScriptRoot\Verzeichnisse\New-KlasseVerzeichnis.ps1
. $PSScriptRoot\Verzeichnisse\New-LernenderVerzeichnis.ps1
. $PSScriptRoot\Verzeichnisse\Remove-KlasseVerzeichnis.ps1

. $PSScriptRoot\Zuweisungen\Add-LernendeToKlasse.ps1
. $PSScriptRoot\Zuweisungen\Remove-LernendeFromKlasse.ps1

function Show-Menu {    
    Write-Host "`n================== Projekt M122 AD-Accounts ==================`n"
    Write-Host " 1: Organisationseinheiten erstellen"
    Write-Host " 2: XML zu CSV konvertieren"
    Write-Host " 3: AD-Accounts für die Lernenden erstellen"
    Write-Host " 4: AD-Lernende, welche im CSV vorhanden sind, aktivieren"
    Write-Host " 5: AD-Lernende, welche nicht im CSV vorhanden sind, deaktivieren"
    Write-Host " 6: AD-Gruppe für die Klassen erstellen"
    Write-Host " 7: AD-Klassen, welche nicht im CSV vorhanden sind, löschen"
    Write-Host " 8: AD-Lernende zu den Klassen zuweisen"
    Write-Host " 9: AD-Lernende aus den Klassen entfernen"
    Write-Host "10: Optionen 1-9 ausführen"
    Write-Host " ========================= Ausgaben ========================== "
    Write-Host "11: Letzte Passwortänderung anzeigen"
    Write-Host "12: CSV-Lernende in Tabelle anzeigen"
    Write-Host "13: AD-Lernende in Tabelle anzeigen"
    Write-Host "14: CSV-Klassen in Tabelle anzeigen"
    Write-Host "15: AD-Klassen in Tabelle anzeigen"
    Write-Host "`n"
    Write-Host "Exit: Geben Sie 'Exit' ein um das Programm zu verlasen`n"
}

function Start-AdAutomation {
    begin {
        # AD Modul importieren
        try {
            Write-Log "Versuche das ActiveDirectory-Modul zu installieren" -Level INFO
            Import-Module ActiveDirectory -ErrorAction Stop
            Write-Log "Das ActiveDirectory-Modul wurde oder ist bereits installiert" -Level DEBUG
        }
        catch {
            Write-Log "Das ActiveDirectory Modul konnte nicht installiert werden! Es ist nur unter Windows Server erhältlich..." -Level FEHLER
        }
    }

    process {
        while ($true) {
            Show-Menu

            # Option auswählen & Leerzeichen entfernen
            [string]$selektion = (Read-Host "Wählen sie eine Option aus").Trim().ToLower()
            Write-Log "Es wurde '$selektion' Selektiert" -Level DEBUG

            Write-Host "`n`n"

            # Aktion gemäss Auswahl ausführen
            switch ($selektion) {
                '1' {
                    Add-Organisationseinheiten
                }
                '2' {
                    Write-Log "Diese Option wurde nicht umgesetzt, da kein XML vorhanden ist" -Level FEHLER
                }
                '3' {
                    Add-ADLernende
                }
                '4' {
                    Enable-ADLernende
                }
                '5' {
                    Remove-ADLernende
                }
                '6' {
                    Add-ADKlassen
                }
                '7' {
                    Remove-ADKlassen
                }
                '8' {
                    Add-LernendeToKlasse
                }
                '9' {
                    Remove-LernendeFromKlasse
                }
                '10' {
                    # Alles ausführen
                    Add-Organisationseinheiten
                    Add-ADLernende
                    Enable-ADLernende
                    Remove-ADLernende
                    Add-ADKlassen
                    Remove-ADKlassen
                    Add-LernendeToKlasse
                    Remove-LernendeFromKlasse
                }
                '11' {
                    Get-LastChanged
                }
                '12' {
                    Read-CSVLernende | Format-Table Surname, GivenName, SamAccountName, Klasse, Klasse2 -AutoSize
                }
                '13' {
                    Read-ADLernende | Format-Table -AutoSize
                }
                '14' {
                    Read-CSVKlassen | Format-Table -AutoSize
                }
                '15' {
                    Read-ADKlassen | Format-Table -AutoSize
                }
                'exit' {
                    # Beendet das Programm
                    return
                }
                default {
                    # Ungültige Eingabe
                    Write-Log  "Ungueltige Eingabe! $selektion" -Level WARNUNG
                }
            }
        }
    }

    end {
        Write-Log "Die Automation wurde beendet" -Level INFO
    }
}

# Programm starten
Start-AdAutomation