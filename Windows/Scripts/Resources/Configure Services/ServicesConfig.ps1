#Import the GroupPolicies.csv file into a variable
$services = Import-Csv -Path "$($PSScriptRoot)\Services.csv"

foreach ($service in $services) {
    
    if ((Get-Service | where name -eq $service.Process) -eq $null) {
        Write-Host "$($service.Name) is not installed on this computer. Ignoring."
        continue
    }

    if ((Get-Service | where name -eq $service.Process).StartType -eq $service.Mode) {
        Write-Host "$($service.Name) is already configured correctly. No action taken."
        continue
    }

    try {
        Set-Service -Name $service.Process -StartupType $service.Mode -ErrorAction Stop
        Write-Host "$($service.Name) was configured incorrectly. Startup type has been switched to $($service.Mode)." -ForegroundColor green
    } catch {
        Write-Host "Failed to change startup type for $($service.Name) to $($service.Mode)." -ForegroundColor red
        continue
    }

    if (($service.Mode -eq 'Automatic') -and -not ((Get-Service | where name -eq $service.Process).Status -eq 'Running')) {
        try {
            Start-Service -Name $service.Process -ErrorAction Stop | Out-Null
            Write-Host "$($service.Name) is now started." -ForegroundColor green
        } catch {
            Write-Host "Failed to start the $($service.Name) service." -ForegroundColor red
            continue
        }
    }

    if (($service.Mode -eq 'Disabled') -and -not ((Get-Service | where name -eq $service.Process).Status -eq 'Stopped')) {
        try {
            Stop-Service -Name $service.Process -ErrorAction Stop | Out-Null
            Write-Host "$($service.Name) is now stopped." -ForegroundColor green
        } catch {
            Write-Host "Failed to stop the $($service.Name) service." -ForegroundColor red
            continue
        }
        
    }
}

cmd /c pause