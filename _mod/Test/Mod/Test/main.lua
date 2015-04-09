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
local Test = commonlib.inherit(commonlib.gettable("Mod.ModBase"),commonlib.gettable("Mod.Test"));

function Test:ctor()
end

-- virtual function get mod name

function Test:GetName()
	return "Test"
end

-- virtual function get mod description 
function Test:GetDesc()
	return "Test is a special kind of plugin in paracraft"
end

function Test:init()
	LOG.std(nil, "info", "Test", "plugin initialized");
end

function Test:OnLogin()
end

-- called when a new world is loaded. 
function Test:OnWorldLoad()
	LOG.std(nil, "info", "Test", "Mod test on world loaded");
end

-- called when a world is unloaded. 
function Test:OnLeaveWorld()
	LOG.std(nil, "info", "Test", "Mod test on leave world");
end

function Test:OnDestroy()
end
