secedit /configure /db "$($env:WinDir)\security\local.sdb" /cfg "$($PSScriptRoot)\Win10Secure.inf" | Out-Null
Write-Host "Applied all security policy settings"

$users = Get-LocalUser | select -property name

foreach ($user in $users) {
    if ($user.Name -eq $env:UserName) {
        continue
    }
    Set-LocalUser -Name $user.name -PasswordNeverExpires $false -UserMayChangePassword $true
    net user $user.Name 'Cyb3rPatri0t!' | Out-Null
}

Write-Host "`nChanged password to Cyb3rPatri0t! and configured password settings for all users (other than you)"

<#
Write-Host "`nList of current users and groups:"
$ignored = 'DefaultAccount', 'RenamedAdm', 'RenamedGue', 'WDAGUtilityAccount', $env:UserName
foreach ($user in $users) {
    if ($ignored -contains $user.Name) {
        continue
    }

    Write-Host "`n$($user.Name)"
    net user $user.Name | select-string 'Local Group Memberships'
}
#>
    

cmd /c pause