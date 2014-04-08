@echo off 
pushd "%~dp0../../redist/" 
call "log.txt" 
call "ParaEngineClient.exe" bootstrapper="source/demo/main.lua" single="false" mc="true" noupdate="true" dev="%~dp0"  
popd 
