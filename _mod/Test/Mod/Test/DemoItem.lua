--[[
Title: DemoItem
Author(s):  LiXizhi
Date: 2016.10.19
Desc: a demo block item
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

	-- register a new block item, id < 512 is internal blocks, which is not recommended to modify. 
	GameLogic.GetFilters():add_filter("block_types", function(xmlRoot) 
		local blocks = commonlib.XPath.selectNode(xmlRoot, "/blocks/");
		if(blocks) then
			blocks[#blocks+1] = {name="block", attr={
				id = 512, 
				threeSideTex = "true",
				text = "Demo Item",
				name = "DemoItem",
				texture="Texture/blocks/bookshelf_three.png",
				obstruction="true",
				solid="true",
				cubeMode="true",
			}}
			LOG.std(nil, "info", "DemoItem", "a new block is registered");
		end
		return xmlRoot;
	end)

	-- add block to category list to be displayed in builder window (E key)
	GameLogic.GetFilters():add_filter("block_list", function(xmlRoot) 
		for node in commonlib.XPath.eachNode(xmlRoot, "/blocklist/category") do
			if(node.attr.name == "tool") then
				node[#node+1] = {name="block", attr={name="DemoItem"} };
			end
		end
		return xmlRoot;
	end)
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