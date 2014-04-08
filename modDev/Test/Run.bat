@echo off

pushd "%~dp0../../redist/"
call "log.txt"
call "ParaEngineClient.exe" single="false" mod="Test" mc="true" noupdate="true" dev="%~dp0" 
popd
