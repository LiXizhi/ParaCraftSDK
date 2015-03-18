@echo off
set PC_SDK_ROOT=%~dp0../
if exist "%PC_SDK_ROOT%redist/ParaEngineClient.dll" (
	call "%PC_SDK_ROOT%redist/ParaEngineClient.exe" single="false" mc="true" noupdate="true" isDevEnv="true"
) else (
	call "%PC_SDK_ROOT%bin/upgrade.bat"
)