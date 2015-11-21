--[[
Title: A SceneNode in a SceneManager
Author(s): Leio
Date: 2009/8/17
Desc: the scene node can be a real obj (like static mesh or character), or it can be a logical container. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display3D/SceneNode.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/TreeNode.lua");
local SceneNode = {
	uid = nil,
	parent = nil, 
	Nodes = nil,
	index = 0,
	--it is a SceneManager instance,仅在最上层设置
	root_scene = nil,
	--是否已经创建
	isattached = false,

	-- if "single", it is a mesh or character model. If it is "container", the scene node is only a logical container
	node_type = "single", 
	--是否以character特有的属性更新，比如MoveTo
	update_with_character = false,
	old_x = 0,
	old_y = 0,
	old_z = 0,
	x = 0,
	y = 0,
	z = 0,
	facing = 0,
	scaling = 1,
	visible = true,
	-- nil or quat like {x=0,y=0,z=0,w=1}
	rotation = nil,
	assetfile = "model/06props/v5/01stone/EvngrayRock/EvngrayRock01.x",
	ischaracter = false,
	entityid = nil,
	tag = nil,--自定义的数据，它可以是常用数据类型，table number bool string
}
commonlib.setfield("CommonCtrl.Display3D.SceneNode",SceneNode);

function SceneNode:new (o)
	o = o or {}   -- create object if user does not provide one
	o.Nodes = {};
	setmetatable(o, self)
	self.__index = self
	o:Init();
	return o
end

function SceneNode:Init()
	local uid = self.uid or ParaGlobal.GenerateUniqueID();
	self.uid = uid;
	self.Nodes = {};
end

function SceneNode:SetUID(uid)
	self.uid = uid;
end
function SceneNode:GetUID()
	return self.uid;
end

--仅在最上层设置，it is a SceneManager instance
function SceneNode:SetRootScene(scene)
	self.root_scene = scene;
end

function SceneNode:GetChildCount()
	return table.getn(self.Nodes);
end

function SceneNode:GetChild(index)
	return self.Nodes[index];
end

function SceneNode:ClearAllChildren()
	local child;
	for child in self:Pre() do
		child:_Detach();
	end
	self.Nodes = {}
end
function SceneNode:SwapChildNodes(index1, index2)
	local node1 = self.Nodes[index1]
	local node2 = self.Nodes[index2]
	if(index1 ~= index2 and node1~=nil and node2~=nil) then
		node1.index, node2.index = index2, index1;
		self.Nodes[index1], self.Nodes[index2] = node2, node1;
	end
end

local function createNodeByParams(node)
	if(not node)then return end
	local params = node:GetParams();
	if(params)then
		local tag;
		if(node.tag)then
			tag = commonlib.deepcopy(node.tag);--clone 自定义数据
		end
		local new_node = CommonCtrl.Display3D.SceneNode:new{
			node_type = params.node_type,
			update_with_character = params.update_with_character,
			dx = params.dx,
			dy = params.dy,
			dz = params.dz,
			x = params.x,
			y = params.y,
			z = params.z,
			facing = params.facing,
			scaling = params.scaling,
			visible = params.visible,
			assetfile = params.assetfile,
			ischaracter = params.ischaracter,
			rotation = params.rotation,
			--entityid = entityid,
			tag = tag,
		}
		return new_node;
	end
end
local function clone(parent,cloned_parent)
	local node;
	for node in parent:Next() do
		if(node)then
			local new_node = createNodeByParams(node);
			if(cloned_parent and new_node)then
				cloned_parent:AddChild(new_node,nil,true);
				clone(node,new_node);
			end
		end
	end
end

--clone 所有的参数，不包括uid 和 entityid
function SceneNode:Clone()
	local cloned_parent = createNodeByParams(self);
	clone(self,cloned_parent);
	return cloned_parent;
end

function SceneNode:AddChild(o, index, noAttach)
	if(type(o) == "table") then
		local nSize = table.getn(self.Nodes);
		if(index == nil or index>nSize or index<=0) then
			-- add to the end
			self.Nodes[nSize+1] = o;
			o.index = nSize+1;
		else
			-- insert to the mid
			local i=nSize+1;
			while (i>index) do 
				self.Nodes[i] = self.Nodes[i-1];
				self.Nodes[i].index = i;
				i = i - 1;
			end
			self.Nodes[index] = o;
			o.index = index;
		end	
		-- for parent
		o.parent = self;
		
		local child = o;
		if(child and not noAttach)then
			child:BeforeAttach();
			child:_Attach();
			child:AfterAttach();
		end
	end	
end

function SceneNode:RemoveChildByIndex(index)
	if(not index)then return end;
	local node;
	for node in self:Next() do
		if(node and node.index == index)then
			node:Detach();
			return
		end
	end
end
function SceneNode:Detach()
	self:BeforeDetach();
	self:_Detach();
	self:AfterDetach();
	local parentNode = self.parent
	if(parentNode == nil) then
		return
	end
	local nSize = table.getn(parentNode.Nodes);
	local i, node;
	
	if(nSize == 1) then
		parentNode.Nodes[1] = nil;
		return;
	end
	
	local i = self.index;
	local node;
	if(i<nSize) then
		local k;
		for k=i+1, nSize do
			node = parentNode.Nodes[k];
			parentNode.Nodes[k-1] = node;
			if(node~=nil) then
				node.index = k-1;
				parentNode.Nodes[k] = nil;
			end	
		end
	else
		parentNode.Nodes[i] = nil;
	end	
end
function SceneNode:Pre()
	local nSize = table.getn(self.Nodes);
	local i = nSize;
	return function ()
		local node;
		while i > 0 do
			node = self.Nodes[i];
			i = i-1;
			return node;
		end
	end	
end
function SceneNode:Next()
	local nSize = table.getn(self.Nodes);
	local i = 1;
	return function ()
		local node;
		while i <= nSize do
			node = self.Nodes[i];
			i = i+1;
			return node;
		end
	end	
end
--获取所有的子节点，如果includeMySelf = true包括它自己
function SceneNode:GetAllChildren(includeMySelf)
	local result = {};
	function getChild(result,parent)
		if(result and parent)then
			local node;
			for node in parent:Next() do
				if(node)then
					table.insert(result,node);
					getChild(result,node);
				end
			end
		end
	end
	getChild(result,self);
	if(includeMySelf)then
		table.insert(result,self);
	end
	return result;
end

-- only called on parent or root node after detach. 
-- such as detaching from mini scene and attach to real scene. 
function SceneNode:Attach()
	self:BeforeAttach();
	self:_Attach();
	self:AfterAttach();
end

function SceneNode:_Attach()
	local scene = self:GetRootScene();
	local children_result = self:GetAllChildren(true);
	if(scene and children_result)then
		local k,child;
		for k,child in ipairs(children_result) do
			if(child and not child.isattached)then
				local params =  child:GetRenderParams();
				if(params)then
					local node_type = params.node_type;
					if(node_type == "single")then
						local entity = scene:CreateEntity(params);
						if(entity)then
							local id = entity:GetID();
							-- bind entity id to child
							child.entityid = id;
						end
						child.isattached = true;
					end
				end
			end
		end
		--更新所有child属性，包括它自己
		self:UpdateEntity();
	end
end
-- destroy the entity from the scene manager
function SceneNode:_Detach()
	local scene = self:GetRootScene();
	local children_result = self:GetAllChildren(true);
	if(scene and children_result)then
		local k,child;
		for k,child in ipairs(children_result) do
			if(child and child.isattached)then
				if(scene.use_name_key) then
					child:UpdateEntityIDFromUID();
				end
				local params =  child:GetRenderParams();
				local node_type = params.node_type;
				if(params and params.entityid and node_type == "single")then
					if(not scene:DestroyEntity(params.entityid)) then
						-- warning: entity id is not found. 
					end
				end
				child.isattached = false;
			end
		end
	end
end
function SceneNode:GetNodePath()
	local path = tostring(self.index);
	while (self.parent ~=nil) do
		path = self.parent.index.."/"..path;
		self = self.parent;
	end
	return path;
end
--是否包含child
function SceneNode:Contains(child)
	if(not child)then return end
	function findNode(parent,node,result)
		if(not parent or not node)then return end
		local c;
		for c in parent:Next() do
			if(c and c == node)then
				result = true;
				return
			end
		end
	end
	local result = false;
	findNode(self,child,result);
	return result;
end
----------------------------------------------属性
function SceneNode:SetEntityID(entityid)
	self.entityid = entityid;
end
function SceneNode:GetEntityID()
	return self.entityid;
end
function SceneNode:SetMoveTo(x,y,z)
	if(self.ischaracter)then
		self.update_with_character = true;
		self:SetPosition(x,y,z)
		self.update_with_character = false;
	end
end
--position
function SceneNode:SetPosition(x,y,z)
	self.old_x = self.x;
	self.old_y = self.y;
	self.old_z = self.z;
	self.x = x;
	self.y = y;
	self.z = z;
	self:UpdateEntity();
end
function SceneNode:GetPosition()
	return self.x,self.y,self.z;
end
-- position delta
function SceneNode:SetPositionDelta(dx,dy,dz)
	local x,y,z = self:GetPosition();
	x = x + dx;
	y = y + dy;
	z = z + dz;
	self:SetPosition(x,y,z)
end
--facing
function SceneNode:SetFacing(value)
	self.facing = value;
	self:UpdateEntity();
end
function SceneNode:GetFacing()
	return self.facing;
end
--facing delta
function SceneNode:SetFacingDelta(value)
	self.facing = self.facing + value;
	if(self.facing < 0)then
		self.facing = 6.28;
	elseif(self.facing > 6.28)then
		self.facing = 0;
	end
	self:UpdateEntity();
end
--scaling
function SceneNode:SetScale(value)
	self.scaling = value;
	self:UpdateEntity();
end
function SceneNode:GetScale()
	return self.scaling;
end
--scaling delta
function SceneNode:SetScalingDelta(value)
	self.scaling = self.scaling + value;
	if(self.scaling < 0)then
		self.facing = 0;
	elseif(self.facing > 100)then
		self.facing = 100;
	end
	self:UpdateEntity();
end
--visible
function SceneNode:SetVisible(value)
	self.visible = value;
	self:UpdateEntity();
end
function SceneNode:GetVisible()
	return self.visible;
end
function SceneNode:Float2(data)
	if(type(data) == "number") then
		local v = string.format("%.2f", data);
		v = tonumber(v);
		return v;
	end	
end
--这个函数是为了兼容 创建的函数
--主要是一些参数大小写不一致
function SceneNode:GetEntityParams()
	local params = self.entity_params;
	if(not params) then
		params = {}
		self.entity_params = params;
	end
	params.x = self:Float2(self.x);
	params.y = self:Float2(self.y);
	params.z = self:Float2(self.z);
	params.name = tostring(self:GetUID());
	params.IsCharacter = self.ischaracter;
	params.facing = self:Float2(self.facing);
	params.alpha = self:Float2(self.alpha);
	params.scaling = self:Float2(self.scaling);
	params.visible = self.visible;
	params.AssetFile = self.assetfile;
	params.homezone = self.homezone;
	params.rotation = self.rotation;
	return params;
end
--获取自己所有的参数
function SceneNode:GetParams()
	local params = self.params;
	if(not params) then
		params = {}
		self.params = params;
	end
	params.node_type = self.node_type;
	params.update_with_character = self.update_with_character;
	params.dx = self.dx;
	params.dy = self.dy;
	params.dz = self.dz;
	params.x = self.x;
	params.y = self.y;
	params.z = self.z;
	params.facing = self.facing;
	params.rotation = self.rotation;
	params.scaling = self.scaling;
	params.visible = self.visible;
	params.assetfile = self.assetfile;
	params.ischaracter = self.ischaracter;
	--params.entityid = self.entityid;
	params.tag = self.tag;
	
	return params;
end
--获取渲染是需要的参数
function SceneNode:GetRenderParams()
	local x,y,z = 0,0,0;
	local dx,dy,dz = self.x - self.old_x,self.y - self.old_y,self.z - self.old_z;
	local facing = self.facing;
	local scaling = 1; -- 
	local visible = true;
	local assetfile = self.assetfile;
	local ischaracter = self.ischaracter;
	local entityid = self.entityid;
	local node_type = self.node_type;
	local update_with_character = self.update_with_character;
	local parent = self;
	while(parent) do
		local _x,_y,_z = parent:GetPosition();
		x = x + _x;
		y = y + _y;
		z = z + _z;
		--local _facing = parent:GetFacing();
		local _scaling = parent:GetScale();
		--facing = facing * _facing
		scaling = scaling * _scaling
		local _visible = parent:GetVisible();
		if(_visible == false)then
			visible = false;
		end
		parent = parent.parent;
	end
	local render_params = self.render_params;
	if(not render_params) then
		render_params = {};
		self.render_params = render_params;
	end
	
	render_params.node_type = node_type;
	render_params.update_with_character = update_with_character;
	render_params.dx = dx;
	render_params.dy = dy;
	render_params.dz = dz;
	render_params.x = x;
	render_params.y = y;
	render_params.z = z;
	render_params.facing = facing;
	render_params.rotation = self.rotation;
	render_params.scaling = scaling;
	render_params.visible = visible;
	render_params.assetfile = assetfile;
	render_params.ischaracter = ischaracter;
	render_params.entityid = entityid;
	render_params.name = tostring(self:GetUID());
	if(self.headontext) then
		render_params.headontext = self.headontext;
		render_params.headontextcolor = self.headontextcolor;
	end
	render_params.physics_group =  self.physics_group;

	return render_params;
end
--获取scene manager
function SceneNode:GetRootScene()
	local parent = self;
	local root;
	while(parent) do
		root = parent;
		parent = parent.parent;
	end
	if(root and root.root_scene)then
		return root.root_scene;
	end
end
--获取 root node
function SceneNode:GetRootNode()
	local parent = self;
	local root;
	while(parent) do
		root = parent;
		parent = parent.parent;
	end
	return root;
end
function SceneNode:UpdateEntity()
	local scene = self:GetRootScene();
	local children_result = self:GetAllChildren(true);
	if(scene and children_result)then
		local k,child;
		for k,child in ipairs(children_result) do
			if(child and child.isattached)then
				local params =  child:GetRenderParams();
				scene:UpdateEntity(params, child);
			end
		end
	end
end
--获取实体对象
function SceneNode:GetEntity()
	if(self.node_type == "single")then
		local scene = self:GetRootScene();
		local entityid = self.entityid;
		if(scene and entityid)then
			local obj = scene:GetEntity(entityid);
			return obj;
		end
	end
end

function SceneNode:UpdateEntityIDFromUID()
	if(self.node_type == "single")then
		local scene = self:GetRootScene();
		local entityid = self.entityid;
		if(scene and entityid)then
			local obj = scene:GetEntity(entityid);
			if(not obj) then
				obj = scene:GetEntityByUID(self:GetUID())
				if(obj) then
					self:SetEntityID(obj:GetID());
				end
			end
		end
	end
end

--uid is a string
function SceneNode:GetChildByUID(id)
	if(not self.Nodes)then return end;
	id = tostring(id);
	if(not id)then return end
	local result;
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node) then
			
			if(node:GetUID() == id)then
				result = node;
				break;
			else
				if(node.GetChildByUID)then
					result = node:GetChildByUID(id)
				end			
			end
		end
	end
	return result;
end

-- get first level child b uid
function SceneNode:GetFirstLevelChildByUID(id)
	if(not self.Nodes)then return end;
	local result;
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node) then
			if(node:GetUID() == id)then
				result = node;
				break;
			end
		end
	end
	return result;
end

function SceneNode:GetChildByEntityID(id)
	if(not self.Nodes)then return end;
	if(not id)then return end
	local result;
	local nSize = table.getn(self.Nodes);
	local i, node;
	for i=1, nSize do
		node = self.Nodes[i];
		if(node) then
			if(node:GetEntityID() == id)then
				result = node;
				break;
			else
				if(node.GetChildByEntityID)then
					result = node:GetChildByEntityID(id)
					if(result)then
						break;
					end
				end			
			end
		end
	end
	return result;
end
-------------------------------------------------
--可以被重写的方法
-------------------------------------------------
--在创建实体之前
function SceneNode:BeforeAttach()

end
--在创建实体之后
function SceneNode:AfterAttach()

end
--在销毁实体之前
function SceneNode:BeforeDetach()

end
--在销毁实体之后
function SceneNode:AfterDetach()
end
function SceneNode:ClassToMcml()

end