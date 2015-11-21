--[[
Title: Sprite3DTarget
Author(s): Leio Zhang
Date: 2008/10/30
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/Target/Sprite3DTarget.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display/Containers/Scene.lua");
NPL.load("(gl)script/ide/Animation/Motion/Target/BaseTarget.lua"); 
NPL.load("(gl)script/ide/commonlib.lua");
local Sprite3DTarget = commonlib.inherit(CommonCtrl.Animation.Motion.BaseTarget, {
	Property = "Sprite3DTarget",
	Owner = nil,
	X = nil,
	Y = nil,
	Z = nil,
	Alpha = nil,
	Facing = nil,
	Scaling = nil,
	Visible = nil,
	Animation = nil,
	Dialog = nil,
	NoOutPut = {Property = 0,Owner = 0,ID = 0},
});
commonlib.setfield("CommonCtrl.Animation.Motion.Sprite3DTarget",Sprite3DTarget);
function Sprite3DTarget:GetDefaultProperty()
	if(not self.DisplayObj)then return end
	self["Facing"] = self.DisplayObj:GetFacing();
	local x,y,z = self.DisplayObj:GetPosition();
	self["X"] = x;
	self["Y"] = y;
	self["Z"] = z;
	self["Alpha"] =  self.DisplayObj:GetAlpha();
	self["Visible"] = self.DisplayObj:GetVisible();
	self["Animation"] = "";
	self["Dialog"] = "";
end
function Sprite3DTarget:GetDifference(curTarget,nextTarget)
	if(not curTarget or not nextTarget)then return; end
	local result = CommonCtrl.Animation.Motion.Sprite3DTarget:new();
	result["Owner"] = curTarget.Owner;
	result["Visible"] = curTarget.Visible;
	self:__GetDifference("Facing",result,curTarget,nextTarget);
	self:__GetDifference("X",result,curTarget,nextTarget);
	self:__GetDifference("Y",result,curTarget,nextTarget);
	self:__GetDifference("Z",result,curTarget,nextTarget);
	self:__GetDifference("Alpha",result,curTarget,nextTarget);
	self:__GetDifference("Scaling",result,curTarget,nextTarget);
	return result;
end
function Sprite3DTarget:Update(curKeyframe,lastFrame,frame)
	local name = self:GetName();
	if(not name)then return end
	if(name == "sender" or name == "receiver")then	
		local effectInstance = self:GetEffectInstance();
		if(effectInstance)then
			local senderORreceiver = effectInstance:GetParams(name);
			if(senderORreceiver)then
				local player = ParaScene.GetPlayer();
				if(player:IsValid())then
					self:CheckValue();
					player:SetVisible(self.Visible);
					if(self.Visible)then	
						local _x,_y,_z = player:GetPosition();
						_x = self.X + _x;
						_y = self.Y + _y;
						_z = self.Z + _z;
						player:SetPosition(_x,_y,_z);		
						player:SetFacing(self.Facing);
						player:SetScale(self.Scaling);
					end
					-- update special value
					if(not curKeyframe or not lastFrame or not frame)then return; end
					local isActivate = curKeyframe:GetActivate();		
					if(isActivate)then
						player:ToCharacter():Stop();
				
						Map3DSystem.Animation.PlayAnimationFile(self.Animation, player);
						if(self.Dialog ~="")then
							headon_speech.Speek(player.name, self.Dialog, math.random(4));
						end
					end
				end
			end			
		end		
	else	
		local obj = CommonCtrl.Display.Containers.AllSceneChildren[name]
		if(not obj)then return; end
		self:CheckValue();
		obj:SetVisible(self.Visible);
		if(self.Visible)then	
			local _x,_y,_z = obj:GetPosition();
			_x = self.X-_x;
			_y = self.Y-_y;
			_z = self.Z-_z;
			obj:SetPositionDelta(_x,_y,_z);		
			obj:SetFacing(self.Facing);
			obj:SetScaling(self.Scaling);
			--obj:SetAlpha(self.Alpha);
		end
	end
end
function Sprite3DTarget:CheckValue()
	self.Facing = tonumber(self.Facing) or 1;
	self.X = tonumber(self.X) or 255;
	self.Y = tonumber(self.Y) or 0;
	self.Z = tonumber(self.Z) or 255;
	self.Scaling = tonumber(self.Scaling) or 1;
	self.Facing = tonumber(self.Facing) or 1;
	self.Alpha = tonumber(self.Alpha) or 1;
	if(self.Visible == nil)then
		self.Visible = true;
	end
end
function Sprite3DTarget:ReverseToMcml()
	
end
function Sprite3DTarget:GetMsgParams()

end