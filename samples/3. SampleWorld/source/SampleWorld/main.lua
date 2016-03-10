--[[
Title: Main loop
Author(s): LiXizhi
Company: ParaEnging Co.
Date: 2014/3/21
Desc: Entry point and game loop
use the lib:
------------------------------------------------------------
NPL.activate("source/HelloWorld/main.lua");
Or run application with command line: bootstrapper="source/HelloWorld/main.lua"
------------------------------------------------------------
]]
-- 加载一些核心类库
NPL.load("(gl)script/kids/ParaWorldCore.lua"); 

--读配置文件
local function load_config()
	System.options.is_client = true;
	-- this is a MicroCosmos app. 
	System.options.mc = true; 
	
	local filename = "config/GameClient.config.xml"
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(not xmlRoot) then
		LOG.std("", "warning", "aries", "warning: failed loading game server config file %s", filename);
		return;
	end	
	local node;
	node = commonlib.XPath.selectNodes(xmlRoot, "/GameClient/asset_server_addresses/address")[1];
	if(node and node.attr) then
		-- 设置资源服务器URL
		ParaAsset.SetAssetServerUrl(node.attr.host);
		LOG.std("", "system", "aries", "Asset server: %s", node.attr.host)
	end
end

-- 初始化程序
local function InitApp()
	--读配置文件
	load_config();

	--初始化系统
	main_state = System.init();

	-- 使用一个Creator风格的内置GUI皮肤
	NPL.load("(gl)script/apps/Aries/Creator/Game/DefaultTheme.mc.lua");
	MyCompany.Aries.Creator.Game.Theme.Default:Load();

	-- 注册一些常用的内部APP模块。 
	System.App.Registration.CheckInstallApps({
		{app={app_key="WebBrowser_GUID"}, IP_file="script/kids/3DMapSystemApp/WebBrowser/IP.xml"},
		{app={app_key="worlds_GUID"}, IP_file="script/kids/3DMapSystemApp/worlds/IP.xml"},
		{app={app_key="Debug_GUID"}, IP_file="script/kids/3DMapSystemApp/DebugApp/IP.xml"},
		{app={app_key="Creator_GUID"}, IP_file="script/kids/3DMapSystemUI/Creator/IP.xml"},
		{app={app_key="Aries_GUID"}, IP_file="script/apps/Aries/IP.xml", bSkipInsertDB = true},
	})
	-- change the login machanism to use our own login module
	System.App.Commands.SetDefaultCommand("Login", "Profile.Aries.Login");
	-- change the load world command to use our own module
	System.App.Commands.SetDefaultCommand("LoadWorld", "File.EnterAriesWorld");
	-- change the handler of system command line. 
	System.App.Commands.SetDefaultCommand("SysCommandLine", "Profile.Aries.SysCommandLine");
	-- change the handler of enter to chat. 
	System.App.Commands.SetDefaultCommand("EnterChat", "Profile.Aries.EnterChat");
	-- change the handler of drop files 
	System.App.Commands.SetDefaultCommand("SYS_WM_DROPFILES", "Profile.Aries.SYS_WM_DROPFILES");

	-- some code driven audio files for backward compatible
	AudioEngine.Init();
	-- set max concurrent sounds
	AudioEngine.SetGarbageCollectThreshold(10)
	-- load wave description resources
	AudioEngine.LoadSoundWaveBank("config/Aries/Audio/AriesRegionBGMusics.bank.xml");

	CommonCtrl.Locale.EnableLocale(false);

	-- 注册常用HTML渲染控件
	NPL.load("(gl)script/apps/Aries/mcml/mcml_aries.lua");
	MyCompany.Aries.mcml_controls.register_all();

	-- load all worlds configuration file
	NPL.load("(gl)script/apps/Aries/Scene/WorldManager.lua");
	MyCompany.Aries.WorldManager:Init();
end

-- 进入一个默认的世界
local function LoadSampleWorld()
	NPL.load("(gl)script/apps/Aries/Creator/Game/main.lua");
	local Game = commonlib.gettable("MyCompany.Aries.Game")

	local worldname = "SampleWorld";
	local worldfolder = "worlds/DesignHouse/";
	local worldpath = worldfolder..worldname;
	if(not ParaIO.DoesFileExist(worldpath)) then
		--  世界不存在就创建一个
		NPL.load("(gl)script/apps/Aries/Creator/Game/Login/CreateNewWorld.lua");
		local CreateNewWorld = commonlib.gettable("MyCompany.Aries.Game.MainLogin.CreateNewWorld")
		if(CreateNewWorld.CreateWorld({
				worldname = worldname, 
				creationfolder=worldfolder, 
				parentworld = "worlds/Templates/Empty/flatsandland", --从哪个世界派生新世界
				world_generator = "flat", -- 超级平坦
				seed = world_name, -- 创建世界的随机种子
			})) then
			-- created new world succeed!
		end
	end
	Game.Start(worldpath);
end

-- 主循环， 每秒会调用2次. 
local function activate()
	if(main_state == nil) then
		main_state = 1;
		-- 保证只调用一次
		InitApp();
		LoadSampleWorld();
	else
		-- loop
	end
end

NPL.this(activate);