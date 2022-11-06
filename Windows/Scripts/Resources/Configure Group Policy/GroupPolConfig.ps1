#List of services to be configured
$services =@('WinUpdate', 'WinDefender', 'EventLog', 'Powershell', 'WinRM', 'SMBv1','Firefox','Chrome','IExplorer','MSEdge','RDP')

#Add to the list of services from user input
if((Read-Host -Prompt "Enable remote desktop? (y/n)") -eq "y") {
    $services = $services + 'RDPOn'
} else {
    $services = $services + 'RDPOff'
}

#Import the GroupPolicies.csv file into a variable
$pols = Import-Csv -Path "$($PSScriptRoot)\GroupPolicies.csv"

#Copy over required .admx and .adml files
foreach ($pol in $pols) {
    if(($pol.Enabled -eq 'TRUE') -and (($pol.Service -eq [string]::Empty) -or ($services -contains $pol.Service))) {
        $admxImportPath = "$($env:SystemRoot)\PolicyDefinitions\$($pol.Template).admx"
        $admxExportPath = "$($PSScriptRoot)\Administrative Templates\$($pol.Template).admx"

        if(-not ($pol.Template -eq [string]::Empty) -and -not (Test-Path -Path $admxImportPath)) {
            try {
                Copy-Item $admxExportPath -Destination $admxImportPath -ErrorAction Stop
                Write-Output "Imported necessary file: $($admxExportPath) to $($admxImportPath)"
            } catch {
                Write-Output "Failed to import file: $($admxExportPath) to $($admxImportPath)"
            }
        }

        $admlImportPath = "$($env:SystemRoot)\PolicyDefinitions\en-us\$($pol.Template).adml"
        $admlExportPath = "$($PSScriptRoot)\Administrative Templates\en-us\$($pol.Template).adml"

        if(-not ($pol.Template -eq [string]::Empty) -and -not (Test-Path -Path $admlImportPath)) {
            try {
                Copy-Item $admlExportPath -Destination $admlImportPath -ErrorAction Stop
                Write-Output "Imported necessary file: $($admlExportPath) to $($admlImportPath)"
            } catch {
                Write-Output "Failed to import file: $($admlExportPath) to $($admlImportPath)"
            }
        }
    }
}

#Set the path to the policy file that will be edited by the script
$polPath = "$($env:SystemRoot)\System32\GroupPolicy\Machine\registry.pol"

#Create a backup of the current computer configuration policy file
try {
    $backupPath = "$($PSScriptRoot)\Backups\Registry($(Get-Date -Format "HH-mm-ss")).pol"
    New-Item -ItemType Directory -Force -Path ($backupPath | Split-Path -Parent) | Out-Null
    Copy-Item $polPath $backupPath -ErrorAction Stop
    Write-Output "Created a backup of the policy file at $($backupPath)"
} catch {
    Write-Output "Failed to create a backup of the policy file. The script will not continue."
    cmd /c pause
    exit
}

#Install PolicyFileEditor to enable manipulation of the pol file using scripts
#For some reason Tls1.2 specifically is required to install the module
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Module -Name PolicyFileEditor -Force

#Go through each row in the array of group policy changes and apply them
foreach ($pol in $pols) {
    #Only edit the policy if it is enabled in the csv and is for a service that needs to be configured
    if(($pol.Enabled -eq 'TRUE') -and (($pol.Service -eq '') -or ($services -contains $pol.Service))) {
        #Opional data type "Remove" will tell the program to delete the setting (set it to not configured)
        if($pol.Type -eq 'Remove') {
            Remove-PolicyFileEntry -Path $polPath -Key $pol.Key -ValueName $pol.Value
        } else {
            Set-PolicyFileEntry -Path $polPath -Key $pol.Key -ValueName $pol.Value -Data $pol.Data -Type $pol.Type
        }
        Write-Output "$($pol.Service) - $($pol.Name) is now set to $($pol.Setting)"
    }
}

#Force Windows to recognize all of the changes and update group policy
Write-Output ""
gpupdate /force

cmd /c pause
