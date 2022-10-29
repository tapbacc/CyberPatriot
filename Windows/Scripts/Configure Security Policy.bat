@echo off

::Check for Admin Rights
net session > nul 2> nul
if not %errorlevel% == 0 (
	echo:&echo Error: Admin privileges required. Please run this script in administrator mode.
	echo:&echo:Press any key to close the window.
	pause > nul
	exit
)

::Configure Security Policy From Template
secedit /configure /db c:\windows\security\local.sdb /cfg "%~dp0\Resources\Configure Security Policy\Win10Secure.inf"

pause
