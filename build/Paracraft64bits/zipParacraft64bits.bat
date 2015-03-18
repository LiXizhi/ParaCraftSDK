REM  pack files
echo off
echo.
Set src_dir=D:\lxzsrc\ParaEngine\ParaWorld\bin64
Set bin_dir=%~dp0..\..\bin
Set dest_dir=%~dp0ParaCraft64bits

mkdir "%dest_dir%"
mkdir "%dest_dir%\bin64"
xcopy "%src_dir%\libcurl.dll" "%dest_dir%\bin64" /C /Y
xcopy "%src_dir%\ParaEngineClient.dll" "%dest_dir%\bin64" /C /Y
xcopy "%src_dir%\ParaEngineClient.exe" "%dest_dir%\bin64" /C /Y
xcopy "%src_dir%\PhysicsBT.dll" "%dest_dir%\bin64" /C /Y
xcopy "%src_dir%\sqlite.dll" "%dest_dir%\bin64" /C /Y
xcopy "%src_dir%\lua51_jit2.0.3_MT_64bits.dll" "%dest_dir%\bin64\lua.dll" /C /Y
xcopy "%src_dir%\sqlite.dll" "%dest_dir%\bin64" /C /Y
xcopy "%src_dir%\Paracraft_64bits.bat" "%dest_dir%\bin64" /C /Y
xcopy "%src_dir%\Aries_64bits.bat" "%dest_dir%\bin64" /C /Y
xcopy "%src_dir%\ParacraftServer_64bits.bat" "%dest_dir%\bin64" /C /Y
xcopy "%bin_dir%\..\redist\ParaCraft.exe" "%dest_dir%" /C /Y
xcopy "%~dp0readme_64bits.txt" "%dest_dir%" /C /Y

call "%bin_dir%\7z.exe" a %~dp0ParaCraft64bits%DATE:~0,4%%DATE:~5,2%%DATE:~8,2%.zip %dest_dir%
