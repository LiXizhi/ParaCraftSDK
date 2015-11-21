--[[
Title: well known application keys
Author(s): LiXizhi
Date: 2008/1/3
Desc: a mapping from name short cut to application keys
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/appkeys.lua");
Map3DSystem.App.GenerateAppDevWikiPages()
------------------------------------------------------------
]]

local L = CommonCtrl.Locale("ParaWorld");

-- TODO: well known application keys
Map3DSystem.App.appkeys = {
-- Profile Application 
["profiles"] = "profiles_GUID", 
-- my land, my worlds, map bbs, map search, etc. 
["map"] = "Map_GUID", 
-- ccs panel, 
["CCS"] = "CCS_GUID", 
-- assets panel, 
["Assets"] = "Assets_GUID", 
-- creator app
["Creator"] = "Creator_GUID",
-- worlds app: new, save, load world, etc.
["worlds"] = "worlds_GUID", 
["Debug"] = "Debug_GUID", 
["MyDesktop"] = "MyDesktop_GUID", 
-- environment modification, like ocean, sky, terrain, etc. 
["Env"] = "Env_GUID", 
["Developers"] = "Developers_GUID", 
-- taking screen shot and upload to website
["screenshot"] = "ScreenShot_GUID", 
-- action feed
["actionfeed"] = "ActionFeed_GUID", 
-- pet app
["pet"] = "ParaEngine.App.Pet.1.0", 
-- bcs panel, 
["BCS"] = "ParaEngine.App.BCS.1.0", 
["Blueprint"] = "Blueprint_GUID", 
-- new world wizards
["createworld"] = "ParaEngine.App.createworld.1.0", 
-- IM, chat, city chat, etc.
["chat"] = "Chat_GUID", 
["EBook"] = "EBook_GUID", 
-- world uploader and publication to map app. 
["publisher"] = "ParaEngine.App.publisher.1.0", 
-- like the audition game
["dance"] = "ParaEngine.App.dance.1.0", 
["inventory"] = "ParaEngine.App.inventory.1.0", 

-- avatar appearance of the current user. 
["avatar"] = "ParaEngine.App.avatar.1.0", 
["poke"] = "ParaEngine.App.poke.1.0", 
["wall"] = "ParaEngine.App.wall.1.0", 
-- artist SDK tools.
["SDK"] = "ParaEngine.App.SDK.1.0", 
--["videorecorder"] = "ParaEngine.App.videorecorder.1.0", 
};

-- Uninstallable official app_key. applications with the following keys can not be uninstalled, either because they are core utility app or official ones. 
Map3DSystem.App.UninstallableKeys = {
-- system module
["EditApps_GUID"] = true,
["RoomHostApp"] = true,
["Inventory_GUID"] = true,
["ActionFeed_GUID"] = true,
["WebBrowser_GUID"] = true,

-- uninstallable in current version
["worlds_GUID"] = true,
["profiles_GUID"] = true,
["Creator_GUID"] = true,
["Chat_GUID"] = true,
["Assets_GUID"] = true,
["Env_GUID"] = true,
["MyDesktop_GUID"] = true,
["ScreenShot_GUID"] = true,
}

-- application categories
local AppCategory = {
	utility = 0,	
	game = 1,
	just_for_fun = 2,
	dating = 3,
	business = 4,
	education = 5,
	others = nil,
	-- TODO: add more here
};
Map3DSystem.App.AppCategory = AppCategory

Map3DSystem.App._debug = {}

-- print app directory to log file. 
function Map3DSystem.App._debug.PrintAppDirectory()
	local i, dir;
	for i,dir in ipairs(Map3DSystem.App.AppDirectory) do
		log(dir.name.."\n"..dir.about.."\n\n");
	end
end

-- print app directory as wiki items. 
function Map3DSystem.App._debug.PrintAppWikiDirectory()
	local i, dir;
	for i,dir in ipairs(Map3DSystem.App.AppDirectory) do
		log(string.format("   * [[Main.%sApp][%s]]\n", dir.name, dir.name));
	end
end

-- register all offcial applications with the remote server. This function is for adiministration purposes only. 
-- %TESTCASE{"Register Official Apps", func="Map3DSystem.App.RegisterOfficialApps", input={uid = "123", size = 100}}%
function Map3DSystem.App.RegisterOfficialApps(input)
	local i=1;
	
	local function RegisterFunc()
		local dir = Map3DSystem.App.AppDirectory[i];
		i = i + 1
		if(dir) then
			paraworld.apps.AddApp({
				nplappname = dir.name,
				username = dir.author,
				desc = dir.about,
				downloadurl = dir.url,
				size = 10,
				appkey = dir.app_key,
			}, 
			"test", 
			function(msg)
				log(commonlib.serialize(msg));
				RegisterFunc();
			end);
		end	
	end
	
	RegisterFunc();
end

-- generate application dev wiki page for all official application. 
-- The wiki word is always XXXAppDev and parent topic is OfficialApps
function Map3DSystem.App.GenerateAppDevWikiPages()
	NPL.load("(gl)script/ide/NPLDocGen.lua");
	
	local i, dir;
	for i,dir in ipairs(Map3DSystem.App.AppDirectory) do
		local input = {TopicParent = "OfficialApps", input={}};
		-- ensure that the app dev's wiki name is XXXAppDev
		local WikiWord = dir.name;
		if(not string.find(WikiWord, "App$")) then
			WikiWord = WikiWord.."App";
		end
		input.WikiWord = WikiWord.."Dev";
		input.desc = ParaMisc.EncodingConvert("", "utf-8", dir.about);
		
		local parentDir = ParaIO.GetParentDirectoryFromPath(dir.IP, 0);
		commonlib.SearchFiles(input.input, parentDir, "*.lua", 3, 150, true)
		
		local k, path;
		for k, path in ipairs(input.input) do
			input.input[k] = parentDir..path;
			if(k>1 and path=="app_main.lua") then
				-- move to front. 
				input.input[k], input.input[1] = input.input[1], input.input[k];
			end
		end
		commonlib.NPLDocGen.GenerateTWikiTopic(input);
	end
end

-- it contains a directory for all applications world wide. It needs to be synchronized with the application app server on demand each day. 
-- however, if network is not available, the default list as in this file is used to populate the application directory which is usually displayed in the EditApps's browser window. 
-- Note: when ParaEngine developers add a new official application, he or she should add an entry here. 
Map3DSystem.App.AppDirectory = {
	{
		app_key = "EditApps_GUID", 
		name = "EditApps", 
		category = AppCategory.utility, 
		about = L"添加/删除程序的应用程序",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemApp/EditApps/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070105,
		-- how many users added this application
		popularity = 12,
		-- how many users used this application in recent days. usually hit count
		activities = 10,
	},
	{
		app_key = "EBook_GUID", 
		name = "EBook", 
		category = AppCategory.utility, 
		about = L"浏览、阅读、制作3D电子书。3D电子书由玩家创作的文字，图片，声音，3D世界组成。 用户可以用它制作App帮助和说明书，贺卡，相册等等，发布后可以和朋友共享。",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemUI/EBook/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070106,
		-- how many users added this application
		popularity = 12,
		-- how many users used this application in recent days. usually hit count
		activities = 10,
	},
	{
		app_key = "Theme_GUID", 
		name = "Theme", 
		category = AppCategory.utility, 
		about = L"更改桌面及所有UI的图形风格,背景音乐等。",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemUI/Theme/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070110,
		-- how many users added this application
		popularity = 1,
		-- how many users used this application in recent days. usually hit count
		activities = 1,
	},
	{
		app_key = "BCS_GUID", 
		name = "BCS", 
		category = AppCategory.utility, 
		about = L"建筑换装系统。像搭积木一样制作一个房子: 地板、楼层、窗户、桌面、装饰等",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemUI/BCS/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070110,
		-- how many users added this application
		popularity = 1,
		-- how many users used this application in recent days. usually hit count
		activities = 1,
	},
	{
		app_key = "CCS_GUID", 
		name = "CCS", 
		category = AppCategory.utility, 
		about = L"编辑人物的种族、相貌、衣着和道具，以及玩家的化身(avatar)管理.",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemUI/CCS/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070110,
		-- how many users added this application
		popularity = 1,
		-- how many users used this application in recent days. usually hit count
		activities = 1,
	},
	{
		app_key = "Env_GUID", 
		name = "Env", 
		category = AppCategory.utility, 
		about = L"编辑自然环境的应用程序: 包括天空、海洋、陆地等",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemUI/Env/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070110,
		-- how many users added this application
		popularity = 1,
		-- how many users used this application in recent days. usually hit count
		activities = 1,
	},
	{
		app_key = "Pet_GUID", 
		name = "Pet", 
		category = AppCategory.utility, 
		about = L"进化宠物系统.宠物是社交动物,可以被玩家领养.",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemUI/Pet/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070110,
		-- how many users added this application
		popularity = 1,
		-- how many users used this application in recent days. usually hit count
		activities = 1,
	},
	{
		app_key = "Chat_GUID", 
		name = "Chat", 
		category = AppCategory.utility, 
		about = L"聊天即时通讯: 支持组、好友列表、隐私管理等",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemUI/Chat/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070110,
		-- how many users added this application
		popularity = 1,
		-- how many users used this application in recent days. usually hit count
		activities = 1,
	},
	{
		app_key = "Blueprint_GUID", 
		name = "Blueprint", 
		category = AppCategory.utility, 
		about = L"浏览、使用、制作3D工程图；与朋友分享你的3D作品. 主要是简化用户在平时和某些APP中的创作。应该也会有人创造出非常好的工程图，在关系网中流传开来。玩家的背包中可以有朋友的，自己的，他人的工程图纸。工程图APP是官方比较重要的APP之一",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemApp/BlueprintApp/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070109,
		-- how many users added this application
		popularity = 18,
		-- how many users used this application in recent days. usually hit count
		activities = 15,
	},
	{
		app_key = "RoomHostApp_GUID", 
		name = "RoomHostApp", 
		category = AppCategory.utility, 
		about = L"为应用程序开发商和用户集中的提供创建、加入他人世界的房间服务",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemApp/RoomHostApp/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070110,
		-- how many users added this application
		popularity = 17,
		-- how many users used this application in recent days. usually hit count
		activities = 8,
	},
	{
		app_key = "Inventory_GUID", 
		name = "Inventory", 
		category = AppCategory.utility, 
		about = L"为应用程序开发商和用户提供可交易物品的背包空间服务, 同时包括物品管理，不同背包内的物品买卖和交易",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemApp/Inventory/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070112,
		-- how many users added this application
		popularity = 13,
		-- how many users used this application in recent days. usually hit count
		activities = 12,
	},
	{
		app_key = "ActionFeed_GUID", 
		name = "ActionFeed", 
		category = AppCategory.utility, 
		about = L"为应用程序开发商和用户提供用户行为在人际关系网中的传播",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemApp/ActionFeed/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070112,
		-- how many users added this application
		popularity = 19,
		-- how many users used this application in recent days. usually hit count
		activities = 30,
	},
	{
		app_key = "ScreenShot_GUID", 
		name = "ScreenShot", 
		category = AppCategory.utility, 
		about = L"快速屏幕截图、上传图片、浏览其他玩家上传的图片",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemUI/ScreenShot/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070118,
		-- how many users added this application
		popularity = 7,
		-- how many users used this application in recent days. usually hit count
		activities = 3,
	},
	{
		app_key = "Debug_GUID", 
		name = "Debug", 
		category = AppCategory.utility, 
		about = L"应用程序开发者，用来调试NPL程序的工具集",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemApp/DebugApp/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070121,
		-- how many users added this application
		popularity = 1,
		-- how many users used this application in recent days. usually hit count
		activities = 1,
	},
	{
		app_key = "Map_GUID", 
		name = "Map", 
		category = AppCategory.utility, 
		about = L"提供2D、3D的地图服务：包括地球尺度的虚拟土地的浏览、买卖、交易、基于Map的广告、个人地图、搜索等等",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemUI/Map/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070124,
		-- how many users added this application
		popularity = 20,
		-- how many users used this application in recent days. usually hit count
		activities = 20,
	},
	{
		app_key = "Login_GUID", 
		name = "Login", 
		category = AppCategory.utility, 
		about = L"提供各种样式的登陆与认证窗口。支持官网和第三方认证方式，应用程序开发商和用户都可以使用。",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemApp/Login/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070125,
		-- how many users added this application
		popularity = 20,
		-- how many users used this application in recent days. usually hit count
		activities = 20,
	},
	{
		app_key = "Settings_GUID", 
		name = "Settings", 
		category = AppCategory.utility, 
		about = L"更改计算机的图形、声音、键盘等的设置",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemUI/Settings/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070128,
		-- how many users added this application
		popularity = 20,
		-- how many users used this application in recent days. usually hit count
		activities = 20,
	},
	{
		app_key = "NewWorld_GUID", 
		name = "NewWorld", 
		category = AppCategory.utility, 
		about = L"创建新的虚拟世界向导。向导提供事先制作好的世界，用户可以直接修改来生成自己的世界。 ",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemUI/NewWorld/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070128,
		-- how many users added this application
		popularity = 20,
		-- how many users used this application in recent days. usually hit count
		activities = 20,
	},
	{
		app_key = "ParaWorldIntro_GUID", 
		name = "ParaWorldIntro", 
		category = AppCategory.utility, 
		about = L"帕拉巫世界介绍: 包含30分钟的社区引导、社区教程、制作群、APP开发网 & SDK、帮助、CG等. 30分钟的社区引导包括：注册，建立3D形象，加入城市，学习3D的操作，创建和浏览关系网和应用程序",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemUI/ParaworldIntro/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070128,
		-- how many users added this application
		popularity = 20,
		-- how many users used this application in recent days. usually hit count
		activities = 20,
	},
	{
		app_key = "WebBrowser_GUID", 
		name = "WebBrowser", 
		category = AppCategory.utility, 
		about = L"内嵌的Internet网页浏览器. 可以在3D世界中直接打开并操作网页。支持多种窗口模式和3D材质模式。应用程序开发商可以调用。",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemApp/WebBrowser/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070128,
		-- how many users added this application
		popularity = 20,
		-- how many users used this application in recent days. usually hit count
		activities = 20,
	},
	{
		app_key = "VideoRecorder_GUID", 
		name = "VideoRecorder", 
		category = AppCategory.utility, 
		about = L"在游戏中录制流媒体视频: 支持AVI,WMV, Xvid, Divx, 3D立体Stereo输出等。",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemUI/Movie/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070128,
		-- how many users added this application
		popularity = 20,
		-- how many users used this application in recent days. usually hit count
		activities = 20,
	},
	{
		app_key = "Painter_GUID", 
		name = "Painter", 
		category = AppCategory.utility, 
		about = L"在3D世界中用画笔绘制图案和贴图：可以在可换贴图的3D模型上绘制，可以用外部图片，电影，Flash文件做模型贴图",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemUI/Painter/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070128,
		-- how many users added this application
		popularity = 20,
		-- how many users used this application in recent days. usually hit count
		activities = 20,
	},
	{
		app_key = "MiniMap_GUID", 
		name = "MiniMap", 
		category = AppCategory.utility, 
		about = L"在3D世界中显示小地图：包括玩家和NPC位置, 应用程序传送点位置等",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemUI/MiniMap/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070128,
		-- how many users added this application
		popularity = 20,
		-- how many users used this application in recent days. usually hit count
		activities = 20,
	},
	{
		app_key = "Groups_GUID", 
		name = "Groups", 
		category = AppCategory.utility, 
		about = L"让玩家建立自己的组群、公会、公司。玩家可以浏览、加入其他人建立的组织，参加组织的讨论、活动等。组群的用户通常会聚集在城市中的某些位置。某些庞大、活跃、地理位置集中的组群可以向官方申请成为新的城市。",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemApp/Groups/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070131,
		-- how many users added this application
		popularity = 20,
		-- how many users used this application in recent days. usually hit count
		activities = 20,
	},
	{
		app_key = "Discussion_GUID", 
		name = "Discussion", 
		category = AppCategory.utility, 
		about = L"给其他应用程序提供BBS论坛方式的聊天、留言板窗口。大多数APP的首页都有一个使用本应用的论坛，上面可以收集用户意见、发布消息等",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemApp/Discussion/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070131,
		-- how many users added this application
		popularity = 20,
		-- how many users used this application in recent days. usually hit count
		activities = 20,
	},
	{
		app_key = "Homepage_GUID", 
		name = "Homepage", 
		category = AppCategory.utility, 
		about = L"给其他应用程序提供多种样式的可定制的首页。开发者只需写一行代码就可以让自己的APP首页具有下面功能: (1) 大厅服务：用户可以通过首页创建或加入其他人或开发者的3D在线世界 (2) 商城：用户可以买到此应用程序的物品 (3) BBS论坛：发布收集用户意见，开发者消息等 (4) 美术资源管理：制定哪些相册图片，3D模型可以显示在创建工具栏中，在3D世界中使用。",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemApp/Homepage/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070131,
		-- how many users added this application
		popularity = 20,
		-- how many users used this application in recent days. usually hit count
		activities = 20,
	},
	{
		app_key = "Assets_GUID", 
		name = "Assets", 
		category = AppCategory.utility, 
		about = L"用户可以上传和使用图片相册、3D模型，并和朋友共享。用户可以将图片和3D模型有选择的加入到自己的创作工具栏中，在3D世界中使用。应用程序开发者也可以将资源发布到自己的应用程序首页，推荐给应用程序的用户。",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemApp/Assets/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070131,
		-- how many users added this application
		popularity = 20,
		-- how many users used this application in recent days. usually hit count
		activities = 20,
	},
	{
		app_key = "Developers_GUID", 
		name = "Developers", 
		category = AppCategory.utility, 
		about = L"创建开发其他应用程序的应用程序。",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemApp/Developers/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070131,
		-- how many users added this application
		popularity = 20,
		-- how many users used this application in recent days. usually hit count
		activities = 20,
	},
	{
		app_key = "tasks_GUID", 
		name = "tasks", 
		category = AppCategory.utility, 
		about = L"让玩家和其他应用程序建立任务的应用程序。 任务是和奖励紧密联系的。用户和其他APP可以通过Task APP 制作和发放任务。任务支持多种完成条件和奖励条件。",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemApp/tasks/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070214,
		-- how many users added this application
		popularity = 5,
		-- how many users used this application in recent days. usually hit count
		activities = 10,
	},
	{
		app_key = "worlds_GUID", 
		name = "worlds", 
		category = AppCategory.utility, 
		about = L"载入/保存 虚拟世界; 发布/下载虚拟世界; 管理游戏世界服务器。",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemApp/worlds/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070214,
		-- how many users added this application
		popularity = 5,
		-- how many users used this application in recent days. usually hit count
		activities = 10,
	},
	{
		app_key = "profiles_GUID", 
		name = "profiles", 
		category = AppCategory.utility, 
		about = L"管理/同步所有用户的信息Profile (mcml). 用户的信息包括基本信息、朋友列表(social graph)、应用程序博客App boxes(Avatar, Map land, ...)等",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemApp/profiles/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070214,
		-- how many users added this application
		popularity = 5,
		-- how many users used this application in recent days. usually hit count
		activities = 10,
	},
	{
		app_key = "MyDesktop_GUID", 
		name = "MyDesktop", 
		category = AppCategory.utility, 
		about = L"游戏内的缺省用户桌面, 允许用户自定义在游戏内桌面, 添加Widgets等",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemUI/MyDesktop/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070214,
		-- how many users added this application
		popularity = 5,
		-- how many users used this application in recent days. usually hit count
		activities = 30,
	},
	{
		app_key = "Creator_GUID", 
		name = "Creator", 
		category = AppCategory.utility, 
		about = L"创建模型等",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemUI/Creator/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20070214,
		-- how many users added this application
		popularity = 5,
		-- how many users used this application in recent days. usually hit count
		activities = 30,
	},
	{
		app_key = "Inventor_GUID", 
		name = "Inventor", 
		category = AppCategory.utility, 
		about = "Inventor",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemUI/Inventor/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20081129,
		-- how many users added this application
		popularity = 5,
		-- how many users used this application in recent days. usually hit count
		activities = 30,
	},
	{
		app_key = "HomeZone_GUID", 
		name = "HomeZone", 
		category = AppCategory.utility, 
		about = "everyone's home",
		-- if the IP file exists, it will be considered as successfully downloaded, and that it can be installed immediately into the app registry.
		-- otherwise, one needs to first download the application from its application web site. Downloading usually means xcopy the IP.xml file to this location as well as any other script or resource files. 
		IP = "script/kids/3DMapSystemUI/HomeZone/IP.xml", 
		
		-- whether this is an official application. 
		IsOfficial = true,
		-- version
		version = "1.0.0", 
		-- use default url, which is usually domain/app_homepage.aspx?app_key=XXX
		url = nil, 
		author = "ParaEngine", 
		lang = "zhCN", 
		-- in format year, month, day
		date = 20090219,
		-- how many users added this application
		popularity = 5,
		-- how many users used this application in recent days. usually hit count
		activities = 30,
	},
}