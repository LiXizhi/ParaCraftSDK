echo off
set PC_SDK_ROOT=%~dp0..\
Set /p modname=请输入Mod的名字:

REM create in "./_mod/[modname]" folder
set modfolder=%PC_SDK_ROOT%_mod\%modname%

mkdir %modfolder%\script
mkdir %modfolder%\Mod\%modname%

xcopy "%PC_SDK_ROOT%samples\mod\Sample\run.bat"  "%modfolder%"
xcopy "%PC_SDK_ROOT%samples\mod\Sample\Mod\Sample\main.lua" "%modfolder%\Mod\%modname%" 

Set RunFileName="%modfolder%\Run.bat"
del %RunFileName%
echo @echo off >> %RunFileName%
echo pushd "%%~dp0../../redist/" >> %RunFileName%
echo call "ParaEngineClient.exe" single="false" mc="true" noupdate="true" dev="%%~dp0" mod="%modname%" isDevEnv="true"  >> %RunFileName%
echo popd >> %RunFileName%

del %modfolder%\Mod\%modname%\main.lua
setlocal enabledelayedexpansion
(for /f "delims=" %%s in (%PC_SDK_ROOT%samples\mod\Sample\Mod\Sample\main.lua) do (
    set "row=%%s"
    if not "!row:function=%!"=="!row!" (echo.)
    set "row=!row:Sample=%modname%!"
    echo,!row!
))>"%modfolder%\Mod\%modname%\main.lua"


echo 恭喜！生成完毕: %modfolder%

start explorer.exe "%modfolder%"
