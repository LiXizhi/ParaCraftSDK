@echo off

pushd "%~dp0../../redist/"
call "ParaEngineClient.exe" single="false" mod="Sample" mc="true" noupdate="true" dev="%~dp0" isDevEnv="true"
popd
