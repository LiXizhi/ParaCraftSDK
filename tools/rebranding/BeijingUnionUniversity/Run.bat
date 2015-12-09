@echo off 
pushd "%~dp0../../../redist/" 
call "ParaEngineClient.exe" dev="%~dp0" isDevEnv="true" mc="true"
popd 
