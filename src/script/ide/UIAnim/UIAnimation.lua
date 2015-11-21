--[[
Title: UI Animation
Author(s): WangTian
Date: 2007/9/30
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/UIAnim/UIAnimation.lua");

local ctl = UIAnimation:new{
	name = "UIAnimation1",
	text = "blarrrr",
	... = 0,
	*** = 300,
	};
ctl:getValue(1, 400);
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/UIAnim/UIAnimBlock.lua");
local type = type;
local UIAnimation = commonlib.gettable("UIAnimation")

local AllObjects = {};
local AutoCounter = 1;


function UIAnimation:new(o)
	o = o or {};
	
	if(not o.ScaleX
		or not o.ScaleY
		or not o.TranslationX
		or not o.TranslationY
		or not o.Rotation
		or not o.RotateOriginX
		or not o.RotateOriginY
		or not o.Alpha
		or not o.ColorR
		or not o.ColorG
		or not o.ColorB) then
		log("error: UIAnimBlock(s) missing in UIAnimation table.\r\n");
		return;
	end
	
	local k, v;
	for k, v in pairs(o) do
		o[k] = UIAnimBlock:new(v);
	end
	
	setmetatable(o, self);
	self.__index = self;
	
	if(o.name ~= nil and type(o.name) == "string") then
		UIAnimation.AddObject(o.name, o);
	else
		UIAnimation.AddObject("AutoObj_"..AutoCounter, o);
		o.name = "AutoObj_"..AutoCounter;
		AutoCounter = AutoCounter + 1;
	end
	
	o.tableType = "UIAnimation";
	
	return o;
end

function UIAnimation:Destroy()
	UIAnimation.DeleteObject(self.name);
	self = nil; -- TODO: still not nil
end

function UIAnimation.AddObject(ObjName, obj)
	AllObjects[ObjName] = obj;
end

function UIAnimation.DeleteObject(ObjName)
	local obj = AllObjects[ObjName];
	if(obj~=nil) then
		AllObjects[ObjName] = nil;
	end
end

function UIAnimation:GetStartFrame(animID)
	local timesID = self.TranslationX.ranges[animID][1];
	return self.TranslationX.times[timesID];
end

function UIAnimation:GetEndFrame(animID)
	local timesID = self.TranslationX.ranges[animID][2];
	return self.TranslationX.times[timesID];
end


function UIAnimation:GetTranslationXValue(animID, currentFrame)
	return self.TranslationX:getValue(animID, currentFrame);
end

function UIAnimation:GetTranslationYValue(animID, currentFrame)
	return self.TranslationY:getValue(animID, currentFrame);
end
function UIAnimation:GetScalingXValue(animID, currentFrame)
	return self.ScaleX:getValue(animID, currentFrame);
end
function UIAnimation:GetScalingYValue(animID, currentFrame)
	return self.ScaleY:getValue(animID, currentFrame);
end
function UIAnimation:GetRotationValue(animID, currentFrame)
	return self.Rotation:getValue(animID, currentFrame);
end
function UIAnimation:GetAlphaValue(animID, currentFrame)
	return self.Alpha:getValue(animID, currentFrame);
end
function UIAnimation:GetColorRValue(animID, currentFrame)
	return self.ColorR:getValue(animID, currentFrame);
end
function UIAnimation:GetColorGValue(animID, currentFrame)
	return self.ColorG:getValue(animID, currentFrame);
end
function UIAnimation:GetColorBValue(animID, currentFrame)
	return self.ColorB:getValue(animID, currentFrame);
end