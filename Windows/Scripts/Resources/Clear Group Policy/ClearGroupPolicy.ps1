#Create a backup of entire group policy
try {
    $backupPath = "$($PSScriptRoot)\Backups\Group Policy($(Get-Date -Format "HH-mm-ss"))"
    New-Item -ItemType Directory -Force -Path ($backupPath | Split-Path -Parent) | Out-Null
    Copy-Item -Path "$($env:SystemRoot)\System32\GroupPolicy" -Destination $backupPath -Recurse -ErrorAction Stop
    Write-Output "Created a backup of the entire Group Policy directory at $($backupPath)"
} catch {
    Write-Output "Failed to create a backup of the policy file. The script will not continue."
    cmd /c pause
    exit
}

#Clear all group policy files
cmd /c RD /S /Q "%WinDir%\System32\GroupPolicyUsers"
cmd /c RD /S /Q "%WinDir%\System32\GroupPolicy"

#Update group policy settings on the computer
gpupdate /force

Write-Output "You may close the group policy window that opens."

cmd /c gpedit.msc

Write-Output "All group policy changes have been cleared."
cmd /c pause