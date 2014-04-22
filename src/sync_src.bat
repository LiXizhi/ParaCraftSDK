echo off
setlocal enabledelayedexpansion
if exist %~dp0sdkpath.txt (
	set /p default_sdk_path=<%~dp0sdkpath.txt
) else (
	set default_sdk_path=D:\workroot\KidsMovie\ParaEngineSDK	
)

set /p SDK_PATH=请输入SDK路径(Enter键默认到%default_sdk_path%):

if "%SDK_PATH%" == "" (
	set SDK_PATH=%default_sdk_path%
) else (
	echo %SDK_PATH% >> %~dp0sdkpath.txt
)

xcopy "%SDK_PATH%\src\*.*"  "%~dp0" /e /d /y /c
xcopy "%SDK_PATH%\config\Aries\creator\bom\*.xml"  "%~dp0config\Aries\creator\bom\" /e /d /y /c
xcopy "%SDK_PATH%\config\Aries\creator\block_types.xml"  "%~dp0config\Aries\creator\" /e /d /y /c
xcopy "%SDK_PATH%\config\Aries\creator\BuildingTasks.xml"  "%~dp0config\Aries\creator\" /e /d /y /c
pause