@echo off 
if not exist "src" ( mkdir src )

pushd "src"

CALL :InstallPackage NPLRuntime
popd

EXIT /B %ERRORLEVEL%

rem install function here
:InstallPackage
if exist "%1\README.md" (
    pushd %1
    git reset --hard
	git pull
    popd
) else (
    rmdir /s /q "%CD%\%1"
    git clone https://github.com/LiXizhi/%1
)
EXIT /B 0