--[[
Title: DisplayObject
Author(s): Leio
Date: 2009/1/13
Desc: 
DisplayObject --> EventDispatcher --> Object 
 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display/DisplayObject.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display/EventDispatcher.lua");
local DisplayObject = commonlib.inherit(CommonCtrl.Display.EventDispatcher,{
	CLASSTYPE = "DisplayObject",
	index = 0,
	x = 0,
	y = 0,
	z = 0,
	rot_x = 0,
	rot_y = 0,
	rot_z = 0,
	rot_w = 1,
	facing = 0,
	scaling = 1,
	alpha = 1,
	visible = true,
	isCharacter = false,
	homezone = "",
	
	isBuilded = false,
});  
commonlib.setfield("CommonCtrl.Display.DisplayObject",DisplayObject);
------------------------------------------------------------
-- private methods
------------------------------------------------------------

------------------------------------------------------------
-- public methods
------------------------------------------------------------
function DisplayObject:Init()

end
-- progress
function DisplayObject:SetProgress(v)
	self.progress = v;
end
function DisplayObject:GetProgress()
	return self.progress;
end

-- isBuilded
function DisplayObject:SetBuilded(v)
	self.isBuilded = v;
end
function DisplayObject:GetBuilded()
	return self.isBuilded;
end
-- entity id
function DisplayObject:SetEntityID(v)
	v = tostring(v);
	self.entityID = v;
end
function DisplayObject:GetEntityID()
	return tostring(self.entityID);
end
function DisplayObject:RebuildEntity()
	
end
-- assetFile
function DisplayObject:GetAssetFile()
	return self.assetFile;
end
function DisplayObject:SetAssetFile(assetFile)
	if(self.assetFile == assetFile)then return end
	self.assetFile = assetFile;
end
-- facing
function DisplayObject:GetFacing()
	return self.facing;
end
function DisplayObject:SetFacing(facing)
	if(self.facing == facing)then return end
	self.facing = facing;
	self:UpdateEntity();
end
function DisplayObject:SetFacingDelta(facing)
	if(not facing or facing == 0)then return end
	local _facing = self:GetFacing();
	_facing = _facing + facing;
	self:SetFacing(_facing);
	self:UpdateEntity();
end
-- position
function DisplayObject:GetPosition()
	return self.x,self.y,self.z;
end
-- relative to the local coordinates of the parent DisplayObjectContainer.
function DisplayObject:SetPosition(x,y,z)
	if(not x or not y or not z)then return end
	self.x,self.y,self.z = x,y,z;	
	self:UpdateEntity();
end
function DisplayObject:SetPositionDelta(x,y,z)
	if(not x or not y or not z)then return end
	local _x,_y,_z = self:GetPosition();
	_x = _x + x;
	_y = _y + y;
	_z = _z + z;
	self:SetPosition(_x,_y,_z)
	self:UpdateEntity();
end
-- view box
function DisplayObject:GetViewBox()
	local root = self:GetRoot();
	if(root and root.GetEntity)then
		local entity = root:GetEntity(self)
		if(entity and entity:IsValid())then
			local box = entity:GetViewBox({}); 
			return box;
		end
	end
end
-- alpha
function DisplayObject:GetAlpha()
	return self.alpha;
end
function DisplayObject:SetAlpha(v)
	if(self.alpha == v)then return end
	self.alpha = v;
	self:UpdateEntity();
end
-- rotation
function DisplayObject:GetRotation()
	return self.rot_x,self.rot_y,self.rot_z,self.rot_w;
end
function DisplayObject:SetRotation(x,y,z,w)
	self.rot_x,self.rot_y,self.rot_z,self.rot_w = x,y,z,w;
	self:UpdateEntity();
end
-- scale
function DisplayObject:GetScale()
	return self.scale_x,self.scale_y,self.scale_z;
end
function DisplayObject:SetScale(x,y,z)
	self.scale_x,self.scale_y,self.scale_z = x,y,z;
	self:UpdateEntity();
end
-- scaling
function DisplayObject:GetScaling()
	return self.scaling;
end
function DisplayObject:SetScaling(scaling)
	if(self.scaling == scaling)then return end
	self.scaling = scaling;
	self:UpdateEntity();
end
function DisplayObject:SetScalingDelta(scaling)
	if(not scaling or scaling == 0)then return end
	local _scaling = self:GetScaling();
	_scaling = _scaling + scaling;
	self:SetScaling(_scaling);
	self:UpdateEntity();
end
-- visible
function DisplayObject:GetVisible()
	return self.visible;
end
function DisplayObject:SetVisible(v)
	--local old = self.visible;
	--local root = self:GetRoot();
	--if(old ~= v)then
		--if(v == false)then
			--root:RemoveObject(self);
		--else
			--root:AddObject(self);
		--end
	--end
	self.visible = v;
	self:UpdateEntity();
end
-- global to local
function DisplayObject:GlobalToLocal(point3D)
	if(not point3D)then return end
	local _x = point3D.x - self.x;
	local _y = point3D.y - self.y;
	local _z = point3D.z - self.z;
	
	local x,y,z = 0,0,0;
	local parent = self:GetParent();
	while (parent) do
		local px,py,pz = parent:GetPosition();
		x = x + px;
		y = y + py;
		z = z + pz;
		parent = parent:GetParent()
	end
	x = _x - x;
	y = _y - y;
	z = _z - z;
	return {x = x,y = y,z = z};
end
-- local to global
function DisplayObject:LocalToGlobal(point3D)
	if(not point3D)then return end
	local _x = point3D.x + self.x;
	local _y = point3D.y + self.y;
	local _z = point3D.z + self.z;
	
	local x,y,z = 0,0,0;
	local parent = self:GetParent();
	while(parent)do
		local px,py,pz = parent:GetPosition();
		x = x + px;
		y = y + py;
		z = z + pz;
		parent = parent:GetParent()
	end
	x = x + _x;
	y = y + _y;
	z = z + _z;
	return {x = x,y = y,z = z};
end
-- bounding box
function DisplayObject:GetBounds()

end
function DisplayObject:HasParent()
	if(self.parent)then
		return true;
	else
		return false;
	end
end
function DisplayObject:GetNodePath()
	local path = tostring(self.index);
	while (self.parent ~=nil) do
		path = self.parent.index.."/"..path;
		self = self.parent;
	end
	return path;
end
-- index
function DisplayObject:GetIndex()
	return self.index;
end
function DisplayObject:SetIndex(v)
	self.index = v;
end
-- parent
function DisplayObject:GetParent()
	return self.parent;
end
-- @param parent:DisplayObjectContainer can be nil
function DisplayObject:SetParent(parent)
	self.parent = parent;
end
function DisplayObject:UpdateEntity()
	
end
-- homezone
function DisplayObject:GetHomeZone()
	return self.homezone;
end
function DisplayObject:SetHomeZone(v)
	if(self.homezone == v)then return end
	self.homezone = v;
	self:UpdateEntity();
end
function DisplayObject:GetRoot()
	local result = self;
	local parent = self:GetParent();
	while(parent)do
		result = parent;
		parent = parent:GetParent();		
	end
	return result;
end
function DisplayObject:__Clone()

end
function DisplayObject:Clone()
	local uid = self:GetUID();
	local entityID = self:GetEntityID();
	local parent = self:GetParent();
	local params = self:GetEntityParams();
	local clone_node = self:__Clone()
	clone_node:Init();
	clone_node:SetUID(uid);
	clone_node:SetEntityID(entityID);
	clone_node:SetParent(parent);
	clone_node:SetEntityParams(params);
	clone_node:SetBuilded(false);
	if(params.rotation)then
		clone_node.rot_x = params.rotation.x;
		clone_node.rot_y = params.rotation.y;
		clone_node.rot_z = params.rotation.z;
		clone_node.rot_w = params.rotation.w;
	end
	return clone_node;
end
function DisplayObject:CloneNoneID()
	local params = self:GetEntityParams();
	local clone_node = self:__Clone()
	clone_node:Init();
	clone_node:SetEntityID("");
	clone_node:SetParent(nil);
	clone_node:SetEntityParams(params);
	clone_node:SetBuilded(false);
	if(params.rotation)then
		clone_node.rot_x = params.rotation.x;
		clone_node.rot_y = params.rotation.y;
		clone_node.rot_z = params.rotation.z;
		clone_node.rot_w = params.rotation.w;
	end
	return clone_node;
end
function DisplayObject:SetSelected(v)

end
function DisplayObject:GetSelected()

end
function DisplayObject:ClassToMcml()
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
	local title = self.CLASSTYPE;
	result =  string.format('<%s %s/>',title,result);
	return result;
end
function DisplayObject:SetEntityParams(params)
	self.x = params.x or 0;
	self.y = params.y or 0;
	self.z = params.z or 0;
	self.scaling=  params.scaling or 1;
	self.facing=  params.facing or 0;
	self.alpha = params.alpha or 1;
	self.visible = params.visible;
	self.isCharacter = params.IsCharacter;
	local file;
	if(self.isCharacter)then
		file = "character/v3/Human/Female/HumanFemale.xml";
	else
		file = "model/06props/shared/pops/muzhuang.x";
	end
	self.assetFile = params.AssetFile or file;
	self.homezone = params.homezone or "";
	local rotation = params.rotation;
	if(not rotation)then rotation = {}; end
	self.rot_x = rotation.rot_x or 0;
	self.rot_y = rotation.rot_y or 0;
	self.rot_z = rotation.rot_z or 0;
	self.rot_w = rotation.rot_w or 1;
end
function DisplayObject:GetEntityParams()
	local params = {};
	params.x = self.x;
	params.y = self.y;
	params.z = self.z;
	params.name = tostring(self:GetUID());
	params.IsCharacter = self.isCharacter;
	params.facing = self.facing;
	params.alpha = self.alpha;
	params.scaling = self.scaling;
	params.visible = self.visible;
	params.AssetFile = self.assetFile;
	params.homezone = self.homezone;
	
	local rotation={ w=self.rot_w, x=self.rot_x, y=self.rot_y, z=self.rot_z };
	params.rotation = rotation;
	return params;
end
function DisplayObject:HitTest()
	local root = self:GetRoot();
	if(root and root.HitTest)then
		if(root:HitTest(self))then
			return 0;
		end
	end
	return -1;
end
function DisplayObject:HitTestObject(startPoint,lastPoint)
	if(not startPoint or not lastPoint)then return end
		local _left, _top, _right, _bottom = startPoint.x,startPoint.y,lastPoint.x,lastPoint.y;
		if(not _left or not _top or not _right or not _bottom)then return end
		local left = math.min(_left,_right);
		local right = math.max(_left,_right);
		local top = math.min(_top,_bottom);
		local bottom = math.max(_top,_bottom);
	local result = {};
	if( not commonlib.partialcompare(left, right, Map3DSystem.App.Inventor.GlobalInventor.minDistance) or
			not commonlib.partialcompare(top, bottom, Map3DSystem.App.Inventor.GlobalInventor.minDistance)) then				
			ParaScene.GetObjectsByScreenRect(result, left, top, right, bottom, "4294967295", -1);
	end
	
	if(#result > 0)then
		local __,obj;
		for __,obj in ipairs(result) do
			local id = tostring(obj:GetID());
			local entityID = self:GetEntityID()
			if(id == entityID)then
				return true;		
			end
		end		
	end
end
-- rotate input vector3 around a given point.
-- @param ox, oy, oz: around which point to rotate the input. 
-- @param a,b,c: radian around the X, Y, Z axis, such as 0, 1.57, 0
function DisplayObject:vec3RotateByPoint(ox, oy, oz, a, b, c)
	local x,y,z = self.x,self.y,self.z;
	NPL.load("(gl)script/ide/math/math3d.lua");
	x,y,z = mathlib.math3d.vec3RotateByPoint(ox, oy, oz, x, y, z, a, b, c);

		self:SetPosition(x,y,z);	
		NPL.load("(gl)script/ide/mathlib.lua");
		local x,y,z,w = self:GetRotation();
		local q1 = {x = x, y = y, z = z,w = w};
		local q2;
		if(a~=0) then
			q2 = mathlib.QuatFromAxisAngle(1, 0, 0, a)
			q1 = mathlib.QuaternionMultiply(q1,q2);
		end
		if(b~=0) then
			q2 = mathlib.QuatFromAxisAngle(0, 1, 0, b)
			q1 = mathlib.QuaternionMultiply(q1,q2);
		end
		if(c~=0) then
			q2 = mathlib.QuatFromAxisAngle(0, 0, 1, c)
			q1 = mathlib.QuaternionMultiply(q1,q2);
		end
		self:SetRotation(q1.x,q1.y,q1.z,q1.w)
end
function DisplayObject:UpdatePlanesParam(facing)
end
------------------------------------------------------------
-- private methods
------------------------------------------------------------
