--[[
Title: the app object asscoiated with each application. 
Author(s): LiXizhi
Date: 2008/1/1
Desc: Only included by AppManager. 
the app object contains an variety of methods, such as commands, app IO, app preferences functions etc. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/app.lua");
-- to get the app object of an given application, use 
local app = Map3DSystem.App.AppManager.GetApp(app_key)
------------------------------------------------------------
]]

-- the app template
Map3DSystem.App.AppManager.app = {
	------------------------------
	-- following are data from registration database
	------------------------------
	-- string of app_key. 
	app_key = nil,
	-- name
	name = "unnamed",	
	-- description.
	description = "application does not provide a description",
	-- type of Map3DSystem.App.AppCategory
	category = nil,
	-- version can be nil or string of format "XX.XX.XX"
	version = nil, -- "1.0.0",
	-- an onload script. This is usually where the app's callbackfunction must be defined. 
	onloadscript = nil,
	-- string name of the application callback function, such as "MyCompany.MyApp.MSGProc"
	callbackfunction = nil, 
	-- default language
	lang = "enUS",
	-- nil or array containing local path of zip packages, such as {"Apps/Map_script_v1.zip", "Apps/Map_model_v1.zip"}
	packageList = {},
	-- boolean: whether this application is added by the local user. Some application is loaded by world dependency.
	UserAdded = nil,
	-- url. this is optional
	url = nil,
	-- an application profile box definition table, data fields not defined in this table is stripped by self:GetMCML function. 
	-- if this is nil, the MCML for the application will be returned by self:GetMCML() unchanged. 
	AppProfileDefinition = nil,
	------------------------------
	-- following are data set or get during application OnConnection message event.
	------------------------------
	-- whether this application is Loaded. see Map3DSystem.App.AppManager.ConnectionStatus:  This parameter is automatically set by application manager. 
	ConnectionStatus = nil,
	-- about text of this application
	about = nil,
	-- default icon path of the application
	icon = nil,
	-- boolean: whether the home icon button should be hidden by default. 
	HideHomeButton = nil,
	-- text to be displayed next to in the homepage command.
	HomeButtonText = nil,
	-- boolean: whether this application needs a navigation link around the in-game mini-map. 
	HasNavigation = nil,
	-- text to be displayed near the navigation button. This is usually tooltip. 
	NavigationButtonText = nil, 
	-- boolean: whether this application has quick action below a user profile. 
	HasQuickAction = nil,
	-- text to be displayed in the quick action link command.
	QuickActionText = nil,
	-- the setting page(MCML) url, it is usually called setting.html in the same folder of onloadscript
	SettingPage = nil,
	-- text to be displayed on title of the setting page. if nil, the self.name is used. 
	SettingPageTitle = nil,
	-- the Help page(MCML) url, it is usually called Help.html in the same folder of onloadscript
	HelpPage = nil,
	-- text to be displayed on title of the Help page. if nil, the self.name is used. 
	HelpPageTitle = nil,
	
	------------------------------
	-- following are privacy settings from the current user's profile: user can change them for each application. 
	------------------------------
	-- do not allow this application to contact me via email
	DenyEmail = nil,
	-- only me and my friends can see profile data of this application. i.e. Strangers are denied from viewing. 
	DenyGuest = nil,
	-- Deny profile action feed
	DenyActionFeed = nil,
	-- do not allow this application to show a homepage button in my application list on the mainmenu
	DenyHomeButton = nil,
	-- do not allow this application to show a quick action link under any profile. 
	DenyQuickAction = nil,
}

-- Create an application from a table. One needs to call AddApp() with the returned app object. 
-- @param o: table containing field in Map3DSystem.App.AppManager.app template table.
function Map3DSystem.App.AppManager.app:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

---------------------------------------
-- application commands: prefined commands and developer defined commands
---------------------------------------
-- return whether a command name is some predefined command name. 
function Map3DSystem.App.AppManager.app:IsHomepageCommand(commandName)
	return (("home."..self.app_key) == commandName);
end

-- return whether a command name is some predefined command name. 
function Map3DSystem.App.AppManager.app:IsNavigationCommand(commandName)
	return (("Nav."..self.app_key) == commandName);
end

-- return whether a command name is some predefined command name. 
function Map3DSystem.App.AppManager.app:IsQuickActionCommand(commandName)
	return (("QuickAction."..self.app_key) == commandName);
end

-- execute a named command of this application. It will first query status and then call exec
-- @param commandName: command name string. It can also be an internal name that is not added to Map3DSystem.App.Commands
-- @param params: optional parameters
-- @return: the msg is returned. msg.status contains the returned command status, other fields may contain optional data returned by the commands. 
--  in most cases, one can ignore the return message of the command.
function Map3DSystem.App.AppManager.app:CallCommand(commandName, params)
	-- query status of the command
	local msg = { app = self, type = Map3DSystem.App.MSGTYPE.APP_QUERY_STATUS, 
		commandName = commandName,
		statusWanted = Map3DSystem.App.CommandStatusWanted.StatusWanted,
	}
	self:SendMessage(msg);
	if( Map3DSystem.App.IsCommandAvailable(msg.status) ) then
		-- if available, execute the command
		msg.type = Map3DSystem.App.MSGTYPE.APP_EXEC;
		msg.params = params;
		self:SendMessage(msg);
	end
	return msg;
end

-- render the application box in 3D using the mcml data table. 
function Map3DSystem.App.AppManager.app:OnRenderBox(mcmlData)
	-- just send an nav message to the application
	self:SendMessage({type = Map3DSystem.App.MSGTYPE.APP_RENDER_BOX, mcml = mcmlData});
end

-- navigate to an application in the current world
function Map3DSystem.App.AppManager.app:Navigate()
	self:SendMessage({type = Map3DSystem.App.MSGTYPE.APP_NAVIGATION});
end

-- go to the homapage of the application
function Map3DSystem.App.AppManager.app:GotoHomepage()
	self:SendMessage({type = Map3DSystem.App.MSGTYPE.APP_HOMEPAGE});
end

-- do quite action to the world owner
function Map3DSystem.App.AppManager.app:DoQuickAction()
	self:SendMessage({type = Map3DSystem.App.MSGTYPE.APP_QUICK_ACTION});
end

------------------------------------------------
-- message and connection functions. 
------------------------------------------------
-- connect to an installed application. 
-- @param connectMode: type of Map3DSystem.App.ConnectMode. 
function Map3DSystem.App.AppManager.app:Connect(connectMode)
	if(connectMode == Map3DSystem.App.ConnectMode.UI_Setup) then
		-- send setup UI message to the application. 
		if(self._app ~= nil) then
			self:SendMessage({type = Map3DSystem.App.MSGTYPE.APP_CONNECTION, app = self, connectMode = Map3DSystem.App.ConnectMode.UI_Setup});
		end
		
	else
		-- create the application and default message window and send the first connection message to the application. 
		if(self.ConnectionStatus == Map3DSystem.App.AppManager.ConnectionStatus.NotLoaded and self._app==nil) then
			-- create application in IDE's os system using the key
			self._app = CommonCtrl.os.CreateGetApp(self.app_key);
			if(self._app ~= nil) then
				-- creating the default "main" window to receive message for this application. 
				self._wnd = self._app:RegisterWindow("main", nil, self.callbackfunction);
				-- finally send the connection message to the application. 
				self:SendMessage({type = Map3DSystem.App.MSGTYPE.APP_CONNECTION, app = self, connectMode = connectMode});
				-- change status to loaded				
				self.ConnectionStatus = Map3DSystem.App.AppManager.ConnectionStatus.Loaded;
				LOG.std("", "system", "app", "app \"%s\" loaded", self.name);
			end
		end	
	end
end

-- disconnect to an installed application. 
function Map3DSystem.App.AppManager.app:Disconnect(disconnectMode)
	if(self._app ~= nil) then
		-- finally send the disconnection message to the application. 
		self:SendMessage({type = Map3DSystem.App.MSGTYPE.APP_DISCONNECTION, app = self, connectMode = disconnectMode});
		-- change status to unloaded				
		self.ConnectionStatus = Map3DSystem.App.AppManager.ConnectionStatus.UnLoaded;
	end
end


-- send a message to the main window of a given application
-- @param AppName: name of the application. 
-- @param msg: msg to be sent. 
-- @param wndName: if nil, it is sent to the default "main" window of the app. Otherwise it can be a sub window name created by the app.
function Map3DSystem.App.AppManager.app:SendMessage(msg, wndName)
	if(self._app~=nil and msg~=nil) then
		msg.wndName = wndName or "main";
		self._app:SendMessage(msg);
	else
		LOG.std("", "error", "app", "error: OS app not found "..tostring(self.app_key));
		commonlib.log(msg);
		commonlib.log(app);
	end
end

----------------------------------------
--  IO functions
----------------------------------------

-- Open or create a file under the application directory. 
-- @return ParaFileObject 
-- e.g. local file = app:openfile("test.txt", "w"); 
function Map3DSystem.App.AppManager.app:openfile(filename, mode)
	local _filename = self:GetAppDirectory()..filename;
	if(ParaIO.CreateDirectory(_filename)) then
		return ParaIO.open(_filename, mode);
	end	
end

-- get the application directory. it ends with '/'. the directory may not exist. but it will always return a path string. 
function Map3DSystem.App.AppManager.app:GetAppDirectory()
	if(not self.app_dir) then
		self.app_dir = ParaIO.GetWritablePath().."temp/apps/"..string.gsub(self.app_key, "%W", "").."/";
	end
	return self.app_dir;
end

-- open directory using external windows browser (windows explorer)
-- @param directory: if nil, it will be the default application directory. e.g. "screenshot/"
-- @param silentmode if true, NO UI is shown. 
function Map3DSystem.App.AppManager.app:OpenInWinExplorer(directory, silentmode)
	if(directory == nil) then
		directory = self:GetAppDirectory();
	end	
	if(directory~=nil) then
		local absPath = string.gsub(ParaIO.GetCurDirectory(0)..directory, "/", "\\");
		if(absPath~=nil) then
			if(not silentmode) then
				_guihelper.MessageBox(string.format(L"您确定要使用Windows浏览器打开文件 %s?", commonlib.Encoding.DefaultToUtf8(absPath)), function()
					ParaGlobal.ShellExecute("open", "explorer.exe", absPath, "", 1); 
				end);
			else
				ParaGlobal.ShellExecute("open", "explorer.exe", absPath, "", 1); 
			end	
		end
	end
end

----------------------------------------
-- application configuration functions
-- configuration can contain any name value pairs, and is stored locally on the temp application directory. 
-- the configuration file is usually empty on a newly installed application. 
----------------------------------------

-- set a name, value pair to the configuration file. it saves immediately to file unless this is called after BeginConfig()
-- it will only save if value is different with the one is the config. 
-- Note: attention should be pay if value is a table, u need to make a commonlib.copy() of the returned object in ReadConfig()
-- otherwise the WriteConfig will not save to config, since the compare function will always be true. 
-- @param name: string name of the configuration field. 
-- @param value: can be any valid npl value. if it is a table, it must not contain recursive references. 
-- @return true if change is made
function Map3DSystem.App.AppManager.app:WriteConfig(name, value)
	local config = self:LoadConfig();
	if(type(name) == "string") then
		if(not commonlib.compare(config[name], value))then
			config[name] = value;
			if(not self.IsBeginConfig) then	
				self:SaveConfig();
			else
				self.IsBeginConfig = 1;	
			end
		end	
	end
end

-- get a configuration field name, 
-- @param name: string name of the configuration field. 
-- @param defaultValue: nil or default value. 
-- @return: the field value is returned. If it is a table, the table reference is returned
function Map3DSystem.App.AppManager.app:ReadConfig(name, defaultValue)
	local config = self:LoadConfig();
	local value = config[name]
	if(value ~= nil) then
		return value
	else
		return defaultValue
	end	
end


-- in case one wants to batch SetConfig without writing to disk file multiple times. 
-- Just make multiple WriteConfig() calls between BeginConfig() and EndConfig() pairs. 
function Map3DSystem.App.AppManager.app:BeginConfig()
	self.IsBeginConfig = true;
end

-- in case one wants to batch SetConfig without writing to disk file multiple times. 
-- Just make multiple WriteConfig() calls between BeginConfig() and EndConfig() pairs. 
-- @return true if saved, otherwise it means that the config file has not changed. 
function Map3DSystem.App.AppManager.app:EndConfig()
	local bSaved; 
	if(self.IsBeginConfig == 1) then
		self:SaveConfig();
		bSaved = true;
	end	
	self.IsBeginConfig = nil;
	return bSaved;
end

-- save the config file.
-- NOTE by andy 2010/2/7: easy encode is added to config file saving
function Map3DSystem.App.AppManager.app:SaveConfig()
	local file = self:openfile("config", "w"); 
	if(file and file:IsValid())then
		file:WriteString(ParaMisc.SimpleEncode(commonlib.serialize(self:LoadConfig())));
		file:close();
	end
end

-- load the config file from this application's temp directory. The config file is named "config"
-- NOTE by andy 2010/2/7: easy encode is added to config file loading
function Map3DSystem.App.AppManager.app:LoadConfig()
	if (not self._config) then
		local file = self:openfile("config", "r"); 
		if(file and file:IsValid())then
			-- backward compatible of non encoded strings
			self._config = NPL.LoadTableFromString((file:GetText()));
			local bNeedSave = false;
			if(type(self._config) ~= "table") then
				self._config = NPL.LoadTableFromString(ParaMisc.SimpleDecode(file:GetText()));
			else
				bNeedSave = true;
			end
			file:close();
			if(bNeedSave == true) then
				self:SaveConfig();
			end
		end
	end
	if(type(self._config) ~= "table") then
		self._config = {};
	end
	return self._config;
end

----------------------------------------
--  profile functions
----------------------------------------

-- Set an application profile box definition table. Data fields not defined in this table is stripped by self:GetMCML function. 
-- if this is nil, the MCML for the application will be returned by self:GetMCML() unchanged. 
-- the reason to use profile definition is that when an application changes the profile box format (data layout), it ensures that old stored profile fields are automatically cleared unpon next get call.
-- @param AppProfileDefinition_: each data member in definition file can be another table definition or true, 0, 1, or 2. 
--	true or 0 means that it is optional. 1 means that it is menditory. array or MCML (XML) node is always optional.
-- e.g. app:SetProfileDefinition({version=true, photopath=true, profile = true})
function Map3DSystem.App.AppManager.app:SetProfileDefinition(AppProfileDefinition_)
	self.AppProfileDefinition = AppProfileDefinition_;
end

-- get the current profile definition. if there is non definition, it will return nil. 
function Map3DSystem.App.AppManager.app:GetProfileDefinition()
	return self.AppProfileDefinition;
end

-- apply the profile definition to the raw profile table. if raw_profile contains fields that does not exist in the current profile's definition file, that field is removed from the raw_profile
-- the reason to apply profile definition is that when an application changes the profile box format (data layout), it ensures that old profile storage fields are automatically cleared unpon next get call.
-- Hence, when an application upgrades, old formats will be discarded automatically. 
-- e.g. 
--		app:SetProfileDefinition({version=true, photopath=true, profile = true})
--		local profile = app:ApplyProfileDefinition({version=1, photopath="ABC", profile = {name="pe:profile"}, unkownfield = {}}), where unkownfield will be removed 
-- @param raw_profile: to which the raw profile that the current profile definition is applied. if this is nil, raw_profile will be unchanged
-- @return: the raw_profile is returned for convinence. 
function Map3DSystem.App.AppManager.app:ApplyProfileDefinition(raw_profile)
	if(self.AppProfileDefinition) then
		local function _apply(dest, src, tolerance)
			if type(src) == type(dest) then
				if(type(dest) =="table")  then
					local unknownfields;
					--
					-- remove unknown fields with string keys
					--
					local key, value
					for key, value in pairs(dest) do
						if(src[key]) then
							if(type(src[key]) == "table") then
								if(type(value) == "table") then
									_apply(value, src[key])
								else
									unknownfields = unknownfields or {};
									table.insert(unknownfields, key);
								end	
							end
						else
							unknownfields = unknownfields or {};
							table.insert(unknownfields, key);
						end
					end
					-- remove unknown fields
					if(unknownfields) then
						local index, key 
						for index, key in ipairs(unknownfields) do
							dest[key] = nil;
						end
						unknownfields = nil;
					end
					--
					-- unknown fields in arrays are always preserved, because they are most likely to be MCML nodes.  
					--
				else
					-- other types ignore.	
				end	
			end
		end
		_apply(raw_profile, self.AppProfileDefinition)
	end	
    return raw_profile;
end

-- this is the wrapper of Map3DSystem.App.profiles.ProfileManager.GetMCML
-- Gets an app MCML that is currently set for a user's profile. A user MCML profile includes the content for both the profile box.
-- See the MCML documentation for a description of the markup and its role in various contexts.
-- @param uid: for which user to get, if nil, the current user is used
-- @param callbackFunc: nil or function to call whenever the data is ready, function(uid, app_key, bSucceed) end , where uid, app_key are forwarded. 
-- @param cache_policy: nil or a cache policy object, such as Map3DSystem.localserver.CachePolicies["never"]
-- @return return true if it is fetching data or data is already available. it returns paraworld.errorcode, if web service can not be called at this time, due to error or too many concurrent calls.
function Map3DSystem.App.AppManager.app:GetMCML(uid, callbackFunc, cache_policy)
	return Map3DSystem.App.profiles.ProfileManager.GetMCML(uid, self.app_key, callbackFunc, cache_policy)
end

-- it will return immediately the application's mcml profile data for the user. I assumes that GetMCML or the user profile is already downloaded and available in memory. 
function Map3DSystem.App.AppManager.app:GetMCMLInMemory(uid)
	return Map3DSystem.App.profiles.ProfileManager.GetMCMLInMemory(uid, self.app_key);
end


-- this is the wrapper of Map3DSystem.App.profiles.ProfileManager.SetMCML, except that ApplyProfileDefinition is called prior to saving to remove unnecessary fields.
-- set MCML for a given application of the current user. 
-- and it will GetMCML for the same app from server immediately after set is completed. This Get operation ensures that local server is also updated. 
-- @param uid: this must be nil and current user is used. In future, we will allow arbitrary id with app signature. 
-- @param profile: if this is table. it is serialized to string. If this is nil, the app MCML will be cleared. 
-- @param callbackFunc: nil or function to call whenever the data is ready, function(uid, app_key, bSucceed) end , where uid, app_key are forwarded. 
function Map3DSystem.App.AppManager.app:SetMCML(uid, profile, callbackFunc)
	-- apply definition to remove unnecessary fields. 
	self:ApplyProfileDefinition(profile);
	-- perform the actual set operation. 
	Map3DSystem.App.profiles.ProfileManager.SetMCML(uid, self.app_key, profile, callbackFunc)
end

------------------------------------------------
-- Misc functions 
------------------------------------------------

-- set the setting page(MCML) url, it is usually called setting.html in the same folder of onloadscript
-- @param filepath; the file path, it can be relative to root folder, or relative to the same folder of self.onloadscript
function Map3DSystem.App.AppManager.app:SetSettingPage(filepath, SettingPageTitle)
	if(not string.find(filepath, "[/\\]")) then
		self.SettingPage = string.gsub(self.onloadscript, "[^/\\]+$", filepath);
	else
		self.SettingPage = filepath;
	end
	self.SettingPageTitle = SettingPageTitle;
end

-- Get the setting page(MCML) url, and title
-- @return: two field is returned. the first is nil or page url. The page is always local. the second is page title or nil.
function Map3DSystem.App.AppManager.app:GetSettingPage()
	return self.SettingPage, self.SettingPageTitle;
end

-- set the Help page(MCML) url, it is usually called Help.html in the same folder of onloadscript
-- @param filepath; the file path, it can be relative to root folder, or relative to the same folder of self.onloadscript
function Map3DSystem.App.AppManager.app:SetHelpPage(filepath, HelpPageTitle)
	if(not string.find(filepath, "[/\\]")) then
		self.HelpPage = string.gsub(self.onloadscript, "[^/\\]+$", filepath);
	else
		self.HelpPage = filepath;
	end
	self.HelpPageTitle = HelpPageTitle;
end

-- Get the Help page(MCML) url, and title
-- @return: two field is returned. the first is nil or page url. The page is always local. the second is page title or nil.
function Map3DSystem.App.AppManager.app:GetHelpPage()
	return self.HelpPage, self.HelpPageTitle;
end