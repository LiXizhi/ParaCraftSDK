--[[
Title: KeyFrame
Author(s): Leio Zhang
Date: 2009/3/26
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Storyboard/KeyFrame.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Storyboard/TimeSpan.lua");
local KeyFrame = {
	KeyTime = "00:00:00",
	SimpleEase = 0,
	Target = nil,
}
commonlib.setfield("CommonCtrl.Storyboard.KeyFrame",KeyFrame);
function KeyFrame:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	o:Initialization();
	return o
end
function KeyFrame:Initialization()
	self.name = ParaGlobal.GenerateUniqueID();
end
function KeyFrame:SetParent(v)
	self.parent = v;
end
function KeyFrame:GetParent()
	return self.parent;
end
function KeyFrame:SetTarget(v)
	if(not v)then return end
	self.Target = v;
	v:SetParent(self);
end
function KeyFrame:GetTarget()
	return self.Target;
end
function KeyFrame:SetSimpleEase(v)
	self.SimpleEase = v;
end
function KeyFrame:GetSimpleEase()
	return self.SimpleEase;
end
function KeyFrame:SetKeyTime(v)
	self.KeyTime = v;
end
function KeyFrame:GetKeyTime()
	return self.KeyTime;
end
function KeyFrame:ToFrame()
	return CommonCtrl.Storyboard.TimeSpan.GetFrames(self.KeyTime);
end
function KeyFrame:SetActivate(v)
	self.Activate = v;
end
function KeyFrame:GetActivate(v)
	return self.Activate;
end