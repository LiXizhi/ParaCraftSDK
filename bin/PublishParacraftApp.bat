REM  Publish App in the Redist folder
echo off
echo.
set PC_SDK_ROOT=%~dp0..\
Set pub_dir=%PC_SDK_ROOT%published\
Set redist_dir=%PC_SDK_ROOT%redist\
Set bin_dir=%PC_SDK_ROOT%bin\
Set /p appname=请输入要发布的APP名字（空表示为产品本身）:
Set start_filename=运行%appname%.bat

pushd %redist_dir%
echo 正在清理%redist_dir%中的临时文件
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
echo 恭喜！%redist_dir%清理完毕
echo 请自己将 %redist_dir% worlds目录手工清理. 

REM application related files
rd "apps" /s /q
del *.bat
popd

REM 生成启动文件
Set RunFileName="%redist_dir%\%start_filename%"
del %RunFileName%
if "%appname%" NEQ "" (
	mkdir "%redist_dir%apps"
	mkdir "%redist_dir%apps\%appname%"
	xcopy "%PC_SDK_ROOT%_apps\%appname%" "%redist_dir%apps\%appname%" /C /E
	echo 成功将"%PC_SDK_ROOT%apps\%appname%" 发布到了apps目录
	
	REM  create the Run.bat file
	echo @echo off >> %RunFileName%
	echo pushd "%%~dp0" >> %RunFileName%
	echo call "ParaEngineClient.exe" bootstrapper="source/%appname%/main.lua" single="false" mc="true" noupdate="true" dev="%%~dp0apps\%appname%"  >> %RunFileName%
	echo popd >> %RunFileName%
) else (
	echo call "%%~dp0ParaCraft.exe" >> %RunFileName%
	echo call "%%~dp0ParaEngineClient.exe" single="false" mc="true" noupdate="true">> %redist_dir%\离线运行.bat
)

echo 恭喜！生成完毕
echo 请自己将 %redist_dir% 打包并发布. 

Set /p tmp=是否将redist目录打包为zip文件（确认按Y）
if '%tmp%'=='Y' (
	call "%bin_dir%7z.exe" a [离线版客户端]ParaCraft%appname%%DATE:~0,4%%DATE:~5,2%%DATE:~8,2%.zip %redist_dir%
) else (
	pause
	start explorer.exe "%redist_dir%"
)
