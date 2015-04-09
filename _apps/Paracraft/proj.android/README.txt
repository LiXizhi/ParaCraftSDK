---++ How to Build APK
Author: LiXizhi@yeah.net
Date: 2015.3.23

---+++ Prepare source code
1. Edit AndroidManifest.xml and modify com.ParaEngine.XXXX to your own package identifier.
2. Make your own icons in ./res/drawable-XXX
3. Edit your own app name in ./res/values/strings.xml

---+++ Prepare environment
1. install ParaCraftSDK
2. install Android SDK 
3. run CreateMyReleaseKey.bat(only once to create your certificate for code signing)

---+++ Build APK
1. run ./proj/android/MakeAndroidAPK.bat (default code sign password is paracraft)
2. my_app_android.final.apk will be generated, which is signed and ready for publishing. 


---+++ FAQ
In case of errors, look at the source code of *.bat and make necessary changes. 