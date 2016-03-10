@echo off

echo install from redist
set PC_SDK_ROOT=%~dp0..\
set REDIST_DIR=%PC_SDK_ROOT%redist\
set DEST_DIR=%~dp0win\bin\
if exist "%REDIST_DIR%ParaEngineClient.dll" (
    mkdir win
    mkdir win\bin
    
    del /Q %DEST_DIR%paraengineclient.*
    copy /Y %REDIST_DIR%ParaEngineClient.exe  %DEST_DIR%
    copy /Y %REDIST_DIR%ParaEngineClient.dll  %DEST_DIR%
    copy /Y %REDIST_DIR%autoupdater.dll  %DEST_DIR%
    copy /Y %REDIST_DIR%caudioengine.dll  %DEST_DIR%
    copy /Y %REDIST_DIR%d3dx9_43.dll  %DEST_DIR%
    copy /Y %REDIST_DIR%freeimage.dll  %DEST_DIR%
    copy /Y %REDIST_DIR%f_in_box.dll  %DEST_DIR%
    copy /Y %REDIST_DIR%libcurl.dll  %DEST_DIR%
    copy /Y %REDIST_DIR%lua.dll  %DEST_DIR%
    copy /Y %REDIST_DIR%openal32.dll  %DEST_DIR%
    copy /Y %REDIST_DIR%sqlite.dll  %DEST_DIR%
    copy /Y %REDIST_DIR%physicsbt.dll  %DEST_DIR%
    copy /Y %REDIST_DIR%wrap_oal.dll  %DEST_DIR%
    
    mkdir win\packages
    del /Q %DEST_DIR%..\packages\main*.pkg
    copy /Y %REDIST_DIR%main*.pkg  %DEST_DIR%..\packages\
) else (
    echo please run %REDIST_DIR%paracraft.exe first to install latest client
    echo and then run this file again
    pause
    call "%REDIST_DIR%paracraft.exe"
    exit
)
echo register NPL runtime to env path
pause
%~dp0win\bin\npls reg_env_path.lua