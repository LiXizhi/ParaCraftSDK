REM  pack files
echo off
echo.
Set src_dir=D:\lxzsrc\ParaEngine\ParaWorld\bin64
Set bin_dir=%~dp0..\..\bin
Set dest_dir=%~dp0ParaCraft

mkdir "%dest_dir%"
xcopy "%bin_dir%\..\redist\ParaCraft.exe" "%dest_dir%" /C /Y

call "%bin_dir%\7z.exe" a %~dp0ParaCraftV0.1.zip %dest_dir%
