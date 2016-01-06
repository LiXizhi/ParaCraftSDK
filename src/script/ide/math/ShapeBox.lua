--[[
Title: Shape Box in 3d space
Author(s): LiXizhi
Date: 2016/1/5
Desc: AABB-related code. min, max box.
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/math/ShapeBox.lua");
local ShapeBox = commonlib.gettable("mathlib.ShapeBox");
local aabb = ShapeBox:new():SetPointBox(0,0,0);
aabb:Extend(1,2,0);
aabb:Extend(-1,-2,0);
echo({aabb:GetWidth(), aabb:GetHeight()});
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/vector.lua");
local vector3d = commonlib.gettable("mathlib.vector3d");

local ShapeBox = commonlib.gettable("mathlib.ShapeBox");
ShapeBox.__index = ShapeBox;

local math_abs = math.abs;
local math_min = math.min;
local math_max = math.max;

-- create a new shape
function ShapeBox:new(o)
	o = o or {};
	setmetatable(o, self);

	o.m_Min = vector3d:new({999999999,999999999,999999999});
	o.m_Max = vector3d:new({-999999999,-999999999,-999999999});

	return o;
end


function ShapeBox:GetMin()
	return  self.m_Min;
end

-- Get max point of the box
function ShapeBox:GetMax()
	return  self.m_Max;
end

-- Setups an empty box
function ShapeBox:SetEmpty()
	self.m_Min:set(999999999,999999999,999999999);
	self.m_Max:set(-999999999,-999999999,-999999999);
end

-- return false if it is empty. i.e. having negative extents
function ShapeBox:IsValid()
	return (self.m_Min[1]<=self.m_Max[1]) and (self.m_Min[2]<=self.m_Max[2]) and (self.m_Min[3]<=self.m_Max[3]);
end

function ShapeBox:GetWidth()
	return self.m_Max[1] - self.m_Min[1];
end

function ShapeBox:GetHeight()
	return self.m_Max[2] - self.m_Min[2];
end

function ShapeBox:GetDepth()
	return self.m_Max[3] - self.m_Min[3];
end

-- Setups a point box.
-- @param x,y,z: x may be vector or float. if vector, y, z should be nil.
function ShapeBox:SetPointBox(x,y,z)
	self.m_Min:set(x,y,z);
	self.m_Max:set(x,y,z);
	return self;
end

-- extend by point
function ShapeBox:Extend(x,y,z)
	self.m_Min[1] = math_min(self.m_Min[1], x);
	self.m_Min[2] = math_min(self.m_Min[2], y);
	self.m_Min[3] = math_min(self.m_Min[3], z);
	self.m_Max[1] = math_max(self.m_Max[1], x);
	self.m_Max[2] = math_max(self.m_Max[2], y);
	self.m_Max[3] = math_max(self.m_Max[3], z);
end
