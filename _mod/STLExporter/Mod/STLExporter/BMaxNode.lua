--[[
Title: bmax node
Author(s): LiXizhi
Date: 2015/12/4
Desc: a single bmax cube node
use the lib:
------------------------------------------------------------
NPL.load("(gl)Mod/STLExporter/BMaxNode.lua");
local BMaxNode = commonlib.gettable("Mod.STLExporter.BMaxNode");
local node = BMaxNode:new();
------------------------------------------------------------
]]
local BMaxNode = commonlib.inherit(nil,commonlib.gettable("Mod.STLExporter.BMaxNode"));

function BMaxNode:ctor()
end

function BMaxNode:init(x,y,z,template_id, block_data)
	self.x = x;
	self.y = y;
	self.z = z;
	self.template_id = template_id;
	self.block_data = block_data;
	return self;
end
	