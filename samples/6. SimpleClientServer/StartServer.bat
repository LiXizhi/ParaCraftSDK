@echo off

rem start server
npl "script/test/network/SimpleClientServer.lua" server="true"

rem show log file
call "log.txt"
