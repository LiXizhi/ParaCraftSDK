--[[
Title: Debug app for Paraworld
Author(s): LiXizhi
Date: 2008/1/21
Desc: Hot Key supported is implemented by Leio. See config/commands.xml, to edit shortcut key, use page "script/ide/KeyboardShortcut/KeyboardShortcut_page.html"
db registration insert script
INSERT INTO apps VALUES (NULL, 'Debug_GUID', 'Debug', '1.0.0', 'http://www.paraengine.com/apps/Debug_v1.zip', 'YourCompany', 'enUS', 'script/kids/3DMapSystemApp/DebugApp/IP.xml', '', 'script/kids/3DMapSystemApp/DebugApp/app_main.lua', 'Map3DSystem.App.Debug.MSGProc', 1);
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/DebugApp/app_main.lua");
------------------------------------------------------------
]]

-- requires
NPL.load("(gl)script/apps/Aries/KeySettings.lua");
local KeySettings = commonlib.gettable("MyCompany.Aries.Desktop.KeySettings");
if(KeySettings.LoadSettings) then
	KeySettings.LoadSettings();
end

-- create class
local Debug = commonlib.gettable("Map3DSystem.App.Debug");


-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of Map3DSystem.App.ConnectMode. 
function Map3DSystem.App.Debug.OnConnection(app, connectMode)
	if(connectMode == Map3DSystem.App.ConnectMode.UI_Setup) then
		-- TODO: place your UI (menus,toolbars, tool buttons) through which the user will communicate to the app
		-- e.g. MainBar.AddItem(), MainMenu.AddItem().
		
		-- e.g. Create a Debug command link in the main menu 
		local commandName = "Help.Debug";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command) then
			-- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			command:AddControl("mainmenu", commandName, 1);
		end
		
		commandName = "Help.TestConsole";
		command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command) then
			-- add command to mainmenu control, using the same folder as commandName. But you can use any folder you like
			command:AddControl("mainmenu", commandName, 2);
		end
	else
		-- TODO: place the app's one time initialization code here.
		-- during one time init, its message handler may need to update the app structure with static integration points, 
		-- i.e. app.about, HomeButtonText, HomeButtonText, HasNavigation, NavigationButtonText, HasQuickAction, QuickActionText,  See app template for more information.
		-- e.g. 


		Map3DSystem.App.Debug.app = app; -- keep a reference
		app.HideHomeButton = true;
		app.icon = "Texture/3DMapSystem/common/script_gear.png"
		app.about =  "debugging NPL applications"
		
		local hook = CommonCtrl.os.hook.SetWindowsHook({hookType=CommonCtrl.os.hook.HookType.WH_CALLWNDPROC, 
		callback = Map3DSystem.App.Debug.OnKeyDownProc, hookName = "Debug", appName="input", wndName = "key_down"});
		-------------------------------------------------------
		-- 快捷键
		-------------------------------------------------------
		-- e.g. Create a Debug command link in the main menu 
		local commandName = "Help.Debug";
		local command = Map3DSystem.App.Commands.GetCommand(commandName);
		if(command == nil) then
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "调试 Debug(F12)", icon = "Texture/3DMapSystem/common/script_gear.png", });
		
			commandName = "Help.TestConsole";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "测试(TestConsole) ", icon = "Texture/3DMapSystem/common/monitor.png", });
				
			commandName = "Help.TogglePerf";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Toggle Perf", icon = "Texture/3DMapSystem/common/monitor.png", });	
			
			commandName = "Help.ToggleCodePerf";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Toggle Code NPL Perf", icon = "Texture/3DMapSystem/common/monitor.png", });

			commandName = "Help.ToggleNPLPerf";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Toggle NPL Perf", icon = "Texture/3DMapSystem/common/monitor.png", });		

			commandName = "Help.ToggleMiniSceneStats";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Toggle ToggleMiniSceneStats", icon = "Texture/3DMapSystem/common/monitor.png", });	
				
			commandName = "Help.DebugPause";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Debug(Pause)", icon = "Texture/3DMapSystem/common/monitor.png", });			
			
			commandName = "Help.ToggleWireFrame";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Toggle Wire Frame", icon = "Texture/3DMapSystem/common/monitor.png", });		
				
			commandName = "Help.ToggleReportAndBoundingBox";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Toggle report and bounding box", icon = "Texture/3DMapSystem/common/monitor.png", });			
			
			commandName = "Help.TogglePhysicsDebugDraw";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Toggle Physics Debug Draw", icon = "Texture/3DMapSystem/common/monitor.png", });			
				
			commandName = "Help.InspectGUIAtCursor";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Inspect GUI At Cursor", icon = "Texture/3DMapSystem/common/monitor.png", });

			commandName = "Help.ToggleGUI";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Toggle All GUI", icon = "Texture/3DMapSystem/common/monitor.png", });
				
			commandName = "Help.DumpClientNetMsg";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Toggle Dump Network Messages", icon = "Texture/3DMapSystem/common/monitor.png", });
								
			commandName = "Help.EditKeyboardShortCut";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Edit key board short cut key", });	

			-- CYF 2010年11月17日
			commandName = "Help.APITest";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "测试(APITest) ", icon = "Texture/3DMapSystem/common/monitor.png", });
				
			-- 2013/7/4 MobCCSAsset and deck
			commandName = "Help.GetMyCCSInfo";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "Get my ccs info", });	
			commandName = "Help.GetMyDeckInfo";	
			command = Map3DSystem.App.Commands.AddNamedCommand(
				{name = commandName,app_key = app.app_key, ButtonText = "get my deck info", });	
		end
	
	end
end
function Map3DSystem.App.Debug.DoLoadConfigFile()
	NPL.load("(gl)script/ide/KeyboardShortcut/KeyboardShortcut.lua");
	Map3DSystem.App.Debug.Commands_Key_List = CommonCtrl.KeyboardShortcut.DoParseFile();
	if(Map3DSystem.App.Debug.Commands_Key_List)then
		local mapping = {};
		local k,item;
		for k,item in ipairs(Map3DSystem.App.Debug.Commands_Key_List) do
			local key = item["ShortcutKey"];
			-- 转换为小写
			key = string.lower(key);
			mapping[key] = item;
		end
		Map3DSystem.App.Debug.Commands_Key_List_Mapping = mapping;
	end
end
-- Receives notification that the Add-in is being unloaded.
function Map3DSystem.App.Debug.OnDisconnection(app, disconnectMode)
	if(disconnectMode == Map3DSystem.App.DisconnectMode.UserClosed or disconnectMode == Map3DSystem.App.DisconnectMode.WorldClosed)then
		-- TODO: remove all UI elements related to this application, since the IDE is still running. 
		
		-- e.g. remove command from mainbar
		local command = Map3DSystem.App.Commands.GetCommand("Help.Debug");
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
-- @param statusWanted: what status of the command is queried. it is of type Map3DSystem.App.CommandStatusWanted
-- @return: returns according to statusWanted. it may return an integer by adding values in Map3DSystem.App.CommandStatus.
function Map3DSystem.App.Debug.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == Map3DSystem.App.CommandStatusWanted) then
		-- TODO: return an integer by adding values in Map3DSystem.App.CommandStatus.
		if(commandName == "Help.Debug" or commandName == "Help.TestConsole") then
			-- return enabled and supported 
			return (Map3DSystem.App.CommandStatus.Enabled + Map3DSystem.App.CommandStatus.Supported)
		end
	end
end

-- This is called when the command is invoked.The Exec is fired after the QueryStatus event is fired, assuming that the return to the statusOption parameter of QueryStatus is supported and enabled. 
-- This is the event where you place the actual code for handling the response to the user click on the command.
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
function Map3DSystem.App.Debug.OnExec(app, commandName, params)
	if(commandName == "Help.Debug") then
		-- TODO: actual code of processing the command goes here. 
		-- e.g.
		NPL.load("(gl)script/kids/3DMapSystemApp/DebugApp/DebugWnd.lua");
		Map3DSystem.App.Debug.ShowDebugWnd(app._app);
	elseif(commandName == "Help.TestConsole") then
		NPL.load("(gl)script/kids/3DMapSystemApp/DebugApp/TestConsoleWnd.lua");
		Map3DSystem.App.Debug.ShowTestConsoleWnd(app._app);	
	elseif(commandName == "Help.TogglePerf") then		
		-- toggle profiling, the profile file will be generated at perf.txt at SDK root directory. 
		local checked = not ParaEngine.GetAttributeObject():GetField("EnableProfiling", false);
		ParaEngine.GetAttributeObject():SetField("EnableProfiling", checked);
	elseif(commandName == "Help.ToggleNPLPerf") then		
		-- toggle NPL profiling
		NPL.load("(gl)script/ide/profiler.lua");
		commonlib.npl_profiler.ToggleProfiling();
	elseif(commandName == "Help.ToggleCodePerf") then		
		-- toggle NPL profiling
		NPL.load("(gl)script/ide/Debugger/NPLProfiler.lua");
		-- turn on/off perf
		commonlib.npl_profiler.perf_enable();
		commonlib.npl_profiler.perf_show(nil, true);
	elseif(commandName == "Help.ToggleMiniSceneStats") then		
		-- toggle mini scene stats. 
		NPL.load("(gl)script/ide/MinisceneManager.lua");
		CommonCtrl.MinisceneManager.ShowStatsOnUI(true);
	elseif(commandName == "Help.DebugPause") then			
		NPL.load("(gl)script/ide/Debugger/ConsoleDebugger.lua");
		pause();
	elseif(commandName == "Help.ToggleWireFrame") then		
		ParaScene.GetAttributeObject():SetField("UseWireFrame", not ParaScene.GetAttributeObject():GetField("UseWireFrame", false));
	elseif(commandName == "Help.ToggleReportAndBoundingBox") then			
		-- toggle report/bounding box
		ParaScene.GetAttributeObject():SetField("ShowBoundingBox", not ParaScene.GetAttributeObject():GetField("ShowBoundingBox", false));
		ParaScene.GetAttributeObject():SetField("GenerateReport", not ParaScene.GetAttributeObject():GetField("GenerateReport", false));
	elseif(commandName == "Help.TogglePhysicsDebugDraw") then
		local nLastMode = ParaScene.GetAttributeObject():GetField("PhysicsDebugDrawMode", 0)
		if(nLastMode == 0) then 
			nLastMode = -1;
		else
			nLastMode = 0;
		end
		ParaScene.GetAttributeObject():SetField("PhysicsDebugDrawMode", nLastMode);
		
	elseif(commandName == "Help.InspectGUIAtCursor") then	
		-- gui inspection
		CommonCtrl.GUI_inspector_simple.InspectUI();
	elseif(commandName == "Help.ToggleGUI") then	
		-- gui toggle GUI
		ParaUI.GetUIObject("root").visible = not ParaUI.GetUIObject("root").visible;
	elseif(commandName == "Help.DumpClientNetMsg") then	
		-- toggle client side net work dump messages. 
		local client = commonlib.gettable("GameServer.rest.client")
		local bWriteOn = not client.debug_stream;
		if(type(params) == "boolean") then
			bWriteOn = params;
		end
		
		client.debug_stream = bWriteOn;
		local GSL = commonlib.gettable("Map3DSystem.GSL");
		GSL.dump_client_msg = bWriteOn;
		
		local jabber_client = commonlib.gettable("GameServer.jabber.client");
		jabber_client.debug_stream = bWriteOn;
		
		local on_off;
		if(bWriteOn) then
			on_off = "ON"
		else
			on_off = "OFF"
		end	
			
		_guihelper.MessageBox(string.format([[Net work log is %s. One can find rest log in log/rest*.log. GSL log in log/GSL*.log. Jabber log in log/jabber*.log]], on_off));
		
	elseif(commandName == "Help.EditKeyboardShortCut") then		
		-- edit shortcut keys. 
		Map3DSystem.App.Commands.Call("File.MCMLWindowFrame", {
			url="script/ide/KeyboardShortcut/KeyboardShortcut_page.html", 
			name="Login.Wnd", 
			app_key=app.app_key, 
			text = "Edit Key Board Short Cut Keys",
			zorder=3,
			directPosition = true,
				align = "_ct",
				x = -600/2,
				y = -500/2,
				width = 600,
				height = 500,
		});
	elseif(app:IsHomepageCommand(commandName)) then
		Map3DSystem.App.Debug.GotoHomepage();
	elseif(app:IsNavigationCommand(commandName)) then
		Map3DSystem.App.Debug.Navigate();
	elseif(app:IsQuickActionCommand(commandName)) then	
		Map3DSystem.App.Debug.DoQuickAction();
	elseif(commandName == "Help.APITest") then  -- CYF 2010年11月17日
		NPL.load("(gl)script/test/APITest.lua");
		Map3DSystem.App.Debug.ShowAPITestConsoleWnd(app._app);
		
	elseif(commandName == "Help.GetMyCCSInfo") then  -- andy 2013/7/4
		if(SystemInfo.GetField("name") == "Aries") then -- for aries only
			local str = Map3DSystem.UI.CCS.GetCCSInfoString();
			ParaMisc.CopyTextToClipboard(str);
			local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
			BroadcastHelper.PushLabel({id="Help_GetMyCCSInfo_tip", label = "CCSinfo复制到剪切板", max_duration=3000, color = "255 0 0", scaling=1, bold=true, shadow=true,});
		end
	elseif(commandName == "Help.GetMyDeckInfo") then  -- andy 2013/7/4
		if(SystemInfo.GetField("name") == "Aries") then -- for aries only
			local MyCardsManager = commonlib.gettable("MyCompany.Aries.Inventory.Cards.MyCardsManager");
			local Combat = commonlib.gettable("MyCompany.Aries.Combat");
			local deck_struct = MyCardsManager.GetLocalCombatBag();
			local rune_struct = MyCardsManager.GetLocalRuneBag();
			local cards_str = "";
			local deck_struct_internal = {};
			local _, pair;
			for _, pair in pairs(deck_struct) do
				local gsid = pair.gsid;
				if(gsid > 0) then
					deck_struct_internal[gsid] = (deck_struct_internal[gsid] or 0) + 1;
				end
			end
			local gsid, count;
			for gsid, count in pairs(deck_struct_internal) do
				cards_str = cards_str..string.format([[(%d+%d)]], gsid, count);
			end
			local _, pair;
			for _, pair in pairs(rune_struct) do
				if(pair.gsid > 0) then
					cards_str = cards_str..string.format([[(%d+%d)]], pair.gsid, 100);
				end
			end
			
			ParaMisc.CopyTextToClipboard(cards_str);
			local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
			BroadcastHelper.PushLabel({id="Help_GetMyDeckInfo_tip", label = "deck信息复制到剪切板", max_duration=3000, color = "255 0 0", scaling=1, bold=true, shadow=true,});
		end
	end
end

-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function Map3DSystem.App.Debug.OnRenderBox(mcmlData)
end


-- called when the user wants to nagivate to the 3D world location relavent to this application
function Map3DSystem.App.Debug.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function Map3DSystem.App.Debug.GotoHomepage()
end

-- called when user clicks the quick action for this application. 
function Map3DSystem.App.Debug.DoQuickAction()
end

-------------------------------------------
-- client world database function helpers.
-------------------------------------------

------------------------------------------
-- all related messages
------------------------------------------

-- key down callback. Hook for F12, Ctrl+F6, Ctrl+F2 key
function Map3DSystem.App.Debug.OnKeyDownProc(nCode, appName, msg)
	-- return the nCode to be passed to the next hook procedure in the hook chain. 
	-- in most cases, if nCode is nil, the hook procedure should do nothing. 
	if(nCode==nil) then return end
	if(KeySettings.IsVisible and KeySettings:IsVisible())then return end

	if(CommonCtrl.KeyboardShortcut and not CommonCtrl.KeyboardShortcut.isOpened)then
		local ctrl_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LCONTROL) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RCONTROL);
		local alt_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LMENU) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RMENU);
		local shift_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LSHIFT) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RSHIFT);
		local combine_key;
		local keys = {};
		if(ctrl_pressed)then
			keys[DIK_SCANCODE.DIK_LCONTROL] = DIK_SCANCODE.DIK_LCONTROL;
		end
		if(alt_pressed)then
			keys[DIK_SCANCODE.DIK_LMENU] = DIK_SCANCODE.DIK_LMENU;
		end
		if(shift_pressed)then
			keys[DIK_SCANCODE.DIK_LSHIFT] = DIK_SCANCODE.DIK_LSHIFT;
		end
		local dik_key = VirtualKeyToScaneCodeStr[msg.virtual_key];
		keys[dik_key] = DIK_SCANCODE[dik_key];
		combine_key = Debug.ConversionKey(keys)

		if(KeySettings.GetFunc) then
			local Dock = commonlib.gettable("MyCompany.Aries.Desktop.Dock");
			local commandName = KeySettings.GetFunc(combine_key);
			if(commandName and Dock.FireCmd)then
				Dock.FireCmd(commandName)
				return;
			end
		end

		if(combine_key and Debug.Commands_Key_List_Mapping)then
			combine_key = string.lower(combine_key);
			local item = Debug.Commands_Key_List_Mapping[combine_key];
			if(item)then
				local commandName = item["Text"];
				local params = item["params"];
				if(string.find(params,"{.-}"))then
					params = commonlib.LoadTableFromString(params);
				end
				-- NOTE: filter the command name that execute through shortcut
				local bAllowExec = true;
				--[[
				local filters = {"File.", "Scene.", "Help."};
				-- check for a hidden file dance_drum.lua
				if(not Map3DSystem.options.isAB_SDK) then
					local _, filter;
					for _, filter in pairs(filters) do
						if(string.find(commandName, filter) == 1) then
							bAllowExec = false;
							nCode = nil;
							break;
						end
					end
				end
				]]
				if(bAllowExec == true) then
					Map3DSystem.App.Commands.Call(commandName,params);
				else
					LOG.std(nil, "warn", "Debug", "command %s not allowed", commandName);
				end
			end
		end

	end
	return nCode
end

-- 返回组合键
function Map3DSystem.App.Debug.ConversionKey(keys)
	if(not keys)then return end
	local s = "";
	local ctrl_pressed;
	local alt_pressed;
	local shift_pressed;
	local char = "";
	local key,v;
	for key,v in pairs(keys) do
		if(v == DIK_SCANCODE.DIK_LCONTROL or v == DIK_SCANCODE.DIK_RCONTROL)then
			ctrl_pressed = true;
		elseif(v == DIK_SCANCODE.DIK_LMENU or v == DIK_SCANCODE.DIK_RMENU)then
			alt_pressed = true;
		elseif(v == DIK_SCANCODE.DIK_LSHIFT or v == DIK_SCANCODE.DIK_RSHIFT)then
			shift_pressed = true;
		else
			local __,__,__,_char = string.find(key,"(.+)_(.+)");
			char = _char;
		end
	end
	if(ctrl_pressed)then
		s = s.."Ctrl+";
	end
	if(alt_pressed)then
		s = s.."Alt+";
	end
	if(shift_pressed)then
		s = s.."Shift+";
	end
	if(char)then
		s = s..char;
	end
	return s;
end
-----------------------------------------------------
-- APPS can be invoked in many ways: 
--	Through app Manager 
--	mainbar or menu command or buttons
--	Command Line 
--  3D World installed apps
-----------------------------------------------------
function Map3DSystem.App.Debug.MSGProc(window, msg)
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == Map3DSystem.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		Map3DSystem.App.Debug.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		Map3DSystem.App.Debug.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = Map3DSystem.App.Debug.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		Map3DSystem.App.Debug.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		Map3DSystem.App.Debug.OnRenderBox(msg.mcml);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		Map3DSystem.App.Debug.Navigate();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		Map3DSystem.App.Debug.GotoHomepage();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		Map3DSystem.App.Debug.DoQuickAction();
	

	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end