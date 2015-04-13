@REM Author: lixizhi@yeah.net  Date:2015.4.13
@REM sync script from main repository. 
@Set paraengine_dir=D:\lxzsrc\ParaEngine\ParaWorld
@Set paraenginemobile_dir=D:\lxzsrc\ParaEngineGit
@Set main_loop_filename=%paraengine_dir%\script\apps\Taurus\main_loop.lua

@if exist "%main_loop_filename%" (
	xcopy "%paraengine_dir%\script\apps\Taurus" script\apps\Taurus /Y /E /R
)
