# Author: {{ author }}
# Datum: {{ date }}
# Version: 1.1
# Funktionsbeschreibung: Erstellt die AD-Benutzer aus der CSV-Datei im Active Directory
# Parameter: 
# Bemerkungen: Mithilfe von JackedProgrammer https://youtu.be/-dot-2GDYTs
#-----

# Konfiguration und Funktionen importieren
. .\Config.ps1
. .\Lernende\Read-CSVLernende.ps1
. .\Lernende\Read-ADLernende.ps1
. .\Verzeichnisse\New-LernenderVerzeichnis.ps1

function Add-ADLernende {    
    begin {
        # Lernende aus CSV Datei auslesen
        $CSVLernende = Read-CSVLernende

        # Lernende aus AD auslesen
        $ADLernende = Read-ADLernende
    }
    
    process {
        try {
            # Neue Lernende heraussuchen, falls es bestehende gibt
            $NeueLernende = $CSVLernende
            if ($null -ne $ADLernende) {
                $NeueLernendeNamen = Compare-Object $ADLernende $CSVLernende -Property SamAccountName | Where-Object { $_.SideIndicator -eq "=>" }
                
                # Neue Lernende aus CSV heraussuchen, welche neu sind
                $NeueLernende = $NeueLernende | Where-Object { $NeueLernendeNamen.SamAccountName -contains $_.SamAccountName }
            }
            Write-Log "Es wurden $($NeueLernende.Count) neue Lernende gefunden" -Level DEBUG

            # Account für neue Lernende erstellen
            $NeueLernende | ForEach-Object {
                Write-Log "Erstelle Konto für $($_.SamAccountName)" -Level DEBUG
                
                # Account erstellen
                New-ADUser -GivenName $_.GivenName `
                    -Surname $_.Surname `
                    -Initials "$($_.GivenName.Substring(0, 1))$($_.Surname.Substring(0, 2))".ToUpper() `
                    -DisplayName ($_.GivenName + " " + $_.Surname) `
                    -Name $_.SamAccountName `
                    -SamAccountName $_.SamAccountName `
                    -UserPrincipalName $_.SamAccountName `
                    -Office $Config.KLASSE_PREFIX.TrimEnd('_') `
                    -AccountPassword $Config.STANDARD_PW `
                    -ChangePasswordAtLogon $Config.ANDERE_PW `
                    -Path "OU=$($Config.OU_LERNENDE),$($Config.DOMAIN)" `
                    -Enabled $Config.BENUTZER_AKTIV
            
                Write-Log "Das Konto für $($_.SamAccountName) wurde erstellt" -Level INFO

                # Verzeichnis erstellen, wenn diese gewollt sind
                if ($Config.WANT_VERZEICHNIS) {
                    New-LernenderVerzeichnis -Lernender $_.SamAccountName
                }
            }
        }
        catch {
            # Fehler beim erstellen
            Write-Log "Fehler beim erstellen der AD-Benutzer : $($_.Exception.Message)" -Level FEHLER
        }
    }

    end {
        Write-Log "Es wurden $($NeueLernende.Count) neue Lernende erstellt" -Level INFO
    }
}