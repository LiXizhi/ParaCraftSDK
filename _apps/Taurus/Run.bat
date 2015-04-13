@echo off 
pushd "..\..\redist\" 
call "log.txt" 
call "ParaEngineClient.exe" bootstrapper="script/apps/Taurus/bootstrapper.xml" single="false" mc="true" noupdate="true" dev="%~dp0"  
popd 
