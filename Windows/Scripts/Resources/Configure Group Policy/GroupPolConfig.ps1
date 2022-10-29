#Record the list of installed services from user input
$services =@()

if((Read-Host -Prompt "Secure Firefox? (y/n)") -eq "y") {
    $services = $services + 'Firefox'
}
if((Read-Host -Prompt "`nSecure Chrome? (y/n)") -eq "y") {
    $services = $services + 'Chrome'
}
if((Read-Host -Prompt "`nSecure Internet Explorer? (y/n)") -eq "y") {
    $services = $services + 'IExplorer'
}
if((Read-Host -Prompt "`nSecure Microsoft Edge? (y/n)") -eq "y") {
    $services = $services + 'MSEdge'
}

Clear-Host

#Import the GroupPolicies.csv file into a variable
#$pols = Import-Csv -Path (($PSCommandPath | Split-path -Parent) + '\GroupPolicies.csv')
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

<#
#skipped pages:
498-499: Win 11
526: No template built into Windows
558-571: NG / BitLocker
573-584: Bitlocker
628-627: Bitlocker
650-653: Bitlocker
705-796: BitLocker
799: Win 11
821-823: Win 11
878-882: Niche and time consuming, probably not applicable to cyberpatriot
912-925: NG / BitLocker
1079-1081: Not applicable to cyberpatriot
1085-1090: Not applicable to cyberpatriot (screensaver)
#>

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
Install-Module -Name PolicyFileEditor -Force

#Go through each row in the array of group policy changes and apply them
foreach ($pol in $pols) {
    if(($pol.Enabled -eq 'TRUE') -and (($pol.Service -eq '') -or ($services -contains $pol.Service))) {
        Set-PolicyFileEntry -Path $polPath -Key $pol.Key -ValueName $pol.Value -Data $pol.Data -Type $pol.Type
        Write-Output "$($pol.Name) is now set to $($pol.Setting)"
    }
}

#Force Windows to recognize all of the changes and update group policy
Write-Output ""
gpupdate /force

cmd /c pause
