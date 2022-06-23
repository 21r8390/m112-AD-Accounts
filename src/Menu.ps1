# Author: Joaquin Koller & Manuel Schumacher
# Datum: 20.06.2022
# Version: 1.1
# Funktionsbeschreibung: Menü zum Ausführen von Funktionen
# Parameter: keine
# Bemerkungen: 
# ---

# Konfigurationen und Methoden laden
. $PSScriptRoot\Config.ps1
. $PSScriptRoot\Add-Klassen.ps1
. $PSScriptRoot\Add-Lernende.ps1
. $PSScriptRoot\Add-OUs.ps1
. $PSScriptRoot\ConvertXML-ToCSV.ps1
. $PSScriptRoot\Get-Lernende.ps1
. $PSScriptRoot\Set-LernendeZuKlassen
. $PSScriptRoot\Remove-Lernende.ps1
. $PSScriptRoot\Remove-Klassen.ps1
. $PSScriptRoot\Set-KlassenVerzeichnis
. $PSScriptRoot\Set-HomeVerzeichnis

# Zeigt das Menu in der Konsole an
Function Show-Menu {
    Write-Log "Menü wird angezeigt" -Level DEBUG
    
    Write-Host "================ Projekt M122 AD-Accounts ================`n"
    
    Write-Host "1: XML zu CSV konvertieren"
    Write-Host "2: AD-Accounts für die Lernenden erstellen"
    Write-Host "3: AD-Gruppen für die Klassen erstellen"
    Write-Host "4: AD-Benutzer, welche nicht im CSV vorhanden sind, deaktivieren"
    Write-Host "5: AD-Gruppen welche nicht im CSV vorhanden sind, löschen"
    Write-Host "6: AD-Benutzer den Gruppen zuweisen"
    Write-Host "7: Optionen 1-6 ausführen"
    Write-Host "8: Klassenverzeichnis umbennen"
    Write-Host "9: Homeverzeichnis umbennen"
    Write-Host "`n"
    Write-Host "Exit: Geben Sie 'Exit' ein um das Programm zu verlasen`n"
}

# Mein Funktion startet das Programm.
Function New-AdAutomation {
    begin {
        Write-Log "Das Programm wurde gestartet" -Level INFO
        # AD Modul importieren
        try {
            Import-Module ActiveDirectory -ErrorAction Stop
        }
        catch {
            # Fehlermeldung anzeigen
            Write-Log "Das Modul ActiveDirectory konnte nicht installiert werden! Es ist nur unter Windows Server verfuegbar..." -Level ERROR
        }

        # Die benötigten OUs werden erstellt.
        Add-OUs
    }

    process {
        # Switchcase ruft die entsprechenden funktionen auf
        while ($True) {
            Clear-Host
            Show-Menu

            # Menüoption auswählen
            [string]$auswahl = (Read-Host "Wählen sie eine Option aus").Trim()
            Write-Log "Option '$($auswahl)' wurde ausgewählt." -Level INFO
            
            # Switchcase für die Auswahl der Optionen
            switch ($auswahl) {
                '1' {
                    # ConvertXML-ToCSV.ps1: XML zu CSV konvertieren
                    Convert-XMLToCSV
                } 
                '2' {
                    # Add-Lernende.ps1: AD-Accounts für die Lernenden erstellen
                    Add-Lernende
                }
                '3' {
                    # Add-Klassen.ps1: AD-Gruppen für die Klassen erstellen
                    Add-Klassen
                } 
                '4' {
                    # Remove-Lernende.ps1: welche nicht im CSV vorhanden sind, deaktivieren
                    Remove-Lernende
                }
                '5' {
                    # Remove-Klassen.ps1: welche nicht im CSV vorhanden sind. loeschen
                    Remove-Klassen
                } 
                '6' {
                    # Set-LernendeZuKlassen.ps1: AD-Benutzer den Gruppen zuweisen
                    Set-LernendeZuKlassen
                }
                '7' {
                    # Fürt die Optionen 1-6 aus
                    Convert-XMLToCSV
                    Add-Lernende
                    Add-Klassen
                    Remove-Lernende
                    Remove-Klassen
                    Set-LernendeZuKlassen
                }
                '8' {
                    # Set-Klassenverzeichnis.ps1: Benennt das Klassenverzeichnis um
                    Set-KlassenVerzeichnis
                }
                '9' {
                    # Set-HomeVerzeichnis.ps1: Benennt das Homeverzeichnis um
                    Set-HomeVerzeichnis
                }
                'exit' {
                    # Beendet das Programm
                    return
                }
                default {
                    # Ungültige Eingabe
                    Write-Log  "Ungueltige Eingabe! $auswahl" -Level WARN
                }
            }
            # Warten bis Benutzer bereit ist
            Pause
        }
    }

    end {
        # Meldung ausgeben
        Write-Log "Das Programm wurde beendet" -Level INFO
    }
}

# Start des Programms
New-AdAutomation