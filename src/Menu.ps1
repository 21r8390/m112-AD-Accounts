# Author: Joaquin Koller & Manuel Schumacher
# Datum: 22.05.2022
# Version: 1.0
# Funktionsbeschreibung: Menü zum Ausführen von Funktionen
# Parameter: keine
# Bemerkungen: Noch nicht fertig
#-----

# Konfigurationen und Methoden laden
. $PSScriptRoot\Config.ps1
. $PSScriptRoot\Add-Klassen.ps1
. $PSScriptRoot\Add-Lernende.ps1
. $PSScriptRoot\Add-OUs.ps1
. $PSScriptRoot\ConvertXML-ToCSV.ps1
. $PSScriptRoot\Get-Lernende.ps1
. $PSScriptRoot\Set-LernendeZuKlassen
. $PSScriptRoot\Write-Log.ps1

# AD Modul importieren
Import-Module ActiveDirectory -erroraction 'silentlycontinue'


# Zeigt das Menu in der Konsole an
function Show-Menu {
    
    Write-Host "================ Projekt M122 AD-Accounts ================`n"
    
    Write-Host "1: XML zu CSV konvertieren"
    Write-Host "2: AD-Accounts für die Lernenden erstellen"
    Write-Host "3: AD-Gruppen für die Klassen erstellen"
    Write-Host "4: AD-Benutzer, welche nicht im CSV vorhanden sind, deaktivieren"
    Write-Host "5: AD-Gruppen welche nicht im CSV vorhanden sind, löschen"
    Write-Host "6: AD-Benutzer den Gruppen zuweisen"
    # Write-Host "`n"
    Write-Host "Exit: Geben Sie 'Exit' ein um das Programm zu verlasen`n"
}

# Solange die '3' nicht ausgewählt wurde wird das Menu angezeigt.
# Switchcase ruft die entsprechenden funktionen auf
do {
    Clear-Host
    Show-Menu
    $selection = Read-Host "Wählen sie eine Option aus"
    switch ($selection) {
        '1' {
            # ConvertXML-ToCSV.ps1: XML zu CSV konvertieren
            Convert-XMLToCSV
            pause
        } 
        '2' {
            # Add-Lernende.ps1: AD-Accounts für die Lernenden erstellen
            Add-Lernende
            pause
        }
        '3' {
            # Add-Klassen.ps1: AD-Gruppen für die Klassen erstellen
            Add-Klassen
            pause
        } 
        '4' {
            # AD-Benutzer, welche nicht im CSV vorhanden sind, deaktivieren
            # TODO: Methode separieren aus Add-Lernende.ps1 ❗
            Clear-Host
            Write-Host "Noch nicht Verfügbar"
            pause
        }
        '5' {
            # AD-Benutzer, welche nicht im CSV vorhanden sind, deaktivieren
            # TODO: Methode separieren aus Add-Lernende.ps1 ❗
            Clear-Host
            Write-Host "Noch nicht Verfügbar"
            pause
        } 
        '6' {
            # Set-LernendeZuKlassen.ps1: AD-Benutzer den Gruppen zuweisen
            Set-LernendeZuKlassen
            pause
        }
    }
}
until ($selection -eq 'Exit')