--[[
Title: Taurus main loop
Author(s): WangTian
Date: 2009/4/28
Desc: Entry point and game loop
commands line
| *name* | *desc* |
| worldpath | initial world path |
use the lib:
------------------------------------------------------------
NPL.activate("(gl)script/apps/Taurus/main_loop.lua");
set the bootstrapper to point to this file, see config/bootstrapper.xml
Or run application with command line: bootstrapper="script/apps/Taurus/bootstrapper.xml"
------------------------------------------------------------
]]

NPL.load("(gl)script/kids/ParaWorldCore.lua"); -- ParaWorld platform includes
-- Choose a core system. Code name("Map3DSystem") is the latest ParaWorld platform system implementation.
System = commonlib.inherit(Map3DSystem);

-- if asset is not found locally, we will look in this place
-- TODO: read this from config file. 
ParaAsset.SetAssetServerUrl("http://update.61.com/haqi/assetupdate/");
--ParaAsset.SetAssetServerUrl("http://192.168.0.228/assetdownload/update/");
ParaEngine.GetAttributeObject():GetChild("AssetManager"):SetField("UseLocalFileFirst", true);

-- uncomment this line to display our logo page. 
-- main_state="logo";

System.options.isAB_SDK = true;
ParaEngine.GetAttributeObject():CallField("BringWindowToTop");

-- pause here to debug. 
--NPL.load("(gl)script/ide/Debugger/IPCDebugger.lua");
--IPCDebugger.Start();
--IPCDebugger.WaitForBreak()

-- some init stuffs that are only called once at engine start up, but after System.init()
local bTaurus_Init;
local function Taurus_Init()
	if(bTaurus_Init) then return end
	bTaurus_Init = true;
	
	System.SystemInfo.SetField("name", "Taurus")
	System.options.isKid = true;
	
	-- in case back buffer is not big enough, we will use UI scaling. 
	local att = ParaEngine.GetAttributeObject();
	att:SetField("IgnoreWindowSizeChange",false);
	ParaUI.SetMinimumScreenSize(960,560,true);
	--att:SetField("ToggleSoundWhenNotFocused", false);
	--att:SetField("AutoLowerFrameRateWhenNotFocused", false);

	-- load default theme
	NPL.load("(gl)script/apps/Taurus/DefaultTheme.lua");
	Taurus_LoadDefaultTheme();
	
	-- always use compression. The current compression method is super light-weighted and is mostly for data encrption purposes. 
	NPL.SetUseCompression(true, true);
	-- set compression key and method. 
	-- NPL.SetCompressionKey({key = "this can be nil", size = 64, UsePlainTextEncoding = 1});
	
	-- install the Taurus app, if it is not installed yet.
	local app = System.App.AppManager.GetApp("Taurus_GUID")
	if(not app) then
		app = System.App.Registration.InstallApp({app_key="Taurus_GUID"}, "script/apps/Taurus/IP.xml", true);
	end
	-- change the login machanism to use our own login module
	System.App.Commands.SetDefaultCommand("Login", "Profile.Taurus.Login");
	-- change the load world command to use our own module
	System.App.Commands.SetDefaultCommand("LoadWorld", "File.EnterTaurusWorld");
	-- change the handler of system command line. 
	System.App.Commands.SetDefaultCommand("SysCommandLine", "Profile.Taurus.SysCommandLine");
	-- change the handler of enter to chat. 
	System.App.Commands.SetDefaultCommand("EnterChat", "Profile.Taurus.EnterChat");
	-- change the handler of drop files 
	System.App.Commands.SetDefaultCommand("SYS_WM_DROPFILES", "Profile.Taurus.SYS_WM_DROPFILES");

	ParaIO.LoadReplaceFile("AssetsReplaceFile.txt", false);
	
	-- load all worlds configuration file
	NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
	MyCompany.Aries.WorldManager:Init("script/apps/Aries/Scene/AriesGameWorlds.config.xml");

	-- enable asset file watcher in Taurus by default. 
	NPL.load("(gl)script/ide/FileSystemWatcher.lua");
	commonlib.FileSystemWatcher.EnableAssetFileWatcher()

	-- register shared aries mcml control for testing.
	NPL.load("(gl)script/apps/Aries/mcml/pe_locationtracker.lua");
	local mcml_controls = commonlib.gettable("MyCompany.Aries.mcml_controls");
	Map3DSystem.mcml_controls.RegisterUserControl("pe:locationtracker", mcml_controls.pe_locationtracker);
	Map3DSystem.mcml_controls.RegisterUserControl("pe:arrowpointer", mcml_controls.pe_arrowpointer);

	NPL.load("(gl)script/kids/3DMapSystemApp/DebugApp/app_main.lua");
	Map3DSystem.App.Debug.DoLoadConfigFile();
end

-- this script is activated every 0.5 sec. it uses a finite state machine (main_state). 
-- State nil is the inital game state. state 0 is idle.
local function activate()
	if(main_state==0) then
		-- this is the main game loop
		
	elseif(main_state==nil) then
		-- initialization 
		main_state = System.init();
		if(main_state~=nil) then
			Taurus_Init();
			
			---- sample code to immediately load the world if app platform is not used. 
			--local res = System.LoadWorld({
				--worldpath="worlds/MyWorlds/1111111111111",
				---- use exclusive desktop mode
				--bExclusiveMode = true,
			--})
			--
			---- show login window
			--NPL.load("(gl)script/apps/Taurus/Login/MainLogin.lua");
			--MyCompany.Taurus.MainLogin.Show();
			
			--local params = {worldpath = "worlds/MyWorlds/1111111111111"}
			--System.App.Commands.Call(System.App.Commands.GetLoadWorldCommand(), params);
			--if(params.res) then
				---- succeed loading
			--end
			
			local params = {
				worldpath = ParaEngine.GetAppCommandLineByParam("worldpath", "worlds/MyWorlds/flatgrassland"),
				-- only give the guest right, to prevent switching character and editing. 
				role = "administrator",
			}
			
			if(ParaWorld.GetWorldDirectory() ~= params.worldpath) then
				System.App.Commands.Call(System.App.Commands.GetLoadWorldCommand(), params);
			else
				log("world is already loaded.\n")	
			end	
		end
	elseif(main_state == "logo") then
		if(not IsServerMode) then
			NPL.load("(gl)script/kids/3DMapSystemUI/Desktop/LogoPage.lua");
			System.UI.Desktop.LogoPage.Show(79, {
				{name = "LogoPage_PE_bg", bg="Texture/whitedot.png", alignment = "_fi", left=0, top=0, width=0, height=0, color="255 255 255 255", anim="script/kids/3DMapSystemUI/Desktop/Motion/Bg_motion.xml"},
				{name = "LogoPage_PE_logoTxt", bg="Texture/3DMapSystem/brand/ParaEngineLogoText.png", alignment = "_rb", left=-320-20, top=-20-5, width=320, height=20, color="255 255 255 255", anim="script/kids/3DMapSystemUI/Desktop/Motion/Bg_motion.xml"},
				{name = "LogoPage_PE_logo", bg="Texture/Taurus/FrontPage_32bits.png;0 111 512 290", alignment = "_ct", left=-512/2, top=-290/2, width=512, height=290, color="255 255 255 0", anim="script/apps/Taurus/Desktop/Motion/Logo_motion.xml"},
			})
		else
			main_state = nil;
		end		
	end	
end
NPL.this(activate);