# Author: LiXizhi
# Contact: lixizhi@yeah.net
# Date: 2015.4.9

;------------------------------------------------------------------------
; Paracraft 
;------------------------------------------------------------------------
SetCompressor /SOLID lzma
; SetOverwrite 	on|off|try|ifnewer

!include LogicLib.nsh
!include WinVer.nsh
!include "FileFunc.nsh"
;--------------------------------
;Include Modern UI
  !include "MUI2.nsh"

;Request application privileges for Windows Vista
RequestExecutionLevel user

;--------------------------------
;Variables
Var StartMenuFolder
Var ShortCutLinkPath
Var MainShortcutName
!define redist_folder ..\..\redist

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING
  !define MUI_WELCOMEPAGE_TEXT  "This wizard will guide you through the installation of Paracraft. It is recommended that you close all other applications before starting Setup. You may require administrator privileges to install Paracraft successfully."
  ;!define MUI_WELCOMEFINISHPAGE_BITMAP "Texture\Paracraft\brand\installer.bmp"
  !define MUI_HEADERIMAGE
  ;!define MUI_HEADERIMAGE_BITMAP  "Texture\Paracraft\brand\header.bmp"

;--------------------------------
;Language Selection Dialog Settings

  ;Remember the installer language
  !define MUI_LANGDLL_REGISTRY_ROOT "HKCU" 
  !define MUI_LANGDLL_REGISTRY_KEY "Software\ParaEngine\Paracraft" 
  !define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"
  !define MUI_LANGDLL_WINDOWTITLE $(LangSelectWinTitle)
  !define MUI_LANGDLL_INFO $(LangSelectWinInfo)
  
;--------------------------------
;Pages

  !insertmacro MUI_PAGE_WELCOME
  ;!insertmacro MUI_PAGE_LICENSE $(myLicenseData)
  ;!insertmacro MUI_PAGE_COMPONENTS
  ;!insertmacro MUI_PAGE_DIRECTORY
	Page directory dir_pre "" dir_leave
	# set to fixed local app data directory, to be compatible with the web edition. 
	!define INSTDIR "$LOCALAPPDATA\ParaEngine\Redist"
  
  ;Start Menu Folder Page Configuration
  !define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKCU" 
  !define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\ParaEngine\Paracraft" 
  !define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Paracraft"
  
  !insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder
  
  !insertmacro MUI_PAGE_INSTFILES

    !define MUI_FINISHPAGE_AUTOCLOSE
    #!define MUI_FINISHPAGE_NOAUTOCLOSE
	!ifdef CacheFolderPath
		#!define MUI_FINISHPAGE_RUN_NOTCHECKED
		!define MUI_FINISHPAGE_RUN
		!define MUI_FINISHPAGE_RUN_TEXT $(LaunchApp)
		!define MUI_FINISHPAGE_RUN_FUNCTION "LaunchLink"
	!else
		!define MUI_FINISHPAGE_TEXT $(LaunchText)
	!endif
	
	!insertmacro MUI_PAGE_FINISH
  !insertmacro MUI_PAGE_FINISH
  
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
;--------------------------------
;Languages
  !insertmacro MUI_LANGUAGE "SimpChinese" ;first language is the default language
  !insertmacro MUI_LANGUAGE "English" 
    

;--------------------------------
;Reserve Files
  
  ;If you are using solid compression, files that are required before
  ;the actual installation should be stored first in the data block,
  ;because this will make your installer start faster.
  
  !insertmacro MUI_RESERVEFILE_LANGDLL
  
;-----------------------------------------------------------------------------------------------------  
!define PROGRAM_NAME "Paracraft"
!define VERSION "1.0.0.2"
!define PluginVersion "1.0.2.1"
;-------------------------------
; define installer descriptions

LangString LangSelectWinTitle ${LANG_ENGLISH} "Product Language"
LangString LangSelectWinTitle ${LANG_SIMPCHINESE} "产品语言"  
LangString LangSelectWinInfo ${LANG_ENGLISH} "Please select a language."
LangString LangSelectWinInfo ${LANG_SIMPCHINESE} "请选择一个语言" 
LicenseLangString myLicenseData ${LANG_ENGLISH} "../../LICENSE"

LangString Name ${LANG_ENGLISH} "Paracraft"
LangString Name ${LANG_SIMPCHINESE} "Paracraft创意空间"


Name $(Name)
LangString LaunchApp ${LANG_ENGLISH} "Launch $(Name)"
LangString LaunchApp ${LANG_SIMPCHINESE} "运行$(Name)"

LangString LaunchText ${LANG_ENGLISH} "Click the icon on desktop to launch $(Name)"
LangString LaunchText ${LANG_SIMPCHINESE} "点击桌面图标运行$(Name)"
LangString Caption ${LANG_ENGLISH} "Paracraft v1"
LangString Caption ${LANG_SIMPCHINESE} "Paracraft"
LangString StringUnInstallWeb ${LANG_ENGLISH} "Uninstall"
LangString StringUnInstallWeb ${LANG_SIMPCHINESE} "卸载"

LangString DskCText ${LANG_ENGLISH} "The available space in your Disk C is not enough, we recommend you keep 1GB available space on Disk C. You can download $(NAME) client installer package to reinstall again ,or quit this installer and clear your Disk C!" 
LangString DskCText ${LANG_SIMPCHINESE} "您的C盘空间可能不足，本程序建议C盘可用空间大于1GB。建议退出并清理C盘空间, 或者在官网下载客户端安装包，重新安装《$(NAME)》到其他盘。" 
LangString DskText ${LANG_ENGLISH} "The available space in your target disk isnot enough, we recommend you install $(NAME) to other disk. Please select your installing path!" 
LangString DskText ${LANG_SIMPCHINESE} "您的目标安装盘空间可能不足，建议安装《$(NAME)》到其他盘。请选择新的安装路径!" 

LangString FolderNoPermission ${LANG_ENGLISH} "you do not have write permission to the folder you selected, please use the default install directory." 
LangString FolderNoPermission ${LANG_SIMPCHINESE} "您选择的目录没有写权限，请使用默认目录安装！" 


Caption $(Caption) 
!ifndef OutputFileName
	!define OutputFileName  "..\..\__backups\Paracraft${VERSION}.exe"
!endif
OutFile "${OutputFileName}"

BrandingText "http://www.paracraft.cn"
#!define ProgramIcon "Texture\Paracraft\brand\installer.ico"
#Icon ${ProgramIcon}
#UninstallIcon "Texture\Paracraft\brand\uninstaller.ico"

VIProductVersion ${VERSION}
VIAddVersionKey "FileVersion" "${VERSION}"
VIAddVersionKey "ProductName" "${PROGRAM_NAME}"
VIAddVersionKey "FileDescription" "Paracraft SDK"
VIAddVersionKey "LegalCopyright" "Copyright 2007-2015 LiXizhi"
#VIAddVersionKey "CompanyName" "ParaEngine & Tatfook"
#VIAddVersionKey "Comments" ""
#VIAddVersionKey "LegalTrademarks" "ParaEngine and NPL are registered trade marks of ParaEngine Corporation"

Var ShortCutName

# uncomment the following line to make the installer silent by default.
;SilentInstall silent
;-------------------------------
; Test if Disk C free space is more than 1GB, if yes, donot disply directory choose page, if no give user the choice
Function dir_pre
 
 Var /GLOBAL  NeedSpace
 ;Var /GLOBAL  DskCEnough

 StrCpy $NeedSpace "1024" 
 ${DriveSpace} "C:\" "/D=F /S=M" $R0
 IntCmp $R0 $NeedSpace is1024 lessthan1024 morethan1024
	
 is1024:
	Goto diskCIsnotEnough

 lessthan1024:
	Goto diskCIsnotEnough

 morethan1024:
	Goto diskCIsEnough

 diskCIsEnough:
	;StrCpy $DskCEnough "1"
	## enable  following line to show directory page, otherwise it will skip the dir page. 
	goto done
	abort
		
 diskCIsnotEnough:
	;StrCpy $DskCEnough "0"
	;MessageBox MB_YESNO|MB_ICONEXCLAMATION "$(DskCText)" IDYES gogoInst IDNO quitInst
	MessageBox MB_OK|MB_ICONEXCLAMATION "$(DskCText)"
	goto done
	;Quit

 ;gogoInst:	
	;Goto done
		
 ;quitInst:
	;Quit
		
 done:		
Functionend

Function dir_leave
 ${GetRoot} $INSTDIR $R1
 ${DriveSpace} $R1 "/D=F /S=M" $R0
 IntCmp $R0 $NeedSpace is1024 lessthan1024 morethan1024
	
 is1024:
	Goto diskCIsnotEnough

 lessthan1024:
	Goto diskCIsnotEnough

 morethan1024:
	Goto diskCIsEnough
		
 diskCIsnotEnough:				
	MessageBox MB_OK|MB_ICONEXCLAMATION "$(DskText)"
	Abort

 diskCIsEnough:		

	# checking if we have write/delete permission on the folder selected by the user
	ClearErrors
	SetOutPath "$INSTDIR\"
	FileOpen $R0 $INSTDIR\tmp.dat w
	FileClose $R0
	Delete $INSTDIR\tmp.dat
	${If} ${Errors}
		 MessageBox MB_OK|MB_ICONEXCLAMATION "$(FolderNoPermission)"
		 Abort
	${EndIf}
		
Functionend

;--------------------------------
;General

;Default installation folder
InstallDir $PROGRAMFILES\$(Name)
  
;--------------------------------
;Installer Functions

LangString InstallerAlreadyRunning ${LANG_ENGLISH} "The installer is already running."
LangString InstallerAlreadyRunning ${LANG_SIMPCHINESE} "安装程序已经在运行"

Function .onInit
	;----------------------
	;prevent multiple runs
	System::Call 'kernel32::CreateMutexA(i 0, i 0, t "myMutex") i .r1 ?e'
	Pop $R0
	
	StrCmp $R0 0 +3
	 MessageBox MB_OK|MB_ICONEXCLAMATION $(InstallerAlreadyRunning)
	 Abort
	
	;-----------------------
	;Language selection dialog
	;!insertmacro MUI_LANGDLL_DISPLAY

	 ${GetDrives} HDD FindHDD
	
FunctionEnd

Function FindHDD
  ${DriveSpace} $9 "/D=F /S=M" $R0
  ${If} $R0 > $R1
    StrCpy $R1 $R0
    StrCpy $INSTDIR "$9$(Name)"
  ${EndIf}
  Push $0
FunctionEnd

;-----------------------
;prevent installed program already runs
Function CheckRunningClient
	FindProcDLL::FindProc "ParaEngineClient.exe"
	Pop $R0
	StrCmp $R0 "1" running notrun

running:
	MessageBox  MB_ICONSTOP  "Paracraft已在运行,请将其关闭并重新安装!"
	Quit
notrun:	

FunctionEnd

Function LaunchLink
  IfSilent SkipLaunch
	ExecShell "" $ShortCutName
	Quit
SkipLaunch:
FunctionEnd

;--------------------------------
; Installer Sections
section
	
	Call CheckRunningClient

	StrCpy $MainShortcutName  "$(Name)"

	# Installing PC version to $INSTDIR
	# Delete all files in Update to prevent old files disturbing normal files
	RMDir /r "$INSTDIR\Update"
	delete "$INSTDIR\version.txt"
	delete "$INSTDIR\config\gameclient.config.xml"
	delete "$INSTDIR\*.pkg"

	SetOutPath "$INSTDIR"
	File "${redist_folder}\ParaCraft.exe"
	StrCpy $ShortCutLinkPath  "$INSTDIR\ParaCraft.exe"
	
	File "${redist_folder}\ParaCraft.exe"
	File "${redist_folder}\paraengineclient.exe"
	File "${redist_folder}\paraengineclient.dll"
	File "${redist_folder}\d3dx9_43.dll"
	File "${redist_folder}\freeimage.dll"
	File "${redist_folder}\libcurl.dll"
	File "${redist_folder}\lua.dll"
	File "${redist_folder}\f_in_box.dll"
	File "${redist_folder}\openal32.dll"
	File "${redist_folder}\caudioengine.dll"
	File "${redist_folder}\physicsbt.dll"
	File "${redist_folder}\sqlite.dll"
	File "${redist_folder}\wrap_oal.dll"

	File "${redist_folder}\paraengine.sig"
	File "${redist_folder}\version.txt"
	File "${redist_folder}\assets_manifest.txt"
	File "..\..\LICENSE"

	File /x main_full.pkg "${redist_folder}\*.pkg" 
	
	# movie codec plugin
	File "${redist_folder}\av*.dll"
	File "${redist_folder}\sw*.dll"
	File "${redist_folder}\MovieCodec*.*"

	SetOutPath "$INSTDIR\database"
	File "${redist_folder}\database\characters.db"
	File "${redist_folder}\database\*.mem"

	SetOutPath "$INSTDIR\config"
	File "${redist_folder}\config\gameclient.config.xml"
	File "${redist_folder}\config\config.txt"
	File "${redist_folder}\config\commands.xml"
	File "${redist_folder}\config\bootstrapper.xml"

	# define uninstaller name
	writeUninstaller "$INSTDIR\uninstaller.exe"
	
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Paracraft" \
                 "DisplayName" "Paracraft"
	WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Paracraft" \
				"DisplayVersion" "${VERSION}"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Paracraft" \
				"Publisher" "ParaEngine Corporation"
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Paracraft" \
				"URLInfoAbout" "http://www.paracraft.cn"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Paracraft" \
                 "UninstallString" '"$INSTDIR\uninstaller.exe"'
	
	# create a shortcuts in the start menu programs directory
    # SetShellVarContext all

	!insertmacro MUI_STARTMENU_WRITE_BEGIN Application
	
	CreateDirectory "$SMPROGRAMS\$StartMenuFolder"

	#-----------------------------
	# we will create different shortcut for third parties according to commandline
	#-----------------------------
	# programe file shortcut
	SetOutPath "$INSTDIR"
	CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$MainShortcutName.lnk" "$ShortCutLinkPath" ""
		
	# uninstaller shortcut
	CreateShortCut "$SMPROGRAMS\$StartMenuFolder\$(StringUnInstallWeb).lnk" "$INSTDIR\uninstaller.exe"

	#Create desktop icon.
	SetOutPath "$INSTDIR"
	CreateShortCut "$DESKTOP\$MainShortcutName.lnk" "$ShortCutLinkPath" ""
	StrCpy $ShortCutName "$DESKTOP\$MainShortcutName.lnk"
			
	!insertmacro MUI_STARTMENU_WRITE_END

# default section end
sectionEnd
 

# create a section to define what the uninstaller does.
# the section will always be named "Uninstall"
section "Uninstall"
	
	# remove start menu but not the folder, because there may be other files in it. 
	!insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder
	delete "$SMPROGRAMS\$StartMenuFolder\$(MainShortcutName).lnk"
	
sectionEnd

;--------------------------------
;Uninstaller Functions

Function un.onInit
	;-----------------------
	;prevent installed program already runs
	FindProcDLL::FindProc "ParaEngineClient.exe"
	Pop $R0
	StrCmp $R0 "1" running notrun
running:
	MessageBox  MB_ICONSTOP  "Paracraft正在运行,请先退出，再执行卸载!"
	Quit

notrun:	

  !insertmacro MUI_UNGETLANGUAGE
FunctionEnd