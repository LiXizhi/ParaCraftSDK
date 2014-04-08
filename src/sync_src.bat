echo off

set default_sdk_path=D:\lxzsrc\ParaEngine\ParaWorld
set /p SDK_PATH=请输入SDK路径.Enter键默认到%default_sdk_path%

if %SDK_PATH% eq "" (
	set SDK_PATH=%default_sdk_path%
)

xcopy %SDK_PATH%/src/*.*  .