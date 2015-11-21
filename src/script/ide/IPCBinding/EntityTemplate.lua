--[[
Title: EntityTemplate
Author(s): LiXizhi
Date: 2010/6/1
Desc: The entity template file. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/IPCBinding/EntityTemplate.lua");
------------------------------------------------------
]]
NPL.load("(gl)script/ide/XPath.lua");
local EntityTemplate = commonlib.gettable("IPCBinding.EntityTemplate");

function EntityTemplate:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- get a function by function name, it will first search in the locally defined function, and then in the global table. 
-- return nil or the function object. 
function EntityTemplate:GetFunc(funcName)
	return commonlib.getfield(funcName, self.functions) or commonlib.getfield(funcName)
end

-- load entity template from a given xml node of a given entity template file. 
-- @param node: the xml node with name "pe:entity_template"
-- @param filename: the entity template file name from which node is parsed. 
-- @return true if succeed. 
function EntityTemplate:LoadFromXMLNode(node, filename)
	local bRes;
	local template = self;
	-- create a new template
	local attr = node.attr;
	if(attr and attr.classname) then
		if(attr.classfile) then
			NPL.load("(gl)"..attr.classfile);
		end
				
		local entity_class = commonlib.getfield(attr.classname);
		if(entity_class and entity_class.GetClassDescriptor) then
			-- now add entity template from code
			template.attr = node.attr;
			template.name = attr.name;
			template.filename = filename;
			template.class = entity_class;

			template.classTitle, template.properties = entity_class:GetClassDescriptor();	
			bRes = true;
		elseif(attr.baseclass) then
			-- this is codeless entity template.
			-- if classname does not exist, but baseclass exist, we will derive class from base class. 
			local base_class = commonlib.getfield(attr.baseclass);
			if(base_class) then
				-- create the entity class by reading the entity template xml file
				-- this is usually used to create simple entity file. 
				local entity_class = commonlib.inherit(base_class);
				commonlib.setfield(attr.classname, entity_class);
						
				-- now add entity template 
				template.attr = node.attr;
				template.name = attr.name;
				template.filename = filename;
				template.class = entity_class;
				bRes = true;

				local baseClassTitle, baseClassProps = base_class:GetClassDescriptor();
				entity_class.classTitle = commonlib.deepcopy(baseClassTitle);
				entity_class.props = commonlib.deepcopy(baseClassProps);
				entity_class.template_file = filename;
				entity_class.template = template;

				if(attr.worldfilter) then
					entity_class.worldfilter = attr.worldfilter;
				end
					
				-- if true, we will delete content in XML
				if(attr.always_delete_content == "true") then
					entity_class.always_delete_content = true;
				end
						
				template.classTitle, template.props = entity_class:GetClassDescriptor();	
				template.classTitle.label = template.name;
				template.classTitle.namespace = template.classTitle.namespace or template.attr.namespace;
				if(attr.serializer) then
					template.serializer = commonlib.gettable(attr.serializer);
				end

				-- parse and save functions
				template.functions = {};
				local funcNode;
				for funcNode in commonlib.XPath.eachNode(node, "/functions/function") do
					if(funcNode.attr and funcNode.attr.name and funcNode[1]) then
						template.functions[funcNode.attr.name] = loadstring(funcNode[1])();
					end
				end

				local function GetFunc_(funcName)
					return commonlib.getfield(template.attr[funcName], template.functions) or commonlib.getfield(template.attr[funcName])
				end

				template.func_create = GetFunc_("func_create");
				template.func_createfrom = GetFunc_("func_createfrom");
				template.func_remove = GetFunc_("func_remove");
				template.func_delete = GetFunc_("func_delete");
				template.func_load = GetFunc_("func_save");
				template.func_save = GetFunc_("func_save");
				template.func_select = GetFunc_("func_select");
				template.func_deselect = GetFunc_("func_deselect");
			
				local editor_names = {};

				local propNode;
				for propNode in commonlib.XPath.eachNode(node, "/properties/property") do
					if(propNode.attr.name) then
						local prop = {
							label=propNode.attr.name, 
							type = propNode.attr.type or "string", 
							category = propNode.attr.category,
							desc = propNode.attr.desc, 
							editor = propNode.attr.editor, 
							editor_attribute = propNode.attr.editor_attribute, 
							converter = propNode.attr.converter, 
							style = propNode.attr.style,
							value_serializer = propNode.attr.value_serializer,
							xpath = propNode.attr.xpath,
							xpath_index = tonumber(propNode.attr.xpath_index),
							-- value to be used when sending to PETools, if NPL object is null.
							default_value = propNode.attr.default_value,
							-- when serializing to data file, if the serialized NPL object value is equal to this string, it will be skipped, thus saving space 
							skip_value = propNode.attr.skip_value,
							-- if the the property can be skipped. 
							is_nullable = if_else(propNode.attr.is_nullable == "true", true, nil),
						};

						if(propNode.attr.get_func) then
							prop.get_func = loadstring(propNode.attr.get_func)();
						end
						if(propNode.attr.set_func) then
							prop.set_func = loadstring(propNode.attr.set_func)();
						end
						
						-- parse all style like css style in html
						if(prop.style) then
							local style = {};
							local name, value;
							for name, value in string.gfind(propNode.attr.style, "([%w%-]+)%s*:%s*([^;]*)[;]?") do
								name = string.lower(name);
								value = string.gsub(value, "%s*$", "");
								style[name] = value;
							end
							prop.style = style;
							if(style.editor) then
								table.insert(editor_names, prop.label);
							end
						end
						table.insert(template.props, prop);
					end
				end
				if(#editor_names > 0) then
					entity_class.editor_names = editor_names;
				end

				-- now we will define the constructor
				entity_class.ctor = function(self)
					if(not attr.worldfilter or node.attr.worldfilter =="") then
						self.worldfilter = ParaWorld.GetWorldDirectory();
					end
					-- bind all editors to this instance. 
					if(self.BindPropertyEditors) then
						self:BindPropertyEditors();
					end
				end
			end
		end
	end

	-- build the property map
	if(bRes) then
		template.prop_map = {};
		if(template.props) then
			local _, prop;
			for _, prop in ipairs(template.props) do
				template.prop_map[prop.label] = prop;
			end
		end
	end
	return bRes;
end

-- get the property description object. 
-- @param property_name: the property name. 
-- @return a table containing the property description if any. 
function EntityTemplate:GetPropertyDesc(property_name)
	return self.prop_map[property_name];
end