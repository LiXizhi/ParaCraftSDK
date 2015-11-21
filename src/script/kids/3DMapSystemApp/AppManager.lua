--[[
Title: Managing the loading, unloading and message dispatching for all applications. 
Author(s): LiXizhi
Date: 2008/1/1
Desc: 
ParaEngine's APP IDE features a number of targeted, programmable object models. By using these models, you can access the underlying components and events.
Each model contains types and members that represent worlds, mainbar, menus, events, user profiles, 3D objects, and more. 
Consequently, you can extend the functionality of the IDE, and integrate other applications into the IDE to increase the fun and social interactions among users. 

Feature Highlights:
- App Registration: Map3DSystem.App.Registration manages application registration and unregistration. One can use XML files (IP.xml) to define the registration settings for add-ins. See also [SampleIP.XML]
- Application Template Wizard: Create a new application by using the solution manager in the .Net IDE or by duplicating and editing the [BaseApp.lua] file. 
- Map3DSystem.UI.MainBar and Map3DSystem.UI.MainMenu:  Host your custom commands as buttons in the MainBar and MainMenu.
- Map3DSystem.UI.Windows.RegisterWindowFrame:  makes it easier to create your own custom windows that host your application UI in various window styles like modal dialog, resizable window, toolbar, etc. 
- TODO: now enables you to specify the style of a button, such as text only, icon only, or text and icon. You can also create additional types of controls to place in the toolbars and menus, such as listbox controls, editbox controls, and drop-down menu controls.
- Localization: On the one time init of connection event, app can retrieve the current IDE's language settings by calling ParaEngine.GetLocale(). The app can then use different resource files for different language. 
- Application add-in Security: One can change global application addin security settings:
	Allow add-in components to load.   Checked by default. When checked, add-ins are allowed to load from local disk or from a ParaEngine trusted website.
	Allow add-in components to load from a URL.   Unchecked by default. When checked, add-ins are allowed to be loaded from external Web sites. Even checked, the installation of the external app still needs user confirmation. 
- programmable components models: the NPL source code and doc as well as all open source offical applications provide overview and examples of programmable components models that a third party application can use. 
	- please note Application code is executed in a sandbox where some IO and log functions may be limited to certain folders.  
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/AppManager.lua");
------------------------------------------------------------
]]

if(not Map3DSystem.App.AppManager) then Map3DSystem.App.AppManager={}; end

-- requires
NPL.load("(gl)script/ide/os.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/AppHelper.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/AppRegistration.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/BaseApp.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/app.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/API/ParaworldAPI.lua");
--------------------------------------
-- app security setting
--------------------------------------
if(not Map3DSystem.App.Security) then Map3DSystem.App.Security={}; end
Map3DSystem.App.Security.AllowTrustedAddin = true;
Map3DSystem.App.Security.AllowExternalAddin = nil;

--------------------------------------
-- app manager class
-- pipeline: AppManager.Startup(),  For each world( AppManager.SetupUI(), LoadWorld, AppManager.LoadUserProfile(), play),  AppManager.Shutdown()
-------------------------------------

-- this function is called when IDE starts up. 
function Map3DSystem.App.AppManager.Startup()
	if(Map3DSystem.App.AppManager.IsStarted) then
		return
	end
	Map3DSystem.App.AppManager.IsStarted = true;
	
	-- connect to all applications in the app registration db
	local db = Map3DSystem.App.Registration.ConnectToAppDB();
	if(db ~= nil) then
		local cmd = string.format("SELECT * FROM apps ORDER BY listorder ASC");
		local row;
		for row in db:rows(cmd) do
			Map3DSystem.App.AppManager.StartupApp(row)
		end
	end
end

-- startup only the given app. 
-- @param row: the database app record. You can get it from database or create it manually. 
function Map3DSystem.App.AppManager.StartupApp(row)
	local app={};
	app.UserAdded = row.UserAdded;
	if(app.UserAdded~=nil) then
		if(type(app.UserAdded) == "number") then
			app.UserAdded = (app.UserAdded>0);
		else
			app.UserAdded = (app.UserAdded ~= "false")
		end	
	end	
	
	app.app_key = row.app_key;
	app.name = row.name;
	app.version = row.version;
	app.onloadscript = row.onloadscript;
	app.callbackfunction = row.callbackfunction;
	app.lang = row.lang;
	app.packageList = row.packageList;
	app.ConnectionStatus = Map3DSystem.App.AppManager.ConnectionStatus.NotLoaded;
	
	---- NOTE 2009/12/19: mark with debug app loaded if the app.callbackfunction is a debug app callback
	--if(ParaIO.DoesFileExist("script/kids/3DMapSystemApp/DebugApp/whosyourdaddy.mom")) then
		--Map3DSystem.App.AppManager.isDebugAppLoaded = true;
	--else
		--if(string.find(string.lower(app.callbackfunction), "debug")) then
			--Map3DSystem.App.AppManager.isDebugAppRemoved = true;
			--return;
		--end
	--end
	
	if(Map3DSystem.App.AppManager.GetApp(app.app_key) == nil ) then
		-- create and add the application to the app manager
		app = Map3DSystem.App.AppManager.app:new(app);
		Map3DSystem.App.AppManager.AddApp(app.app_key, app);
		
		if(app.onloadscript~=nil and app.onloadscript~="") then
			-- load onload script: it contains the definition of app.callbackfunction
			NPL.load(app.onloadscript);
		end
		-- convert string to NPL function pointer
		if(type(app.callbackfunction) == "string") then
			app.callbackfunction = commonlib.getfield(app.callbackfunction);
		end
		-- connect to app: one time initialization. 
		if(app.UserAdded) then
			app:Connect(Map3DSystem.App.ConnectMode.Startup);
		end
		return app;
	else
		LOG.std("", "warning", "app", "app \"%s\" already loaded. could it be two apps share the same key?\n", app.name);
	end
end

-- call the render box function for all applications that is in the user profile or the current world's app attributes
-- @param userProfile: mcml table. 
function Map3DSystem.App.AppManager.LoadUserProfile(userProfile)
	-- for each app in userProfile do
	--	Map3DSystem.App.AppManager.LoadRenderBox
	--	Map3DSystem.App.AppManager.LoadActionFeed
	--	Map3DSystem.App.AppManager.LoadInventory
	-- end
end

function Map3DSystem.App.AppManager.LoadRenderBox(userProfile)
	-- TODO: 
end

function Map3DSystem.App.AppManager.LoadActionFeed(userProfile)
	-- TODO: 
end

function Map3DSystem.App.AppManager.LoadInventory(userProfile)
	-- TODO: 
end

-- send APP_WORLD_LOAD msg for each installed application, whenever a new world is loaded (just before the 3d scene is enabled, yet after world data is loaded). 
-- per-world attributes is available here. This message is sent before APP_RENDER_BOX. 
-- e.g. the CCS (character app) changes the avatar to the user defined avatar in this place just before the world show up. 
-- Synchronous preprocessing code can also take place here,since there will be a progress bar informing the world loading progress. 
function Map3DSystem.App.AppManager.OnWorldLoad()
	local app_key, app;
	local msg = {type = Map3DSystem.App.MSGTYPE.APP_WORLD_LOAD, };
	for app_key, app in pairs(Map3DSystem.App.AppManager.applist) do
		if(app.UserAdded) then
			msg.app = app;
			app:SendMessage(msg);
		end
	end
end

-- send APP_WORLD_CLOSING msg is for each installed application, whenever a world is being closed. 
-- However, the application can set msg.DisableClosing = true to disallow closing, such as asking the user to save the world. 
-- @return: true if any app disallow closing
function Map3DSystem.App.AppManager.OnWorldClosing()
	local app_key, app;
	local msg = {type = Map3DSystem.App.MSGTYPE.APP_WORLD_CLOSING, DisableClosing = nil};
	for app_key, app in pairs(Map3DSystem.App.AppManager.applist) do
		if(app.UserAdded) then
			msg.app = app;
			app:SendMessage(msg);
			-- no longer need to call following apps if current one disallow closing
			if(msg.DisableClosing) then
				break;
			end
		end	
	end
	return msg.DisableClosing
end

-- send APP_WORLD_CLOSING msg for each installed application, whenever a world is being closed. 
-- However, the application can set msg.DisableClosing = true to disallow closing, such as asking the user to save the world. 
-- @return: true if APP_WORLD_CLOSED message are sent to all application
function Map3DSystem.App.AppManager.OnWorldClosed()
	local app_key, app;
	local msg = {type = Map3DSystem.App.MSGTYPE.APP_WORLD_CLOSED, };
	for app_key, app in pairs(Map3DSystem.App.AppManager.applist) do
		if(app.UserAdded) then
			msg.app = app;
			app:SendMessage(msg);
		end	
	end
	return true;
end

-- send APP_WORLD_CLOSING msg for each installed application, whenever a world is being closed. 
-- However, the application can set msg.DisableClosing = true to disallow closing, such as asking the user to save the world. 
-- @return: true if APP_WORLD_CLOSED message are sent to all application
function Map3DSystem.App.AppManager.OnWorldClosed()
	local app_key, app;
	local msg = {type = Map3DSystem.App.MSGTYPE.APP_WORLD_CLOSED, };
	for app_key, app in pairs(Map3DSystem.App.AppManager.applist) do
		if(app.UserAdded) then
			msg.app = app;
			app:SendMessage(msg);
		end	
	end
	return true;
end

-- send APP_CONNECTION_ESTABLISHED msg for each installed application, whenever the connection is been established
-- @return: true if APP_CONNECTION_ESTABLISHED message are sent to all application
function Map3DSystem.App.AppManager.OnConnectionEstablished(nid)
	local app_key, app;
	local msg = {type = Map3DSystem.App.MSGTYPE.APP_CONNECTION_ESTABLISHED, nid = nid };
	for app_key, app in pairs(Map3DSystem.App.AppManager.applist) do
		if(app.UserAdded) then
			msg.app = app;
			app:SendMessage(msg);
		end	
	end
	return true;
end

-- send APP_CONNECTION_DISCONNECTED msg for each installed application, whenever the connection is been lost
-- @return: true if APP_CONNECTION_DISCONNECTED message are sent to all application
function Map3DSystem.App.AppManager.OnConnectionDisconnected(nid,reason)
	local app_key, app;
	local msg = {type = Map3DSystem.App.MSGTYPE.APP_CONNECTION_DISCONNECTED, nid = nid, reason = reason};
	for app_key, app in pairs(Map3DSystem.App.AppManager.applist) do
		if(app.UserAdded) then
			msg.app = app;
			app:SendMessage(msg);
		end	
	end
	return true;
end

-- call this function to setup UI of all currently loaded applications. 
-- it will also add homepage icons to mainmenu for all user added applications. 
function Map3DSystem.App.AppManager.SetupUI()
	local app_key, app;
	for app_key, app in pairs(Map3DSystem.App.AppManager.applist) do
		if(app.ConnectionStatus == Map3DSystem.App.AppManager.ConnectionStatus.Loaded) then
			app:SendMessage({type = Map3DSystem.App.MSGTYPE.APP_CONNECTION, app = app, connectMode = Map3DSystem.App.ConnectMode.UI_Setup});
		end
		if(app.UserAdded and not app.HideHomeButton and not DenyHomeButton)  then
			-- add this application's homepage command button to the main menu's app folder. 
			-- create a command name with "home." and application key
			local commandName = "home."..app.app_key;
			local command = Map3DSystem.App.Commands.GetCommand(commandName);
			if(command == nil) then
				command = Map3DSystem.App.Commands.AddNamedCommand(
					{name = commandName,app_key = app.app_key, ButtonText = app.HomeButtonText or app.name, icon = app.icon,});
				-- add command to mainmenu control at folder "Profile.app." plus app_key(replacing non alphanumerical name and dot with _)
				local pos_category = string.gsub(app.app_key, "%W", "_");
				pos_category = "Profile.app."..pos_category;
				command:AddControl("mainmenu", pos_category);
			end
		end
	end
end

-- this function is called when IDE is shut down
function Map3DSystem.App.AppManager.Shutdown()
	-- disconnect all loaded applications. 
	local app_key, app;
	for app_key, app in pairs(Map3DSystem.App.AppManager.applist) do
		if(app.ConnectionStatus == Map3DSystem.App.AppManager.ConnectionStatus.Loaded) then
			app:Disconnect(Map3DSystem.App.DisconnectMode.HostShutdown);
		end
	end
end

--------------------------------------
-- app list
--------------------------------------
if(not Map3DSystem.App.AppManager.applist) then Map3DSystem.App.AppManager.applist = {}; end

-- how an application is currently connected with the IDE. 
Map3DSystem.App.AppManager.ConnectionStatus = {
	-- application is not loaded. and should be loaded at properly time without the need of user confirmation. 
	NotLoaded = nil,
	-- loaded application
	Loaded = 1,
	-- locked. 
	Locked = 2,
	-- downloading from remote server
	Downloading = 3,
	--  User needs to confirm in order for this application to be loaded or added. This usually happens when a new application is successfully downloaded from the server. 
	RequestUserConfirm = 4,
}


-- add app to manager
function Map3DSystem.App.AppManager.AddApp(app_key, app)
	Map3DSystem.App.AppManager.applist[app_key] = app;
end

-- get app structure by its app_key
function Map3DSystem.App.AppManager.GetApp(app_key)
	if(app_key==nil) then
		app_key = Map3DSystem.UI.AppDesktop.GetCurDesktopappkey()
	end
	if(app_key) then
		return Map3DSystem.App.AppManager.applist[app_key];
	end	
end

-- return an iterator of (app_key, app) pairs. 
function Map3DSystem.App.AppManager.GetNextApp ()
	return pairs(Map3DSystem.App.AppManager.applist)
end

