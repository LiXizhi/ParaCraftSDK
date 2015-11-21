--[[
Title: CameraTarget
Author(s): Leio Zhang
Date: 2008/10/27
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/Target/CameraTarget.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Animation/Motion/Target/BaseTarget.lua"); 
NPL.load("(gl)script/ide/commonlib.lua");
local CameraTarget = commonlib.inherit(CommonCtrl.Animation.Motion.BaseTarget, {
	Property = "CameraTarget",
	ID = nil,
	X = nil,
	Y = nil,
	Z = nil,
	Dist = nil,
	Angle = nil,
	RotY = nil,
});
commonlib.setfield("CommonCtrl.Animation.Motion.CameraTarget",CameraTarget);
function CameraTarget:GetDifference(curTarget,nextTarget)
	if(not curTarget or not nextTarget)then return; end
	local result = CommonCtrl.Animation.Motion.CameraTarget:new();
	result["Owner"] = curTarget.Owner;
	self:__GetDifference("X",result,curTarget,nextTarget);
	self:__GetDifference("Y",result,curTarget,nextTarget);
	self:__GetDifference("Z",result,curTarget,nextTarget);
	self:__GetDifference("Dist",result,curTarget,nextTarget);
	self:__GetDifference("Angle",result,curTarget,nextTarget);
	self:__GetDifference("RotY",result,curTarget,nextTarget);
	return result;
end
function CameraTarget:GetDefaultProperty()
	local x,y,z = ParaCamera.GetLookAtPos();
	x = self:FormatNumberValue(x) or 255;
	y = self:FormatNumberValue(y) or 255;
	z = self:FormatNumberValue(z) or 255;
	self.X,self.Y,self.Z = x,y,z;
	
	x,y,z = ParaCamera.GetEyePos();
	x = self:FormatNumberValue(x) or 1;
	y = self:FormatNumberValue(y) or 1;
	z = self:FormatNumberValue(z) or 1;
	self.Dist,self.Angle,self.RotY = x,y,z;
end
function CameraTarget:Update()
	self:CheckValue()	
	ParaCamera.SetLookAtPos(self.X,self.Y,self.Z); 
	ParaCamera.SetEyePos(self.Dist,self.Angle,self.RotY); 
end
function CameraTarget:CheckValue()
	self.X = tonumber(self.X) or 255;
	self.Y = tonumber(self.Y) or 0;
	self.Z = tonumber(self.Z) or 255;
	self.Dist = tonumber(self.Dist) or 1;
	self.Angle = tonumber(self.Angle) or 1;
	self.RotY = tonumber(self.RotY) or 1;
end