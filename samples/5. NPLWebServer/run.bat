@echo off
rem run in development mode
npl -d bootstrapper="script/apps/WebServer/WebServer.lua" port="8099" root="www/" dev="%~dp0"

rem "npl main.lua"