--[[
Title: 
Author(s):  
Date: 
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/Sample/main.lua");
local Sample = commonlib.gettable("Mod.sample");
------------------------------------------------------------
]]
local Sample = commonlib.inherit(commonlib.gettable("Mod.ModBase"),commonlib.gettable("Mod.Sample"));

function Sample:ctor()
end

-- virtual function get mod name
function Sample:GetName()
	return "Sample"
end

-- virtual function get mod description 
function Sample:GetDesc()
	return "Sample is a special kind of plugin in paracraft"
end

function Sample:init()
	LOG.std(nil, "info", "Sample", "plugin initialized");
end

function Sample:OnLogin()
end

-- called when a new world is loaded. 
function Sample:OnWorldLoad()
end

-- called when a world is unloaded. 
function Sample:OnLeaveWorld()
end

function Sample:OnDestroy()
end