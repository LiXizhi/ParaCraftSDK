--[[
Title: Taurus app_main
Author(s): WangTian
Date: 2009/4/28
Desc: Taurus is a ParaEngine SDK project
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/apps/Taurus/app_main.lua");
------------------------------------------------------------
]]
-- create class
commonlib.setfield("MyCompany.Taurus", {});

-- requires
NPL.load("(gl)script/apps/Taurus/Desktop/TaurusDesktop.lua");

-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of System.App.ConnectMode. 
function MyCompany.Taurus.OnConnection(app, connectMode)
	if(connectMode == System.App.ConnectMode.UI_Setup) then
		-- TODO: place your UI (menus,toolbars, tool buttons) through which the user will communicate to the app
		-- e.g. MainBar.AddItem(), MainMenu.AddItem().
		
		-- e.g. Create a Taurus command link in the main menu 
		local commandName = "Profile.Taurus.Login";
		local command = System.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "登录", icon = app.icon, });
			
			commandName = "Profile.Taurus.Register";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, ButtonText = "注册新用户",  icon = app.icon, });			
				
			commandName = "Profile.Taurus.HomePage";
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Taurus Front Page", icon = app.icon, });	
				
			commandName = "Profile.Taurus.Rooms";
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Taurus Rooms Page", icon = app.icon, });		
				
			commandName = "Profile.Taurus.Actions";
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Actions Page", icon = app.icon, });	
				
			commandName = "Profile.Taurus.CreateRoom";
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Create Room Page", icon = app.icon, });
			
			commandName = "Profile.Taurus.MyIncome";
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "My income page", icon = app.icon, });	
				
			commandName = "Profile.Taurus.ShowAssetBag";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, icon = app.icon, });	
			
			commandName = "Profile.Taurus.ShowBCSBag";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, icon = app.icon, });		
				
			commandName = "Profile.Taurus.AddSelectionToAssetBag";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, icon = app.icon, });		
			
			commandName = "Profile.Taurus.SysCommandLine";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, icon = app.icon, });		
			
			commandName = "Profile.Taurus.SYS_WM_DROPFILES";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, icon = app.icon, });

			commandName = "Profile.Taurus.DoSkill";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, icon = app.icon, });			
				
			commandName = "Profile.Taurus.EnterChat";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, icon = app.icon, });				
			
			commandName = "Profile.Taurus.Task";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, icon = app.icon, });
				
			commandName = "Profile.Taurus.WorldPage";
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName, app_key = app.app_key, icon = app.icon, });
				
		end
					
		--NPL.load("(gl)script/ide/IPCBinding/IPCBinding.lua");
		--IPCBinding.Start();	
		NPL.load("(gl)script/ide/ExternalInterface.lua");
		ExternalInterface.DoStart()
	else
		-- TODO: place the app's one time initialization code here.
		-- during one time init, its message handler may need to update the app structure with static integration points, 
		-- i.e. app.about, HomeButtonText, HomeButtonText, HasNavigation, NavigationButtonText, HasQuickAction, QuickActionText,  See app template for more information.
		
		-- e.g. 
		MyCompany.Taurus.app = app; -- keep a reference
		app.about = "Taurus application"
		app.HomeButtonText = "Hello Chat";
		
		local commandName = "File.EnterTaurusWorld";
		local command = System.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = System.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Enter the world", icon = app.icon, });
		end
		
	end
end

-- Receives notification that the Add-in is being unloaded.
function MyCompany.Taurus.OnDisconnection(app, disconnectMode)
	if(disconnectMode == System.App.DisconnectMode.UserClosed or disconnectMode == System.App.DisconnectMode.WorldClosed)then
		-- TODO: remove all UI elements related to this application, since the IDE is still running. 
		
		-- e.g. remove command from mainbar
		local command = System.App.Commands.GetCommand("Profile.Taurus.Login");
		if(command == nil) then
			command:Delete();
		end
	end
	-- TODO: just release any resources at shutting down. 
end

-- This is called when the command's availability is updated
-- When the user clicks a command (menu or mainbar button), the QueryStatus event is fired. 
-- The QueryStatus event returns the current status of the specified named command, whether it is enabled, disabled, 
-- or hidden in the CommandStatus parameter, which is passed to the msg by reference (or returned in the event handler). 
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
-- @param statusWanted: what status of the command is queried. it is of type System.App.CommandStatusWanted
-- @return: returns according to statusWanted. it may return an integer by adding values in System.App.CommandStatus.
function MyCompany.Taurus.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == System.App.CommandStatusWanted) then
		-- TODO: return an integer by adding values in System.App.CommandStatus.
		--if(commandName == "Profile.Taurus.Login") then
			-- return enabled and supported 
			return (System.App.CommandStatus.Enabled + System.App.CommandStatus.Supported)
		--end
	end
end

-- @param cmdline: parse command line params. 
-- @return: table[1] contains the url, and table.fieldname contains other fields. 
local function GetURLCmds(cmdline)
	local cmdURL = string.match(cmdline, "paraworldviewer://(.*)");
	local params = {};
	if(cmdURL) then
		local section
		for section in string.gfind(cmdURL, "[^;]+") do
			local name, value = string.match(section, "%s*(%w+)%s*=%s*(.*)");
			if(not name) then
				table.insert(params, section);
			else
				params[name] = value;
			end
		end
	end	
	return params;
end

	
-- This is called when the command is invoked.The Exec is fired after the QueryStatus event is fired, assuming that the return to the statusOption parameter of QueryStatus is supported and enabled. 
-- This is the event where you place the actual code for handling the response to the user click on the command.
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
function MyCompany.Taurus.OnExec(app, commandName, params)
	if(commandName == "Profile.Taurus.Login") then
		local title, cmdredirect;
		if(type(params) == "string") then
			title = params;
		elseif(type(params) == "table")	then
			title = params.title;
			cmdredirect = params.cmdredirect;
		end
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url=System.localserver.UrlHelper.BuildURLQuery("script/apps/Taurus/Desktop/LoginPage.html", {cmdredirect=cmdredirect}), 
			name="HelloLogin.Wnd", 
			app_key=app.app_key, 
			text = title or "登陆窗口",
			icon = "Texture/3DMapSystem/common/lock.png",
			
			directPosition = true,
				align = "_ct",
				x = -320/2,
				y = -230/2,
				width = 320,
				height = 230,
				bAutoSize=true,
			zorder=3,
		});
	elseif(commandName == "Profile.Taurus.Register") then
		-- register a new window
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/apps/Taurus/Registration/TaurusReg.html", 
			name="HelloReg.Wnd", 
			app_key=app.app_key, 
			text = "注册新用户",
			icon = "Texture/3DMapSystem/common/lock.png",
			DestroyOnClose = true,
			directPosition = true,
				align = "_ct",
				x = -640/2,
				y = -480/2,
				width = 640,
				height = 480,
				bAutoSize=true,
		});
	elseif(commandName == "Profile.Taurus.CreateRoom") then
		-- register a new window
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/apps/Taurus/Registration/TaurusRegRoom.html", 
			name="HelloReg.Wnd", 
			app_key=app.app_key, 
			text = "申请我的社区",
			icon = "Texture/3DMapSystem/common/lock.png",
			DestroyOnClose = true,
			directPosition = true,
				align = "_ct",
				x = -640/2,
				y = -480/2,
				width = 640,
				height = 480,
				bAutoSize=true,
		});	
	elseif(commandName == "Profile.Taurus.Task") then	
		-- register a new window
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/apps/Taurus/Task/HelloTask.html", 
			name="HelloTask.Wnd", 
			app_key=app.app_key, 
			text = "任务",
			icon = "Texture/3DMapSystem/AppIcons/Tasks_64.dds",
			bToggleShowHide = true, 
			directPosition = true,
				align = "_ct",
				x = -400/2,
				y = -450/2,
				width = 400,
				height = 450,
				bAutoSize=true,
		});	
	elseif(commandName == "Profile.Taurus.SYS_WM_DROPFILES") then
		-- whenever drop file is received. 
		local filelist = params;
		if(filelist) then
			NPL.load("(gl)script/apps/Taurus/DataAPI/model_import.lua");
			local model_import = commonlib.gettable("PETools.model_import");

			LOG.std("", "system", "wm_dropfiles", "", commonlib.Encoding.DefaultToUtf8(commonlib.serialize(filelist)));
			local _, filename;
			for _, filename in ipairs(filelist) do
				model_import.load_from_file(filename);	
			end
			return;
		end
		
	elseif(commandName == "Profile.Taurus.SysCommandLine") then		
		-- this function is called when the engine receives an external command, such as internet web browser to login to a given world. 
		local cmdParams = GetURLCmds(params);
		if(cmdParams[1] and cmdParams[1]~="") then
			-- let us load the world and/or movie
			System.App.Commands.Call(System.App.Commands.GetLoadWorldCommand(), {worldpath = cmdParams[1], movie=cmdParams.movie});
		end	
			
	elseif(commandName == "File.EnterTaurusWorld") then
		if(System.options.layout == "iCad")then
			MyCompany.Taurus.EnterICadWorld(app, commandName, params)
			return;
		end			
		
		-- Our custom load world function
		if(type(params) ~= "table") then return end
		
		if(params.worldpath == nil or params.worldpath == "") then
			-- load the command line world or just the default chat world. 
			local cmdParams = GetURLCmds(ParaEngine.GetAppCommandLine());
			params.worldpath = cmdParams[1] or "worlds/MyWorlds/flatgrassland"
			params.movie = cmdParams.movie;
		end
		--if(not ParaIO.DoesAssetFileExist(params.worldpath, true)) then
		-- [string "script/apps/Taurus/app_main.lua"]:262: attempt to call field 'DoesAssetFileExist' (a nil value) <Runtime error>
		if(not ParaIO.DoesFileExist(params.worldpath, true)) then
			commonlib.log(params.worldpath.." does not exist\n")
			-- TODO: if the world is not downloaded or does not exist, use a default world and download in the background. 
			params.worldpath = "worlds/MyWorlds/flatgrassland";
		end
		
		ParaNetwork.EnableNetwork(false, "","");
		local res = System.LoadWorld({
				worldpath = params.worldpath,
				-- use exclusive desktop mode
				bExclusiveMode = true,
				--OnProgress = function(percent)
					--commonlib.echo({loading_percent = percent});
				--end
			})
		params.res = res;
		if(res == true) then
			-- switch to Taurus app_main desktop and make it default.
			System.UI.AppDesktop.SetDefaultApp("Taurus_GUID", true);
			
			System.User.SetRole("administrator");
			
			local player = ParaScene.GetPlayer();
			if(player:GetPrimaryAsset():GetKeyName():match("^character/v3/Elf/")) then
				player:SetScale(1.6105)
				LOG.std(nil, "debug", "Taurus", "The character is aries elf character, we will scale it to 1.6105")
			end
			
			-- NOTE LiXizhi: 2009.7.30: Remove this in release build. 
			-- for testing purposes we will start the game server and force connecting to it
			local test_using_local_game_server = false;
			if(test_using_local_game_server) then
				NPL.load("(gl)script/apps/GameServer/GSL.lua");
				
				-- start the game server on the local machine
				local worker = NPL.CreateRuntimeState("world1", 0);
				worker:Start();
				NPL.activate("(world1)script/apps/GameServer/GSL_system.lua", {type="restart", config={nid="localhost", ws_id="world1"}});
				
				NPL.StartNetServer("127.0.0.1", "60001");
				NPL.LoadPublicFilesFromXML();
				
				NPL.AddNPLRuntimeAddress({host = "127.0.0.1", port = "60002", nid = "gs1",});
				
				Map3DSystem.User.nid = tostring(math.floor(ParaGlobal.GetGameTime()*1000)%100000);
				
				commonlib.applog("TODO: remove this in release build: connecting to local game server, ...")
				local run_gs_locally = false;
				if(run_gs_locally) then
					while(NPL.activate("localhost:script/apps/GameServer/test/accept_any.lua", {user_nid = Map3DSystem.GSL.GetNID(), callback=[[Map3DSystem.GSL_client:LoginServer("localhost", "world1");]]})~=0) do end
				else
					while(NPL.activate("gs1:script/apps/GameServer/test/accept_any.lua", {user_nid = Map3DSystem.GSL.GetNID()})~=0) do end
					ParaEngine.Sleep(0.5);
					Map3DSystem.GSL_client:LoginServer("gs1", "world1");
				end	
				commonlib.applog("local game server connected")
			end
			
		elseif(type(res) == "string") then
			-- show the error message
			_guihelper.MessageBox(res);
		end
	elseif(commandName == "Profile.Taurus.EnterChat") then
		-- TODO: user pressed enter key to chat. 
		if(commonlib.getfield("MyCompany.Taurus.ChatWnd.Show")) then
			MyCompany.Taurus.ChatWnd.Show(true);
		end
		
	elseif(commandName == "Profile.Taurus.DoSkill") then	
		if(type(params) == "table") then
			local player = ParaScene.GetPlayer();
			-- play animation
			if(params.anim) then
				System.Animation.PlayAnimationFile(params.anim, player);
			end	
			-- change headonmodel or headonchar
			if(params.headonmodel or params.headonchar) then
				player:ToCharacter():RemoveAttachment(11);
				local asset;
				if(params.headonmodel) then 
					asset = ParaAsset.LoadStaticMesh("", params.headonmodel);
				elseif(params.headonchar) then 
					asset = ParaAsset.LoadParaX("", params.headonchar);
				end	
				if(asset~=nil and asset:IsValid()) then
					player:ToCharacter():AddAttachment(asset, 11);
				end
			else
				player:ToCharacter():RemoveAttachment(11);
			end
			
			-- play effect, as well
			-- TODO: demo effects. 
			--ParaScene.FireMissile(headon_speech.GetAsset("tag"), distH/0.6, to_x, to_y+distH, to_z, to_x, to_y, to_z);
		end
	elseif(commandName == "Profile.Taurus.ShowBCSBag") then	
		-- TODO: 
		--System.App.Commands.Call("Creation.NormalCharacter");
		System.App.Commands.Call("Creation.BuildingComponents");
		
		-- hide asset bag
		System.App.Commands.Call("File.MCMLWindowFrame", {name="HelloAssetBag", 
			app_key = app.app_key, 
			bShow = false,
		});
		
	elseif(commandName == "Profile.Taurus.WorldPage") then
		-- register a new window
		System.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/apps/Taurus/Desktop/WorldPage.html", 
			name="HelloReg.Wnd", 
			app_key=app.app_key, 
			text = "申请我的社区",
			icon = "Texture/3DMapSystem/common/lock.png",
			DestroyOnClose = true,
			enable_esc_key = true,
			directPosition = true,
				align = "_ct",
				x = -680/2,
				y = -540/2,
				width = 680,
				height = 500,
				bAutoSize=true,
		});	
	elseif(commandName == "Profile.Taurus.ShowAssetBag") then
		-- show the asset bag. 
		if(type(params) == "string") then 
			params = {url=params};
		elseif(type(params) ~= "table") then 
			return 
		end
		System.App.Commands.Call("File.MCMLWindowFrame", {name="HelloAssetBag", 
			url=params.url, 
			app_key = app.app_key, 
			bToggleShowHide = true,
			icon = params.icon or "Texture/3DMapSystem/common/ViewFiles.png",
			text = params.text or "我的资源包",
			directPosition = true,
				align = "_rb",
				x = -175,
				y = -82-380,
				width = 175,
				height = 380,
				bAutoSize = true,
		});
		-- hide BCS
		System.App.Commands.Call("Creation.BuildingComponents", {bShow=false});
	elseif(commandName == "Profile.Taurus.AddSelectionToAssetBag") then	
		-- add selection to bag
		if(type(params) ~= "string") then return end
		local dataSource = params;
		local objParams = System.obj.GetObjectParams("selection");
		if(not objParams or not objParams.AssetFile) then 
			_guihelper.MessageBox("请先在3D场景中选择一个要添加的物体");
			return;
		end
		if(type(dataSource) == "string") then
			if(string.match(dataSource, "http://")) then
				-- TODO: remote xml or web serivce bag
			else
				-- local disk xml file. 
				local xmlRoot = ParaXML.LuaXML_ParseFile(dataSource);
				if(not xmlRoot) then 
					commonlib.log("pe:bag xml file %s is created. \n", dataSource);
					xmlRoot = {name="pe:mcml", n=0}
				end
				NPL.load("(gl)script/ide/XPath.lua");
				local fileNode, bagNode;
				local result = commonlib.XPath.selectNodes(xmlRoot, string.format("//pe:asset[@src='%s']", objParams.AssetFile));
				if(result and #result > 0) then
					_guihelper.MessageBox("当前选择的物品已经在背包中了");
					return;
				end
				-- add to the last bag in the file
				for fileNode in commonlib.XPath.eachNode(xmlRoot, "//pe:bag") do
					bagNode = fileNode;
				end
				if(not bagNode) then
					bagNode = {name="pe:bag", n=0};
					xmlRoot[#xmlRoot+1] = bagNode;
				end
				-- add new asset node. 
				local newNode = {name="pe:asset", attr={}};
				
				newNode.attr["src"] = objParams.AssetFile;
				if(objParams.IsCharacter) then
					newNode.attr["type"] = "char";
				end
				bagNode[#bagNode+1] = newNode;
				
				-- output project file.
				ParaIO.CreateDirectory(dataSource);
				local file = ParaIO.open(dataSource, "w");
				if(file:IsValid()) then
					file:WriteString([[<?xml version="1.0" encoding="utf-8"?>]]);
					file:WriteString("\r\n");
					-- change encoding to "utf-8" before saving
					file:WriteString(ParaMisc.EncodingConvert("", "utf-8", commonlib.Lua2XmlString(xmlRoot)));
					file:close();
				end
				-- refresh the page. 
				System.App.Commands.Call("File.MCMLWindowFrame", {name="HelloAssetBag", app_key=app.app_key, bRefresh=true});
			end
		end
		-- TODO: need to update bag and play some marker animation perhaps.
	
	elseif(System.UI.AppDesktop.CheckUser(commandName)) then	
		-- all functions below requres user is logged in. 	
		if(commandName == "Profile.Taurus.HomePage") then
			System.App.Commands.Call("File.MCMLBrowser", {url="script/apps/Taurus/Desktop/LoggedInHomePage.html", name="HelloPage", title="我的首页", DisplayNavBar = true});
		elseif(commandName == "Profile.Taurus.Rooms") then
			System.App.Commands.Call("File.MCMLBrowser", {url="script/apps/Taurus/Desktop/RoomsPage.html", name="HelloPage", title="邻居聊天室", DisplayNavBar = true});
		elseif(commandName == "Profile.Taurus.Actions") then
			System.App.Commands.Call("File.MCMLBrowser", {url="script/apps/Taurus/Desktop/ActionsPage.html", name="HelloPage", title="动作", DisplayNavBar = true});
		elseif(commandName == "Profile.Taurus.MyIncome") then	
			System.App.Commands.Call("File.MCMLBrowser", {url="script/apps/Taurus/Desktop/MyIncome.html", name="HelloPage", title="我的收益", DisplayNavBar = true});
		end
	elseif(app:IsHomepageCommand(commandName)) then
		MyCompany.Taurus.GotoHomepage();
	elseif(app:IsNavigationCommand(commandName)) then
		MyCompany.Taurus.Navigate();
	elseif(app:IsQuickActionCommand(commandName)) then	
		MyCompany.Taurus.DoQuickAction();
	end
end

-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function MyCompany.Taurus.OnRenderBox(mcmlData)
end


-- called when the user wants to nagivate to the 3D world location relavent to this application
function MyCompany.Taurus.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function MyCompany.Taurus.GotoHomepage()
end

-- called when user clicks the quick action for this application. 
function MyCompany.Taurus.DoQuickAction()
end

-- whenever this application becomes active. Init UI of this app.
function MyCompany.Taurus.OnActivateDesktop()
	
	System.UI.AppDesktop.ChangeMode("edit");
	
	NPL.load("(gl)script/apps/Aries/Scene/EffectManager.lua");
	MyCompany.Aries.EffectManager.Init();

	-- start UI animation framework.
	NPL.load("(gl)script/ide/UIAnim/UIAnimManager.lua");
	UIAnimManager.Init();
end

function MyCompany.Taurus.OnDeactivateDesktop()
end

function MyCompany.Taurus.OnWorldLoad()
	-- enable sound
	ParaAudio.SetVolume(1);

	-- set some time of day on each world load
	--ParaScene.SetTimeOfDaySTD(0.25);
	-- set day length of the day, set to 24 hours
	--ParaScene.SetDayLength(1440);
	
	-- always show head on text
	local player = ParaScene.GetPlayer();
	local att = player:GetAttributeObject()
	att:SetDynamicField("AlwaysShowHeadOnText", true);
	System.ShowHeadOnDisplay(true, player, player.name);
	
	-- apply effect settings
	Map3DSystem.world:ApplyEditorAttributes();

	-- set the enviroment params only for haqitown worlds
	local worldpath = ParaWorld.GetWorldDirectory();
	if(string.find(string.lower(worldpath), "61haqitown$") or string.find(string.lower(worldpath), "20100825_new")) then
		-- set the fog range and far plane from the current ViewDistance
		local att = ParaScene.GetAttributeObject();
		local FarPlane = tonumber(ParaEngine.GetAttributeObject():GetDynamicField("ViewDistance", 200));
		local FogStart, FogRange;
		local FarPlane_range = {from=100,to=420}
		local FogStart_range = {from=50,to=80}
		local FogEnd_range	 = {from=70,to=130}
		att:SetField("FogEnd", 42 + 80);
		att:SetField("FogStart", 80);
		ParaCamera.GetAttributeObject():SetField("FarPlane", 420);
		
		-- set sky parameters
		local att = ParaScene.GetAttributeObjectSky()
		att:SetField("SkyFogAngleFrom", -0.03);
		att:SetField("SkyFogAngleTo", 0.2);
		att:SetField("SkyColor", {255/255, 255/255, 255/255});
		
		-- mid noon
		local att = ParaScene.GetAttributeObjectSunLight();
		att:SetField("DayLength", 10000);
		att:SetField("TimeOfDaySTD", 0.35);
		att:SetField("MaximumAngle", 1.5);
		att:SetField("AutoSunColor", false)
		att:SetField("Ambient", {149/255, 149/255, 149/255});
		att:SetField("Diffuse", {255/255, 255/255, 255/255});
	end
	
	MyCompany.Taurus.Desktop.Show();
	MyCompany.Taurus.Desktop.MiniMap.InitMiniMap()
	
end


function MyCompany.Taurus.EnterICadWorld(app, commandName, params)
	
	
	-- Our custom load world function
	if(type(params) ~= "table") then return end
	params.worldpath = "worlds/MyWorlds/iCadWorld";
	if(params.worldpath == nil or params.worldpath == "") then
		-- load the command line world or just the default chat world. 
		local cmdParams = GetURLCmds(ParaEngine.GetAppCommandLine());
		params.worldpath = cmdParams[1] or "worlds/MyWorlds/flatgrassland"
		params.movie = cmdParams.movie;
	end
	--if(not ParaIO.DoesAssetFileExist(params.worldpath, true)) then
	-- [string "script/apps/Taurus/app_main.lua"]:262: attempt to call field 'DoesAssetFileExist' (a nil value) <Runtime error>
	if(not ParaIO.DoesFileExist(params.worldpath, true)) then
		commonlib.log(params.worldpath.." does not exist\n")
		-- TODO: if the world is not downloaded or does not exist, use a default world and download in the background. 
		params.worldpath = "worlds/MyWorlds/flatgrassland";
	end
		
	ParaNetwork.EnableNetwork(false, "","");
	local res = System.LoadWorld({
			worldpath = params.worldpath,
			-- use exclusive desktop mode
			bExclusiveMode = true,
			--OnProgress = function(percent)
				--commonlib.echo({loading_percent = percent});
			--end
		})
	params.res = res;
	if(res == true) then
		-- switch to Taurus app_main desktop and make it default.
		System.UI.AppDesktop.SetDefaultApp("Taurus_GUID", true);
			
		System.User.SetRole("administrator");
			
		-- set model
		if(System.options.layout == "iCad") then
			ParaScene.GetPlayer():ToCharacter():ResetBaseModel(ParaAsset.LoadParaX("", "character/test/Toumingren.x"));
		end

		-- NOTE LiXizhi: 2009.7.30: Remove this in release build. 
		-- for testing purposes we will start the game server and force connecting to it
		local test_using_local_game_server = false;
		if(test_using_local_game_server) then
			NPL.load("(gl)script/apps/GameServer/GSL.lua");
				
			-- start the game server on the local machine
			local worker = NPL.CreateRuntimeState("world1", 0);
			worker:Start();
			NPL.activate("(world1)script/apps/GameServer/GSL_system.lua", {type="restart", config={nid="localhost", ws_id="world1"}});
				
			NPL.StartNetServer("127.0.0.1", "60001");
			NPL.LoadPublicFilesFromXML();
				
			NPL.AddNPLRuntimeAddress({host = "127.0.0.1", port = "60002", nid = "gs1",});
				
			Map3DSystem.User.nid = tostring(math.floor(ParaGlobal.GetGameTime()*1000)%100000);
				
			commonlib.applog("TODO: remove this in release build: connecting to local game server, ...")
			local run_gs_locally = false;
			if(run_gs_locally) then
				while(NPL.activate("localhost:script/apps/GameServer/test/accept_any.lua", {user_nid = Map3DSystem.GSL.GetNID(), callback=[[Map3DSystem.GSL_client:LoginServer("localhost", "world1");]]})~=0) do end
			else
				while(NPL.activate("gs1:script/apps/GameServer/test/accept_any.lua", {user_nid = Map3DSystem.GSL.GetNID()})~=0) do end
				ParaEngine.Sleep(0.5);
				Map3DSystem.GSL_client:LoginServer("gs1", "world1");
			end	
			commonlib.applog("local game server connected")
		end
			
	elseif(type(res) == "string") then
		-- show the error message
		_guihelper.MessageBox(res);
	end
end

function MyCompany.Taurus.OnLoadICadWorld()
	-- enable sound
	ParaAudio.SetVolume(1);

	-- apply effect settings
	Map3DSystem.world:ApplyEditorAttributes();

	-- set the enviroment params only for haqitown worlds
	local worldpath = ParaWorld.GetWorldDirectory();

	--hide terrain
	att=ParaTerrain.GetAttributeObject();
	att:SetField("RenderTerrain",false);		

	--disable fog
	local att = ParaScene.GetAttributeObject();
	local FarPlane = tonumber(ParaEngine.GetAttributeObject():GetDynamicField("ViewDistance", 800));
	att:SetField("FogEnd", 800);
	att:SetField("FogStart", 799);
	att:SetField("FogColor",{70/255,70/255,70/255});
	ParaCamera.GetAttributeObject():SetField("FarPlane", 800);

	--render a grid in the center
	local asset = ParaAsset.LoadStaticMesh("","ReferenceGrid.iges")
	local obj = ParaScene.CreateMeshPhysicsObject("igesTest", asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
	obj:SetPosition(ParaScene.GetPlayer():GetPosition());
	obj:GetAttributeObject():SetField("progress",1);
	ParaScene.Attach(obj);

	MyCompany.Taurus.Desktop.Show();
	MyCompany.Taurus.Desktop.MiniMap.InitMiniMap()

	ParaScene.GetPlayer():ToCharacter():ResetBaseModel(ParaAsset.LoadParaX("", "character/test/Toumingren.x"));
end



-- user clicks to register
function MyCompany.Taurus.OnUserRegister(btnName, values, bindingContext)
	local L = CommonCtrl.Locale("ParaWorld");
	if(btnName == "register") then
		local errormsg = "";
		-- validate name
		if(string.len(values.username)<3) then
			errormsg = errormsg..L"名字太短了\n"
		end
		-- validate password
		if(string.len(values.password)<6) then
			errormsg = errormsg..L"密码太短了\n"
		elseif(values.password~=values.password_confirm) then
			errormsg = errormsg..L"确认密码与密码不一致\n"
		end
		-- validate email
		values.email = string.gsub(values.email, "^%s*(.-)%s*$", "%1")
		if(not string.find(values.email, "^%s*[%w%._%-]+@[%w%.%-]+%.[%a]+%s*$")) then
			errormsg = errormsg..L"Email地址格式不正确\n"
		end
		if(errormsg~="") then
			paraworld.ShowMessage(errormsg)
		else
			local msg = {
				-- is this app key needed?
				appkey = "fae5feb1-9d4f-4a78-843a-1710992d4e00",
				username = values.username,
				password = values.password,
				email = values.email,
				referrer = values.referrer,
			};
			paraworld.ShowMessage(L"正在连接注册服务器, 请等待")
			paraworld.users.Registration(msg, "login", function(msg)
				if(paraworld.check_result(msg, true)) then
					paraworld.ShowMessage(L"恭喜！注册成功！\n 请您查收Email激活您的登录帐号.");
					-- start login procedure
					--NPL.load("(gl)script/kids/3DMapSystemApp/Login/LoginProcedure.lua");
					--Map3DSystem.App.Login.Proc_Authentication(values);
				end	
			end);
		end
	end
end
-------------------------------------------
-- client world database function helpers.
-------------------------------------------

------------------------------------------
-- all related messages
------------------------------------------
-----------------------------------------------------
-- APPS can be invoked in many ways: 
--	Through app Manager 
--	mainbar or menu command or buttons
--	Command Line 
--  3D World installed apps
-----------------------------------------------------
function MyCompany.Taurus.MSGProc(window, msg)
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == System.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		MyCompany.Taurus.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == System.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		MyCompany.Taurus.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == System.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = MyCompany.Taurus.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == System.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		MyCompany.Taurus.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == System.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		MyCompany.Taurus.OnRenderBox(msg.mcml);
		
	elseif(msg.type == System.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		MyCompany.Taurus.Navigate();
	
	elseif(msg.type == System.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		MyCompany.Taurus.GotoHomepage();
	
	elseif(msg.type == System.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		MyCompany.Taurus.DoQuickAction();
	
	elseif(msg.type == System.App.MSGTYPE.APP_ACTIVATE_DESKTOP) then
		MyCompany.Taurus.OnActivateDesktop();
		
	elseif(msg.type == System.App.MSGTYPE.APP_DEACTIVATE_DESKTOP) then
		MyCompany.Taurus.OnDeactivateDesktop();
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_WORLD_LOAD) then
		-- called whenever a new world is loaded (just before the 3d scene is enabled, yet after world data is loaded). 
		if(System.options.layout == "iCad")then
			MyCompany.Taurus.OnLoadICadWorld();
		else
			MyCompany.Taurus.OnWorldLoad();
		end
		  
		
	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end