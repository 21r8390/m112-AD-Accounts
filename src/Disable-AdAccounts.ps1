# Author: Joaquin Koller & Manuel Schumacher
# Datum: 22.05.2022
# Version: 1.1
# Funktionsbeschreibung: AD-Benutzer, welche nicht im XML vorhanden sind, deaktivieren
# Parameter: keine
# Bemerkungen: 
#-----

# Konfigurationen und Methoden laden
. $PSScriptRoot\Config.ps1
. $PSScriptRoot\Get-Schueler.ps1

function Disable-AdAccounts() {
    # Methode aus "ImportUsers", Importiert alle Schüler als Liste aus dem CSV
    $User_CSV = Get-Schueler

    # # Liste aller User - User aus der CSV Liste
    #Get-AdUser -Filter * -Properties * | Where-Object { $User_CSV -notcontains $_.SamAccountName } | Select-Object SamAccountName, Name
    Get-AdUser -Filter * -Properties * | Where-Object { $User_CSV -notcontains $_.SamAccountName } | Select-Object SamAccountName, Name
}