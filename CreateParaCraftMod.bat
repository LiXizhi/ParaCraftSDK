echo off

Set /p modname=请输入Mod的名字:

mkdir modDev\%modname%
mkdir modDev\%modname%\script
mkdir modDev\%modname%\Mod\%modname%

xcopy "%~dp0modDev\Sample\run.bat"  "%~dp0modDev\%modname%"
xcopy "%~dp0modDev\Sample\Mod\Sample\main.lua" "%~dp0modDev\%modname%\Mod\%modname%" 

Set RunFileName="%~dp0modDev\%modname%\Run.bat"
del %RunFileName%
echo @echo off >> %RunFileName%
echo pushd "%%~dp0../../redist/" >> %RunFileName%
echo call "ParaEngineClient.exe" single="false" mc="true" noupdate="true" dev="%%~dp0" mod="%modname%" isDevEnv="true"  >> %RunFileName%
echo popd >> %RunFileName%

del %~dp0modDev\%modname%\Mod\%modname%\main.lua
setlocal enabledelayedexpansion
(for /f "delims=" %%s in (F:/github/ParaCraftSDK/modDev/Sample/Mod/Sample/main.lua) do (
    set "row=%%s"
    if not "!row:function=%!"=="!row!" (echo.)
    set "row=!row:Sample=%modname%!"
    echo,!row!
))>"%~dp0modDev\%modname%\Mod\%modname%\main.lua"


echo 恭喜！生成完毕: modDev\%modname%

start explorer.exe "%~dp0modDev\%modname%"
