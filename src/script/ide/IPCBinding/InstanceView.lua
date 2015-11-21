--[[
Title: InstanceView
Author(s): LiXizhi
Date: 2010/6/1
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/IPCBinding/InstanceView.lua");

-- the IDE usually calls the following functions for deletion. 
InstanceView.BindInstance(filename, uid, worldfilter, codefile, callback_id)
InstanceView.UnbindInstance(filename, uid, worldfilter, callback_id)
InstanceView.DeleteInstance(filename, uid, worldfilter, callback_id)
InstanceView.SaveInstance(filename, uid, worldfilter, callback_id)
InstanceView.SaveAll()
InstanceView.SelectInstance(filename, uid, worldfilter, callback_id)
InstanceView.DeselectInstance(filename, uid, worldfilter, callback_id)
------------------------------------------------------
]]
NPL.load("(gl)script/ide/XPath.lua");
local InstanceView = commonlib.gettable("IPCBinding.InstanceView");
local EntityView = commonlib.gettable("IPCBinding.EntityView");
local IPCBindingContext = commonlib.gettable("IPCBindingContext");

-- mapping from worldfilter string to a table of uid to instance map. 
local worldfilters = {};

-- First create the instance (from an existing object in the game engine ) and then bind it by its uid. 
-- the IDE usually use a lazy-binding scheme. I.e. it will only bind an object whenever a user interacts with it.  
-- @param filename: template file name
-- @param uid: uid string
-- @param worldfilter: world filter path
-- @param codefile: the code file from which to load
-- @param callback_id: this is a callback string, that is forwarded back to the event handler on the IDE side. 
-- @return the binded instance if available. 
function InstanceView.BindInstance(filename, uid, worldfilter, codefile, callback_id)
	local template = EntityView.CreateGetEntityTemplate(filename);
	if(not template or not template.class) then
		log("warning: failed to EntityView.CreateNewEntityInstance\n");
		return;
	end

	if(worldfilter) then
		local instance_map = worldfilters[worldfilter];
		if(not instance_map) then
			instance_map = {};
			worldfilters[worldfilter] = {};
		end
		local instance = instance_map[uid];

		if (not instance) then
			-- if instance is not added before, we will need to find it on the NPL side. 
			local entity_class = template.class;
			
			-- call the load func if exist, otherwise use the default. 
			local func_load = template.func_load;
			if(func_load) then
				instance = func_load(template, uid, worldfilter);
			else
				if(entity_class.IDELoadExistingInstance) then
					instance = entity_class.IDELoadExistingInstance(template, uid, worldfilter, codefile);
				end
			end

			if(instance) then
				-- immediately update the editor view in the game engine if any
				if(instance.UpdateView) then
					instance:UpdateView();
				end
				instance_map[uid] = instance;
			end
		end

		if(instance) then
			-- now bind it
			InstanceView.BindObject(instance, worldfilter, callback_id);
		end
		return instance;
	end
end

-- this function is called when the IDE binding is removed. 
-- please note that after unbinding an instance, the instance still exist in the scene(not delete), so one can rebind it at a later time. 
-- return false if can not unbind at the moment. 
function InstanceView.UnbindInstance(filename, uid, worldfilter, callback_id)
	local instance = InstanceView.GetInstance(worldfilter, uid);
	if(instance) then
		local template = EntityView.CreateGetEntityTemplate(filename);
		if(template) then
			local entity_class = template.class;
			local func_remove = template.func_remove;

			if(func_remove and func_remove(instance) == false) then
				return false;
			end
			
			return InstanceView.UnBindObject(instance, callback_id);
		end
	end
end

-- IDE will call this function to permanently delete an object from binding. Please note that we may need to save deleting operation inside this function. 
-- internally, we will first UnbindInstance and then delete them
-- return false if can not delete at the moment. 
function InstanceView.DeleteInstance(filename, uid, worldfilter, callback_id)
	local instance = InstanceView.GetInstance(worldfilter, uid);
	if(instance) then
		if(InstanceView.UnbindInstance(filename, uid, worldfilter, callback_id) ~= false) then
			local template = EntityView.CreateGetEntityTemplate(filename);
			if(template) then
				local entity_class = template.class;
				local func_delete = template.func_delete;

				if(func_delete and func_delete(instance) == false) then
					return false;
				end
				
				if(instance.IDEOnDeleteObject) then
					return instance:IDEOnDeleteObject();
				end
			end
		else
			return false;
		end
	end
end

-- This function will be called when the IDE wants to explicitly save an entity instance. 
-- please note that we will only save if instance.is_modified is true or nil. 
-- @param filename: template file name, this can be nil, where the template that created the object will be used. 
-- @return true is object is modified and saved. 
function InstanceView.SaveInstance(filename, uid, worldfilter, callback_id)
	local instance = InstanceView.GetInstance(worldfilter, uid);
	if(instance) then
		local template = instance.template;
		if(not template and filename) then
			template = EntityView.CreateGetEntityTemplate(filename);
		end
		return InstanceView.SaveInstanceObject(instance, template);
	end
end

-- save instance object 
-- please note that we will only save if instance.is_modified is true or nil. 
-- @param instance: the entity instance object
-- @param template: this can be nil, where instance.template will be used. 
function InstanceView.SaveInstanceObject(instance, template)
	template = template or instance.template;
	if(template and instance.is_modified) then
		instance.is_modified = nil;
		local entity_class = template.class;
		local func_save = template.func_save;

		if(func_save and func_save(instance) == false) then
			return false;
		end
		if(instance.IDEOnSave) then
			return instance:IDEOnSave();
		end
	end
end

-- This function will be called when the IDE just select the entity instance in its instance view. 
function InstanceView.SelectInstance(uid, worldfilter, callback_id)
	local instance = InstanceView.GetInstance(worldfilter, uid);
	if(instance) then
		local template = instance.template;
		if(template) then
			local entity_class = template.class;
			local func_select = template.func_select;

			if(func_select and func_select(instance) == false) then
				return false;
			end
			if(instance.IDEOnSelect) then
				return instance:IDEOnSelect();
			end
		end
	end
end

-- This function will be called when the IDE just deselect the entity instance in its instance view. 
function InstanceView.DeselectInstance(uid, worldfilter, callback_id)
	local instance = InstanceView.GetInstance(worldfilter, uid);
	if(instance) then
		local template = instance.template;
		if(template) then
			local entity_class = template.class;
			local func_deselect = template.func_deselect;

			if(func_deselect and func_deselect(instance) == false) then
				return false;
			end
			if(instance.IDEOnDeselect) then
				return instance:IDEOnDeselect();
			end
		end
	end
end

-- invoke a function called func_name where the first parameter is the instance and forward additional parameters. 
-- @param func_name: string of the full function name. We will first search in locally defined functions inside entity template and then globally 
function InstanceView.InvokeNPLCommand(uid, worldfilter, func_name, ...)
	local instance = InstanceView.GetInstance(worldfilter, uid);
	if(instance and instance.template) then
		local func = instance.template:GetFunc(func_name);
		if(type(func) == "function") then
			func(instance, ...);
		end
	end
end

-- This function will automatically save all modified entity instances. 
-- @param worldfilter: if not nil, it will be only saving every instances in the world filter.  if nil, it will be everything. 
function InstanceView.SaveAll(worldfilter)
	if(worldfilter == nil) then
		-- save all loaded worldfilters 
		local filtername, instance_map
		for filtername, instance_map in pairs(worldfilters) do
			InstanceView.SaveAll(filtername);
		end
	else
		-- iterate all instances in the given world. 
		instance_map = worldfilters[worldfilter];
		if (instance_map) then
			local uid, instance
			for uid, instance in pairs(instance_map) do
				InstanceView.SaveInstanceObject(instance);
			end
		end
	end
end

-- get an existing instance by template filename, world filter and uid.
function InstanceView.GetInstance(worldfilter, uid)
	local instance_map = worldfilters[worldfilter];
	if(instance_map) then
		return instance_map[uid];
	end
end

-- private: add instance to view and invoke IDE to bind it. 
function InstanceView.BindObject(instance, worldfilter, callback_id)
	-- just ensure that instance is added before we bind. 
	InstanceView.AddInstance(instance, worldfilter);

	local obj_modified;
	if(instance.IDEOnBindObject) then
		obj_modified = instance:IDEOnBindObject();
	end
	-- invoke IDE to bind it. if obj is modified, we will force refresh the object. 
	IPCBindingContext.AddBinding(instance, obj_modified);
end

-- private: remove binding
function InstanceView.UnBindObject(instance, callback_id)
	local bCanRemove;
	if(instance.IDEOnRemoveBinding) then
		if(instance:IDEOnRemoveBinding() == false) then
			log("warning: can not remove object binding at the moment.\n");
			return false;
		end
	end
	InstanceView.RemoveInstance(instance, instance.worldfilter);
	IPCBindingContext.RemoveBinding(instance, callback_id);
end


-- private: add an object to the instance pool. Please note that the instance is not binded yet, 
-- one need to manually call BindObject() in order for the instance to be bound with the IDE. 
-- @param instance: the object instance itself
-- @param worldfilter: nil or the worldfilter string. if nil, it default to instance.worldfilter
function InstanceView.AddInstance(instance, worldfilter)
	if(instance) then
		worldfilter = worldfilter or instance.worldfilter;
		if(worldfilter) then
			local instance_map = worldfilters[worldfilter];
			if(not instance_map) then
				instance_map = {};
				worldfilters[worldfilter] = instance_map;
			end
			instance_map[instance.uid] = instance;
		end
	end
end

-- private: remove an object from the instance pool
function InstanceView.RemoveInstance(instance, worldfilter)
	if(instance) then
		worldfilter = worldfilter or instance.worldfilter;
		if(worldfilter) then
			local instance_map = worldfilters[worldfilter];
			if(instance_map) then
				local instance = instance_map[instance.uid];
				if(instance) then
					instance.__is_removed = true;
				end
				-- instance_map[instance.uid] = nil;
			end
		end
	end
end

-- remove all objects in a given world filter. 
function InstanceView.RemoveWorldFilter(worldfilter)
	if(worldfilter) then
		worldfilters[worldfilter] = nil;
	end
end

-- remove all
function InstanceView.ClearAll()
	worldfilters = {}
end

-- only for debugging purposes
function InstanceView.DumpAll()
	log("dumping IPC data binding instance view\n")
	local filtername, instance_map
	for filtername, instance_map in pairs(worldfilters) do
		log("filter name: "..filtername.."\n")
		local uid, instance
		for uid, instance in pairs(instance_map) do
			commonlib.log("uid: %s classTitle: %s---------\n", uid, instance.classTitle.label);
			local _, props = instance:GetClassDescriptor();
			local prop;
			for _, prop in ipairs(props) do
				commonlib.log("\t%s : %s\n", prop.label, tostring(instance[prop.label]));
			end
		end
	end
	log("dumping ended\n")
end

-- an iterator returning uid, instance pair in a given worldfilter. 
-- @param worldfilter: if nil, it will be the current world. 
function InstanceView.eachInstance(worldfilter)
	worldfilter = worldfilter or ParaWorld.GetWorldDirectory();
	local instance_map = worldfilters[worldfilter];
	if(instance_map) then
		return pairs(instance_map)
	else
		return function() end
	end
end