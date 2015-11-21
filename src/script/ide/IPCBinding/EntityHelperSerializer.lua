--[[
Title: provide default serialization for entity object
Author(s): LiXizhi
Date: 2010/6/5
Desc: If the entity template and game code uses the same serializer, 
then it could be extremely simple for use create IDE editor for the data type. 
In fact, it can create true codeless game data editor via entity template file. 

Several loading and saving functions are provided, so that they can be used by either IDE or game code. 
TODO: we may provide other types of serializer such as REST/SQL_DB/Lua_Table_file/plain_text, etc. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/IPCBinding/EntityHelperSerializer.lua");

-- create using the default parameter
IPCBinding.EntityHelperSerializer.LoadInstance(template, uid, worldpath, codefile)
IPCBinding.EntityHelperSerializer.SaveInstance(template, instance, uid, worldpath)
------------------------------------------------------
]]
NPL.load("(gl)script/ide/XPath.lua");
NPL.load("(gl)script/ide/LuaXML.lua");
local EntityHelperSerializer = commonlib.gettable("IPCBinding.EntityHelperSerializer");
local EntityHelper = commonlib.gettable("IPCBinding.EntityHelper");
local InstanceView = commonlib.gettable("IPCBinding.InstanceView");

local table_concat = table.concat;

-- known value serializers
local value_serializers = {
	-- array of number or boolean
	["array"] = {
		Deserialize = function(value)
			if(value) then
				return NPL.LoadTableFromString("{"..value.."}");
			end
		end,
		Serialize = function(value)
			if(value) then
				return table_concat(value, ",");
			end
		end
	},
	-- array of strings (string must not contain commar)
	["array_string"] = {
		Deserialize = function(value)
			if(value) then
				local obj = {};
				local v;
				for v in value:gmatch("[^,]+") do
					obj[#obj+1] = v;
				end
				return obj;
			end
		end,
		Serialize = function(value)
			if(value) then
				return table_concat(value, ",");
			end
		end
	},
};

-- property names that should be ignored. 
local ignore_props_maps = {
	uid = true,
	codefile = true, 
	worldfilter = true, 
	template_file = true,
}

-- deserialize value 
-- @param value: the value string stream
-- @param prop: the property description table.
-- @param value_type: optional value type. This should be nil in most cases, where type is get from the property description. 
local function DeserializeValue(value, prop, value_type)
	local value_serializer;
	if(prop) then
		-- use the type defined in template if the file does not explicitly specify it
		value_type = value_type or prop.type;
		value_serializer = prop.value_serializer;
	end
	if(value_serializer) then
		-- use serializer if one is provided explicitly. 
		local serializer = value_serializers[value_serializer];
		if(serializer) then
			return serializer.Deserialize(value);
		else
			commonlib.log("warning: unknown serializer %s\n", value_serializer);
		end
	elseif(value == nil) then
		-- for nil value, we will return nil.
		return;
	elseif(not value_type or value_type=="string") then
		return value;
	elseif(value_type=="boolean") then
		return (value == "true");
	elseif(value_type=="number") then
		return tonumber(value);
	elseif(value_type=="table") then
		return NPL.LoadTableFromString(value);
	end
end

-- load instance from a entity xml node. 
-- @return instance, file_modified. file_modified is true if we need to modify the file when saving 
function EntityHelperSerializer.LoadInstanceFromXMLNode(template, entityNode, worldpath, codefile)
	if(not template or not entityNode or not codefile) then
		return;
	end
	local file_modified;
	local entity_class = template.class;
	if (entity_class) then
		local instance = {};
		entityNode.attr = entityNode.attr or {};
		local uid = entityNode.attr.uid;
		if(not uid) then
			-- if no uid is created 
			uid = ParaGlobal.GenerateUniqueID();
			entityNode.attr.uid = uid;
			file_modified = true
			LOG.std("", "debug", "EntityHelperSerializer", "warning: a node without uid is found in instance file: %s, we will auto-generate one for it", codefile);
		end

		instance.uid = uid;
		-- LOG.std("", "debug", "EntityHelperSerializer", "new singleton entity instance created: uid %s (%s)", instance.uid, template.name);

		local nIndex, prop;
		for nIndex, prop in ipairs(template.props) do
			local name = prop.label;
			if(not ignore_props_maps[name]) then
				local xpath = prop.xpath;
				local xpath_index = prop.xpath_index;

				if(not xpath) then
					-- if no xpath is specified, we will deserialize from a child node with value attribute.
					local _, propNode, node_index;
					for _, propNode in ipairs(entityNode) do
						if(propNode.name == name) then
							node_index = (node_index or 0) + 1;
							if(not xpath_index or node_index == xpath_index) then
								local value = propNode.attr and propNode.attr.value;
								instance[name] = DeserializeValue(value, prop);
								break;
							end
						end
					end
				else
					local parent_propertyname = xpath:match("^%[@(.+)%]$");
					if(parent_propertyname) then
						-- if xpath is in the form [@parent_propertyname], it will be saved as an attribute on the parent node. 
						local value = entityNode.attr[parent_propertyname];
						instance[name] = DeserializeValue(value, prop);
					else
						local child_nodename = xpath:match("^[^%[%]]+$");
						if(child_nodename) then
							-- if xpath is just a name, it will be saved as a child name with value in the inner text. 
							local _, propNode, node_index
							for _, propNode in ipairs(entityNode) do
								if(propNode.name == name) then
									node_index = (node_index or 0) + 1;
									if(not xpath_index or node_index == xpath_index) then
										local value = propNode[1];
										instance[name] = DeserializeValue(value, prop); 
										break;
									end
								end
							end
						else
							-- if xpath is of the form child_nodename[@child_property_name], then it will be serialized as a child node with value in the attribute field. 
							local child_nodename, child_property_name = xpath:match("^([^%[%]]+)%[@(.+)%]$");
							if(child_nodename and child_property_name) then
								local _, propNode, node_index
								for _, propNode in ipairs(entityNode) do
									if(propNode.name == child_nodename and propNode.attr) then
										node_index = (node_index or 0) + 1;
										if(not xpath_index or node_index == xpath_index) then
											local value = propNode.attr[child_property_name];
											instance[name] = DeserializeValue(value, prop);
											break;
										end
									end
								end
							else
								LOG.std("", "warn", "EntityHelperSerializer", "warning: unknown xpath when serializing entity %s", tostring(xpath));
							end
						end
					end
				end
				if(instance[name] == nil) then
					if(not prop.skip_value) then
						if(prop.default_value and prop.default_value~=prop.skip_value) then
							-- if default_value is provided, and there is no skip_value, we will assign it here. 
							instance[name] = DeserializeValue(prop.default_value, prop);
						else
							if(not prop.is_nullable) then
								LOG.std("", "debug", "EntityHelperSerializer", "warning: property value not found for %s when deserializing entity %s", name, tostring(uid));
							end
						end
					end
				end
			end
		end

		-- add template file and code file. 
		instance.worldfilter = instance.worldfilter or worldpath;
		instance.codefile = codefile;
		instance = entity_class:new(instance)
		return instance, file_modified;
	end
end

-- Load a new instance from file using default serializer 
-- @param template: the template used for the instance
-- @param uid: the uid of the instance. 
-- @param worldpath: the world path from which to load the file. If nil, it will be the current world path. 
--   this parameter is only used when the template code file contains [worldpath]
-- @param codefile: the code file path. 
-- @return the entity instance loaded. 
function EntityHelperSerializer.LoadInstance(template, uid, worldpath, codefile)
	if(template) then
		codefile = codefile or EntityHelper.GetCodeFileByUid(template, uid, worldpath);
		if(codefile) then
			local codefile_xpath = template.attr.codefile_xpath or "/instances/entity";
			codefile_xpath = codefile_xpath..string.format("[@uid='%s']",uid);
			
			local xmlDocIP = ParaXML.LuaXML_ParseFile(codefile);
			local entityNode;
			-- find existing parent note from file, if exist. 
			if(xmlDocIP) then
				-- if file already exist, find the parent element. 
				local result = commonlib.XPath.selectNodes(xmlDocIP, codefile_xpath);
				if(result and #result == 1) then
					entityNode = result[1];
					return EntityHelperSerializer.LoadInstanceFromXMLNode(template, entityNode, worldpath, codefile);
				end
			end
		end
	end
end

-- load instance(s) from filename, we will return all instances that matched the template in the code file. Therefore, multiple may be returned. 
-- @param template: the template object
-- @param codefile: the instance file path. 
-- @param instances: newly loaded instances will be appended to this table array. if nil, an empty talbe will be created. 
-- @return a table array containing instances created. if may return nil if none is created. 
function EntityHelperSerializer.LoadInstancesFromFile(template, codefile, worldpath, instances)
	local entity_class = template.class;
	if(codefile and entity_class) then
		local codefile_xpath = template.attr.codefile_xpath or "/instances/entity";
			
		local xmlDocIP = ParaXML.LuaXML_ParseFile(codefile);
		local entityNode;
		local file_modified;
		-- find existing parent note from file, if exist. 
		if(xmlDocIP) then
			-- if file already exist, find the parent element. 
			instances = instances or {};
			local instance;
			for entityNode in commonlib.XPath.eachNode(xmlDocIP, codefile_xpath) do
				
				instance, file_modified = EntityHelperSerializer.LoadInstanceFromXMLNode(template, entityNode, worldpath, codefile)
				if(instance) then
					table.insert(instances, instance);
				end
			end
			if(file_modified) then
				LOG.std("", "warn", "EntityHelperSerializer", "%s is modified to add missing fields such as uid to it.", codefile);
				EntityHelperSerializer.WriteXMLFile(codefile, xmlDocIP);
			end
			if(#instances > 0) then
				return instances;
			end
		end
	end
end

-- helper function to write xmlDocRoot node to codefile
-- return true if succeed. 
function EntityHelperSerializer.WriteXMLFile(codefile, xmlDocRoot)
	local file = ParaIO.open(codefile, "w");
	if(file:IsValid()) then
		file:WriteString([[<?xml version="1.0" encoding="utf-8"?>
]]);
		file:WriteString(commonlib.Lua2XmlString(xmlDocRoot, true));
		file:close();
		return true;
	else
		_guihelper.MessageBox(format("Error: can not open file: %s for reading. The file may be read only.", codefile))
	end
end

-- remove all child node of an xml node, except those whose tag name matches a given regular expression. 
local function FilterNodeByTagName(parentNode, sRegExp)
	local index, node, node_index
	local last_index = 0; 
	for index, node in ipairs(parentNode) do
		if(type(node)=="table" and node.name:match(sRegExp)) then
			last_index = last_index + 1;
			parentNode[last_index] = node;
		end
	end
	table.resize(parentNode, last_index, nil);
end

-- Save an instance to file using default serializer 
-- @return true if serialization succeed. 
function EntityHelperSerializer.SaveInstance(instance)
	if(instance.__is_removed and instance.__save_option ~= "delete_this") then
		return;
	end

	local template, uid, worldpath = instance.template, instance.uid, instance.worldfilter;
	if(worldpath == ".*") then
		worldpath = nil;
	end
	if(template) then
		local codefile = instance:CreateGetCodeFile();
		if(codefile) then
			local codefile_xpath = template.attr.codefile_xpath or "/instances/entity";
			local parent_xpath, element_name = codefile_xpath:match("^(.*)/([^/]+)$");

			ParaIO.CreateDirectory(codefile);

			local xmlDocIP = ParaXML.LuaXML_ParseFile(codefile);
			local parentNode;

			-- find existing parent note from file, if exist. 
			if(xmlDocIP) then
				-- if file already exist, find the parent element. 
				local parent_xpath = codefile_xpath:gsub("/[^/]+$", "");
				local result = commonlib.XPath.selectNodes(xmlDocIP, parent_xpath);
				if(result and #result == 1) then
					parentNode = result[1];
				end
			end

			-- if parent node does not exist, we will create a new xml document. 
			if( not parentNode) then
				-- if file does not exist, create a new parent Node based on xPath. 
				xmlDocIP = {};
				parentNode = xmlDocIP;
				local tagName;
				for tagName in string.gmatch(parent_xpath, "[^/]+") do
					local temp = {name = tagName}
					parentNode[1] = temp;
					parentNode = temp;
				end
			end

			-- find if an existing uid instance is already in the list. 
			local entityNode;
			if (parentNode) then
				local index, node, node_index
				for index, node in ipairs(parentNode) do
					if(type(node) == "table" and node.name == element_name and node.attr.uid == uid) then
						entityNode = node;
						-- We will preserve a node whose name contains "item_ex"
						FilterNodeByTagName(entityNode, "item_ex")
						-- We will preserve a node whose name contains "gossip"
						FilterNodeByTagName(entityNode, "gossip")
						node_index = index;
						break;
					end
				end
				--local result = commonlib.XPath.selectNodes(parentNode, string.format("/%s[@uid='%s']", element_name, uid));
				--if(result and #result == 1) then
					--entityNode = result[1];
					--table.resize(entityNode, 0, nil);
				--end

				-- in case this is a delete operation, remove it and return 
				if(instance.__save_option == "delete_this") then
					if( entityNode and node_index) then
						commonlib.removeArrayItem(parentNode, node_index)
						return EntityHelperSerializer.WriteXMLFile(codefile, xmlDocIP);
					end
					return
				end

				if(not entityNode) then
					entityNode = {name=element_name, attr = {uid = uid}};
					parentNode[#parentNode + 1] = entityNode;
				end
			end
			
			-- now populate the entity node with data
			if(entityNode) then
				local props = instance.props;
				local nIndex, prop;
				for nIndex, prop in ipairs(props) do
					local name = prop.label;
					if(not ignore_props_maps[name]) then
						local value, value_type, value_stream;
						if(prop.get_func) then
							value = prop.get_func(instance);
						else
							value = instance[name];
						end
						if(value~=nil) then
							value_type = type(value);
							if(prop.value_serializer) then
								-- use serializer if one is provided explicitly. 
								local serializer = value_serializers[prop.value_serializer];
								if(serializer) then
									value_stream = serializer.Serialize(value);
								else
									LOG.std("", "warn", "EntityHelperSerializer", "unknown serializer %s", prop.value_serializer);
								end
							else
								
								if( value_type == "number") then
									value_stream = tostring(value);
								elseif( value_type == "boolean") then
									value_stream = tostring(value);
								elseif( value_type == "string") then
									value_stream = value;
								elseif( value_type == "table") then
									value_stream = commonlib.serialize_compact2(value);
									-- skip serialization if value is same as the skip value. 
									if(prop.skip_value) then
										if(not prop.skip_value_) then
											prop.skip_value_ = NPL.LoadTableFromString(prop.skip_value)
										end
										if(commonlib.compare(value, prop.skip_value_)) then
											-- if value is same, skip
											value_stream = nil;
										end
									end
								end
							end
						else
							-- Note: for null field, we will simply skip it
							-- LOG.std("", "debug", "EntityHelperSerializer", "null field: %s, entity uid is %s", name, uid);
						end

						-- only write to data source if value_stream is different from prop.skip_value
						local bRemove;
						if(not (value_stream and value_stream~=prop.skip_value)) then
							bRemove = true;
						end
						do
							-- now write to the correct location according to xpath. 
							local xpath = prop.xpath;
							local xpath_index = prop.xpath_index;
							if(not xpath) then
								-- if no xpath is specified, we will serialize to a child node with value attribute.
								if(not bRemove) then
									local propNode = {name=name, attr={value=value_stream},};
									table.insert(entityNode, propNode);
								end
							else
								local parent_propertyname = xpath:match("^%[@(.+)%]$");
								if(parent_propertyname) then
									-- if xpath is in the form [@parent_propertyname], it will be saved as an attribute on the parent node. 
									if(not bRemove) then
										entityNode.attr[parent_propertyname] = value_stream;
									else
										entityNode.attr[parent_propertyname] = nil;
									end
								else
									local child_nodename = xpath:match("^[^%[%]]+$");
									if(child_nodename) then
										-- if xpath is just a name, it will be saved as a child name with value in the inner text. 
										if(not bRemove) then
											local propNode = {name=child_nodename, [1] = value_stream};
											table.insert(entityNode, propNode);
										end
									else
										-- if xpath is of the form child_nodename[@child_property_name], then it will be serialized as a child node with value in the attribute field. 
										local child_nodename, child_property_name = xpath:match("^([^%[%]]+)%[@(.+)%]$");
										if(child_nodename and child_property_name) then
											local _, propNode, propNode_, node_index;
											for _, propNode_ in ipairs(entityNode) do
												if(propNode_.name == child_nodename) then
													node_index = (node_index or 0) + 1;
													if(not xpath_index or node_index == xpath_index) then
														propNode = propNode_;
														break;
													end
												end
											end
											if(not propNode) then
												if(not bRemove) then
													propNode = {name=child_nodename, attr={[child_property_name]=value_stream},};
													table.insert(entityNode, propNode);
												end
											else
												if(not bRemove) then
													propNode.attr[child_property_name] = value_stream;
												else
													propNode.attr[child_property_name] = nil;
												end
											end
										else
											LOG.std("", "warn", "EntityHelperSerializer", "unknown xpath when serializing entity %s", tostring(xpath));
										end
									end
								end
							end
						end
					end
				end	

				EntityHelperSerializer.WriteXMLFile(codefile, xmlDocIP);
			end
		end
	end
end

