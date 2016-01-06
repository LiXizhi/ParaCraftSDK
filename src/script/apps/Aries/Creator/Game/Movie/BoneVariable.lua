--[[
Title: Bone variable
Author(s): LiXizhi
Date: 2015/9/8
Desc: a single bone variable, it is a multi variable containing rotation, translation and scaling attribute variable. 
use the lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/BoneVariable.lua");
local BoneVariable = commonlib.gettable("MyCompany.Aries.Game.Movie.BoneVariable");
-------------------------------------------------------
]]
NPL.load("(gl)script/apps/Aries/Creator/Game/Common/MultiAnimBlock.lua");
NPL.load("(gl)script/apps/Aries/Creator/Game/Movie/BoneAttributeVariable.lua");
local BoneAttributeVariable = commonlib.gettable("MyCompany.Aries.Game.Movie.BoneAttributeVariable");
local ATTRIBUTE_FIELDTYPE = commonlib.gettable("System.Core.ATTRIBUTE_FIELDTYPE");

local BoneVariable = commonlib.inherit(commonlib.gettable("MyCompany.Aries.Game.Common.MultiAnimBlock"), commonlib.gettable("MyCompany.Aries.Game.Movie.BoneVariable"));
BoneVariable.name = "";

function BoneVariable:ctor()
end

-- @param attr: parax bone attribute model
-- @param animInstance: the animation instance 
-- @param parent: get the parent BonesVariable.
function BoneVariable:init(attr, animInstance, parent)
	self.parent = parent;
	self.name = attr:GetField("name", "");
	self.rot_name = attr:GetField("RotName", "");
	self.trans_name = attr:GetField("TransName", "");
	self.scale_name = attr:GetField("ScaleName", "");

	self.variables:add(BoneAttributeVariable:new():init(self.rot_name, "rot", attr, animInstance, parent));
	self.variables:add(BoneAttributeVariable:new():init(self.trans_name, "trans", attr, animInstance, parent));
	self.variables:add(BoneAttributeVariable:new():init(self.scale_name, "scale", attr, animInstance, parent));

	self.attr = attr;
	self.animInstance = animInstance;
	return self;
end

-- save from C++'s current anim instance to actor's timeseries
function BoneVariable:SaveToTimeVar()
	for i=1, #(self.variables) do
		self.variables[i]:SaveToTimeVar();
	end
end

-- Load from actor's timeseries to C++'s current anim instance. 
function BoneVariable:LoadFromTimeVar()
	for i=1, #(self.variables) do
		self.variables[i]:LoadFromTimeVar();
	end
end

function BoneVariable:GetRotName()
	return self.rot_name;
end

function BoneVariable:GetScaleName()
	return self.scale_name;
end

function BoneVariable:GetTransName()
	return self.trans_name;
end

function BoneVariable:getValue(anim, time)
	local v = BoneVariable._super.getValue(self, anim, time);
	if(v and not next(v)) then
		v = nil;
	end
	return v;
end