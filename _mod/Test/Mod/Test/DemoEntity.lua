--[[
Title: DemoEntity
Author(s):  
Date: 
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/Test/DemoEntity.lua");
local DemoEntity = commonlib.gettable("Mod.Test.DemoEntity");
------------------------------------------------------------
]]
local DemoEntity = commonlib.inherit(nil,commonlib.gettable("Mod.Test.DemoEntity"));

function DemoEntity:ctor()
end

function DemoEntity:init()
	LOG.std(nil, "info", "DemoEntity", "init");
end
