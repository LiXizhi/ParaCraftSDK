--[[
Title: Event mapping in ParaEngine. such as virtual keys 
Author(s): 
Date: 2006/12/1
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/event_mapping.lua");
Event_Mapping.EM_KEY_C -- it stands for both lower case and upper case when in key event handler
Event_Mapping.EM_KEY_F1
-------------------------------------------------------
]]
local i=0;
local function AutoEnum()
	i=i+1;
	return i;
end
local function LastEnum(index)
	if(index~=nil) then
		i=index;
	end
	return i;
end
-- direct input scan code, used in 
--		ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LCONTROL)
DIK_SCANCODE = {
 DIK_ESCAPE          =1,
 DIK_1               =2,
 DIK_2               =3,
 DIK_3               =4,
 DIK_4               =5,
 DIK_5               =6,
 DIK_6               =7,
 DIK_7               =8,
 DIK_8               =9,
 DIK_9               =10,
 DIK_0               =11,
 DIK_MINUS           =12,--    /* - on main keyboard */
 DIK_EQUALS          =13,
 DIK_BACK            =14,--    /* backspace */
 DIK_TAB             =15,
 DIK_Q               =16,
 DIK_W               =17,
 DIK_E               =18,
 DIK_R               =19,
 DIK_T               =20,
 DIK_Y               =21,
 DIK_U               =22,
 DIK_I               =23,
 DIK_O               =24,
 DIK_P               =25,
 DIK_LBRACKET        =26,
 DIK_RBRACKET        =27,
 DIK_RETURN          =28,--   /* Enter on main keyboard */
 DIK_LCONTROL        =29,
 DIK_A               =30,
 DIK_S               =31,
 DIK_D               =32,
 DIK_F               =33,
 DIK_G               =34,
 DIK_H               =35,
 DIK_J               =36,
 DIK_K               =37,
 DIK_L               =38,
 DIK_SEMICOLON       =39,
 DIK_APOSTROPHE      =40,
 DIK_GRAVE           =41, --   /* accent grave */
 DIK_LSHIFT          =42,
 DIK_BACKSLASH       =43,
 DIK_Z               =44,
 DIK_X               =45,
 DIK_C               =46,
 DIK_V               =47,
 DIK_B               =48,
 DIK_N               =49,
 DIK_M               =50,
 DIK_COMMA           =51,
 DIK_PERIOD          =52,   -- /* . on main keyboard */
 DIK_SLASH           =53,  -- /* / on main keyboard */
 DIK_RSHIFT          =54,
 DIK_MULTIPLY        =55,   -- /* * on numeric keypad */
 DIK_LMENU           =56,  -- /* left Alt */
 DIK_SPACE           =57,
 DIK_CAPITAL         =58,
 DIK_F1              =59,
 DIK_F2              =60,
 DIK_F3              =61,
 DIK_F4              =62,
 DIK_F5              =63,
 DIK_F6              =64,
 DIK_F7              =65,
 DIK_F8              =66,
 DIK_F9              =67,
 DIK_F10             =68,
 DIK_NUMLOCK         =69,
 DIK_SCROLL          =70,   -- /* Scroll Lock */
 DIK_NUMPAD7         =71,
 DIK_NUMPAD8         =72,
 DIK_NUMPAD9         =73,
 DIK_SUBTRACT        =74,   -- /* - on numeric keypad */
 DIK_NUMPAD4         =75,
 DIK_NUMPAD5         =76,
 DIK_NUMPAD6         =77,
 DIK_ADD             =78,   -- /* + on numeric keypad */
 DIK_NUMPAD1         =79,
 DIK_NUMPAD2         =80,
 DIK_NUMPAD3         =81,
 DIK_NUMPAD0         =82,
 DIK_DECIMAL         =83,   -- /* . on numeric keypad */
 DIK_OEM_102         =86,  -- /* <> or \| on RT 102-key keyboard (Non-U.S.) */
 DIK_F11             =87,
 DIK_F12             =88,
 DIK_F13             =100,   -- /*                     (NEC PC98) */
 DIK_F14             =101,  -- /*                     (NEC PC98) */
 DIK_F15             =102, -- /*                     (NEC PC98) */
 DIK_KANA            =112,-- /* (Japanese keyboard)            */
 DIK_ABNT_C1         =115,-- /* /? on Brazilian keyboard */
 DIK_CONVERT         =121,-- /* (Japanese keyboard)            */
 DIK_NOCONVERT       =123,-- /* (Japanese keyboard)            */
 DIK_YEN             =125,    -- /* (Japanese keyboard)            */
 DIK_ABNT_C2         =126,    -- /* Numpad . on Brazilian keyboard */
 DIK_NUMPADEQUALS    =141,    -- /* =tonumber(" on numeric keypad (NEC PC98) */
 DIK_PREVTRACK       =144,    -- /* Previous Track (DIK_CIRCUMFLEX on Japanese keyboard) */
 DIK_AT              =145,    -- /*                     (NEC PC98) */
 DIK_COLON           =146,    -- /*                     (NEC PC98) */
 DIK_UNDERLINE       =147,    -- /*                     (NEC PC98) */
 DIK_KANJI           =148,    -- /* (Japanese keyboard)            */
 DIK_STOP            =149,    -- /*                     (NEC PC98) */
 DIK_AX              =150,    -- /*                     (Japan AX) */
 DIK_UNLABELED       =151,    -- /*                        (J3100) */
 DIK_NEXTTRACK       =153,    -- /* Next Track */
 DIK_NUMPADENTER     =156,    -- /* Enter on numeric keypad */
 DIK_RCONTROL        =157,
 DIK_MUTE            =160,    -- /* Mute */
 DIK_CALCULATOR      =161,    -- /* Calculator */
 DIK_PLAYPAUSE       =162,    -- /* Play / Pause */
 DIK_MEDIASTOP       =164,    -- /* Media Stop */
 DIK_VOLUMEDOWN      =174,    -- /* Volume - */
 DIK_VOLUMEUP        =176,    -- /* Volume + */
 DIK_WEBHOME         =178,    -- /* Web home */
 DIK_NUMPADCOMMA     =179,    -- /* ",16), on numeric keypad (NEC PC98) */
 DIK_DIVIDE          =181,    -- /* / on numeric keypad */
 DIK_SYSRQ           =183,
 DIK_RMENU           =184,    -- /* right Alt */
 DIK_PAUSE           =197,    -- /* Pause */
 DIK_HOME            =199,    -- /* Home on arrow keypad */
 DIK_UP              =200,    -- /* UpArrow on arrow keypad */
 DIK_PRIOR           =201,    -- /* PgUp on arrow keypad */
 DIK_LEFT            =203,    -- /* LeftArrow on arrow keypad */
 DIK_RIGHT           =205,    -- /* RightArrow on arrow keypad */
 DIK_END             =207,    -- /* End on arrow keypad */
 DIK_DOWN            =208,    -- /* DownArrow on arrow keypad */
 DIK_NEXT            =209,    -- /* PgDn on arrow keypad */
 DIK_INSERT          =210,    -- /* Insert on arrow keypad */
 DIK_DELETE          =211,    -- /* Delete on arrow keypad */
 DIK_LWIN            =219,    -- /* Left Windows key */
 DIK_RWIN            =220,    -- /* Right Windows key */
 DIK_APPS            =221,    -- /* AppMenu key */
 DIK_POWER           =222,    -- /* System Power */
 DIK_SLEEP           =223,    -- /* System Sleep */
 DIK_WAKE            =227,    -- /* System Wake */
 DIK_WEBSEARCH       =229,    -- /* Web Search */
 DIK_WEBFAVORITES    =230,    -- /* Web Favorites */
 DIK_WEBREFRESH      =231,    -- /* Web Refresh */
 DIK_WEBSTOP         =232,    -- /* Web Stop */
 DIK_WEBFORWARD      =233,    -- /* Web Forward */
 DIK_WEBBACK         =234,    -- /* Web Back */
 DIK_MYCOMPUTER      =235,    -- /* My Computer */
 DIK_MAIL            =236,    -- /* Mail */
 DIK_MEDIASELECT     =237,    -- /* Media Select */
}

-- virtual key event mapping
Event_Mapping = {
	EM_NONE = LastEnum(),
	--player control
	EM_PL_FORWARD=AutoEnum(),
	EM_PL_BACKWARD=AutoEnum(),
	EM_PL_LEFT=AutoEnum(),
	EM_PL_RIGHT=AutoEnum(),
	EM_PL_SHIFTLEFT=AutoEnum(),
	EM_PL_SHIFTRIGHT=AutoEnum(),
	EM_PL_JUMP=AutoEnum(),
	EM_PL_CROUCH=AutoEnum(),
	EM_PL_TOGGLE_ALWAYS_RUN=AutoEnum(),
	EM_PL_TOGGLE_RUN_WALK=AutoEnum(),
	EM_PL_MOUNT_ON=AutoEnum(),
	EM_PL_ACTION1=AutoEnum(),
	EM_PL_ACTION2=AutoEnum(),
	EM_PL_ACTION3=AutoEnum(),
	EM_PL_ACTION4=AutoEnum(),
	--game control
	EM_GM_PAUSE=AutoEnum(),
	EM_GM_NEXTANIM=AutoEnum(),
	EM_GM_PRIORANIM=AutoEnum(),
	EM_GM_NEXTOBJ=AutoEnum(),

	--camera control
	EM_CAM_LOCK=AutoEnum(),
	EM_CAM_RESET=AutoEnum(),
	EM_CAM_MODE_FOLLOW=AutoEnum(),
	EM_CAM_MODE_FREE=AutoEnum(),
	EM_CAM_FOCUS_POS_UP=AutoEnum(),
	EM_CAM_FOCUS_POS_DOWN=AutoEnum(),
	EM_CAM_FORWARD=AutoEnum(),
	EM_CAM_BACKWARD=AutoEnum(),
	EM_CAM_LEFT=AutoEnum(),
	EM_CAM_RIGHT=AutoEnum(),
	EM_CAM_SHIFTLEFT=AutoEnum(),
	EM_CAM_SHIFTRIGHT=AutoEnum(),
	EM_CAM_LEFTDOWN=AutoEnum(),
	EM_CAM_LEFTUP=AutoEnum(),
	EM_CAM_RIGHTDOWN=AutoEnum(),
	EM_CAM_RIGHTUP=AutoEnum(),
	EM_CAM_ZOOM=AutoEnum(), -- mouse wheel 
	EM_CAM_ZOOM_IN=AutoEnum(),
	EM_CAM_ZOOM_OUT=AutoEnum(),

	--GUI control events
	EM_CTRL_CHANGE=AutoEnum(),
	EM_CTRL_MODIFY=AutoEnum(),
	EM_CTRL_CHAR=AutoEnum(),
	EM_CTRL_KEYDOWN=AutoEnum(),
	EM_CTRL_KEYUP=AutoEnum(),
	EM_CTRL_HOLDKEY=AutoEnum(),
	EM_CTRL_SELECT=AutoEnum(),
	EM_CTRL_FOCUSIN=AutoEnum(),
	EM_CTRL_FOCUSOUT=AutoEnum(),
	EM_CTRL_FRAMEMOVE=AutoEnum(),
	EM_CTRL_UPDATEKEY=AutoEnum(),
	EM_CTRL_CAPTUREMOUSE=AutoEnum(),
	EM_CTRL_RELEASEMOUSE=AutoEnum(),
	EM_CTRL_NEXTKEYFOCUS=AutoEnum(),

	--GUI button events
	EM_BTN_DOWN=AutoEnum(),
	EM_BTN_UP=AutoEnum(),
	EM_BTN_CLICK=AutoEnum(),

	--GUI scrollbar events
	EM_SB_ACTIONEND=AutoEnum(),
	EM_SB_ACTIONBEGIN=AutoEnum(),
	EM_SB_PAGEDOWN=AutoEnum(),
	EM_SB_PAGEUP=AutoEnum(),
	EM_SB_STEPDOWN=AutoEnum(),
	EM_SB_STEPUP=AutoEnum(),
	EM_SB_SCROLL=AutoEnum(),

	--GUI EditBox Events
	EM_EB_SELECTSTART=AutoEnum(),
	EM_EB_SELECTEND=AutoEnum(),
	EM_EB_SELECTALL=AutoEnum(),

	--GUI IMEEditBox events
	EM_IME_SELECT=AutoEnum(),

	--GUI ListBox events
	EM_LB_ACTIONEND=AutoEnum(),
	EM_LB_ACTIONBEGIN=AutoEnum(),

	--GUI Slider events
	EM_SL_ACTIONBEGIN=AutoEnum(),
	EM_SL_ACTIONEND=AutoEnum(),
	EM_SL_CHANGEVALUE=AutoEnum(),

	--GUI Canvas events
	EM_CV_ROTATEBEGIN=AutoEnum(),
	EM_CV_ROTATEEND=AutoEnum(),
	EM_CV_PANBEGIN=AutoEnum(),
	EM_CV_PANEND=AutoEnum(),

	--virtual keys
	EM_KEY_BACKSPACE=AutoEnum(),
	EM_KEY_TAB=AutoEnum(),
	EM_KEY_RETURN=AutoEnum(),
	EM_KEY_SHIFT=AutoEnum(),
	EM_KEY_CONTROL=AutoEnum(),
	EM_KEY_ALT=AutoEnum(),
	EM_KEY_PAUSE=AutoEnum(),
	EM_KEY_CAPSLOCK=AutoEnum(),
	EM_KEY_ESCAPE=AutoEnum(),
	EM_KEY_SPACE=AutoEnum(),
	EM_KEY_PAGE_DOWN=AutoEnum(),
	EM_KEY_PAGE_UP=AutoEnum(),
	EM_KEY_END=AutoEnum(),
	EM_KEY_HOME=AutoEnum(),
	EM_KEY_LEFT=AutoEnum(),
	EM_KEY_UP=AutoEnum(),
	EM_KEY_RIGHT=AutoEnum(),
	EM_KEY_DOWN=AutoEnum(),
	EM_KEY_PRINT=AutoEnum(),
	EM_KEY_INSERT=AutoEnum(),
	EM_KEY_DELETE=AutoEnum(),
	EM_KEY_HELP=AutoEnum(),
	EM_KEY_WIN_WINDOW=AutoEnum(),
	EM_KEY_WIN_LWINDOW=AutoEnum(),
	EM_KEY_WIN_RWINDOW=AutoEnum(),
	EM_KEY_WIN_APPS=AutoEnum(),
	EM_KEY_NUMPAD0=AutoEnum(),
	EM_KEY_UPNUMPAD0=AutoEnum(),--insert
	EM_KEY_NUMPAD1=AutoEnum(),
	EM_KEY_UPNUMPAD1=AutoEnum(),--end
	EM_KEY_NUMPAD2=AutoEnum(),
	EM_KEY_UPNUMPAD2=AutoEnum(),--down
	EM_KEY_NUMPAD3=AutoEnum(),
	EM_KEY_UPNUMPAD3=AutoEnum(),--page down
	EM_KEY_NUMPAD4=AutoEnum(),
	EM_KEY_UPNUMPAD4=AutoEnum(),--left
	EM_KEY_NUMPAD5=AutoEnum(),
	EM_KEY_UPNUMPAD5=AutoEnum(),--nothing
	EM_KEY_NUMPAD6=AutoEnum(),
	EM_KEY_UPNUMPAD6=AutoEnum(),--right
	EM_KEY_NUMPAD7=AutoEnum(),
	EM_KEY_UPNUMPAD7=AutoEnum(),--home
	EM_KEY_NUMPAD8=AutoEnum(),
	EM_KEY_UPNUMPAD8=AutoEnum(),--up
	EM_KEY_NUMPAD9=AutoEnum(),
	EM_KEY_UPNUMPAD9=AutoEnum(),--page up
	EM_KEY_MULTIPLY=AutoEnum(),
	EM_KEY_ADD=AutoEnum(),
	EM_KEY_SEPARATOR=AutoEnum(),
	EM_KEY_SUBTRACT=AutoEnum(),
	EM_KEY_DECIMAL=AutoEnum(),
	EM_KEY_UPDECIMAL=AutoEnum(),--delete
	EM_KEY_DIVIDE=AutoEnum(),
	EM_KEY_NUMPADENTER=AutoEnum(),
	EM_KEY_NUMPADEQUALS=AutoEnum(),
	EM_KEY_F1=AutoEnum(),
	EM_KEY_F2=AutoEnum(),
	EM_KEY_F3=AutoEnum(),
	EM_KEY_F4=AutoEnum(),
	EM_KEY_F5=AutoEnum(),
	EM_KEY_F6=AutoEnum(),
	EM_KEY_F7=AutoEnum(),
	EM_KEY_F8=AutoEnum(),
	EM_KEY_F9=AutoEnum(),
	EM_KEY_F10=AutoEnum(),
	EM_KEY_F11=AutoEnum(),
	EM_KEY_F12=AutoEnum(),
	EM_KEY_F13=AutoEnum(),
	EM_KEY_F14=AutoEnum(),
	EM_KEY_F15=AutoEnum(),
	EM_KEY_NUMLOCK=AutoEnum(),
	EM_KEY_SCROLLLOCK=AutoEnum(),
	EM_KEY_LSHIFT=AutoEnum(),
	EM_KEY_RSHIFT=AutoEnum(),
	EM_KEY_LCONTROL=AutoEnum(),
	EM_KEY_RCONTROL=AutoEnum(),
	EM_KEY_LALT=AutoEnum(),
	EM_KEY_RALT=AutoEnum(),
	EM_KEY_TILDE=AutoEnum(),--'`'
	EM_KEY_UPTILDE=AutoEnum(),--'~'
	EM_KEY_MINUS=AutoEnum(),--'-'
	EM_KEY_UPMINUS=AutoEnum(),--'_'
	EM_KEY_EQUALS=AutoEnum(),--'='
	EM_KEY_UPEQUALS=AutoEnum(),--'+'
	EM_KEY_LBRACKET=AutoEnum(),--'['
	EM_KEY_UPLBRACKET=AutoEnum(),--'{'
	EM_KEY_RBRACKET=AutoEnum(),--']'
	EM_KEY_UPRBRACKET=AutoEnum(),--'}'
	EM_KEY_BACKSLASH=AutoEnum(),--'\'
	EM_KEY_UPBACKSLASH=AutoEnum(),--'|'
	EM_KEY_SEMICOLON=AutoEnum(),--';'
	EM_KEY_UPSEMICOLON=AutoEnum(),--':'
	EM_KEY_APOSTROPHE=AutoEnum(),--'''
	EM_KEY_UPAPOSTROPHE=AutoEnum(),--'"'
	EM_KEY_GRAVE=AutoEnum(),
	EM_KEY_UPGRAVE=AutoEnum(),
	EM_KEY_COMMA=AutoEnum(),--'=AutoEnum(),'
	EM_KEY_UPCOMMA=AutoEnum(),--'<'
	EM_KEY_PERIOD=AutoEnum(),--'.'
	EM_KEY_UPPERIOD=AutoEnum(),--'>'
	EM_KEY_SLASH=AutoEnum(),--'/'
	EM_KEY_UPSLASH=AutoEnum(),--'?'
	EM_KEY_0=AutoEnum(),
	EM_KEY_UP0=AutoEnum(),--')'
	EM_KEY_1=AutoEnum(),
	EM_KEY_UP1=AutoEnum(),--'!'
	EM_KEY_2=AutoEnum(),
	EM_KEY_UP2=AutoEnum(),--'@'
	EM_KEY_3=AutoEnum(),
	EM_KEY_UP3=AutoEnum(),--'#'
	EM_KEY_4=AutoEnum(),
	EM_KEY_UP4=AutoEnum(),--'$'
	EM_KEY_5=AutoEnum(),
	EM_KEY_UP5=AutoEnum(),--'%'
	EM_KEY_6=AutoEnum(),
	EM_KEY_UP6=AutoEnum(),--'^'
	EM_KEY_7=AutoEnum(),
	EM_KEY_UP7=AutoEnum(),--'&'
	EM_KEY_8=AutoEnum(),
	EM_KEY_UP8=AutoEnum(),--'*'
	EM_KEY_9=AutoEnum(),
	EM_KEY_UP9=AutoEnum(),--'('
	EM_KEY_Z=AutoEnum(),
	EM_KEY_UPZ=AutoEnum(),
	EM_KEY_Y=AutoEnum(),
	EM_KEY_UPY=AutoEnum(),
	EM_KEY_X=AutoEnum(),
	EM_KEY_UPX=AutoEnum(),
	EM_KEY_W=AutoEnum(),
	EM_KEY_UPW=AutoEnum(),
	EM_KEY_V=AutoEnum(),
	EM_KEY_UPV=AutoEnum(),
	EM_KEY_U=AutoEnum(),
	EM_KEY_UPU=AutoEnum(),
	EM_KEY_T=AutoEnum(),
	EM_KEY_UPT=AutoEnum(),
	EM_KEY_S=AutoEnum(),
	EM_KEY_UPS=AutoEnum(),
	EM_KEY_R=AutoEnum(),
	EM_KEY_UPR=AutoEnum(),
	EM_KEY_Q=AutoEnum(),
	EM_KEY_UPQ=AutoEnum(),
	EM_KEY_P=AutoEnum(),
	EM_KEY_UPP=AutoEnum(),
	EM_KEY_O=AutoEnum(),
	EM_KEY_UPO=AutoEnum(),
	EM_KEY_N=AutoEnum(),
	EM_KEY_UPN=AutoEnum(),
	EM_KEY_M=AutoEnum(),
	EM_KEY_UPM=AutoEnum(),
	EM_KEY_L=AutoEnum(),
	EM_KEY_UPL=AutoEnum(),
	EM_KEY_K=AutoEnum(),
	EM_KEY_UPK=AutoEnum(),
	EM_KEY_J=AutoEnum(),
	EM_KEY_UPJ=AutoEnum(),
	EM_KEY_I=AutoEnum(),
	EM_KEY_UPI=AutoEnum(),
	EM_KEY_H=AutoEnum(),
	EM_KEY_UPH=AutoEnum(),
	EM_KEY_G=AutoEnum(),
	EM_KEY_UPG=AutoEnum(),
	EM_KEY_F=AutoEnum(),
	EM_KEY_UPF=AutoEnum(),
	EM_KEY_E=AutoEnum(),
	EM_KEY_UPE=AutoEnum(),
	EM_KEY_D=AutoEnum(),
	EM_KEY_UPD=AutoEnum(),
	EM_KEY_C=AutoEnum(),
	EM_KEY_UPC=AutoEnum(),
	EM_KEY_B=AutoEnum(),
	EM_KEY_UPB=AutoEnum(),
	EM_KEY_A=AutoEnum(),
	EM_KEY_UPA=AutoEnum(),
	EM_KEY=AutoEnum(),--any key
	--virtual mouse 
	EM_MOUSE_LEFTDOWN=AutoEnum(),
	EM_MOUSE_LEFTUP=AutoEnum(),
	EM_MOUSE_LEFTCLICK=AutoEnum(),
	EM_MOUSE_LEFTDBCLICK=AutoEnum(),
	EM_MOUSE_RIGHTDOWN=AutoEnum(),
	EM_MOUSE_RIGHTUP=AutoEnum(),
	EM_MOUSE_RIGHTCLICK=AutoEnum(),
	EM_MOUSE_RIGHTDBCLICK=AutoEnum(),
	EM_MOUSE_MIDDLEDOWN=AutoEnum(),
	EM_MOUSE_MIDDLEUP=AutoEnum(),
	EM_MOUSE_MIDDLECLICK=AutoEnum(),
	EM_MOUSE_MIDDLEDBCLICK=AutoEnum(),
	EM_MOUSE_LEFTDRAGBEGIN=AutoEnum(),
	EM_MOUSE_LEFTDRAGEND=AutoEnum(),
	EM_MOUSE_RIGHTDRAGBEGIN=AutoEnum(),
	EM_MOUSE_RIGHTDRAGEND=AutoEnum(),
	EM_MOUSE_MIDDLEDRAGBEGIN=AutoEnum(),
	EM_MOUSE_MIDDLEDRAGEND=AutoEnum(),
	EM_MOUSE_DRAGBEGIN=AutoEnum(),
	EM_MOUSE_DRAGOVER=AutoEnum(),
	EM_MOUSE_DRAGEND=AutoEnum(),
	EM_MOUSE_MOVE=AutoEnum(),
	EM_MOUSE_HOVER=AutoEnum(),
	EM_MOUSE_WHEEL=AutoEnum(),
	EM_MOUSE_ENTER=AutoEnum(),
	EM_MOUSE_LEAVE=AutoEnum(),
	EM_MOUSE_DOWN=AutoEnum(),
	EM_MOUSE_UP=AutoEnum(),
	EM_MOUSE_CLICK=AutoEnum(),
	EM_MOUSE_DBCLICK=AutoEnum(),
	EM_MOUSE_LEFT=AutoEnum(),
	EM_MOUSE_RIGHT=AutoEnum(),
	EM_MOUSE_MIDDLE=AutoEnum(),
	EM_MOUSE=AutoEnum(),
	EM_UNKNOWN,
};


--[[ParaEngine reserved technique handle:
e.g. MyParaObject:GetAttributeObject:SetField("render_tech", render_tech.TECH_SIMPLE_MESH_NORMAL_UNLIT);
]]
render_tech = {
	-- the object is not renderable, thus having no technique. (CBaseObject)
	TECH_NONE = LastEnum(0),
	-- the object is rendered for occlusion testing. Z-write is disabled and pixel shader is simplified.
	TECH_OCCLUSION_TEST = AutoEnum(),
	-- vertex declaration is POSITION | TEXCord1, these are usually for static meshes. (CMeshObject)
	TECH_SIMPLE_MESH = AutoEnum(),
	-- vertex declaration is POSITION | NORMAL | TEXCord1, these are usually for static meshes. For (CMeshObject) whose asset ParaX file contains the normal data.
	TECH_SIMPLE_MESH_NORMAL = AutoEnum(),
	-- it shares the same shader with TECH_SIMPLE_MESH_NORMAL
	TECH_SIMPLE_MESH_NORMAL_VEGETATION = AutoEnum(),
	--  same as TECH_SIMPLE_MESH_NORMAL, except that instancing is used. 
	TECH_SIMPLE_MESH_NORMAL_INSTANCED = AutoEnum(),
	-- this is the same as TECH_SIMPLE_MESH_NORMAL except that it receive shadows and can not be reflective. 
	TECH_SIMPLE_MESH_NORMAL_SHADOW = AutoEnum(),
	-- this is similar to TECH_SIMPLE_MESH_NORMAL 
	TECH_SIMPLE_MESH_NORMAL_TRANSPARENT = AutoEnum(),
	-- vertex declaration is POSITION | NORMAL | TEXCord1, these are usually for static meshes.It displays an animation in shader when the mesh is being constructed.
	TECH_SIMPLE_MESH_NORMAL_CTOR = AutoEnum(),
	-- vertex declaration is POSITION | NORMAL | TEXCord1, without any lighting computation.
	TECH_SIMPLE_MESH_NORMAL_UNLIT = AutoEnum(),
	-- vertex declaration is POSITION | NORMAL | TEXCord1, these are usually for selected meshes. 
	TECH_SIMPLE_MESH_NORMAL_SELECTED = AutoEnum(),
	-- vertex declaration is POSITION | NORMAL | TEXCord1 | TEXCord2, these are usually for  meshes with a second UV set.
	TECH_SIMPLE_MESH_NORMAL_TEX2 = AutoEnum(),
	-- vertex declaration is POSITION | NORMAL | TEXCord1| TEXCord2 , usually for animated character model. (CBipedObject, CMissileObject)
	TECH_CHARACTER = AutoEnum(),
	-- vertex declaration is POSITION | NORMAL | TEXCord1 | Color1, usually for animated particle model.
	TECH_PARTICLES = AutoEnum(),
	-- vertex declaration is POSITION | NORMAL | TEXCord1 | Color1, usually for animated particle model.
	TECH_WATER_RIPPLE = AutoEnum(),
	--  vertex declaration is POSITION | TEXCord1|COLOR, for sprite object. (CSpriteObject)
	TECH_SPRITE = AutoEnum(),
	-- vertex declaration is POSITION | TEXCord1, for sky mesh object. (CSkyObject)
	TECH_SKY_MESH = AutoEnum(),
	-- vertex declaration is POSITION | TEXCord1 | TEXCord2, usually used for terrain surface drawing.
	TECH_TERRAIN = AutoEnum(),
	--  default ocean with shaders
	TECH_OCEAN = AutoEnum(),
	--  requires just vertex shader 1.1 and no pixel shader
	TECH_OCEAN_FFT = AutoEnum(),
	--  under water effect: currently there is only a fixed function pipeline version
	TECH_OCEAN_UNDERWATER = AutoEnum(),
	--  full screen glow effect shader.
	TECH_FULL_SCREEN_GLOW = AutoEnum(),
	--  full screen shadow map blur effect shader.
	TECH_SHADOWMAP_BLUR = AutoEnum(),
	--  GUI rendering
	TECH_GUI = AutoEnum(),
};

-- system events
Sys_Event = {
	-- this is fired when the same application receives a message from the command line.
	SYS_COMMANDLINE = LastEnum(0),
	-- the user requests to close the application, such as clicking the x or alt-f4. only fired if ParaEngine.GetAttributeObject():GetField("IsWindowClosingAllowed", true) == false
	SYS_WM_CLOSE = AutoEnum(),
	-- a file drop event whenever user drags from windows explorer to this window. 
	SYS_WM_DROPFILES = AutoEnum(),
	-- window is being destroyed, do final clean up and save states. 
	SYS_WM_DESTROY = AutoEnum(),
	-- such as the slate or dock mode is changing under win8. 
	SYS_WM_SETTINGCHANGE = AutoEnum(),
};

-- NPL return code. it is also the NPL network event code
NPLReturnCode = {
	NPL_OK = LastEnum(0),
	NPL_Error = AutoEnum(),
	NPL_ConnectionNotEstablished = AutoEnum(),
	NPL_QueueIsFull = AutoEnum(),
	NPL_StreamError = AutoEnum(),
	NPL_RuntimeState_NotExist = AutoEnum(),
	NPL_FailedToLoadFile = AutoEnum(),
	NPL_RuntimeState_NotReady = AutoEnum(),
	NPL_FileAccessDenied = AutoEnum(),
	NPL_ConnectionEstablished = AutoEnum(),
	NPL_UnableToResolveName = AutoEnum(),
	NPL_ConnectionTimeout = AutoEnum(),
	NPL_ConnectionDisconnected = AutoEnum(),
	NPL_ConnectionAborted = AutoEnum(),
	NPL_Command = AutoEnum(),
}

-- OBSOLETED used NPLReturnCode instead: NPL network events
Net_Event = {
	NPL_TYPE_BEGIN = LastEnum(100),
	ID_NPL_ACTIVATE_NEURON = LastEnum(100),
	ID_NPL_ACTIVATE_GLIA=AutoEnum(),
	ID_NPL_PENDING_PACKET=AutoEnum(),
	ID_NPL_CHAT=AutoEnum(), 

	ID_NPL_BROADCAST=AutoEnum(),

	ID_NPL_LOGIN_PING=AutoEnum(),

	ID_ACCOUNT_LOGIN_QUEST=AutoEnum(),
	-- received by [RECEPTOR] whenever this client has successfully connected to a remote server. 
	ID_ACCOUNT_LOGIN_ACCEPTED=AutoEnum(),
	-- received by [RECEPTOR] whenever this client has unsuccessfully connected to a remote server. 
	ID_ACCOUNT_LOGIN_DENIED=AutoEnum(),
	ID_ACCOUNT_ALREADY_LOGIN=AutoEnum(),

	-- received by [CENTER] whenever a new receptor is connected to the center server.
	ID_NEW_RECEPTOR_CONNECT=AutoEnum(), 
	-- received by [RECEPTOR] when the receptor loses connection with its user(usually another center). the data and source field of the NPL packet contains the disconnected user name
	ID_RECEPTOR_USER_LOST=AutoEnum(), 
	-- received by [CENTER] when the center loses connection with its user(usually another receptor).the data and source field of the NPL packet contains the disconnected user name
	ID_CENTER_USER_LOST=AutoEnum(), 
	-- send by [CENTER|RECEPTOR] if the source sends this type of package to its destination. The connection between them will be closed. 
	ID_NPL_NOTIFY_FOR_DISCONNECT=AutoEnum(), 

	-- send or received by [CENTER|RECEPTOR]
	CS_NORMAL_UPDATE = LastEnum(200),
	-- send or received by [CENTER|RECEPTOR]
	CS_NORMAL_CHAT=AutoEnum(),
	-- send or received by [CENTER|RECEPTOR]
	CS_TERRAIN_UPDATE=AutoEnum(),
	-- received by [CENTER|RECEPTOR]
	ID_NPL_ERROR=AutoEnum(),
};

-- used in JabberClient
Jabber_Event =
{
	 --[[msg = {
		from = string, JID
		presenceType = number, -1 available,
			/// May I subscribe to you?
			subscribe = 0,
			/// Yes, you may subscribe.
			subscribed = 1,
			/// Unsubscribe from this entity.
			unsubscribe = 2,
			/// No, you may not subscribe.
			unsubscribed = 3,
			/// Offline
			unavailable = 4,
			/// server-side only.
			probe = 5,
			/// A presence error.
			error = 6,
			/// Invisible presence: we're unavailable to them, but still see theirs.
			invisible = 7
	 }]]
	Jabber_OnPresence = LastEnum(0),--We received a presence packet.
	--[[msg = {
		msg = nil or string, -- error message
	}]]
	Jabber_OnError=AutoEnum(),
	Jabber_OnRegistered=AutoEnum(),--After calling Register(), the registration succeeded or failed.
	Jabber_OnRegisterInfo=AutoEnum(),--after calling Register, information about the user is required.  Fill in the given IQ with the requested information.
	Jabber_OnIQ=AutoEnum(),--We received an IQ packet.
	--[[msg = {
		from = string,
		subject = nil or string, 
		body = nil or string,
	}]]
	Jabber_OnMessage=AutoEnum(),--We received a message packet.
	Jabber_OnAuthError=AutoEnum(),--Authentication failed.  The connection is not terminated if there is an auth error and there is at least one event handler for this event.
	Jabber_OnLoginRequired=AutoEnum(),--AutoLogin is false, and it's time to log in.

	Jabber_OnConnect=AutoEnum(), -- The connection is connected, but no stream:stream has been sent, yet.
	Jabber_OnAuthenticate=AutoEnum(), -- The connection is complete, and the user is authenticated.
	Jabber_OnDisconnect=AutoEnum(), -- The connection is disconnected

	Jabber_OnRosterEnd=AutoEnum(), --Fired when a roster result is completed being processed.
	Jabber_OnRosterBegin=AutoEnum(), -- Fired when a roster result starts, before any OnRosterItem events fire.
	--[[msg = {
		Subscription = number, -- 0(to), 1(from), 2(both), 3(none), 4(remove)
		JID = string, -- jabber ID
	}]]
	Jabber_OnRosterItem=AutoEnum(), --event for new roster items. A roster may belong to multiple groups
		
	--[[msg = {
		from = string, -- jabber ID
	}]]
	Jabber_OnSubscription=AutoEnum(), -- a new user subscribes to this user
	
	--[[msg = {
		from = string, -- jabber ID
	}]]
	Jabber_OnUnsubscription=AutoEnum(), -- a user unsubscribes from this user
		
};

VirtualKeyToScaneCodeStr = {};
local key,v;
for key,v in pairs(Event_Mapping) do
	local __,__,__,__,k = string.find(key,"(.+)_(.+)_(.+)");
	if(k)then
		k = "DIK_"..k;
		VirtualKeyToScaneCodeStr[v] = k;
	end
end

-- touch event mapping
TouchEvent = {
	TouchEvent_Begin = LastEnum(0),
	TouchEvent_Move = AutoEnum(0),
	TouchEvent_End = AutoEnum(0),
	TouchEvent_Cancel = AutoEnum(0),
}

