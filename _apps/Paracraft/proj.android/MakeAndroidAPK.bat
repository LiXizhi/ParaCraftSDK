REM Author: lixizhi@yeah.net  Date:2015.3.22
REM modify android_sdk_dir to match your installation
Set android_sdk_dir=%ANDROID_SDK_ROOT%
Set android_buildtool_dir=%android_sdk_dir%\build-tools\android-4.4.2\
@Set android_tool_dir=%android_sdk_dir%\tools\
@set PC_SDK_ROOT=%~dp0..\..\..\
@Set bin_dir=%PC_SDK_ROOT%bin\
@Set apk_file_name=my_app_android.apk
@Set apk_final_filename=my_app_android.final.apk

@call SyncFiles.bat

del %apk_file_name%
del %apk_final_filename%
call %android_buildtool_dir%aapt package -S res -A assets -M AndroidManifest.xml  -I %android_sdk_dir%\platforms\android-19\android.jar -F %apk_file_name%
call %android_buildtool_dir%aapt add %apk_file_name% classes.dex
call %android_buildtool_dir%aapt add %apk_file_name% lib/armeabi/libparaenginemobile.so
@rem call %android_buildtool_dir%aapt add %apk_file_name% lib/armeabi/gdbserver

@rem sign your app with your private key. IMPORTANT ! replace the password with the one you used when you create the keystore file
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore my-release-key.keystore -storepass paracraft %apk_file_name% paracraft

REM Verify that your APK is signed. For example:
jarsigner -verify -verbose -certs %apk_file_name%

REM Align the final APK package using zipalign.
%android_tool_dir%zipalign -v 4 %apk_file_name% %apk_final_filename%