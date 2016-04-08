@echo off

rem start client
npl "script/test/network/SimpleClientServer.lua" client="true"

rem show log file
call "log.txt"