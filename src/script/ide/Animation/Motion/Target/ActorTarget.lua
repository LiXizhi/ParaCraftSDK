--[[
Title: ActorTarget
Author(s): Leio Zhang
Date: 2008/10/30
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/Target/ActorTarget.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Animation/Motion/Target/BaseTarget.lua"); 
NPL.load("(gl)script/ide/commonlib.lua");
local ActorTarget = commonlib.inherit(CommonCtrl.Animation.Motion.BaseTarget, {
	Property = "ActorTarget",
	Owner = nil,
	ID = nil,
	AssetFile = nil,
	IsCharacter = nil,
	Facing = nil,
	Name = nil,
	Price = nil,
	X = nil,
	Y = nil,
	Z = nil,
	Animation = nil,
	Dialog = nil,
	RunTo_X = nil,
	RunTo_Y = nil,
	RunTo_Z = nil,
	Rot_X = nil,
	Rot_Y = nil,
	Rot_Z = nil,
	Scaling = nil,
	IsRunTo = nil,
	-- not use
	Visible = nil,
	NoOutPut = {Property = 0,Owner = 0,ID = 0,Price = 0,X = 0,Y = 0,Z = 0},
});
commonlib.setfield("CommonCtrl.Animation.Motion.ActorTarget",ActorTarget);
function ActorTarget:GetDefaultProperty(obj_params)
	if(obj_params)then
		self["AssetFile"] = obj_params["AssetFile"];
		self["IsCharacter"] = obj_params["IsCharacter"];
		self["Facing"] = self:FormatNumberValue(obj_params["facing"]);
		self["Name"] = obj_params["name"];
		self["Price"] = obj_params["price"];
		self["X"] = self:FormatNumberValue(obj_params["x"]);
		self["Y"] = self:FormatNumberValue(obj_params["y"]);
		self["Z"] = self:FormatNumberValue(obj_params["z"]);
		self["Animation"] = "";
		self["Dialog"] = "";
		self["RunTo_X"] = self:FormatNumberValue(obj_params["x"]);
		self["RunTo_Y"] = self:FormatNumberValue(obj_params["y"]);
		self["RunTo_Z"] = self:FormatNumberValue(obj_params["z"]);	
		self["Rot_X"] = 0;
		self["Rot_Y"] = 0;
		self["Rot_Z"] = 0;
		self["Scaling"] = 1;
		self["IsRunTo"] = true;
		self["Visible"] = true;
	else
		self["AssetFile"] = "";
		self["IsCharacter"] = true;
		self["Facing"] = 1;
		self["Name"] = "";
		self["Price"] = "";
		self["X"] = 0;
		self["Y"] = 0;
		self["Z"] = 0;
		self["Animation"] = "";
		self["Dialog"] = "";
		self["RunTo_X"] = 0;
		self["RunTo_Y"] = 0;
		self["RunTo_Z"] = 0;	
		self["Rot_X"] = 0;
		self["Rot_Y"] = 0;
		self["Rot_Z"] = 0;
		self["Scaling"] = 1;	
		self["IsRunTo"] = true;
		self["Visible"] = true;
	end
end
function ActorTarget:GetDifference(curTarget,nextTarget)
	if(not curTarget or not nextTarget)then return; end
	local result = CommonCtrl.Animation.Motion.ActorTarget:new();
	result["Owner"] = curTarget.Owner;
	result["IsRunTo"] = nextTarget.IsRunTo;
	result["Visible"] = curTarget.Visible;
	self:__GetDifference("Facing",result,curTarget,nextTarget);
	self:__GetDifference("X",result,curTarget,nextTarget);
	self:__GetDifference("Y",result,curTarget,nextTarget);
	self:__GetDifference("Z",result,curTarget,nextTarget);
	self:__GetDifference("RunTo_X",result,curTarget,nextTarget);
	self:__GetDifference("RunTo_Y",result,curTarget,nextTarget);
	self:__GetDifference("RunTo_Z",result,curTarget,nextTarget);
	self:__GetDifference("Rot_X",result,curTarget,nextTarget);
	self:__GetDifference("Rot_Y",result,curTarget,nextTarget);
	self:__GetDifference("Rot_Z",result,curTarget,nextTarget);
	self:__GetDifference("Scaling",result,curTarget,nextTarget);
	return result;
end
function ActorTarget:Update(curKeyframe,lastFrame,frame)
	local name = self:GetName();
	if(not name)then return; end
	local object = ParaScene.GetCharacter(name);
	if(object:IsValid())then
		self:CheckValue();	
		object:SetPosition(self.RunTo_X,self.RunTo_Y,self.RunTo_Z);		
		object:Rotate(self.Rot_X,self.Rot_Y,self.Rot_Z);
		object:SetScale(self.Scaling);
		object:SetFacing(self.Facing);
		--update visible
		object:SetVisible(self.Visible);
		
		-- update special value
		if(not curKeyframe or not lastFrame or not frame)then return; end
		local isActivate = curKeyframe:GetActivate();		
		if(isActivate)then
			object:ToCharacter():Stop();
			object:SetPosition(self.RunTo_X,self.RunTo_Y,self.RunTo_Z);
			
			Map3DSystem.Animation.PlayAnimationFile(self.Animation, object);
			if(self.Dialog ~="")then
				headon_speech.Speek(name, self.Dialog, math.random(4));
			end
		else
			local beginTarget = curKeyframe:GetValue();
			if(beginTarget)then
				if(not lastFrame)then
					lastFrame = frame;
				end 
				local t = frame - lastFrame;
				local x_change = self["RunTo_X"] -  beginTarget["RunTo_X"];
				local y_change = self["RunTo_Y"] -  beginTarget["RunTo_Y"];
				local z_change = self["RunTo_Z"] -  beginTarget["RunTo_Z"];
				x_change = x_change * t;
				y_change = y_change * t;
				z_change = z_change * t;
				if(x_change and y_change and z_change)then
					if(x_change ==0 and y_change==0 and z_change==0)then
						object:ToCharacter():Stop();
					else
						object:SetPosition(self.RunTo_X,self.RunTo_Y,self.RunTo_Z);
						if(Map3DSystem.Movie.MoviePlayerPage.playState == "playing")then
							if(self.IsRunTo)then
								object:MakeSentient(true)
								object:ToCharacter():GetSeqController():RunTo(x_change,y_change,z_change);
							else
								object:MakeSentient(true)
								object:ToCharacter():GetSeqController():WalkTo(x_change,y_change,z_change);
							end
						end					
					end
				end
			else
				object:ToCharacter():Stop();
			end
		end
	end
end
function ActorTarget:CheckValue()
	self.Facing = tonumber(self.Facing) or 1;
	self.X = tonumber(self.X) or 255;
	self.Y = tonumber(self.Y) or 0;
	self.Z = tonumber(self.Z) or 255;
	self.Rot_X = tonumber(self.Rot_X) or 0;
	self.Rot_Y = tonumber(self.Rot_Y) or 0;
	self.Rot_Z = tonumber(self.Rot_Z) or 0;
	self.Scaling = tonumber(self.Scaling) or 1;
	self.RunTo_X = tonumber(self.RunTo_X) or 255;
	self.RunTo_Y = tonumber(self.RunTo_Y) or 0;
	self.RunTo_Z = tonumber(self.RunTo_Z) or 255;
	if(self.Visible == nil)then
		self.Visible = true;
	end
	self.Animation = self.Animation or "";
	self.Dialog = self.Dialog or "";
end
function ActorTarget:ReverseToMcml()
	local mcmlTitle = self.Property;
	local k,v;
	local result = "";
	for k,v in pairs(self) do
		if(self.NoOutPut[k] ~= 0)then
			v = tostring(v) or "";
			local s = string.format('%s="%s" ',k,v);
			result = result .. s;
		end
	end
	local Dialog;
	if(self.Dialog and self.Dialog  ~= "")then
		Dialog = "<![CDATA["..self.Dialog.."]]>"
	else
		Dialog = "";
	end
	local str = string.format([[<%s %s>%s</%s>]],
			mcmlTitle,result,Dialog,mcmlTitle);
	return str;
end
function ActorTarget:GetMsgParams()

end