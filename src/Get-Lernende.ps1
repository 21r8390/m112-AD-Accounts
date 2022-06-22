# Author: Joaquin Koller & Manuel Schumacher
# Datum: 22.05.2022
# Version: 1.3
# Funktionsbeschreibung: Importiert CSV Datei
# Parameter: keine
# Bemerkungen: Inspiriert von https://github.com/JackedProgrammer/AutomatingAD
#-----

# Konfigurationen und Methoden laden
. $PSScriptRoot\Config.ps1

# Normalisiert den SamAccountName
# Namensschema: Vorname{0-3}.Nachname{0-13}-Nummer
Function Get-NormalizedSamAccountName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        $Lernender, # Der Lernende
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.HashSet[string]]$ExistingAccNames, # Bereits existierende SamAccountNames
        [Parameter(Mandatory = $false)]
        $AdLernende # Lernende aus dem AD
    )
    begin {
        # Nur wenn Lernende vorhanden sind
        if ($AdLernende) {
            # Validieren, dass alle AD Lernende in ExistingAccNames vorhanden sind
            $AdLernende | ForEach-Object {
                if (-not ($ExistingAccNames -Contains $_.SamAccountName)) {
                    throw "Der SamAccountName des Lernenden $($_.SamAccountName) ist nicht in ExistingAccNames vorhanden!"
                }
            }
        }
    }
    process {
        # AD nach lernenden durchsuchen
        if ($AdLernende) {
            $AccName = $AdLernende | Where-Object { $_.Surname -eq $Lernender.Surname -and $_.GivenName -eq $Lernender.GivenName } | Select-Object SamAccountName -First 1
            if ($AccName) {
                # Wenn vorhanden, dann bereits generierten Name zurueckgeben
                Write-Log "Der Accountname $($AccName.SamAccountName) wurde im AD gefunden" -Level DEBUG
                return $AccName.SamAccountName
            }
        }

        # Alles ausser Buchstaben entfernen
        [regex]$ReplaceRegex = "[^a-zA-Z]"

        # Teile des Namensschema auslesen
        [string]$Start = $Lernender.GivenName -replace $ReplaceRegex
        if ($Start.Length -gt 3) {
            $Start = $Start.Substring(0, 3)
        }
        [string]$End = $Lernender.Surname -replace $ReplaceRegex
        if ($End.Length -gt 13) {
            $End = $End.Substring(0, 13)
        }

        for ([int]$index = 1; ; $index++) {
            # SamAccountName erzeugen
            [string]$SamAccountName = "$Start.$End-$index".ToLower()

            if ($SamAccountName.Length -gt 20) {
                # Name zu lang, Abbruch
                throw "Keine gültige Kombination für den Accountnamen des Lernenden: $Lernender gefunden"
            }

            # Pruefen, ob der SamAccountName bereits existiert
            if (-not $ExistingAccNames.Contains($SamAccountName)) {
                # Wenn der SamAccountName noch nicht existiert, dann wird er verwendet
                $ExistingAccNames.Add($SamAccountName) | Out-Null
                Write-Log "Der Accountname $SamAccountName wurde neu generiert für $Lernender" -Level DEBUG
                return $SamAccountName
            }
        }
    }
}

# Importiert die Lernende aus der CSV Datei
Function Get-Lernende {
    begin {
        # Ad Lernende auslesen
        $AdLernende = Get-AdUser -Filter '*'  -SearchBase "OU=$($Config.LERNENDE_OU),OU=$($Config.SCHULE_OU), $($Config.DOMAIN)"
        Write-Log "Es wurden $($AdLernende.Count) Klassen im AD gefunden" -Level DEBUG
        
        # Existierende Accountnamen auslesen
        [System.Collections.Generic.HashSet[string]]$ExistingAccNames = New-Object System.Collections.Generic.HashSet[string]
        $AdLernende | ForEach-Object {
            $ExistingAccNames.Add($_.SamAccountName) | Out-Null
        }
        Write-Log "Es wurden $($ExistingAccNames.Count) Accountnamen im AD gefunden" -Level DEBUG
    }
    process {
        # Try-Catch falls es einen Fehler beim Konvertieren gibt
        try {
            # Felder des CSV definieren, damit Spalten immer gleich sind
            $SyncFelder = @{
                # CSV Feld  |  AD Feld
                Name         = "Surname"
                Vorname      = "GivenName"
                Benutzername = "SamAccountName"
                Klasse       = "Klasse"
                Klasse2      = "Klasse2"
            };

            # Für jedes Feld ein Property erstellen
            $Properties = foreach ($Property in $SyncFelder.GetEnumerator()) {
                # Property erstellen
                @{
                    Name       = $Property.Value; # Feld in CSV
                    Expression = [scriptblock]::Create("`$_.$($Property.Key)"); # Feld in Sync
                }
            }
        
            # CSV Importieren und Spalten umbenennen (Ohne Dupplikate)
            $Lernende = (Import-Csv -Path $Config.CSV_PFAD -Delimiter $Config.DELIMITER | Select-Object -Property $Properties -Unique)
            Write-Log "Es wurden $($Lernende.Count) Lernende aus dem CSV geladen" -Level DEBUG

            $Lernende | ForEach-Object {
                # Normalisierung des SamAccountNames
                $_.SamAccountName = Get-NormalizedSamAccountName $_ $ExistingAccNames $AdLernende
            }

            return $Lernende
        }
        catch {
            # Fehler beim Konvertieren loggen
            Write-Log -Meldung "Fehler beim Konvertieren: $($_.Exception.Message)" -Level ERROR
        
            # Leere Liste zurück geben
            return @()
        }
    }
}