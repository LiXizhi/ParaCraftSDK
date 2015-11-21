--[[
Title: Base class for all 3D editors for IDE property
Author(s): LiXizhi
Date: 2010/6/7
Desc: The most important function to editor helpers is databind.
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/IPCBinding/EntityHelperEditorBase.lua");
local EditorBase = commonlib.gettable("IPCBinding.Editors.EditorBase");
local my_editor = EditorBase:new();
my_editor:DataBind(instance, "uid")
------------------------------------------------------
]]
NPL.load("(gl)script/ide/IPCBinding/BindableObject.lua");
NPL.load("(gl)script/ide/IPCBinding/EntityDesign.lua");
local EntityDesign = commonlib.gettable("IPCBinding.EntityDesign");

local EditorBase = commonlib.inherit(nil, commonlib.gettable("IPCBinding.Editors.EditorBase"));

function EditorBase:ctor()
end

-- bind a given perperty of an entity instance to this editor instance. 
function EditorBase:DataBind(instance, property_name)
	self.instance = instance;
	self.property_name = property_name;
	local template = instance.template;
	self.prop = template:GetPropertyDesc(property_name);
	self.style = self.prop.style;

	self.is_array = (self.prop.value_serializer=="array");

	self.has_editor = (self:GetAttribute("editor") ~= nil);

	if(self.has_editor) then
		-- now attach the 3d editor.
		instance:AttachEditor(property_name, self);
	end
end


-- whether this object can be selected by mouse events. 
function EditorBase:CanSelect()
	return true;
end

-- set value of the binded instance property and inform IDE about the changes. 
function EditorBase:SetValue(value)
	self.instance:SetValue(self.property_name, value);
end

-- the user has modified the position of the editor from 3d scene. 
-- we will modify the property value if it is a position table type. 
function EditorBase:SetPosition(x,y,z)
	if(self.prop.type == "table") then
		local old_value = self:GetValue(nil);
		if(old_value and old_value[1]) then 
			self:SetValue({x, y, z});
		else
			self:SetValue({x=x, y=y, z=z});
		end
	end
end

-- get value of the binded instance property 
-- @param default_value: default value, which can be nil. 
function EditorBase:GetValue(default_value)
	return self.instance:GetValue(self.property_name, default_value);
end

-- Get a given editor style attribute. 
-- please note that attr_value can reference another property on the binded instance if attr_value is a string surrounded by square brackets
function EditorBase:GetAttribute(name, default_value)
	local attr_value = self:GetStyle(name);
	if(type(attr_value) == "string") then
		local ref_name = string.match(attr_value, "^%[(.+)%]$");
		if(ref_name) then
			-- if attr_value is referencing another property on the object. 
			return self.instance:GetValue(ref_name, default_value);
		end
	end
	return attr_value;
end

-- get attribute as a number value
-- @return nil or a number value
function EditorBase:GetAttributeNumber(name, default_value)
	return tonumber(self:GetAttribute(name, default_value));
end

-- get attribute as a vector 3
-- the input attribute field can be commar seperated string, or a table array , or a table with x,y,z,w
-- return a table {x=x, y=y, z=z}
function EditorBase:GetAttributeVector3(name, default_value)
	local value = self:GetAttribute(name, default_value);
	local value_type = type(value);
	if(value_type == "table" and not value.x and value[1]) then
		value = {x = value[1], y = value[2], z = value[3]}
	elseif(value_type == "string")then
		local x,y,z = value:match("^([^,]+),([^,]+),([^,]+)");
		value = {x = tonumber(x), y = tonumber(y), z = tonumber(z)};
	end
	return value;
end

-- get attribute as a vector 4
-- the input attribute field can be commar seperated string, or a table array , or a table with x,y,z,w
-- return a table {x=x, y=y, z=z, w=w}
function EditorBase:GetAttributeVector4(name, default_value)
	local value = self:GetAttribute(name, default_value);
	local value_type = type(value);
	if(value_type == "table" and not value.x and value[1]) then
		value = {x = value[1], y = value[2], z = value[3], w = value[4]}
	elseif(value_type == "string")then
		local x,y,z,w = value:match("^([^,]+),([^,]+),([^,]+),([^,]+)");
		value = {x = tonumber(x), y = tonumber(y), z = tonumber(z), w = tonumber(w)};
	end
	return value;
end

-- Set a given editor style attribute.  Since most editor style attribute are read-only, we will only set if the attribute is binded to another property of the binded instance.  
-- please note that it does not take effect if the attribute is not referencing another property value on the binded instance. 
function EditorBase:SetAttribute(name, value)
	local attr_value = self:GetStyle(name);
	if(type(attr_value) == "string") then
		local ref_name = string.match(attr_vale, "^%[(.+)%]$");
		if(ref_name) then
			-- if attr_value is referencing another property on the object. 
			self.instance:SetValue(ref_name, value);
		end
	end
end

-- get a given style object by name. 
-- @param keyname: the style name, such as "editor", "editor-center", "editor-model-mesh", "editor-model-facing", "editor-file-filter", "editor-file-initialdir", "container-name", 
-- @return: nil or the value string (most are strings)
function EditorBase:GetStyle(keyname, default_value)
	if(self.style) then
		return self.style[keyname] or default_value;
	end
end

-- get the 3d entity scene node representing the current binded instance
-- please note that the entity scene node contains editor child nodes, such as position, facing, scaling, etc. 
-- @param bDoNotCreate: if nil, it will try to create one if exist, otherwise it will not try to create it. 
-- @return the scene node or nil. 
function EditorBase:GetEntitySceneNode(bDoNotCreate)
	if(not self.has_editor) then return end

	local entity_node = self.instance.entity_node;
	if(entity_node) then
		return entity_node;
	elseif(not bDoNotCreate) then
		-- create the entity node if it does not exist. 
		local rootNode = EntityDesign:GetRootNode();
		if(rootNode) then
			local container_name = self:GetStyle("container-name");
			if(container_name) then
				entity_node = rootNode:GetFirstLevelChildByUID(container_name);
				
				if(not entity_node) then
					entity_node = CommonCtrl.Display3D.SceneNode:new{
						uid = container_name, 
						node_type = "container",
						visible = true,
						-- a private tag that if true, meaning that several entity instance may share it and only one is displayed. 
						is_shared_node_ = true,
					};
					rootNode:AddChild(entity_node);
				end
				self.instance.entity_node = entity_node;
				return entity_node;
			else
				local model_center = self:GetAttributeVector3("editor-model-center")
				if(model_center) then
					entity_node = CommonCtrl.Display3D.SceneNode:new{
						node_type = "container",
						--x = model_center.x,
						--y = model_center.y,
						--z = model_center.z,
						visible = true,
					};
					rootNode:AddChild(entity_node);
					self.instance.entity_node = entity_node;
					return entity_node;
				end
			end
		end
	end
end

-- remove any visualizer
function EditorBase:RemoveView()
	if(not self.has_editor) then return end
	
	-- do not create
	local entity_node = self.instance.entity_node;
	if(entity_node) then
		self.instance.entity_node = nil;
		entity_node:Detach();
	end
end

-- visualize this editor in the scene using the mesh editor model.
-- @param bUpdateEntity: if nil it is true. if false, it means that we will not update entity
function EditorBase:UpdateView(bUpdateEntity)
	local entity_node = self:GetEntitySceneNode()

	if(not entity_node) then
		return 
	end

	local model_mesh = self:GetAttribute("editor-model-mesh")
	local model_center = self:GetAttributeVector3("editor-model-center")
	local model_facing = self:GetAttributeNumber("editor-model-facing")
	local model_rotation = self:GetAttributeVector4("editor-model-rotation")
	if(model_rotation and not model_rotation.w) then
		model_rotation = nil;
	end
	local model_scaling = self:GetAttributeNumber("editor-model-scaling")
	
	local model_scale = self:GetAttributeNumber("editor-model-scale")
	if(model_scale) then
		model_scaling = (model_scaling or 1)*model_scale
	end
	local model_headontext = self:GetAttribute("editor-model-headontext")
	local model_headontextcolor = self:GetAttribute("editor-model-headoncolor") or "0 255 0"
	local model_physicsgroup =  self:GetAttributeNumber("editor-physicsgroup")
						
	if(not model_mesh) then
		return;
	end

	-- for shared node, always update position relative to current player position. 
	-- position is always relative to current player
	if(entity_node.is_shared_node_) then
		local x, y, z = ParaScene.GetPlayer():GetPosition();
		if(model_center) then
			x = x + model_center.x;
			y = y + model_center.y;
			z = z + model_center.z;
		else
			model_center = {};
		end
		model_center.x = x;
		model_center.y = y;
		model_center.z = z;
	end

	local editor_node = self.editor_node;
	if(editor_node and editor_node.assetfile ~= model_mesh) then
		-- if primary asset is changed, we will delete and recreate the scene node. 
		editor_node:Detach();
		editor_node = nil;
	end
	
	if (not editor_node) then
		local ischaracter;
		if(model_mesh:match("^character/")) then
			ischaracter = true;
		end
		local x,y,z = 0,0,0;
		if(model_center) then
			x = model_center.x;
			y = model_center.y;
			z = model_center.z;
		end
		editor_node = CommonCtrl.Display3D.SceneNode:new{
			node_type = "single",
			x = x,
			y = y,
			z = z,
			assetfile = model_mesh,
			facing = model_facing,
			rotation = model_rotation,
			headontext = model_headontext,
			headontextcolor = model_headontextcolor,
			ischaracter = ischaracter,
			scaling = model_scaling,
			physics_group = model_physicsgroup,
			visible = true,
			tag = self, -- keep a reference here
		};
		self.editor_node = editor_node;

		entity_node:AddChild(editor_node);
	else
		if(model_center) then
			if(editor_node.x ~= model_center.x or editor_node.y ~= model_center.y or editor_node.z ~= model_center.z) then
				editor_node.x = model_center.x;
				editor_node.y = model_center.y;
				editor_node.z = model_center.z;
			end
		end
		editor_node.facing = model_facing;
		editor_node.scaling = model_scaling;
		editor_node.model_headontext = model_headontext;
		editor_node.model_headontextcolor = model_headontextcolor;
		editor_node.physics_group = model_physicsgroup;
		editor_node.rotation = model_rotation;

		if(not editor_node.isattached) then
			entity_node:AddChild(editor_node);
		elseif(bUpdateEntity~=false) then
			editor_node:UpdateEntity();
		end
	end
end

-- called whenever the user has selected the associated container
function EditorBase:IDEOnSelect()
	local entity_node = self:GetEntitySceneNode()
	if(not entity_node) then
		return 
	end
	if(entity_node.is_shared_node_)then
		self:UpdateView();
	end
end

-- called whenever the user has deselected the associated container
function EditorBase:IDEOnDeselect()
	local entity_node = self:GetEntitySceneNode()
	if(entity_node and entity_node.is_shared_node_) then
		entity_node:ClearAllChildren();
	end
end