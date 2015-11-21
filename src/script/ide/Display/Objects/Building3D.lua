--[[
Title: Building3D
Author(s): Leio
Date: 2009/1/13
Desc: 
Building3D --> InteractiveObject --> DisplayObject --> EventDispatcher --> Object
Building3D can be instance
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display/Objects/Building3D.lua");
local building3D = CommonCtrl.Display.Objects.Building3D:new()
building3D:Init();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display/InteractiveObject.lua");
local Building3D = commonlib.inherit(CommonCtrl.Display.InteractiveObject,{
	CLASSTYPE = "Building3D"
});  
commonlib.setfield("CommonCtrl.Display.Objects.Building3D",Building3D);
function Building3D:Init()
	self:ClearEventPools();
end
function Building3D:RebuildEntity()
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
function Building3D:UpdateEntity()
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
					ParaScene.Attach(entity);
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
				entity:SetPosition(point3D.x,point3D.y,point3D.z);	-- render position in the global coordinates of the scene 
			end
			-- alpha
			local alpha =self:GetAlpha();
			if(alpha)then
				entity:GetAttributeObject():SetField("progress",alpha);
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
function Building3D:__Clone()
	return CommonCtrl.Display.Objects.Building3D:new();
end

--function Building3D:Clone()
	--local uid = self:GetUID();
	--local entityID = self:GetEntityID();
	--local parent = self:GetParent();
	--local params = self:GetEntityParams();
	--local clone_node = CommonCtrl.Display.Objects.Building3D:new();
	--clone_node:Init();
	--clone_node:SetUID(uid);
	--clone_node:SetEntityID(entityID);
	--clone_node:SetParent(nil);
	--clone_node:SetEntityParams(params);
	--return clone_node;
--end
--function Building3D:CloneNoneID()
	--local params = self:GetEntityParams();
	--local clone_node = CommonCtrl.Display.Objects.Building3D:new();
	--clone_node:Init();
	--clone_node:SetEntityID("");
	--clone_node:SetParent(nil);
	--clone_node:SetEntityParams(params);
	--return clone_node;
--end
function Building3D:SetSelected(v)
	self.internal_selected = v;
	local root = self:GetRoot();
	if(root and root.GetEntity)then
		local entity = root:GetEntity(self)
		if(entity)then
			if(v)then
				--entity:GetAttributeObject():SetField("showboundingbox", true);
				ParaSelection.AddObject(entity,1)
				entity:LoadPhysics();
			else
				--entity:GetAttributeObject():SetField("showboundingbox", false);
				ParaSelection.AddObject(entity,-1)
			end
		end
	end
end
function Building3D:IsLoadPhysics(entity)
	if(not entity)then return end
	if(entity:GetSelectGroupIndex()>=0) then
		return true;
	else
		return false;
	end
end
function Building3D:GetSelected()
	return self.internal_selected;
end
------------------------------------------------------------
-- public methods
------------------------------------------------------------
--[[
{
  AssetFile="model/06props/shared/pops/muzhuang.x",
  EnablePhysics=true,
  IsCharacter=false,
  ViewBox={
    obb_x=2.178240776062,
    obb_y=2.178240776062,
    obb_z=2.178240776062,
    pos_x=250.22796630859,
    pos_y=0.084271669387817,
    pos_z=256.05856323242 
  },
  facing=0,
  name="",
  rotation={ w=1, x=0, y=0, z=0 },
  scaling=1,
  x=250.1865234375,
  y=0.41087201237679,
  z=256.10507202148 
}
--]]