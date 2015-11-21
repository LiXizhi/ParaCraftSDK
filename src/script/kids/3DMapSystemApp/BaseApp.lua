--[[
Title: Base class to all application. 
Author(s): LiXizhi
Date: 2007/12/28
Desc: One can see this file as an application API definition. Use the template script/templates/app_simple.lua
Map3DSystem.App object is the root object. It is literally a pointer to the IDE through which all other objects that are exposed by IDE are referenced. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/BaseApp.lua");
------------------------------------------------------------
]]

-- requires
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/kids/3DMapSystemApp/AppCommands.lua");

if(not Map3DSystem.App.BaseApp) then Map3DSystem.App.BaseApp={}; end

-- application predefined message types here 
Map3DSystem.App.MSGTYPE = {
	-- Receives notification that the app is being loaded.
	-- during one time init, its message handler may need to update the app structure with static integration points, 
	-- i.e. app.about, app.HomeButtonText, app.HasNavigation, app.HasQuickAction. See app template for more information.
	-- msg = {app [in/out], connectMode = Map3DSystem.App.ConnectMode }
	APP_CONNECTION = 501,
	-- Receives notification that the app is being unloaded.
	-- msg = {app, connectMode = Map3DSystem.App.DisconnectMode }
	APP_DISCONNECTION = 502,
	
	-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
	APP_NAVIGATION = 503,
	-- called when user clicks the quick action for this application. 
	APP_QUICK_ACTION = 504,
	-- called when user clicks to check out the homepage of this application. Homepage usually includes:
	-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
	APP_HOMEPAGE = 505,
	
	-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
	-- msg = {app, mcml = mcmlTable}
	APP_RENDER_BOX = 507,
	
	-- When the user clicks a command (menu or mainbar button), the QueryStatus event is fired. 
	-- The QueryStatus event returns the current status of the specified named command, whether it is enabled, disabled, 
	-- or hidden in the CommandStatus parameter, which is passed to the event by reference. 
	--[[ msg = {app, commandName = string, 
		statusWanted = of Map3DSystem.App.CommandStatusWanted
		status = [out] Map3DSystem.App.CommandStatus or anything else according to statusWanted
	}]]
	APP_QUERY_STATUS = 508,
	
	-- The Exec msg is fired after the QueryStatus event is fired, assuming that the return to the status option parameter of Query Status is supported and enabled. 
	-- This is the event where you place the actual code for handling the response to the user click on the command.
	-- msg = {app, commandName = string, params}
	APP_EXEC = 509,
	
	-- this msg is sent for each installed application, whenever a new world is loaded (just before the 3d scene is enabled, yet after world data is loaded). 
	-- per-world attributes is available here. This message is sent before APP_RENDER_BOX and after APP_CONNECTION(ConnectMode==UI_Setup)
	-- e.g. the CCS (character app) changes the avatar to the user defined avatar in this place just before the world show up. 
	-- Synchronous preprocessing code can also take place here,since there will be a progress bar informing the world loading progress. 
	APP_WORLD_LOAD = 510,
	
	-- TODO: this msg is sent for each installed application, whenever a new world is loaded (after APP_WORLD_LOAD and after the 3d scene is enabled). 
	-- However, the application can set msg.Pause = true to disallow following applications to receive this message
	-- For example, an tutorial app may display an interactive dialog or CG, before the main story begins. When an application paused step, 
	-- it should sent this message again in order for other applications to process. 
	APP_WORLD_STARTUP_STEPS = 511,
	
	-- TODO: this msg is sent for each installed application, whenever a new world is saved by an explicit user action. 
	-- __NOTE__: in most cases, an application should not rely on this message for saving. 
	-- Instead, save immediately to app profile when user made changes.
	APP_WORLD_SAVE = 512,
	
	-- TODO: this msg is sent for each installed application, whenever a world is being closed. 
	-- However, the application can set msg.DisableClosing = true to disallow closing, such as asking the user to save the world. 
	APP_WORLD_CLOSING = 513,
	
	-- TODO: this msg is sent for each installed application, whenever a world is closed. Usually application release resources used in the world session. 
	APP_WORLD_CLOSED = 514,
	
	-- This message is sent to an application, whenever the user clicks to enter the application exclusive desktop mode. 
	-- This message is triggered from the AppTaskBar. Inside this message, an application can add toolbar items to application toolbar via AppTaskBar.AddCommand method. 
	-- more information, please see AppTaskBar.
	APP_ACTIVATE_DESKTOP = 520,
	
	-- This message is sent to an application, whenever an application is requested to quit its current exclusive desktop mode. 
	-- This message is triggered automatically from the AppTaskBar before a new different application's desktop can be activated
	-- Normally, an application needs to save its desktop configuration or modification states for its next activation restoration.
	-- However, it is common for application to do nothing in this message and simple presents the user a default app desktop layout each time it is activated. 
	APP_DEACTIVATE_DESKTOP = 521,
	
	-- This message is sent to an application, whenever the connection is been established
	APP_CONNECTION_ESTABLISHED = 531,
	
	-- This message is sent to an application, whenever whenever the connection is been lost
	APP_CONNECTION_DISCONNECTED = 532,
	
	-- user messages should have values larger than this one. 
	APP_USER_MSG_BEGINS = 1000,
};

-- how app was loaded by the integrated development environment (IDE). 
Map3DSystem.App.ConnectMode = {
	-- app was loaded when the the IDE was started 
	Startup = 2,
	-- app  was loaded by another program other than the IDE 
	External = 3,
	-- the devenv command loaded the add-in. devenv is a tool that lets you set various options for the IDE from the command line 
	Commandline = 4,
	-- app loaded when a 3D World session was loaded with a dependency on the add-in 
	WorldRequire = 5,
	-- called only once when application should add interface to places like menu, mainbar,etc. 
	UI_Setup= 6,
};

-- how app is unloaded
Map3DSystem.App.DisconnectMode = {
	--  The app was unloaded when IDE was shut down.  
	HostShutdown = 1, 
	-- The app was unloaded when a dependent 3D world session was closed. This only happens that the app is only used in a remote world and that the local user does not install it. 
	WorldClosed = 2,
	-- The app was unloaded while IDE was still running.  I.e. The user removes it during game session.
	UserClosed = 3,
};

-------------------------------------------
-- event handlers
-------------------------------------------

-- OnConnection method is the obvious point to place your UI (menus, mainbars, tool buttons) through which the user will communicate to the app. 
-- This method is also the place to put your validation code if you are licensing the add-in. You would normally do this before putting up the UI. 
-- If the user is not a valid user, you would not want to put the UI into the IDE.
-- @param app: the object representing the current application in the IDE. 
-- @param connectMode: type of Map3DSystem.App.ConnectMode. 
function Map3DSystem.App.BaseApp.OnConnection(app, connectMode)
	if(connectMode == Map3DSystem.App.ConnectMode.UI_Setup) then
		-- TODO: place your UI (menus,toolbars, tool buttons) through which the user will communicate to the app
		-- e.g. MainBar.AddItem(), MainMenu.AddItem().
	else
		-- TODO: place the app's one time initialization code here.
		-- during one time init, its message handler may need to update the app structure with static integration points, 
		-- i.e. app.about, app.HomeButtonText, app.HasNavigation, app.HasQuickAction. See app template for more information.
	end
end

-- Receives notification that the Add-in is being unloaded.
function Map3DSystem.App.BaseApp.OnDisconnection(app, disconnectMode)
	if(disconnectMode == Map3DSystem.App.DisconnectMode.UserClosed or disconnectMode == Map3DSystem.App.DisconnectMode.WorldClosed)then
		-- TODO: remove all UI elements related to this application, since the IDE is still running. 
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
function Map3DSystem.App.BaseApp.OnQueryStatus(app, commandName, statusWanted)
	if(statusWanted == Map3DSystem.App.CommandStatusWanted) then
		-- TODO: return an integer by adding values in Map3DSystem.App.CommandStatus.
		if(commandName == "Your.Command.Name") then
			-- return enabled and supported 
			return (Map3DSystem.App.CommandStatus.Enabled + Map3DSystem.App.CommandStatus.Supported)
		end
	end
end

-- This is called when the command is invoked.The Exec is fired after the QueryStatus event is fired, assuming that the return to the statusOption parameter of QueryStatus is supported and enabled. 
-- This is the event where you place the actual code for handling the response to the user click on the command.
-- @param commandName: The name of the command to determine state for. Usually in the string format "Category.SubCate.Name".
function Map3DSystem.App.BaseApp.OnExec(app, commandName, params)
	if(commandName == "Your.Command.Name") then
		-- TODO: actual code of processing the command goes here. 
	elseif(app:IsHomepageCommand(commandName)) then
		Map3DSystem.App.BaseApp.GotoHomepage();
	elseif(app:IsNavigationCommand(commandName)) then
		Map3DSystem.App.BaseApp.Navigate();
	elseif(app:IsQuickActionCommand(commandName)) then	
		Map3DSystem.App.BaseApp.DoQuickAction();
	end
end

-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
function Map3DSystem.App.BaseApp.OnRenderBox(mcmlData)
end


-- called when the user wants to nagivate to the 3D world location relavent to this application
function Map3DSystem.App.BaseApp.Navigate()
end

-- called when user clicks to check out the homepage of this application. Homepage usually includes:
-- developer info, support, developer worlds information, app global news, app updates, all community user rating, active users, trade, currency transfer, etc. 
function Map3DSystem.App.BaseApp.GotoHomepage()
end

-- called when user clicks the quick action for this application. 
function Map3DSystem.App.BaseApp.DoQuickAction()
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
function Map3DSystem.App.BaseApp.MSGProc(window, msg)
	
	----------------------------------------------------
	-- application plug-in messages here
	----------------------------------------------------
	if(msg.type == Map3DSystem.App.MSGTYPE.APP_CONNECTION) then	
		-- Receives notification that the Add-in is being loaded.
		Map3DSystem.App.BaseApp.OnConnection(msg.app, msg.connectMode);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_DISCONNECTION) then	
		-- Receives notification that the Add-in is being unloaded.
		Map3DSystem.App.BaseApp.OnDisconnection(msg.app, msg.disconnectMode);

	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUERY_STATUS) then
		-- This is called when the command's availability is updated. 
		-- NOTE: this function returns a result. 
		msg.status = Map3DSystem.App.BaseApp.OnQueryStatus(msg.app, msg.commandName, msg.statusWanted);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_EXEC) then
		-- This is called when the command is invoked.
		Map3DSystem.App.BaseApp.OnExec(msg.app, msg.commandName, msg.params);
				
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_RENDER_BOX) then	
		-- Change and render the 3D world with mcml data that is usually retrieved from the current user's profile page for this application. 
		Map3DSystem.App.BaseApp.OnRenderBox(msg.mcml);
		
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_NAVIGATION) then
		-- Receives notification that the user wants to nagivate to the 3D world location relavent to this application
		Map3DSystem.App.BaseApp.Navigate();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_HOMEPAGE) then
		-- called when user clicks to check out the homepage of this application. 
		Map3DSystem.App.BaseApp.GotoHomepage();
	
	elseif(msg.type == Map3DSystem.App.MSGTYPE.APP_QUICK_ACTION) then
		-- called when user clicks the quick action for this application. 
		Map3DSystem.App.BaseApp.DoQuickAction();
	

	----------------------------------------------------
	-- normal windows messages here
	----------------------------------------------------
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_HIDE) then
		
		
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SHOW) then
		
	end
end