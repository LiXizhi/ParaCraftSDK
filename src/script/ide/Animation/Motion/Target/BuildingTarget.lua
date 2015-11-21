--[[
Title: BuildingTarget
Author(s): Leio Zhang
Date: 2008/10/30
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/Target/BuildingTarget.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Animation/Motion/Target/BaseTarget.lua"); 
NPL.load("(gl)script/ide/commonlib.lua");
local BuildingTarget = commonlib.inherit(CommonCtrl.Animation.Motion.BaseTarget, {
	Property = "BuildingTarget",
	Owner = nil,
	ID = nil,
	AssetFile = nil,
	EnablePhysics = nil,
	IsCharacter = nil,
	Obb_X = nil,
	Obb_Y = nil,
	Obb_Z = nil,
	Pos_X = nil,
	Pos_Y = nil,
	Pos_Z = nil,
	Name = nil,
	Rot_W = nil,
	Rot_X = nil,
	Rot_Y = nil,
	Rot_Z = nil,
	Scaling = nil,
	X = nil,
	Y = nil,
	Z = nil,
	Visible = nil,
	NoOutPut = {Property = 0,ID = 0,Owner = 0,InternalObj = 0},
});
commonlib.setfield("CommonCtrl.Animation.Motion.BuildingTarget",BuildingTarget);
function BuildingTarget:GetDifference(curTarget,nextTarget)
	if(not curTarget or not nextTarget)then return; end
	local result = CommonCtrl.Animation.Motion.BuildingTarget:new();
	result["Owner"] = curTarget.Owner;
	local obj = curTarget.InternalObj or nextTarget.InternalObj;
	curTarget.InternalObj = obj;
	nextTarget.InternalObj = obj;
	result["InternalObj"] = curTarget.InternalObj;
	result["Visible"] = curTarget.Visible;
	self:__GetDifference("X",result,curTarget,nextTarget);
	self:__GetDifference("Y",result,curTarget,nextTarget);
	self:__GetDifference("Z",result,curTarget,nextTarget);
	self:__GetDifference("Rot_X",result,curTarget,nextTarget);
	self:__GetDifference("Rot_Y",result,curTarget,nextTarget);
	self:__GetDifference("Rot_Z",result,curTarget,nextTarget);
	self:__GetDifference("Scaling",result,curTarget,nextTarget);	
	result["Obb_X"] = curTarget["Obb_X"];
	result["Obb_Y"] = curTarget["Obb_Y"];
	result["Obb_Z"] = curTarget["Obb_Z"];
	result["Pos_X"] = curTarget["Pos_X"];
	result["Pos_Y"] = curTarget["Pos_Y"];
	result["Pos_Z"] = curTarget["Pos_Z"];
	return result;
end
function BuildingTarget:GetDefaultProperty(obj_params)
	if(obj_params)then
		self["AssetFile"] = obj_params["AssetFile"];
		self["EnablePhysics"] = obj_params["EnablePhysics"];
		self["IsCharacter"] = obj_params["IsCharacter"];
		self["Obb_X"] = obj_params["ViewBox"]["obb_x"];
		self["Obb_Y"] = obj_params["ViewBox"]["obb_y"];
		self["Obb_Z"] = obj_params["ViewBox"]["obb_z"];
		self["Pos_X"] = obj_params["ViewBox"]["pos_x"];
		self["Pos_Y"] = obj_params["ViewBox"]["pos_y"];
		self["Pos_Z"] = obj_params["ViewBox"]["pos_z"];
		self["Name"] = obj_params["name"];
		self["Rot_W"] = obj_params["rotation"]["w"];
		self["Rot_X"] = obj_params["rotation"]["x"];
		self["Rot_Y"] = obj_params["rotation"]["y"];
		self["Rot_Z"] = obj_params["rotation"]["z"];
		self["Scaling"] = obj_params["scaling"];		
		self["X"] = obj_params["x"];
		self["Y"] = obj_params["y"];
		self["Z"] = obj_params["z"];
		self["Visible"] = obj_params["Visible"] or true;
	else
		self["AssetFile"] = "";
		self["EnablePhysics"] = false;
		self["IsCharacter"] = false;
		self["Obb_X"] = 0;
		self["Obb_Y"] = 0;
		self["Obb_Z"] = 0;
		self["Pos_X"] = 0;
		self["Pos_Y"] = 0;
		self["Pos_Z"] = 0;
		self["Name"] = "";
		self["Rot_W"] = 1;
		self["Rot_X"] =0;
		self["Rot_Y"] = 0;
		self["Rot_Z"] = 0;
		self["Scaling"] = 0;		
		self["X"] = 0;
		self["Y"] = 0;
		self["Z"] = 0;
		self["Visible"] = true;
	end
end
function BuildingTarget:GetInternalObj()
	local owner = self.Owner;
	if(owner)then
		local keyFrames = owner:GetParent();
		if(keyFrames)then
			local targetName = keyFrames.TargetName;
			local obj = CommonCtrl.Animation.Motion.TargetResourceManager[targetName]
			if(obj and obj:IsValid())then
				return obj;
			end
		end
	end
end
function BuildingTarget:Update(curKeyframe)
	local object = self:GetInternalObj()
	if(object and object:IsValid())then
		self:CheckValue();	
		object:SetPosition(self.X,self.Y,self.Z);	
		object:SetRotation({x = self.Rot_X, y = self.Rot_Y,z = self.Rot_Z,w = (self.Rot_W or 1)});
		object:SetScale(self.Scaling);
		
		--update visible
		object:SetVisible(self.Visible);
	end
end
function BuildingTarget:GetViewBox()
	local viewBox = {};
	viewBox["obb_x"] = self["Obb_X"];
	viewBox["obb_y"] = self["Obb_Y"];
	viewBox["obb_z"] = self["Obb_Z"];
	viewBox["pos_x"] = self["Pos_X"];
	viewBox["pos_y"] = self["Pos_Y"];
	viewBox["pos_z"] = self["Pos_Z"];
	
	return viewBox;
end
function BuildingTarget:SetViewBox(viewBox)
	if(not viewBox)then return; end
	self["Obb_X"] = viewBox["obb_x"];
	self["Obb_Y"] = viewBox["obb_y"];
	self["Obb_Z"] = viewBox["obb_z"];
	self["Pos_X"] = viewBox["pos_x"];
	self["Pos_Y"] = viewBox["pos_y"];
	self["Pos_Z"] = viewBox["pos_z"];

end
function BuildingTarget:CheckValue()
	self.X = tonumber(self.X) or 255;
	self.Y = tonumber(self.Y) or 0;
	self.Z = tonumber(self.Z) or 255;
	self.Rot_X = tonumber(self.Rot_X) or 0;
	self.Rot_Y = tonumber(self.Rot_Y) or 0;
	self.Rot_Z = tonumber(self.Rot_Z) or 0;
	self.Scaling = tonumber(self.Scaling) or 1;
	if(self.Visible == nil)then
		self.Visible = true;
	end
end
function BuildingTarget:GetMsgParams()
	local obj_params = { ViewBox = {}, rotation = {}}
	obj_params["AssetFile"] = self["AssetFile"];
	obj_params["EnablePhysics"] = self["EnablePhysics"];
	obj_params["IsCharacter"] = self["IsCharacter"];
		obj_params["ViewBox"]["obb_x"] = self["Obb_X"];
		obj_params["ViewBox"]["obb_y"] = self["Obb_Y"];
		obj_params["ViewBox"]["obb_z"] = self["Obb_Z"];
		obj_params["ViewBox"]["pos_x"] = self["Pos_X"];
		obj_params["ViewBox"]["pos_y"] = self["Pos_Y"];
		obj_params["ViewBox"]["pos_z"] = self["Pos_Z"];
		obj_params["name"] = self["Name"];
		obj_params["rotation"]["w"] = self["Rot_W"];
		obj_params["rotation"]["x"] = self["Rot_X"];
		obj_params["rotation"]["y"] = self["Rot_Y"];
		obj_params["rotation"]["z"] = self["Rot_Z"];
		obj_params["scaling"] = self["Scaling"];		
		obj_params["x"] = self["X"];
		obj_params["y"] = self["Y"];
		obj_params["z"] = self["Z"];
		obj_params["Visible"] = self["Visible"];
		
	return obj_params;
end
