@echo off 
pushd "%~dp0..\..\redist\" 
call "log.txt" 
call "ParaEngineClient.exe" bootstrapper="script/apps/Aries/main_loop.lua" mc="true" single="false" noupdate="true" dev="%~dp0"
popd 
