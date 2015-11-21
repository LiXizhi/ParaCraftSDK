--[[
Title: Base class for entity object
Author(s): LiXizhi
Date: 2010/6/1
Desc: Custom entity template class can derived from this class. 
Some simple entity class can use this class directly, where all properties and logics can be defined in XML file. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/IPCBinding/EntityBase.lua");
IPCBinding.EntityBase:new("script/ide/IPCBinding/Entity/StaticMesh.xml")
------------------------------------------------------
]]
NPL.load("(gl)script/ide/IPCBinding/BindableObject.lua");
NPL.load("(gl)script/ide/IPCBinding/EntityHelperSerializer.lua");

local EntityBase = commonlib.inherit(IPCBinding.BindableObject, commonlib.gettable("IPCBinding.EntityBase"));

local InstanceView = commonlib.gettable("IPCBinding.InstanceView");
local EntityHelper = commonlib.gettable("IPCBinding.EntityHelper");

EntityBase.classTitle = {label = "EntityBase",};
EntityBase.props = {
		{ label = "uid", type="string", desc="unique id", },
		{ label = "worldfilter", type="string", desc="if empty, it means the current world. if .*, it means global.", },
		{ label = "codefile", type="string", desc="code behind file", },
		{ label = "template_file", type="string", desc="the template file used for creating the object", },
};
-- empty string or regular expression of the default desitnation that instance of this template should be put to 
-- e.g. if empty, it means the current world. if ".*", it means global.
EntityBase.worldfilter = "";

function EntityBase:ctor()
end

-- attach an editor to this entity instance
function EntityBase:AttachEditor(property_name, editor)
	self.editors = self.editors or {};
	self.editors[property_name] = editor;
end

-- know editor types
-- TODO: move this to a separate file. 
local editor_types = {
	["point"] = commonlib.gettable("IPCBinding.Editors.EditorBase"),
	["circle"] = commonlib.gettable("IPCBinding.Editors.EditorBase"),
	["facing"] = commonlib.gettable("IPCBinding.Editors.EditorBase"),
	["static-mesh-file"] = commonlib.gettable("IPCBinding.Editors.EditorBase"),
}

-- get property description table by property name. 
-- @return nil if not found. 
function EntityBase:GetPropertyDesc(property_name)
	local template = self.template;
	if (template) then
		return template:GetPropertyDesc(property_name);
	end
end

-- this function is usually called by the contructor to bind all property editors
function EntityBase:BindPropertyEditors()
	if(not self.editors and self.editor_names) then
		local _, editor_name;
		for _, editor_name in ipairs(self.editor_names) do
			local prop = self:GetPropertyDesc(editor_name);
			if(prop and prop.style and prop.style.editor) then
				local editor = editor_types[prop.style.editor];
				if(editor) then
					local propEditor = editor:new()
					propEditor:DataBind(self, prop.label);
				end
			end
		end
	end
end

-- update the 3d view. the IDE need to call this function when it wants to visualize(update) the 3D editor view of this object. 
function EntityBase:UpdateView()
	if (self.editors) then
		local _, editor
		for _, editor in pairs(self.editors) do
			editor:UpdateView();
		end
	end
end

function EntityBase:RemoveView()
	if (self.editors) then
		local _, editor
		for _, editor in pairs(self.editors) do
			editor:RemoveView();
		end
	end
end

-- IDE is requesting to create a new instance based on the given entity template and initial params
-- here we can immediately create the instance and invoke the callback or display some UI for collect more info from the user before invoke the callback. 
-- @param template:
-- @param params: some init table
-- @param callback: the callback function. 
-- @return the created instance object if it can be immediately created, otherwise it is none. 
function EntityBase.IDECreateNewInstance(template, params, callback)
	-- TODO: add more default ways to create instance
	local instance;
	local entity_class = template.class;
	if (entity_class) then
		instance = entity_class:new(params);
		if(template.attr.singleton == "true") then
			instance.uid = template.name or "default";
			LOG.std("", "debug", "IDECreateNewInstance", "new singleton entity instance created: uid %s (%s)", instance.uid, template.name);
		else
			instance.uid = instance.uid or ParaGlobal.GenerateUniqueID();
			LOG.std("", "debug", "IDECreateNewInstance", "new default entity instance created: uid %s (%s)", instance.uid, template.name);
		end
	end
	
	if(instance) then
		-- set template file
		-- instance.template_file = template.filename;
		
		-- set default worldfilter
		local worldfilter = template.attr.worldfilter;
		if(not worldfilter or worldfilter == "") then
			worldfilter = ParaWorld.GetWorldDirectory();
		end
		instance.worldfilter = worldfilter;

		-- set code file
		instance.codefile = instance:CreateGetCodeFile();

		if(callback) then
			callback(instance);
		end
	end
	return instance;
end

-- IDE is requesting to create from an existing instance that has not been tracked by the IDE in the game engine.  
-- the instance should already exist in the game engine environment. Different entity template may translate to different meaning, 
-- please note, if instance_filename contains multiple matching instances, then multiple object will be created. 
-- @param template: the entity template
-- @param instance_filename: the instance file name. if nil, we will create the default existing one, such as the currently selected object. 
-- @param callback: function(instance) end, when ever an instance is created, this is called. 
function EntityBase.IDECreateFromExisting(template, instance_filename, worldfilter, callback)
	-- TODO: add more default ways to create instance
	local instance;
	local entity_class = template.class;
	if (entity_class) then
		-- set default worldfilter
		worldfilter = worldfilter or template.attr.worldfilter;
		if(not worldfilter or worldfilter == "") then
			worldfilter = ParaWorld.GetWorldDirectory();
		end

		if(instance_filename) then
			if(template.serializer and template.serializer.LoadInstancesFromFile) then
				local instances = template.serializer.LoadInstancesFromFile(template, instance_filename, worldfilter);
				if(instances) then
					local _, instance
					for _, instance in ipairs(instances) do
						instance.worldfilter = worldfilter;

						if(callback) then
							callback(instance);
						end
					end
				end
			end
		else
			instance = entity_class:new();
			instance.uid = template.name or "default";
			instance.worldfilter = worldfilter;

			if(callback) then
				callback(instance);
			end
		end
	end
	return instance;
end

-- Get or create an existing instance. 
function EntityBase.IDELoadExistingInstance(template, uid, worldfilter, codefile)
	local entity_class = template.class;
	if (entity_class) then
			
		local instance = InstanceView.GetInstance(worldfilter, uid);
		if(not instance) then
			-- we will use the default serializer to do the job. 
			if(template.serializer and template.serializer.LoadInstance) then
				instance = template.serializer.LoadInstance(template, uid, worldfilter, codefile)
			else
				instance = entity_class:new();
				instance.uid = uid;
			end
			if(instance) then
				instance.worldfilter = worldfilter;
				InstanceView.AddInstance(instance, worldfilter);
			end
		end

		return instance;
	end
end

-- if code file is not generated, calling this function will generate the code file based on template's codefile 
function EntityBase:CreateGetCodeFile()
	if(not self.codefile or self.codefile == "") then
		local uid = self.uid;
		local worldpath = self.worldfilter;
		local template = self.template;
		local codefile = template.attr.codefile;
		if(not codefile) then
			if(template.name ~= uid) then
				codefile = string.format("[worldpath]/entity/%s_%s.xml", template.name, uid);
			else
				codefile = string.format("[worldpath]/entity/%s.xml", template.name);
			end
		end
		if(codefile) then
			worldpath = worldpath or ParaWorld.GetWorldDirectory()
			worldpath = string.gsub(worldpath, "/$", "");
			local worldname = string.match(worldpath, "([^/\\]+)$");

			-- note: one can add more replaceable strings here. 
			codefile = string.gsub(codefile, "%[worldpath%]", worldpath); 
			codefile = string.gsub(codefile, "%[worldname%]", worldname); 
			codefile = string.gsub(codefile, "%[uid%]", uid); 

			local bContinue = true;
			while (bContinue) do
				local preStr, prop_name, postStr = codefile:match("^(.-)%[([^%[%]]+)%](.*)$");
				if(prop_name) then
					local value = tostring(self:GetValue(prop_name));
					if(value) then
						codefile = preStr..value..postStr; 
					else
						codefile = preStr..postStr; 
					end
				else
					bContinue = nil;
				end
			end
			self.codefile = codefile;
		end
	end
	return self.codefile;
end

-- this means that IDE has requested to bind or rebind the given object. 
-- usually we just refresh all parameters on this object. 
-- @return true if object is modified since last bind. otherwise nil. 
function EntityBase:IDEOnBindObject()
	local obj_modified;
	if(self.worldfilter == ".*") then
		local props = self.props;
		local nIndex, prop;
		for nIndex, prop in ipairs(props) do
			if(prop.get_func) then
				local value = prop.get_func(self);
				if(self[prop.label] ~= value) then
					self[prop.label] = value;
					-- TODO: needs to inform IDE that value has changed since last binding?
					obj_modified = true;
				end
			end
		end
	end
	return obj_modified;
end

-- this function is called when the IDE binding is removed. 
-- return false will cancel removing binding
function EntityBase:IDEOnRemoveBinding()
	self:RemoveView();
	self.is_modified = false;
	if(self.template and self.template.class and self.template.class.always_delete_content) then
		-- set the save option, so that when saving, the node will be removed from xml file. 
		self.__save_option = "delete_this";
		self.is_modified = true;
	end
end

-- IDE will call this function to permanently remove an object from binding. Please note that we may need to save deleting operation inside this function. 
function EntityBase:IDEOnDeleteObject()
	self:RemoveView();
end

-- This function will be called when the IDE wants to explicitly save an entity instance. 
-- if return false, no further action is taken. 
function EntityBase:IDEOnSave()
	local template = self.template;
	if(template) then
		local entity_class = template.class;
		if (entity_class) then
			local instance = InstanceView.GetInstance(self.worldfilter, self.uid);
			if(instance) then
				-- we will use the default serializer to do the job. 
				if(template.serializer and template.serializer.SaveInstance) then
					template.serializer.SaveInstance(instance)
				end
			end
		end
	end
end

-- The user just selected it in the IDE instance view
function EntityBase:IDEOnSelect()
	if(not self.is_selected_) then
		self.is_selected_ = true;

		if (self.editors) then
			local _, editor
			for _, editor in pairs(self.editors) do
				editor:IDEOnSelect();
			end
		end
	end
end

-- The user just deselected it in the IDE instance view
function EntityBase:IDEOnDeselect()
	if(self.is_selected_) then
		self.is_selected_ = false;

		if (self.editors) then
			local _, editor
			for _, editor in pairs(self.editors) do
				editor:IDEOnDeselect();
			end
		end
	end
end