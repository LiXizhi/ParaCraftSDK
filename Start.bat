@echo off
if exist "%CD%/redist/ParaEngineClient.dll" (
	start %CD%/redist/ParaEngineClient.exe single="false" mc="true" noupdate="true"
) else (
	start %CD%/upgrade.bat
)