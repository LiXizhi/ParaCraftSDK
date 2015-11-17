REM  Publish App in the Redist folder
echo off
echo.
set PC_SDK_ROOT=%~dp0..\
Set pub_dir=%PC_SDK_ROOT%published\
Set redist_dir=%PC_SDK_ROOT%redist\
Set bin_dir=%PC_SDK_ROOT%bin\
Set /p appname=Please enter application name (empty for current product):
Set start_filename=run %appname%.bat

pushd %redist_dir%
echo cleaning up temp files in %redist_dir%
del asset.log
del log.txt
del perf.txt
del *.mem.exe
del database\creator_profile.db
del database\localserver.*
del database\userdata.*
del database\app.*
rd "worlds\DesignHouse\userworlds" /s /q
rd "worlds\DesignHouse\backups" /s /q

rd "Screen Shots" /s /q
rd "log" /s /q
rd "Update" /s /q
rd "temp/apps" /s /q
rd "temp/composeface" /s /q
rd "temp/composeskin" /s /q
rd "temp/tempdatabase" /s /q
rd "temp/webcache" /s /q
rd "temp/tempdownloads" /s /q
rd "temp/cache" /s /q
rd "temp/mybag" /s /q
rd "mono" /s /q
rd "launcher_caches" /s /q
rd "launcher_res" /s /q
rd "caches" /s /q
rd "bin64" /s /q
echo Congrat! %redist_dir% is cleaned up
echo please manually remove all files in world directory %redist_dir%

REM application related files
rd "apps" /s /q
del *.bat
popd

REM generate start file
Set RunFileName="%redist_dir%\%start_filename%"
del %RunFileName%
if "%appname%" NEQ "" (
	mkdir "%redist_dir%apps"
	mkdir "%redist_dir%apps\%appname%"
	xcopy "%PC_SDK_ROOT%_apps\%appname%" "%redist_dir%apps\%appname%" /C /E
	echo Successfully published app to "%PC_SDK_ROOT%apps\%appname%"
	
	REM  create the Run.bat file
	echo @echo off >> %RunFileName%
	echo pushd "%%~dp0" >> %RunFileName%
	echo call "ParaEngineClient.exe" bootstrapper="source/%appname%/main.lua" single="false" mc="true" noupdate="true" dev="%%~dp0apps\%appname%"  >> %RunFileName%
	echo popd >> %RunFileName%
) else (
	echo call "%%~dp0ParaCraft.exe" >> %RunFileName%
	echo call "%%~dp0ParaEngineClient.exe" single="false" mc="true" noupdate="true">> %redist_dir%\run_offline.bat
)

echo Congrat! finished!
echo please manually zip and publish %redist_dir% 

Set /p tmp=Do you want to zip redist directory (Y to confirm)
if '%tmp%'=='Y' (
	call "%bin_dir%7z.exe" a [Offline]ParaCraft%appname%%DATE:~0,4%%DATE:~5,2%%DATE:~8,2%.zip %redist_dir%
) else (
	pause
	start explorer.exe "%redist_dir%"
)
