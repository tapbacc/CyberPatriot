@echo off
::---------------------------------------------------------------------------------------
::Service Configuration
::---------------------------------------------------------------------------------------
::List Automatic Services:
::bfe				::Base Filtering Engine
::dhcp				::DHCP Client
::dnscache			::DNS Client
::eventlog			::Windows Event Log
::mpssvc			::Windows Firewall
::List End

::List Manual Services:
::trustedinstaller		::Windows Modules Installer
::wuauserv			::Windows Update
::List End

::List Disabled Services:
::btagservice			::Bluetooth Audio Gateway Service
::bthserv			::Bluetooth Support Service
::browser			::Computer Browser
::mapsbroker			::Downloaded Maps Manager
::lfsvc				::Geolocation Service
::iisadmin			::IIS Admin Service
::irmon				::Infrared Monitor Service
::sharedaccess			::Internet Connection Sharing (ICS)
::iphlpsvc			::IP Helper
::lltdsvc			::Link-Layer Topology Discovery Mapper
::lxssmanager			::LxssManager
::ftpsvc			::Microsoft FTP Service
::msiscsi			::Microsoft iSCSI Initiator Service
::installservice		::Microsoft Store Install Service
::nettcpportsharing		::Net.Tcp Port Sharing Service
::sshd				::OpenSSH SSH Server
::pnrpsvc			::Peer Name Resolution Protocol
::p2psvc			::Peer Networking Grouping
::p2pimsvc			::Peer Networking Identity Manager
::pnrpautoreg			::PNRP Machine Name Publication Service
::wercplsupport			::Problem Reports and Solutions Control Panel Support
::rasauto			::Remote Access Auto Connection Manager
::rpclocator			::Remote Procedure Call (RPC) Locator
::remoteregistry		::Remote Registry
::remoteaccess			::Routing and Remote Access
::seclogon			::Secondary Logon
::simptcp			::Simple TCP/IP Services
::snmp				::SNMP Service
::ssdpsrv			::SSDP Discovery
::upnphost			::UPnP Device Host
::wmsvc				::Web Management Service
::wersvc			::Windows Error Reporting Service
::wecsvc			::Windows Event Collector
::wmpnetworksvc			::Windows Media Player Network Sharing Service
::icssvc			::Windows Mobile Hotspot Service
::wpnservice			::Windows Push Notifications System Service
::pushtoinstall			::Windows PushToInstall Service
::winrm				::Windows Remote Management (WS-Management)
::w3svc				::World Wide Web Publishing Service
::xboxgipsvc			::Xbox Accessory Management Sercice
::xblauthmanager		::Xbox Live Auth Manager
::xblgamesave			::Xbox Live Game Save
::xboxnetapisvc			::Xbox Live Networking Services
::List End

::---------------------------------------------------------------------------------------
::Check for Admin Rights
net session > nul 2> nul
if not %errorlevel% == 0 (
	echo:&echo Error: Admin privileges required. Please run this script in administrator mode.
	echo:&echo:Press any key to close the window.
	pause > nul
	exit
)

::Global Variables
set problemsFound=0
set problemsSolved=0

::-----------------------------
::Enable Automatic Services
::-----------------------------

for /f "skip=2 delims=[]" %%i in ('find /n "List Automatic Services" "%~f0"') do (
	set /a startingLine=%%i
	goto :break
)
:break

for /f "skip=%startingline% tokens=1,2 delims=:" %%a in ('type "%~f0"') do (
	if "%%~a" == "List End" (
		goto :break
	)
	echo: & echo Enabling %%b:
	sc query %%a > nul 2> nul
	if errorlevel 1060 (
		echo Service is not installed on this computer. Ignoring.
	) else (
		sc qc %%a | find "START_TYPE" | find "AUTO_START" > nul && (
			echo Service is already configured correctly. No action taken.
		) || (
			set /a problemsFound+=1
			sc config %%a start= auto > nul 2> nul
			echo Service was configured incorrectly. Startup type has been switched to automatic.
			sc query %%a | find "STATE" | find "STOPPED" > nul 2> nul && (
				echo Service is not Running. Attempting to start the service...
   				net start %%a > nul 2> nul && (
        				echo Service started successfully.
					set /a problemsSolved+=1
   				) || (
					call echo Failed to start service.
				)
			) || (
				set /a problemsSolved+=1
			)
		)
	)
)
:break

::-----------------------------
::Enable Manual Services
::-----------------------------

for /f "skip=2 delims=[]" %%i in ('find /n "List Manual Services" "%~f0"') do (
	set /a startingLine=%%i
	goto :break
)
:break

for /f "skip=%startingline% tokens=1,2 delims=:" %%a in ('type "%~f0"') do (
	if "%%~a" == "List End" (
		goto :break
	)
	echo: & echo Enabling %%b:
	sc query %%a > nul 2> nul
	if errorlevel 1060 (
		echo Service is not installed on this computer. Ignoring.
	) else (
		sc qc %%a | find "START_TYPE" | find "DEMAND_START" > nul && (
			echo Service is already configured correctly. No action taken.
		) || (
			set /a problemsFound+=1
			sc config %%a start= demand > nul 2> nul
			echo Service was configured incorrectly. Startup type has been switched to manual.
			set /a problemsSolved+=1
		)
	)
)
:break

::-----------------------------
::Disable Vulnerable Services
::-----------------------------

for /f "skip=2 delims=[]" %%i in ('find /n "List Disabled Services" "%~f0"') do (
	set /a startingLine=%%i
	goto :break
)
:break

for /f "skip=%startingline% tokens=1,2 delims=:" %%a in ('type "%~f0"') do (
	if "%%~a" == "List End" (
		goto :break
	)
	echo: & echo Disabling %%b:
	sc query %%a > nul 2> nul
	if errorlevel 1060 (
		echo Service is not installed on this computer. Ignoring.
	) else (
		sc qc %%a | find "START_TYPE" | find "DISABLED" > nul && (
			echo Service is already configured correctly. No action taken.
		) || (
			set /a problemsFound+=1
			sc config %%a start= disabled > nul 2> nul
			echo Service was configured incorrectly. Startup type has been switched to disabled.
			sc query %%a | find "STATE" | find "RUNNING" > nul 2> nul && (
				echo Service is Running. Attempting to stop the service...
   				net stop %%a > nul 2> nul && (
        				echo Service stopped successfully.
					set /a problemsSolved+=1
   				) || (
					call echo Failed to stop service.
				)
			) || (
				set /a problemsSolved+=1
			)
		)
	)
)
:break

::-----------------------------
::End Report
::-----------------------------

echo:&echo:-----------------------------------------
echo:^| Script finished.			^|
echo:^| Problems found: %problemsFound%			^|
echo:^| Problems solved: %problemsSolved%			^|
echo:^|					^|
echo:^| Press any key to close the window.	^|
echo:-----------------------------------------
pause > nul
