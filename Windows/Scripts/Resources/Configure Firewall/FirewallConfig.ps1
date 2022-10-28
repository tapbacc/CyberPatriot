#Turn on firewall for all profiles
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled True

#Set firewall to block all inrestricted inbound traffic and allow all unrestricted outbound traffic
Set-NetFirewallProfile -Profile Domain, Public, Private -DefaultInboundAction Block -DefaultOutboundAction Allow

#Set firewall to notify the user when a program's traffic is blocked by the firewall, and disable unicast
Set-NetFirewallProfile -Profile Domain, Public, Private –NotifyOnListen True -AllowUnicastResponseToMulticast False

#Properly configure firewall log location and size
Set-NetFirewallProfile -Profile Domain, Public, Private –LogFileName %SystemRoot%\System32\LogFiles\Firewall\pfirewall.log -LogMaxSizeKilobytes 16384

#Make sure that all important firewall events are logged
Set-NetFirewallProfile -Profile Domain, Public, Private -LogAllowed True -LogBlocked True

Write-Output "Firewall successfully configured."
cmd /c pause
