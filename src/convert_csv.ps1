# Author: Joaquin koller
# Datum: 09.05.2022
# Version: 1.0
# Funktionsbeschreibung: Konvertiert CSV zu XML.
# Parameter: keine
# Bemerkungen:
#-----

$path = "C:\Users\Koller\Documents\dev\m112-AD-Accounts\src\assets"

Import-CSV "$($path)\schueler.csv" | Export-CliXML "$($path)\schueler.xml"