rem echo off
setlocal enabledelayedexpansion
if exist %~dp0sdkpath.txt (
	set /p default_sdk_path=<%~dp0sdkpath.txt
) else (
	set default_sdk_path=D:\workroot\KidsMovie\ParaEngineSDK	
)

set /p SDK_PATH=Please enter SDK path(press Enter to default to %default_sdk_path%):

if "%SDK_PATH%" == "" (
	set SDK_PATH=%default_sdk_path%
) else (
	echo %SDK_PATH% >> %~dp0sdkpath.txt
)

xcopy "%SDK_PATH%\src"  "%~dp0" /e /d /y /c

exit 0