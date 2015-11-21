--[[
Title: SkyTarget
Author(s): Leio Zhang
Date: 2008/10/27
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/Target/SkyTarget.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Animation/Motion/Target/BaseTarget.lua"); 
NPL.load("(gl)script/ide/commonlib.lua");
local SkyTarget = commonlib.inherit(CommonCtrl.Animation.Motion.BaseTarget, {
	Property = "SkyTarget",
	ID = nil,
	SkyBoxFile = nil,
	SkyBoxName = nil,
	SkyColor_R = nil,
	SkyColor_G = nil,
	SkyColor_B = nil,
	Timeofday = nil,
	
	FogColor_R = nil,
	FogColor_G = nil,
	FogColor_B = nil,
	UseSimulatedSky = nil,
});
commonlib.setfield("CommonCtrl.Animation.Motion.SkyTarget",SkyTarget);
function SkyTarget:GetDifference(curTarget,nextTarget)
	if(not curTarget or not nextTarget)then return; end
	local result = CommonCtrl.Animation.Motion.SkyTarget:new();
	result["SkyBoxFile"] = curTarget.SkyBoxFile;
	result["SkyBoxName"] = curTarget.SkyBoxName;
	self:__GetDifference("SkyColor_R",result,curTarget,nextTarget);
	self:__GetDifference("SkyColor_G",result,curTarget,nextTarget);
	self:__GetDifference("SkyColor_B",result,curTarget,nextTarget);
	self:__GetDifference("Timeofday",result,curTarget,nextTarget);
	self:__GetDifference("FogColor_R",result,curTarget,nextTarget);
	self:__GetDifference("FogColor_G",result,curTarget,nextTarget);
	self:__GetDifference("FogColor_B",result,curTarget,nextTarget);
	return result;
end
function SkyTarget:GetDefaultProperty()
	NPL.load("(gl)script/kids/3DMapSystemUI/Env/SkyPage.lua");
	local item = Map3DSystem.App.Env.SkyPage.skyboxes[1];
	if(item)then
		self.SkyBoxFile = item.file
		self.SkyBoxName = item.name
	end
	self.Timeofday = self:FormatNumberValue(ParaScene.GetTimeOfDaySTD());
	
	local att = ParaScene.GetAttributeObject();
	if(att~=nil) then
		-- update sky color UI
		local color = ParaScene.GetAttributeObjectSky():GetField("SkyColor", {1, 1, 1});
		self.SkyColor_R,self.SkyColor_G,self.SkyColor_B = color[1],color[2],color[3]
		self.SkyColor_R = self:FormatNumberValue(self.SkyColor_R);
		self.SkyColor_G = self:FormatNumberValue(self.SkyColor_G);
		self.SkyColor_B = self:FormatNumberValue(self.SkyColor_B);
		
		-- update fog color UI
		color = att:GetField("FogColor", {1, 1, 1});
		self.FogColor_R,self.FogColor_G,self.FogColor_B = color[1],color[2],color[3]
		self.FogColor_R = self:FormatNumberValue(self.FogColor_R);
		self.FogColor_G = self:FormatNumberValue(self.FogColor_G);
		self.FogColor_B = self:FormatNumberValue(self.FogColor_B);
	end	
	local att = ParaScene.GetAttributeObjectSky();
	if(att~=nil) then
		self.UseSimulatedSky = att:GetField("SimulatedSky",false);
	end
	
end
function SkyTarget:Update(curKeyframe,lastFrame,frame)
	if (self.Timeofday) then
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, timeofday = self.Timeofday})
	end	
	
	local r,g,b = self.FogColor_R,self.FogColor_G,self.FogColor_B;
	if(r and g and b) then
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, fog_r = r, fog_g = g, fog_b = b,})
	end
	r,g,b = self.SkyColor_R,self.SkyColor_G,self.SkyColor_B;
	if(r and g and b) then
		Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, sky_r = r, sky_g = g, sky_b = b,})
	end
	-- update special value
	if(not curKeyframe or not lastFrame or not frame)then return; end
	local isActivate = curKeyframe:GetActivate();	
	if(isActivate)then
		if(self.SkyBoxFile and self.SkyBoxName) then	
			Map3DSystem.SendMessage_env({type = Map3DSystem.msg.SKY_SET_Sky, skybox = self.SkyBoxFile,  skybox_name = self.SkyBoxName})
		end
		local att = ParaScene.GetAttributeObjectSky();
		if(att~=nil) then
			att:SetField("SimulatedSky", self.UseSimulatedSky);
		end
	end
end