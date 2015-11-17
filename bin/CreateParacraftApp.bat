echo off
set PC_SDK_ROOT=%~dp0..\

Set /p appname=Please enter app name to create:

REM create in "./_apps/[appname]" folder
set appfolder=%PC_SDK_ROOT%_apps\%appname%
mkdir %appfolder%\source\%appname%

xcopy "%PC_SDK_ROOT%samples\1. HelloWorld\*.*"  "%appfolder%"
xcopy "%PC_SDK_ROOT%samples\1. HelloWorld\source\HelloWorld" "%appfolder%\source\%appname%" /C /E


REM  create the Run.bat file
Set RunFileName="%appfolder%\Run.bat"
del %RunFileName%
echo @echo off >> %RunFileName%
echo pushd "%%~dp0..\..\redist\" >> %RunFileName%
echo call "log.txt" >> %RunFileName%
echo call "ParaEngineClient.exe" bootstrapper="source/%appname%/main.lua" single="false" mc="true" noupdate="true" dev="%%~dp0"  >> %RunFileName%
echo popd >> %RunFileName%


echo Congrat! successfully created at: %appfolder%\%appname%

start explorer.exe "%appfolder%"

pause