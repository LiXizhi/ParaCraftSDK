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

function DemoItem:OnWorldLoad()
	if(self.isInited) then
		return 
	end
	self.isInited = true;

	NPL.load("(gl)script/apps/Aries/Creator/Game/blocks/block_types.lua");
	local block_types = commonlib.gettable("MyCompany.Aries.Game.block_types")
	local block_template = block_types.get(101);
	if(block_template) then
		
	end
end