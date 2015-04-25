--[[
Title: 
Author(s):  
Date: 
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/Test/main.lua");
local Test = commonlib.gettable("Mod.Test");
------------------------------------------------------------
]]
NPL.load("(gl)Mod/Test/DemoCommand.lua");
NPL.load("(gl)Mod/Test/DemoEntity.lua");
NPL.load("(gl)Mod/Test/DemoGUI.lua");
NPL.load("(gl)Mod/Test/DemoItem.lua");
local DemoItem = commonlib.gettable("Mod.Test.DemoItem");
local DemoGUI = commonlib.gettable("Mod.Test.DemoGUI");
local DemoEntity = commonlib.gettable("Mod.Test.DemoEntity");
local DemoCommand = commonlib.gettable("Mod.Test.DemoCommand");
local Test = commonlib.inherit(commonlib.gettable("Mod.ModBase"),commonlib.gettable("Mod.Test"));

function Test:ctor()
end

-- virtual function get mod name

function Test:GetName()
	return "Test"
end

-- virtual function get mod description 
function Test:GetDesc()
	return "Test is a plugin in paracraft"
end

function Test:init()
	LOG.std(nil, "info", "Test", "plugin initialized");
	DemoItem:init();
	DemoGUI:init();
	DemoEntity:init();
	DemoCommand:init();
end

function Test:OnLogin()
end

-- called when a new world is loaded. 
function Test:OnWorldLoad()
	LOG.std(nil, "info", "Test", "Mod test on world loaded");
	DemoGUI:OnWorldLoad();
end

-- called when a world is unloaded. 
function Test:OnLeaveWorld()
	LOG.std(nil, "info", "Test", "Mod test on leave world");
	DemoGUI:OnLeaveWorld();
end

function Test:OnDestroy()
end
