@echo off
if exist "%~dp0/redist/ParaEngineClient.dll" (
	call "%~dp0/redist/ParaEngineClient.exe" single="false" mc="true" noupdate="true"
) else (
	call "%~dp0/upgrade.bat"
)