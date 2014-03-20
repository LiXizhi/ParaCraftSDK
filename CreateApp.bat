echo off

Set /p appname=请输入APP的名字:

mkdir apps\%appname%
mkdir apps\%appname%\script
mkdir apps\%appname%\script\%appname%

xcopy samples\HelloWorld\script\HelloWorld\  apps\%appname%\
xcopy samples\HelloWorld\script\HelloWorld  /C /E apps\%appname%\script\%appname%

echo 恭喜！生成完毕: apps\%appname%

start explorer.exe "%CD%\apps\%appname%"