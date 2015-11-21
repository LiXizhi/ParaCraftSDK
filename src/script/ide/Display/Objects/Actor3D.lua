--[[
Title: Actor3D
Author(s): Leio
Date: 2009/1/13
Desc: 
Actor3D --> InteractiveObject --> DisplayObject --> EventDispatcher --> Object
Actor3D can be instance
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display/Objects/Actor3D.lua");
local actor3D = CommonCtrl.Display.Objects.Actor3D:new()
actor3D:Init();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display/InteractiveObject.lua");
local Actor3D = commonlib.inherit(CommonCtrl.Display.InteractiveObject,{
	CLASSTYPE = "Actor3D",
	isCharacter = true,
});  
commonlib.setfield("CommonCtrl.Display.Objects.Actor3D",Actor3D);
function Actor3D:Init()
	self:ClearEventPools();
end
function Actor3D:RebuildEntity()
	local root = self:GetRoot();
	if(root)then
		local classType = self.CLASSTYPE;
		local params = self:GetEntityParams();
		local obj = CommonCtrl.Display.Util.ObjectsCreator.CreateObjectByParams(classType,params)
		root:RemoveObject(self);
		root:AddObject(obj,self);
		self:UpdateEntity();
	end
end
------------------------------------------------------------
-- override methods:DisplayObject
------------------------------------------------------------
function Actor3D:UpdateEntity()
	local root = self:GetRoot();
	if(root and root.GetEntity)then
		local entity = root:GetEntity(self)
		local class_type = root.CLASSTYPE;
		if(entity)then
			local visible = self.visible;
			-- visible
			if(visible == false)then
				if(class_type == "Scene")then
					ParaScene.Detach(entity)
					entity:CallField("addref");
				else
					entity:SetVisible(visible);
				end
				return
			else
				if(class_type == "Scene")then
					ParaScene.Attach(entity)
					entity:CallField("release");
				else
					entity:SetVisible(visible);
				end
			end
			--entity:SetVisible(visible);
			--if(not visible)then return end
			-- position
			local point3D = self:LocalToGlobal({x = 0, y = 0, z = 0})
			if(point3D)then
				entity:SetPosition(point3D.x,point3D.y,point3D.z);	-- render in the global coordinates of the scene 
			end
			-- rotation
			local x,y,z,w = self.rot_x,self.rot_y,self.rot_z,self.rot_w;
			if(x and y and z and w)then
				entity:SetRotation({x = x,y = y,z = z,w = w});	
			end
			-- scaling
			local scaling = self.scaling;
			if(scaling)then
				entity:SetScale(scaling);
			end
			-- facing
			local facing = self.facing;
			if(facing)then
				entity:SetFacing(facing)
			end
			-- homezone
			local homezone = self.homezone
			if(homezone)then
				entity:GetAttributeObject():SetField("homezone", s or "");
			end
			if(class_type == "Scene")then
				ParaScene.Attach(entity)
			end
		end
	end
end
function Actor3D:__Clone()
	return CommonCtrl.Display.Objects.Actor3D:new();
end
--function Actor3D:Clone()
	--local uid = self:GetUID();
	--local entityID = self:GetEntityID();
	--local parent = self:GetParent();
	--local params = self:GetEntityParams();
	--local clone_node = CommonCtrl.Display.Objects.Actor3D:new();
	--clone_node:Init();
	--clone_node:SetUID(uid);
	--clone_node:SetEntityID(entityID);
	--clone_node:SetParent(nil);
	--clone_node:SetEntityParams(params);
	--return clone_node;
--end
--function Actor3D:CloneNoneID()
	--local params = self:GetEntityParams();
	--local clone_node = CommonCtrl.Display.Objects.Actor3D:new();
	--clone_node:Init();
	--clone_node:SetEntityID("");
	--clone_node:SetParent(nil);
	--clone_node:SetEntityParams(params);
	--return clone_node;
--end
function Actor3D:SetSelected(v)
	self.internal_selected = v;
	local root = self:GetRoot();
	if(root and root.GetEntity)then
		local entity = root:GetEntity(self)
		if(entity)then
			if(v)then
				entity:GetAttributeObject():SetField("showboundingbox", true);
				--ParaSelection.AddObject(entity,1)
			else
				entity:GetAttributeObject():SetField("showboundingbox", false);
				--ParaSelection.ClearGroup(1);
			end
		end
	end
end
function Actor3D:GetSelected()
	return self.internal_selected;
end
------------------------------------------------------------
-- public methods
------------------------------------------------------------
--[[
{
["y"]=29.970724105835,
["IsCharacter"]=true,
["name"]="200811671944187-1185",
["facing"]=-2.7599999904633,
["price"]=0,
["AssetFile"]="character/v3/Human/Female/HumanFemale.xml",
["x"]=1310.0899658203,
["z"]=1868.4699707031,
}
--]]
