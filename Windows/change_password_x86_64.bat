@echo off

rem This script is part of keepass-usb-portable GitHub repository which is released under the MIT License.
rem See file License in the directory containing this script or go to https://github.com/PatVax/keepass-usb-portable for full detail.

set sfp=%~dp0

IF EXIST %sfp%portable_appdata\Syncthing\config.xml.aes GOTO OLD_PASSWORD

	echo No Syncthing config found. Use the init script to initialize the config. Exiting...
	pause
	exit

:OLD_PASSWORD

	rem Entering old password
	set pass_old=""
	set "psCommand=powershell -Command "$pword = read-host 'Enter old password' -AsSecureString ; ^
		$BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword); ^
		[System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
	for /f "usebackq delims=" %%p in (`%psCommand%`) do set pass_old=%%p

	rem Try decrypting Syncthing config
	%sfp%x86_64\AESCrypt\aescrypt.exe -p "%pass_old%" -d %sfp%portable_appdata\Syncthing\config.xml.aes

	rem Handle decryption failure
	IF EXIST %sfp%portable_appdata\Syncthing\config.xml GOTO NEW_PASSWORD
	echo Wrong password. Exiting...
	pause
	exit

:NEW_PASSWORD

	rem Entering new password
	set pass_new="pass_new"
	set "psCommand=powershell -Command "$pword = read-host 'Enter new password' -AsSecureString ; ^
		$BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword); ^
		[System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
	for /f "usebackq delims=" %%p in (`%psCommand%`) do set pass_new=%%p

	set pass_repeat="pass_repeat"
	set "psCommand=powershell -Command "$pword = read-host 'Repeat new password' -AsSecureString ; ^
		$BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword); ^
		[System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
	for /f "usebackq delims=" %%p in (`%psCommand%`) do set pass_repeat=%%p

	rem Repeat password if passwords did not match
	if "%pass_new%" == "%pass_repeat%" goto ENCRYPT

	echo Passwords did not match. Repeat.
	goto NEW_PASSWORD

:ENCRYPT

	echo Password changed successfully.
	rem Encrypt the config with the new password
	%sfp%x86_64\AESCrypt\aescrypt.exe -p "%pass_new%" -e %sfp%portable_appdata\Syncthing\config.xml
	del %sfp%portable_appdata\Syncthing\config.xml
	pause