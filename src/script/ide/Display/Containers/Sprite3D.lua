--[[
Title: Sprite3D
Author(s): Leio
Date: 2009/1/13
Desc: 
Sprite3D --> DisplayObjectContainer --> InteractiveObject --> DisplayObject --> EventDispatcher --> Object 
Sprite3D can be instance
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display/Containers/Sprite3D.lua");
local sprite3D = CommonCtrl.Display.Containers.Sprite3D:new()
sprite3D:Init();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display/Util/ObjectsCreator.lua");
NPL.load("(gl)script/ide/Display/DisplayObjectContainer.lua");
local Sprite3D = commonlib.inherit(CommonCtrl.Display.DisplayObjectContainer,{
	CLASSTYPE = "Sprite3D",
});  
commonlib.setfield("CommonCtrl.Display.Containers.Sprite3D",Sprite3D);
function Sprite3D:Init()
	self:ClearEventPools();
	self:ClearChildren();
end
------------------------------------------------------------
-- private methods
------------------------------------------------------------
------------------------------------------------------------
-- override parent methods:DisplayObjectContainer
------------------------------------------------------------
function Sprite3D:__BuildEntity(child)
	if(child)then		
		local root = child:GetRoot();
		local parent = child:GetParent();	
		local parent_isBuilded
		if(parent)then
			parent_isBuilded = parent:GetBuilded();
		end
		local isBuilded = child:GetBuilded();
		local classType = child.CLASSTYPE;
		if(classType == "Sprite3D")then
			if(parent_isBuilded)then
				child:SetBuilded(true);
			end
			local nSize = child:GetNumChildren();
			local i, node;
			for i=1, nSize do
				node = child:GetChildAt(i);
				if(node~=nil) then
					child:__BuildEntity(node)
				end
			end
		else		
			if(root and parent)then			
				if(parent_isBuilded and not isBuilded)then
					local params = child:GetEntityParams();
					local obj = CommonCtrl.Display.Util.ObjectsCreator.CreateObjectByParams(classType,params)
					if(root.AddObject)then
						root:AddObject(obj,child);
					end
				end
			end		
		end
	end
end
function Sprite3D:__DestroyEntity(child)
	if(child)then			
		local classType = child.CLASSTYPE;
		if(classType == "Sprite3D")then
			local nSize = child:GetNumChildren();		
			local i, node;
			for i=1, nSize do
				node = child:GetChildAt(i);
				if(node~=nil) then
					child:__DestroyEntity(node);
				end
			end
		else
			local root = self:GetRoot();
			if(root and root.RemoveObject)then		
				root:RemoveObject(child);	
			end	
		end
		
		--if(classType == "Actor3D" or classType == "Building3D" or classType == "ZoneNode" or classType == "PortalNode"  or classType == "Flower")then
			--local root = self:GetRoot();
			--if(root and root.RemoveObject)then		
				--root:RemoveObject(child);	
			--end
		--elseif(classType == "Sprite3D")then
			--local nSize = child:GetNumChildren();		
			--local i, node;
			--for i=1, nSize do
				--node = child:GetChildAt(i);
				--if(node~=nil) then
					--child:__DestroyEntity(node);
				--end
			--end
		--end
	end
end
------------------------------------------------------------
-- override parent methods:DisplayObject
------------------------------------------------------------
function Sprite3D:ClassToMcml()
	local params = self:GetEntityParams();
	local k,v;
	local result = "";
	for k,v in pairs(params) do
			if(type(v)~="table")then
				v = tostring(v) or "";
				local s = string.format('%s="%s" ',k,v);
				result = result .. s;
			end
	end
	
	local child_str = "";
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node~=nil) then
			child_str = child_str ..node:ClassToMcml().."\r\n";
		end
	end
	local title = self.CLASSTYPE;
	result =  string.format('<%s %s>%s</%s>',title,result,child_str,title);
	return result;
end
-- assetFile
function Sprite3D:SetAssetFile(assetFile)
	self.assetFile = assetFile;
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node~=nil) then
			node:SetAssetFile(assetFile);
		end
	end
end
-- facing
function Sprite3D:SetFacing(facing)
	self.facing = facing;
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node~=nil) then
			node:SetFacing(facing);
		end
	end
end
function Sprite3D:SetFacingDelta(facing)
	if(not facing)then return end
	local _facing = self:GetFacing();
	_facing = _facing + facing;
	self:SetFacing(_facing);
	
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node~=nil) then
			node:SetFacingDelta(facing);
		end
	end
end
-- alpha
function Sprite3D:SetAlpha(v)
	if(not v)then return end
	self.alpha = v;
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node~=nil) then
			local child_a = node:GetAlpha();
			if(child_a)then
				child_a = child_a * v;
				node:SetAlpha(child_a);
			end
		end
	end
end
-- rotation
function Sprite3D:SetRotation(x,y,z,w)
	self.rot_x,self.rot_y,self.rot_z,self.rot_w = x,y,z,w;
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node~=nil) then
			node:SetRotation(x,y,z,w);
		end
	end
end
-- scale
function Sprite3D:SetScale(x,y,z)
	self.scale_x,self.scale_y,self.scale_z = x,y,z;
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node~=nil) then
			node:SetScale(x,y,z);
		end
	end
end
-- scaling
function Sprite3D:SetScaling(scaling)
	self.scaling = scaling;
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node~=nil) then
			node:SetScaling(scaling);
		end
	end
end
function Sprite3D:SetScalingDelta(scaling)
	if(not scaling)then return end
	local _scaling = self:GetScaling();
	_scaling = _scaling + scaling;
	self:SetScaling(_scaling);
	
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node~=nil) then
			node:SetScalingDelta(scaling);
		end
	end
end
-- visible
function Sprite3D:SetVisible(v)
	self.visible = v;
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node~=nil) then
			node:SetVisible(v);
		end
	end
end
-- parent
function Sprite3D:SetParent(parent)
	self.parent = parent;
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node~=nil) then
			node:SetParent(self);
		end
	end
end
-- homezone
function Sprite3D:SetHomeZone(v)
	self.homezone = v;
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node~=nil) then
			node:SetHomeZone(v);
		end
	end
end
-- UpdateEntity
function Sprite3D:UpdateEntity()
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node~=nil) then
			node:UpdateEntity();
		end
	end
end
-- clone
function Sprite3D:Clone()
	local uid = self:GetUID();
	local entityID = self:GetEntityID();
	local parent = self:GetParent();
	local params = self:GetEntityParams();
	local clone_node = CommonCtrl.Display.Containers.Sprite3D:new();
	clone_node:Init();
	clone_node:SetUID(uid);
	clone_node:SetEntityID("");
	clone_node:SetParent(parent);
	clone_node:SetEntityParams(params);
	
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node~=nil) then
			clone_node:AddChild(node:Clone())
		end
	end
	
	return clone_node;
end
-- clone without id
function Sprite3D:CloneNoneID()
	local params = self:GetEntityParams();
	local clone_node = CommonCtrl.Display.Containers.Sprite3D:new();
	clone_node:Init();
	clone_node:SetEntityID("");
	clone_node:SetParent(parent);
	clone_node:SetEntityParams(params);
	
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node~=nil) then
			clone_node:AddChild(node:CloneNoneID())
		end
	end
	
	return clone_node;
end
function Sprite3D:SetSelected(v)
	self.internal_selected = v;
	--local nSize = table.getn(self.Nodes);
	--local i, node;
	--for i=1, nSize do
		--node = self.Nodes[i];
		--if(node~=nil) then
			--node:SetSelected(v);
		--end
	--end
end
function Sprite3D:GetSelected()
	return self.internal_selected;
end
function Sprite3D:HitTest()
	local result = -1;
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node~=nil) then
			result = node:HitTest();
			if(result == 0)then
				return result;
			end
		end
	end
	return result;
end
function Sprite3D:HitTestObject(startPoint,lastPoint)
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node~=nil) then
			local result = node:HitTestObject(startPoint,lastPoint);
			if(result == true)then
				return true;
			end
		end
	end
end
-- rotate input vector3 around a given point.
-- @param ox, oy, oz: around which point to rotate the input. 
-- @param a,b,c: radian around the X, Y, Z axis, such as 0, 1.57, 0
function Sprite3D:vec3RotateByPoint(ox, oy, oz, a, b, c)
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node~=nil) then
			node:vec3RotateByPoint(ox, oy, oz, a, b, c);
		end
	end
end
function Sprite3D:UpdatePlanesParam(facing)
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node~=nil) then
			node:UpdatePlanesParam(facing)
		end
	end
end