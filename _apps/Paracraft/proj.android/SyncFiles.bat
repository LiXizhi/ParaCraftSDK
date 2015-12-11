@REM Author: lixizhi@yeah.net  Date:2015.3.22
@REM this is where to find the *.so and *.pkg etc files
@Set paraengine_dir=D:\lxzsrc\ParaEngine\ParaWorld\
@Set paraenginemobile_dir=D:\lxzsrc\ParaEngineGit\
@Set paraengine_so_filename=%paraenginemobile_dir%Mobile\trunk\ParaCraftMobile\frameworks\runtime-src\proj.android\libs\armeabi\libparaenginemobile.so
@Set main_full_filename=%paraengine_dir%installer\main_full_mobile.pkg

@rem no asset file for mobile version
rem xcopy %~dp0..\..\..\redist\assets_manifest.txt  assets\res\ /Y

xcopy %~dp0..\source  assets\res\source\ /Y /E

xcopy D:\HudsonLocal\jobs\make_paracraft_android_apk\workspace\paracraft_android_res  assets\res\ /Y /E

@if exist "%paraengine_so_filename%" (xcopy %paraengine_so_filename% lib\armeabi\ /Y)
@if exist "%main_full_filename%" (copy %main_full_filename% assets\res\main.pkg /Y)
