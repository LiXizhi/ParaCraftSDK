--[[
Title: DemoItem
Author(s):  
Date: 
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/Test/DemoItem.lua");
local DemoItem = commonlib.gettable("Mod.Test.DemoItem");
------------------------------------------------------------
]]
local DemoItem = commonlib.inherit(nil,commonlib.gettable("Mod.Test.DemoItem"));

function DemoItem:ctor()
end

function DemoItem:init()
	LOG.std(nil, "info", "DemoItem", "init");
end
