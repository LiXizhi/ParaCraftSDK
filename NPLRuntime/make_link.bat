pushd %~dp0
echo after running install.bat, one can run make_link.bat to create permanent link
del /Q win\bin\paraengineclient.*
del /Q win\packages\*.pkg
mklink win\bin\paraengineclient.dll D:\lxzsrc\ParaEngine\ParaWorld\paraengineclient.dll
mklink win\bin\paraengineclient.exe D:\lxzsrc\ParaEngine\ParaWorld\paraengineclient.exe
mklink win\packages\main.pkg D:\lxzsrc\ParaEngine\ParaWorld\installer\main_full_mobile.pkg
popd
pause