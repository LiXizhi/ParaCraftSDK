--[[
Title: EntityView
Author(s): LiXizhi
Date: 2010/6/1
Desc: Used by the IDE to create a new instance from a given entity template file. Or it can be used to create from an existing object in the game engine based on a given template file. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/IPCBinding/EntityView.lua");

-- the most commonly used functions are 
IPCBinding.EntityView.CreateNewEntityInstance(template_filename, callback_id)
IPCBinding.EntityView.CreateFromExistingFile(template_filename, instance_filename, callback_id)
IPCBinding.InstanceView.BindInstance(template_filename, uid, worldfilter, codefile, callback_id)


-- call this to generate
IPCBinding.EntityView.GenerateIDEFileFromTemplateFile(filename)
------------------------------------------------------
]]
NPL.load("(gl)script/ide/XPath.lua");
NPL.load("(gl)script/ide/IPCBinding/EntityTemplate.lua");
local EntityView = commonlib.gettable("IPCBinding.EntityView");
local InstanceView = commonlib.gettable("IPCBinding.InstanceView");
local EntityTemplate = commonlib.gettable("IPCBinding.EntityTemplate");
local EntityHelper = commonlib.gettable("IPCBinding.EntityHelper");

-- mapping from entity name to template class. 
local templates = {};
-- mapping from entity file name to template class
local templates_filemap = {};

-- load entity template
-- @param filename: such as EntitySampleTemplate.entity.xml
-- @param bForceRefresh: if true, it will reload the entity template. default to nil.
-- @return the last laoded entity
function EntityView.LoadEntityTemplate(filename, bForceRefresh)
	local template = templates_filemap[filename];
	if(not template or bForceRefresh) then
		template = nil;

		local xmlDocRoot = ParaXML.LuaXML_ParseFile(filename);
		local node;
		for node in commonlib.XPath.eachNode(xmlDocRoot, "//pe:entity_template") do
			local attr = node.attr;
			template = EntityTemplate:new();
			if(template:LoadFromXMLNode(node, filename)) then
				-- add to template
				if(template.name) then
					templates[template.name] = template;
				end
				templates_filemap[filename] = template;
				LOG.std("", "system", "IPC.EntityView", "Entity template %s loaded", template.name or filename);
			else
				template = nil;
				LOG.std("", "warn", "IPC.EntityView", "entity template %s does not have class defined or class description not found", attr.classname);
			end
		end
	end
	return template;
end

-- get entity template
-- @param filename: such as EntitySampleTemplate.entity.xml
-- @return entity table or nil if not found. 
function EntityView.GetEntityTemplate(filename)
	return templates_filemap[filename] or templates[filename];
end

-- get entity template
-- @param filename: such as EntitySampleTemplate.entity.xml
-- @return entity table or nil if not found. 
function EntityView.CreateGetEntityTemplate(filename)
	local template = templates_filemap[filename];
	if(not template) then
		template = EntityView.LoadEntityTemplate(filename);
	end
	return template;
end

-- create a new entity instance based on the given template 
-- it is up to the template to decide how to create the new entity, it can create an entity instance with default parameter and bind immediately with the IDE.
-- or it can display an mcml dialog to let user to fill in some default parameter and then create in the game scene, etc. 
-- @param filename: this is entity template file name or entity name. 
-- @param callback_id: this is a callback string, that is forwarded back to the OnEntityCreated event handler on the IDE side. 
-- @return if the instance is immediately created, then it will be returned. if failed or it can not be created immediately, then it will return nil. 
function EntityView.CreateNewEntityInstance(filename, callback_id)
	local template = EntityView.CreateGetEntityTemplate(filename);
	if(not template or not template.class) then
		LOG.std("", "warn", "IPC.EntityView", "failed to EntityView.CreateNewEntityInstance");
		return;
	end
	local worldfilter = template.attr.worldfilter;
	if(not worldfilter or worldfilter == "") then
		worldfilter = ParaWorld.GetWorldDirectory();
	end

	local instance_immediate;
	-- this function is called when a new instance has been successfully created. 
	local function OnInstanceCreated(instance)
		instance_immediate = instance;
		instance.is_modified = true;
		instance.codefile = instance:CreateGetCodeFile();
		
		-- here we simply bind the object after creation
		InstanceView.BindObject(instance, worldfilter, callback_id);
		-- immediately update the editor view in the game engine if any
		if(instance.UpdateView) then
			instance:UpdateView();
		end
	end

	local entity_class = template.class;
	-- if attr.func_create exist we will use it, otherwise we will use entity_class.IDECreateNewInstance as create new instance function. 
	local func_create = template.func_create or entity_class.IDECreateNewInstance;
	
	-- create a new instance based on params
	local function create_with_params_(params)
		-- create a new instance and invoke callback
		if(func_create) then
			params = params or {};
			func_create(template, params, OnInstanceCreated);
		else	
			local instance = entity_class:new();
			OnInstanceCreated(instance);
		end
	end

	-- if template has specified creation MCML page, then we will need to display that page first. and gether params from forms
	-- if no mcml page specified, we will simply create a new object using the default empty settings. 
	if(template.attr.new_instance_form) then
		-- display a mcml page to gether initial params via UI. 
		if(not template.new_instance_form_params) then
			local url = template.attr.new_instance_form;
			if(not url:match("[/\\]+")) then
				-- if no parent directory is specified, it will be looked up in the same folder as the entity template file
				url = template.filename:gsub("([^/\\]+)$", url);
			end

			template.new_instance_form_params = {
					url = url, 
					name = "EntityTemplate"..template.name, 
					text = "Create New Instance of "..template.name,
					isShowTitleBar = true,
					DestroyOnClose = false, 
					-- style = CommonCtrl.WindowFrame.ContainerStyle,
					zorder = 1,
					isTopLevel = true,
					allowDrag = true,
					directPosition = true,
						align = "_ct",
						x = -256,
						y = -200,
						width = 512,
						height = 400,
			};
		end
		System.App.Commands.Call("File.MCMLWindowFrame", template.new_instance_form_params);
		local page = template.new_instance_form_params._page;
		if(page) then
			page.OnClose = function () 
				if(page._result) then
					create_with_params_(page._result);
				end
			end
		end
	else
		-- no creation form specified, so create with empty params
		create_with_params_(nil);
		return instance_immediate;
	end
end

-- create an existing object based on the given template and an optional instance file. 
-- it is up to the entity to decide how an existing object is added. For example, the entity may use the currently selected
-- object as the data source, or it can display a dialog and let the user to select from a list, etc. 
-- @param filename: this is entity template file. 
-- @param instance_filename: if not nil, it means that we want to create from an existing entity data source file. 
-- @param callback_id: this is a callback string, that is forwarded back to the OnEntityCreated event handler on the IDE side. 
function EntityView.CreateFromExistingFile(template_filename, instance_filename, callback_id)
	local template = EntityView.CreateGetEntityTemplate(template_filename);
	if(not template or not template.class) then
		LOG.std("", "warn", "IPC.EntityView", "failed to EntityView.CreateNewEntityInstance");
		return;
	end

	local worldfilter = template.attr.worldfilter;
	if(not worldfilter or worldfilter == "") then
		worldfilter = ParaWorld.GetWorldDirectory();
	end

	local instance_immediate;

	-- this function is called when a new instance has been successfully created. 
	local function OnInstanceCreated(instance)
		instance_immediate = instance;
		instance.is_modified = true;
		instance.codefile = instance:CreateGetCodeFile();

		-- here we simply bind the object after creation
		InstanceView.BindObject(instance, worldfilter, callback_id);

		-- immediately update the editor view in the game engine if any
		if(instance.UpdateView) then
			instance:UpdateView();
		end
	end

	local entity_class = template.class;
	-- if attr.func_createfrom exist we will use it, otherwise we will use entity_class.IDECreateNewInstance as create new instance function. 
	local func_createfrom = template.func_createfrom or entity_class.IDECreateFromExisting;

	-- create a new instance and invoke callback
	if(func_createfrom) then
		-- TODO: if template has specified creation MCML page, then we will need to display that page first. and gether params from forms
		-- For, simplicity, we will just create a new object using the default empty settings. 
		local params = {};
		func_createfrom(template, instance_filename, worldfilter, OnInstanceCreated);
	else
		local entity_class = template.class;
		if(entity_class.IDELoadExistingInstance) then
			instance = entity_class.IDECreateFromExisting(template, instance_filename, worldfilter, OnInstanceCreated);
		end
	end
	return instance_immediate;
end


-- TODO: display the entity template in mcml. 
function EntityView.ShowTemplate(filename)
end

-- call this function to generate C# files to be used on the IDE side. 
-- @param filename: entity xml file name
-- @param output_file: if nil, it will rename the extension of filename to cs
function EntityView.GenerateIDEFileFromTemplateFile(filename, output_file)
	NPL.load("(gl)script/ide/IPCBinding/IPCClassBuilder.lua");
	local IPCClassBuilder = commonlib.gettable("IPCBinding.IPCClassBuilder");

	local template = EntityView.CreateGetEntityTemplate(filename);
	if(template and template.class) then
		local entity_class = template.class;
		local classTitle, props = entity_class:GetClassDescriptor();
		local namespace = template.attr.namespace;

		LOG.std("", "system", "IPC.EntityView", "Generate IDE CS file from xml entity template file: %s", filename);

		local file_content = IPCClassBuilder.ParseClassByLuaParams(namespace, classTitle, props, template.attr.editor_attribute);
	
		local csharp_path = output_file or string.gsub(filename, "%..-$", ".cs");
		ParaIO.CreateDirectory(csharp_path);
	    local file = ParaIO.open(csharp_path, "w");
	    if(file:IsValid()) then
		    file:WriteString(file_content);
		    file:close();
		else
			LOG.std("", "error", "IPC.EntityView", "can not create or open file: %s. Make sure it is not READ-ONLY", filename);
	    end
	end
end

