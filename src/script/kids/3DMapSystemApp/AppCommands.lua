--[[
Title: commands in application 
Author(s): LiXizhi
Date: 2008/1/4
Desc: 
   * To call a command:  Map3DSystem.App.Commands.Call("CommandName", param1, ...)
   * To get a command:  local cmd = Map3DSystem.App.Commands.GetCommand("CommandName")
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/3DMapSystemApp/AppCommands.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/Desktop/DesktopWnd.lua");


-- A constant specifying if information is returned from the check, and if so, what type of information is returned. 
Map3DSystem.App.CommandStatusWanted = {
	-- the status of the current command (Map3DSystem.App.CommandStatus) is wanted
	StatusWanted = 1,
	-- the command name is wanted in the current language setting. 
	NameWanted = 2,
	-- the command description is wanted.
	DescriptionWanted = 3,
	-- the tooltip for this command is wanted. 
	TooltipWanted = 4,
};

-- descripting the current status of a given application command item such as in mainbar or menu. 
-- values can be added together to achieve some bitwise operation like (Map3DSystem.App.CommandStatus.Enabled + Map3DSystem.App.CommandStatus.Supported)
Map3DSystem.App.CommandStatus = {
	-- The command is currently enabled.
	Enabled = 1,
	-- The command is currently hidden.
	Invisible = 2,
	-- The command is currently latched (locked).
	Locked = 4,
	-- The command is Reserved for future use.
	Reserved = 8,
	-- The command is supported in this context.  
	Supported = 16,
	-- The command is not supported in this context.  
	Unsupported = 32,
};
local CommandStatus = Map3DSystem.App.CommandStatus;

-- a static function that check if Map3DSystem.App.CommandStatus is available. 
function Map3DSystem.App.IsCommandAvailable(commandStatus)
	return ( commandStatus == nil or 
		    (commandStatus == CommandStatus.Enabled) or 
		    (commandStatus == (CommandStatus.Enabled+CommandStatus.Supported)));
end

-- Defines command style options. 
Map3DSystem.App.CommandStyle = {
	--This command displays an icon only when placed on a mainbar. It displays an icon and text on a menubar.  
	Pict = nil, 
	-- This command displays both an icon and text on both mainbars and menubars.  	
	PictAndText = 1,
	-- This command displays text on a mainbar. It displays both icon and text on a menubar.  
	Text = 2, 
	-- this is just a separator not a clickable command.
	Separator = 3, 
};

-----------------------------------------
-- command
-----------------------------------------

-- Represents a command in the environment. a command is usually displayed as a button in the mainmenu, mainbar, action feed bar, or even a tradable item.
Map3DSystem.App.Command = {
	-- a command must have a unique string name, for tradable items, it may be the item name plus its GUID. 
	-- name command with only letters with "." to seperate category. such as "Tools.Art.ModelBrowser", 
	-- internally, we will use a tree hierarchy to store commands instead of a flat tree. Each dot in the name create a sub tree. 
	name = nil,
	-- application key that this command should be executed in, this can be nil if onclick is not nil.
	app_key = nil,
	-- The name to use if the command is bound to a button that is displayed by name rather than by icon.
	ButtonText = nil,
	-- The text displayed when a user hovers the mouse pointer over any control bound to the new command.
	tooltip = nil,
	-- default icon path of the command
	icon = nil,
	-- whether the command is tradable. if true, it can be exchanged between different user's inventory box
	IsTradable = nil,
	-- any additional data associated with this command. 
	tag = nil,
	-- type of the command, some application may needs this to distinguish the same command name under different situations. 
	type = nil,
	-- command status, it should be nil or addition of the Map3DSystem.App.CommandStatus 
	CommandStatus = nil,
	-- Value from the Map3DSystem.App.CommandStyle enumeration. Controls the visual style of any UI added for this command.
	CommandStyle = nil,
	-- this is function to be called when app_key is nil. format is function(self) end where self is the command object itself. 
	onclick = nil,
};

-- create a new command
function Map3DSystem.App.Command:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Gets a value indicating whether or not the Command is currently enabled
function Map3DSystem.App.Command:IsAvailable()
	return Map3DSystem.App.IsCommandAvailable( self.CommandStatus )
end

-- Creates a persistent command bar control for the command. It may be a button in mainbar or mainmenu or inventory, or actionfeed, etc
-- @param owner: it may be "mainbar", "mainmenu", "actionfeed", "inventory", "desktop".
-- @param position: this is a tree path string of folder names separated by dot
--  e.g. "Tools.Artist", "File.Save", "File.Open".
-- @param posIndex: if position is a item in another folder, this is the index at which to add the item. 
-- if nil, it is added to end, if 1 it is the beginning. See GetPosIndex() below
function Map3DSystem.App.Command:AddControl(owner, position, posIndex)
	if(owner == "mainmenu") then
		if(Map3DSystem.UI.MainMenu) then
			Map3DSystem.UI.MainMenu.AddMenuCommand(self, position, posIndex)
		end
	elseif(owner == "mainbar") then
		-- TODO:
	elseif(owner == "inventory") then
		-- TODO:
	elseif(owner == "actionfeed") then
		-- TODO: 
	elseif(owner == "statusbar") then
		-- TODO: add status bar item
		-- take position index as the priority
		local priority = posIndex;
		if(Map3DSystem.UI.AppTaskBar) then
			Map3DSystem.UI.AppTaskBar.AddStatusBarCommand(self, priority);
		end
	elseif(owner == "creator") then
		-- TODO:
		if(Map3DSystem.DB) then
			Map3DSystem.DB.AddGroupCommand(self, position, posIndex);
		end
	elseif(owner == "desktop") then
		-- TODO:
		if(Map3DSystem.UI.Desktop) then
			Map3DSystem.UI.Desktop.AddDesktopItem(self, position, posIndex)
		end
	end
end

-- [static function] get the position index of an existing position string. One can call this function on a predefined position, 
-- such as a named separator in the mainmenu, to determine where the current command should be inserted. 
-- @param owner: it may be "mainbar", "mainmenu", "actionfeed", "inventory", "desktop".
-- @param position: this is a tree path string of folder names separated by dot
--  e.g. "Tools.Artist", "File.Save", "File.Open".
-- @return: return the index for the position string. it may return nil if position is not found. 
function Map3DSystem.App.Command.GetPosIndex(owner, position)
	if(owner == "mainmenu") then
		return Map3DSystem.UI.MainMenu.GetItemIndex(position);
	elseif(owner == "mainbar") then
		-- TODO:
	elseif(owner == "inventory") then
		-- TODO:
	elseif(owner == "actionfeed") then
		-- TODO:
	elseif(owner == "desktop") then
		-- TODO:
		Map3DSystem.UI.Desktop.AddDesktopItem(self, position, posIndex)
	end
end

-- TODO: use an UI highlighter to guide the user to click this command. It needs to save
-- parameters in AddControl(owner, position) in order to do this automatically for each type of owner. 
function Map3DSystem.App.Command:HighLight()
end

-- Executes the specified command. 
-- It will first call QueryStatus and then call Exec of the given commands. 
-- @param params: optional parameters
-- @return the msg is returned. 
function Map3DSystem.App.Command:Call (params)
	if(self.app_key~=nil) then
		local app = Map3DSystem.App.AppManager.GetApp (self.app_key);
		if(app~=nil) then
			local msg = app:CallCommand(self.name, params);
			if(msg~=nil and msg.status~=nil) then
				self.CommandStatus = msg.status;
			end
			return msg;
		end
	end
	if(type(self.onclick) == "function") then
		return self.onclick(self, params);
	end
end

-- Removes a named command that was created with the Map3DSystem.App.AddNamedCommand method.
function Map3DSystem.App.Command:Delete()
	Map3DSystem.App.Commands.RemoveCommand(self.name);
	-- TODO: remove from UI
end


-----------------------------------------
-- commands
-----------------------------------------

-- Contains all of the commands, in the form of Command objects, in the environment. 
-- internally, we will use a tree hierarchy to store commands instead of a flat tree. Each dot in the name create a sub tree. 
Map3DSystem.App.Commands = {
	-- private: internal data to store all commands
	_commands = {},
	-- mapping from command id to command name
	DefaultCmds = {
		Login = "Profile.Login",
		LoadWorld = "File.EnterWorld",
		SysCommandLine = "File.SysCommandLine",
		EnterChat = "Profile.Chat.QuickChat",
	},
};

-- Creates a named command and add it to the IDE commands list
-- @param command: partial table of Map3DSystem.App.Command
function Map3DSystem.App.Commands.AddNamedCommand(command)
	if(command~=nil and command.name~=nil) then
		command = Map3DSystem.App.Command:new (command);
		Map3DSystem.App.Commands.Add (command);
		return command
	end
end

-- not intended to be used directly from your code. Add a new command and overwrite existing ones. 
-- @param command: of type Map3DSystem.App.Command. command.name should only contain letters with "." to seperate category. such as "Tools.Art.ModelBrowser", 
-- internally, we will use a tree hierarchy to store commands instead of a flat tree. Each dot in the name create a sub tree. 
function Map3DSystem.App.Commands.Add(command)
	commonlib.setfield(command.name, command, Map3DSystem.App.Commands._commands);
end

-- not intended to be used directly from your code. remove a given command, in most cases, there is no need to remove it. 
function Map3DSystem.App.Commands.RemoveCommand(commandName)
	commonlib.setfield(commandName, nil, Map3DSystem.App.Commands._commands);
end

-- get a Map3DSystem.App.Command object by its name from the command pool
function Map3DSystem.App.Commands.GetCommand(commandName)
	return commonlib.getfield(commandName, Map3DSystem.App.Commands._commands);
end

-- get a iterator of depth first tranversal for all elements (including folders) in commands. 
-- @param rootEnv: from which command group to search. if nil the root command is used. Otherwise it can be a command folder name, e.g. "Files", "Profile.MyApps"
function Map3DSystem.App.Commands.GetEnumerator (rootEnv)
	local cur;
	if(rootEnv == nil) then
		cur = Map3DSystem.App.Commands._commands;
	else
		cur = Map3DSystem.App.Commands.GetCommand(rootEnv);
	end
	local stack = {};
	stack[1] = cur;
	return function()
		local obj;
		
		local item = stack[table.getn(stack)];
		if(item ~= nil) then
			-- no more items 
			return nil;
		end
		-- pop last item
		stack[table.getn(stack)] = nil;
		
		-- add all child items to queue
		local key, value;
		for key, value in pairs(item) do
			stack[table.getn(stack)+1] = value;	
		end
		return item;
	end
end

-- set the default login command. If one wants to replace the login machanism, just replace this command with a user supplied one. 
-- @param cmd: default to "Profile.Login"
function Map3DSystem.App.Commands.SetLoginCommand(cmd)
	Map3DSystem.App.Commands.SetDefaultCommand("Login", cmd);
end

-- return the command name to call when the user is not logged in
-- @return: default to "Profile.Login"
function Map3DSystem.App.Commands.GetLoginCommand()
	return Map3DSystem.App.Commands.GetDefaultCommand("Login");
end

-- set the default login command. If one wants to replace the login machanism, just replace this command with a user supplied one. 
-- @param cmd: default to "Profile.Login"
function Map3DSystem.App.Commands.SetLoadWorldCommand(cmd)
	Map3DSystem.App.Commands.SetDefaultCommand("LoadWorld", cmd);
end

-- return the command name to call when the user is not logged in
-- @return: default to "Profile.Login"
function Map3DSystem.App.Commands.GetLoadWorldCommand()
	return Map3DSystem.App.Commands.GetDefaultCommand("LoadWorld");
end

-- set the default login command. If one wants to replace the login machanism, just replace this command with a user supplied one. 
-- @param cmd: default to "Profile.SysCommandLine"
function Map3DSystem.App.Commands.SetSysCommandLineCommand(cmd)
	Map3DSystem.App.Commands.SetDefaultCommand("SysCommandLine", cmd);
end

-- return the command name to call when the user is not logged in
-- @return: default to "Profile.SysCommandLine"
function Map3DSystem.App.Commands.GetSysCommandLineCommand()
	return Map3DSystem.App.Commands.GetDefaultCommand("SysCommandLine");
end

-- set the default login command. If one wants to replace the login machanism, just replace this command with a user supplied one. 
-- @param cmdName: internal command name. such as "SysCommandLine", "LoadWorld", "Login", "EnterChat"
-- @param cmd: 
function Map3DSystem.App.Commands.SetDefaultCommand(cmdName, cmd)
	Map3DSystem.App.Commands.DefaultCmds[cmdName] = cmd;
end

-- return the command name to call when the user is not logged in
-- @return: 
function Map3DSystem.App.Commands.GetDefaultCommand(cmdName)
	return Map3DSystem.App.Commands.DefaultCmds[cmdName]
end

-- Executes the specified command. 
-- It will first call QueryStatus and then call Exec of the given commands. 
-- @param commandName: 
-- @param params: nil or additional parameters
-- @return the msg is returned. 
function Map3DSystem.App.Commands.Call (commandName, params)
	local cmd = Map3DSystem.App.Commands.GetCommand(commandName);
	if(cmd~=nil and cmd.Call~=nil) then
		return cmd:Call(params);
	end
end

