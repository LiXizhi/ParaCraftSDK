--[[
Title: OceanTarget
Author(s): Leio Zhang
Date: 2008/10/27
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/Target/OceanTarget.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Animation/Motion/Target/BaseTarget.lua"); 
NPL.load("(gl)script/ide/commonlib.lua");
local OceanTarget = commonlib.inherit(CommonCtrl.Animation.Motion.BaseTarget, {
	Property = "OceanTarget",
	ID = nil,
	WaterLevel = nil,
	R = nil,
	G = nil,
	B = nil,
	Color = nil,
});
commonlib.setfield("CommonCtrl.Animation.Motion.OceanTarget",OceanTarget);
function OceanTarget:GetDifference(curTarget,nextTarget)
	if(not curTarget or not nextTarget)then return; end
	local result = CommonCtrl.Animation.Motion.OceanTarget:new();
	self:__GetDifference("R",result,curTarget,nextTarget);
	self:__GetDifference("G",result,curTarget,nextTarget);
	self:__GetDifference("B",result,curTarget,nextTarget);
	self:__GetDifference("WaterLevel",result,curTarget,nextTarget);
	return result;
end
function OceanTarget:GetDefaultProperty()
	local att = ParaScene.GetAttributeObjectOcean();
	if(att~=nil) then
		-- update Ocean color UI
		local color = att:GetField("OceanColor", {1, 1, 1});
		self.R = color[1];
		self.G = color[2];
		self.B = color[3];
		
		self.R = self:FormatNumberValue(self.R);
		self.G = self:FormatNumberValue(self.G);
		self.B = self:FormatNumberValue(self.B);
		
		self.Color = string.format("%d %d %d", self.R, self.G, self.B)
	end	
	self.WaterLevel = ParaScene.GetGlobalWaterLevel();
	self.WaterLevel = self:FormatNumberValue(self.WaterLevel);
end
function OceanTarget:Update()
	local r,g,b = self.R,self.G,self.B;
	local height = self.WaterLevel
	Map3DSystem.SendMessage_env({type = Map3DSystem.msg.OCEAN_SET_WATER, r = r, g = g, b = b,})
	Map3DSystem.SendMessage_env({type = Map3DSystem.msg.OCEAN_SET_WATER, height = height, bEnable = true})
end