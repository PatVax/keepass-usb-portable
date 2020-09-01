@echo off

echo This script is part of keepass-usb-portable GitHub repository 
echo which is released under the MIT License.
echo See file License in the directory containing this script 
echo or go to https://github.com/PatVax/keepass-usb-portable for full detail.

set sfp=%~dp0
set AppData=%sfp%portable_appdata
set LocalAppData=%AppData%

IF %ERRORLEVEL%==0 GOTO PATH_IS_OK
exit

:PATH_IS_OK
	
	rem Check if config.xml exists
	IF EXIST %sfp%portable_appdata\Syncthing\config.xml.aes GOTO READ_PASSWORD
	
	echo First run. Creating config files...
	
	rem Generate config file
	%sfp%x86_32\Syncthing\syncthing.exe -generate=%sfp%portable_appdata\Syncthing
	
	echo Removing default Sync directory from the Config...
	
	powershell -Command "((Get-Content portable_appdata\Syncthing\config.xml) -join '`n' -split '`n.*<folder.*?>' -split '</folder>`n' | select-string -pattern '^`n.*?`n' -notmatch) -split '`n' | Out-File -Encoding 'utf8' portable_appdata\Syncthing\config.xml"
	
	echo
	echo Please specify a password:
	
	rem Create password
	set pass=""
	set "psCommand=powershell -Command "$pword = read-host 'Enter password' -AsSecureString ; ^
		$BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword); ^
        [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
	for /f "usebackq delims=" %%p in (`%psCommand%`) do set pass=%%p
	
	set pass_repeat=""
	set "psCommand=powershell -Command "$pword = read-host 'Repeat password' -AsSecureString ; ^
		$BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword); ^
        [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
	for /f "usebackq delims=" %%p in (`%psCommand%`) do set pass_repeat=%%p
	
	rem Abort in case the passwords do not match
	IF "%pass%" == "%pass_repeat%" GOTO DECRYPT_OK
	
	echo Passwords did not match. Exiting...
	call %sfp%reset_config.bat
	pause
	exit
	
:READ_PASSWORD

	rem Read password
	set pass=""
	set "psCommand=powershell -Command "$pword = read-host 'Enter password' -AsSecureString ; ^
		$BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword); ^
        [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)""
	for /f "usebackq delims=" %%p in (`%psCommand%`) do set pass=%%p

	rem Decrypt Syncthing config
	%sfp%x86_64\AESCrypt\aescrypt.exe -p "%pass%" -d %sfp%portable_appdata\Syncthing\config.xml.aes

	rem Handle decryption failure
	IF EXIST %sfp%portable_appdata\Syncthing\config.xml GOTO DECRYPT_OK
	echo Wrong password. Exiting...
	pause
	exit

:DECRYPT_OK

	rem Delete encrypted Syncthing config
	del /q %sfp%portable_appdata\Syncthing\config.xml.aes

	rem Reset Syncthing Database to avoid syncing conflicts
	%sfp%x86_64\Syncthing\syncthing.exe -reset-database
	rem Run Syncthing. Stop by using CTRL+C command
	%sfp%x86_64\Syncthing\syncthing.exe -reset-deltas -no-browser

:ENCRYPT
	
	rem Attempt to encrypt Syncthing config with the original password
	%sfp%x86_64\AESCrypt\aescrypt.exe -p "%pass%" -e %sfp%portable_appdata\Syncthing\config.xml
	
IF EXIST %sfp%portable_appdata\Syncthing\config.xml.aes GOTO END

rem Error handling if Syncthing config could not be encrypted with the original password
echo Error: Password could not be set. Proceed to manual input...

rem Attempt encryption with manual password input and repeat if failed
:ENCRYPT_MANUAL

	%sfp%x86_64\AESCrypt\aescrypt.exe -e %sfp%portable_appdata\Syncthing\config.xml

IF NOT EXIST %sfp%portable_appdata\Syncthing\config.xml.aes GOTO ENCRYPT_MANUAL

rem Delete the Syncthing config and synced KeePass database
:END
	
	del %sfp%portable_appdata\Syncthing\config.xml
	del /q %sfp%DBs\*
	pause