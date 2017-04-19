@echo off
call :sub >"%~dp0main_temp.bat.txt"
exit /b
:sub
reg query HKCU\Environment /v PATH