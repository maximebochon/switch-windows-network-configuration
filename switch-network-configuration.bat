@echo off

rem -- Script:    switch-network-configuration.bat
rem -- Author:    maxime.bochon@gmail.com
rem -- Creation:  03/10/2018
rem -- Update:    02/08/2021
rem -- Notice:    All IP adresses and configuration data here are fictitious.

goto check_admin

:check_admin
	net session >nul 2>&1
	if not %ErrorLevel% == 0 (
		echo. 
		echo. Please run this script as administrator.
		echo.
		pause
		goto end
	)

goto menu

:menu
	cls
	
	echo.
	echo. Configure proxy and DNS resolution for:
	echo.   I) intranet
	echo.   E) extranet
	echo.
	echo. Switch internet proxy:
	echo.   0) off
	echo.   1) on
	echo.
	echo. Quit:
	echo.   Q)
	echo.
	
	choice /C IE01Q
	cls
	if %Errorlevel% == 1 goto set_conf_intranet
	if %Errorlevel% == 2 goto set_conf_extranet
	if %Errorlevel% == 3 goto switch_proxy_off
	if %Errorlevel% == 4 goto switch_proxy_on
	if %Errorlevel% == 5 goto end

:set_conf_intranet
	set ENV="intranet"
	set DNS="10.10.10.10"
	set PROXY_SERVER="proxy.bochon.intra"
	set PROXY_OVERRIDE=""
	goto set_conf

:set_conf_extranet
	set ENV="extranet"
	set DNS="10.27.255.71"
	set PROXY_SERVER="10.27.255.71:8080"
	set PROXY_OVERRIDE="*.outside;*.local;10.*.*.*;192.168.*.*;*.bochon.intra;"
	goto set_conf

:set_conf
	echo.
	echo. ^=^> proxy and DNS configuration for %ENV%
	echo.
	netsh interface ipv4 add dnsserver "Ethernet" address=%DNS% index=1
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /t REG_SZ /d %PROXY_SERVER% /f
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /t REG_SZ /d %PROXY_OVERRIDE% /f
	pause
	goto menu

:switch_proxy_on
	set SWITCH_NAME="on"
	set SWITCH_VALUE=1
	goto switch_proxy

:switch_proxy_off
	set SWITCH_NAME="off"
	set SWITCH_VALUE=0
	goto switch_proxy

:switch_proxy
	echo.
	echo. ^=^> switch proxy %SWITCH_NAME%
	echo.
	reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d %SWITCH_VALUE% /f
	pause
	goto menu

:end
