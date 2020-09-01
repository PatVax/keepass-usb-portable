@echo off

rem This script is part of keepass-usb-portable GitHub repository which is released under the MIT License.
rem See file License in the directory containing this script or go to https://github.com/PatVax/keepass-usb-portable for full detail.

set sfp=%~dp0

IF EXIST "%sfp%portable_appdata\Syncthing" (
    for /F "delims=" %%i in ('dir "%sfp%portable_appdata\Syncthing" /B') do (rmdir "%sfp%portable_appdata\Syncthing\%%i" /S /Q 2>NUL || del "%%i" /S /Q >NUL)
)