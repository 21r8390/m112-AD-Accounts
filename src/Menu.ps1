# Author: Joaquin Koller & Manuel Schumacher
# Datum: 22.05.2022
# Version: 1.0
# Funktionsbeschreibung: Menü zum Ausführen von Funktionen
# Parameter: keine
# Bemerkungen: Noch nicht fertig
#-----

# Konfigurationen und Methoden laden
. $PSScriptRoot\Config.ps1

# AD Modul importieren
Import-Module ActiveDirectory

# OUs am Start erstellen
Add-OrganizationalUnits