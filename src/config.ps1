# Author: Joaquin koller & Manuel Schumacher
# Datum: 16.05.2022
# Version: 1.1
# Funktionsbeschreibung: Konfigurationsdatei für statische Werte
# Parameter: keine
# Bemerkungen: Relative Pfade werden in absoulte Pfade umgewandelt
#-----

$config = @{
    XML_Path = ("src\assets\schueler.xml" |  Resolve-Path);
    CSV_Path = ("src\assets\schueler.csv" |  Resolve-Path);
}