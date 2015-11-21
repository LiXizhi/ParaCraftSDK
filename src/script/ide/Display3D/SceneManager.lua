--[[
Title: 
Author(s): Leio
Date: 2009/8/17
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Storyboard/Storyboard.lua");
NPL.load("(gl)script/ide/Display3D/SceneManager.lua");
NPL.load("(gl)script/ide/Display3D/SceneNode.lua");
local scene = CommonCtrl.Display3D.SceneManager:new();
local rootNode = CommonCtrl.Display3D.SceneNode:new{
	root_scene = scene,
}
local container_node = CommonCtrl.Display3D.SceneNode:new{
	node_type = "container",
	x = 0,
	y = 0,
	z = 0,
	visible = true,
};
local node_1 = CommonCtrl.Display3D.SceneNode:new{
	x = 255,
	y = 0,
	z = 255,
	assetfile = "model/06props/shared/pops/muzhuang.x",
};
container_node:AddChild(node_1);
local node_2 = CommonCtrl.Display3D.SceneNode:new{
	x = 255,
	y = 3,
	z = 255,
	assetfile = "model/06props/shared/pops/muzhuang.x",
};
container_node:AddChild(node_2);
local node_3 = CommonCtrl.Display3D.SceneNode:new{
	x = 255,
	y = 0,
	z = 255,
	assetfile = "character/v5/01human/Sophie/Sophie.x",
	ischaracter = true,
};
container_node:AddChild(node_3);
rootNode:AddChild(container_node);

--rootNode:Detach();
--container_node:Detach();
--node_1:Detach();
--node_2:Detach();

local storyboard = CommonCtrl.Storyboard.Storyboard:new();
storyboard:SetDuration(100);
storyboard.OnPlay = function(s)
	container_node:SetVisible(true);
end
storyboard.OnUpdate = function(s)
	local x,y,z = container_node:GetPosition();
	container_node:SetPosition(x+0.05,y,z);
end
storyboard.OnEnd = function(s)
	container_node:SetVisible(false);
end
storyboard:Play();
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/Display3D/SceneNode.lua");
local SceneManager = {
	uid = nil,
	type = "scene", --"scene" or "miniscene",
	pools = {},
}
commonlib.setfield("CommonCtrl.Display3D.SceneManager",SceneManager);

function SceneManager:new (o)
	o = o or {}   -- create object if user does not provide one
	o.Nodes = {};
	setmetatable(o, self)
	self.__index = self
	o:Init();
	return o
end
function SceneManager:Init()
	local uid = self.uid or ParaGlobal.GenerateUniqueID();
	self.uid = uid;
	if(self.type == "miniscene")then
		self.miniScene = ParaScene.GetMiniSceneGraph("container"..uid);
	end
end
--[[
	node_type = "single", -- "single" or "container"
	x = 0,
	y = 0,
	z = 0,
	facing = 1,
	visible = true,
	assetfile = "model/06props/shared/pops/muzhuang.x",
	ischaracter = false,
	entityid = nil,
	--]]
function SceneManager:CreateEntity(params)
	local entity_params = {
		name = params.name,
		x = params.x,
		y = params.y,
		z = params.z,
		AssetFile = params.assetfile,
		rotation = params.rotation,
		facing = params.facing,
		IsCharacter = params.ischaracter,
	}

	local entity = ObjEditor.CreateObjectByParams(entity_params);
	if(entity and entity:IsValid())then
		-- head on text
		if(params.headontext) then
			entity:SetHeadOnText(params.headontext,0);
			if(params.headontextcolor) then
				entity:SetHeadOnTextColor(params.headontextcolor,0);
			end
		end
		-- render technique to use
		if(params.render_tech) then
			entity:SetField("render_tech", params.render_tech);
		end

		if(params.physics_group) then
			entity:SetPhysicsGroup(params.physics_group);
		end

		if(self.type == "miniscene" and self.miniScene)then
			self.miniScene:AddChild(entity);
		else
			ParaScene.Attach(entity);
		end
		entity:GetAttributeObject():SetField("progress",1);
		return entity;
	end
end
function SceneManager:DestroyEntity(id)
	local entity = self:GetEntity(id)
	if(entity and entity:IsValid())then
		if(self.type == "miniscene" and self.miniScene)then
			self.miniScene:DestroyObject(entity);
		else
			ParaScene.Delete(entity);
		end
		return true;
	end
end
function SceneManager:GetEntity(id)
	id = tonumber(id);
	if(not id)then return end
	local entity = ParaScene.GetObject(id);
	if(entity and entity:IsValid())then
		return entity;
	end
end

function SceneManager:GetEntityByUID(uid)
	if(not uid)then return end
	if(self.type == "miniscene" and self.miniScene)then
		local entity = self.miniScene:GetObject(uid);
		if(entity and entity:IsValid())then
			return entity;
		end
	else
		local entity = ParaScene.GetObject(uid);
		if(entity and entity:IsValid())then
			return entity;
		end
	end
end

function SceneManager:UpdateEntity(params, childnode)
	if(not params)then return end
	local id = params.entityid;
	local entity = self:GetEntity(id);
	if(entity)then
		local x,y,z = params.x,params.y,params.z;
		local dx,dy,dz = params.dx,params.dy,params.dz;
		local facing = params.facing;
		local scaling = params.scaling;
		local visible = params.visible;
		local ischaracter = params.ischaracter;
		local rotation = params.rotation;
		local update_with_character = params.update_with_character;
		-- visible
		local _visible = entity:IsVisible();
		if(_visible ~= visible)then
			if(visible == false or visible == nil)then
				if(self.type == "scene")then
					entity:SetVisible(visible);
					ParaScene.Detach(entity)
					entity:CallField("addref");
				else
					entity:SetVisible(visible);
				end
				return
			else
				if(self.type == "scene")then
					entity:SetVisible(visible);
					ParaScene.Attach(entity)
					entity:CallField("release");
				else
					entity:SetVisible(visible);
				end
			end
		end
		--position
		
		if(ischaracter)then
			if(update_with_character)then
				if(dx and dy and dz)then
					entity:ToCharacter():MoveTo(dx,dy,dz);
				end
			else
				local _x,_y,_z = entity:GetPosition();
				if(_x ~= x or _y ~= y or _z ~= z)then
					if(x and y and z)then
						entity:SetPosition(x,y,z);
					end
				end
			end
		else
			local _x,_y,_z = entity:GetPosition();
			if(_x ~= x or _y ~= y or _z ~= z)then
				if(x and y and z)then
					entity:SetPosition(x,y,z);
				end
			end
		end
		--facing
		local _facing = entity:GetFacing();
		if(facing and _facing ~= facing)then
			entity:SetFacing(facing);
		end
		
		--scaling
		local _scaling = entity:GetScale();
		if(scaling and _scaling ~= scaling)then
			entity:SetScale(scaling);
		end

		-- rotation is only for model 
		if(not ischaracter and rotation and rotation.w) then
			local _rotation = entity:GetRotation({});
			if(_rotation.x ~= rotation.x or _rotation.y ~= rotation.y or _rotation.z ~= rotation.z or _rotation.w ~= rotation.w) then
				entity:SetRotation(rotation);
			end
		end

		-- head on text
		if(params.headontext) then
			entity:SetHeadOnText(params.headontext,0);
			if(params.headontextcolor) then
				entity:SetHeadOnTextColor(params.headontextcolor,0);
			end
		end
		-- render technique to use
		if(params.render_tech) then
			entity:GetAttributeObject():SetField("render_tech", params.render_tech);
		end

		--if(self.type == "scene")then
			--ParaScene.Attach(entity)
		--end

		if(self.OnUpdateEntity) then
			self.OnUpdateEntity(entity, params, childnode);
		end
	end
end

-- mouse pick and return the id. 
-- @param filter: string name of the filter to be used.  if nil, it defaults to pick everything. 
-- "4294967295" means everything. One can also pick by physics group, "p:1" means only pick for physics group 0.
function SceneManager:MousePickID(filter)
	local obj;
	if(self.type == "scene")then
		obj = ParaScene.MousePick(40, filter or "4294967295");		
		if(obj and obj:IsValid()) then
			return obj:GetID();
		end
	else
		if(self.miniScene)then
			-- use current mouse position
			local x, y = ParaUI.GetMousePosition();
			local obj = self.miniScene:MousePick(x,y,40, filter or "4294967295");	
			if(obj and obj:IsValid()) then
				return obj:GetID();
			end
		end
	end
end

-- toggle scene headon display. by default, miniscenegraph head on is disabled. 
function SceneManager:ShowHeadOnDisplay(bShow)
	if(self.type == "scene")then
		-- TODO: 
	else
		if(self.miniScene)then
			self.miniScene:ShowHeadOnDisplay(bShow);
		end
	end
end
function SceneManager.AddScene(name,scene)
	if(not name)then return end
	SceneManager.pools[name] = scene;
end
function SceneManager.GetScene(name)
	if(not name)then return end
	return SceneManager.pools[name];
end

