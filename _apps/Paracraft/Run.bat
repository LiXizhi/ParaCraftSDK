@echo off 
pushd "%~dp0..\..\redist\" 
call "log.txt" 
call "ParaEngineClient.exe" bootstrapper="source/SeerCraft/main.lua" single="false" noupdate="true" dev="%~dp0"
popd 
