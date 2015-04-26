--[[
Title: DemoCommand
Author(s):  
Date: 
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/Test/DemoCommand.lua");
local DemoCommand = commonlib.gettable("Mod.Test.DemoCommand");
------------------------------------------------------------
]]
local Commands = commonlib.gettable("MyCompany.Aries.Game.Commands");
local CommandManager = commonlib.gettable("MyCompany.Aries.Game.CommandManager");

local DemoCommand = commonlib.inherit(nil,commonlib.gettable("Mod.Test.DemoCommand"));

function DemoCommand:ctor()
end

function DemoCommand:init()
	LOG.std(nil, "info", "DemoCommand", "init");
	self:InstallCommand();
end

function DemoCommand:InstallCommand()
	Commands["demo"] = {
		name="demo", 
		quick_ref="/demo", 
		desc="show a demo", 
		handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
			_guihelper.MessageBox("this is from demo command");
		end,
	};
	Commands["demo2"] = {
		name="demo2", 
		quick_ref="/demo2", 
		desc="show a demo", 
		handler = function(cmd_name, cmd_text, cmd_params, fromEntity)
			
		end,
	};
end
