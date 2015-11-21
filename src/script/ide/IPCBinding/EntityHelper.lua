--[[
Title: Some helper functions used by entity template 
Author(s): LiXizhi
Date: 2010/6/4
Desc: Entity helper functions
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/IPCBinding/EntityHelper.lua");

-- call this function when world is cleared. 
IPCBinding.EntityHelper.ClearAllCachedObject()

-- call this to generate all buildin template. 
IPCBinding.EntityHelper.GenerateBuildinTemplates("script/PETools/Buildin/")
------------------------------------------------------
]]
NPL.load("(gl)script/ide/IPCBinding/BindableObject.lua");

local EntityHelper = commonlib.gettable("IPCBinding.EntityHelper");


-- ParaEngine.GetAttributeObject():CallField("PrintMe")

-- generate build in ParaEngine build-in entity templates
-- @param dest_folder: if nil, it will defaults to "script/PETools/buildin/"
function EntityHelper.GenerateBuildinTemplates(dest_folder)
	NPL.load("(gl)script/ide/IPCBinding/EntityView.lua");

	dest_folder = dest_folder or "script/PETools/Buildin/"
	ParaIO.CreateDirectory(dest_folder);

	local buildin_templates = {
		{ name = "GlobalSettings", attr = ParaEngine.GetAttributeObject() },
		{ name = "Camera", attr = ParaCamera.GetAttributeObject() },
		{ name = "Sky", attr = ParaScene.GetAttributeObjectSky() },
		{ name = "Terrain", attr = ParaTerrain.GetAttributeObject() },
		{ name = "Ocean", attr = ParaScene.GetAttributeObjectOcean() },
		{ name = "Scene", attr = ParaScene.GetAttributeObject() },
	}
	local _, template
	for _, template in ipairs(buildin_templates) do
		local filename = dest_folder..template.name..".entity.xml";
		local file = ParaIO.open(filename, "w");
		if(file:IsValid()) then
			file:WriteString(string.format("<!-- %s -->\n", filename));
			file:WriteString(EntityHelper.GenerateEntityTemplateFromAttrObject(template.attr, template.name, "PETools.EntityTemplates.Buildin"));
			file:close();
		end	
		IPCBinding.EntityView.GenerateIDEFileFromTemplateFile(filename);
	end
	IPCBinding.EntityView.GenerateIDEFileFromTemplateFile("script/ide/IPCBinding/EntitySamplePlaceableTemplate.entity.xml");
	IPCBinding.EntityView.GenerateIDEFileFromTemplateFile("script/ide/IPCBinding/EntitySampleTemplate.entity.xml");
end

function EntityHelper.GenerateParaObjectTemplate()
end

-- get codefile by uid and worldpath
-- Note: one should consider callign EntityBase:CreateGetCodeFile() instead. 
function EntityHelper.GetCodeFileByUid(template, uid, worldpath)
	if(template) then
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
		end
		return codefile;
	end
end

-- generate a given entity template file from an attribute object(ParaAttributeObject) or a table having the same interface. 
-- One can further edit the generated file to add more custom stuffs. 
-- @param attrObject: the attribute object, such as ParaEngine.GetAttributeObject()
-- @param name: string name of the class. If this is a table, it means all the following paramter fields will be extracted from the key, value pair of the table. 
--   such as {name="ObjName", namespace="PETools.ABC", ...}
-- @param namespace: namespace of the class in the C# side. defaults to "PETools.EntityTemplates"
-- @param display_name: any display name, default to name. 
-- @param classname: classname on the NPL side. default to (namespace.."."..name).
function EntityHelper.GenerateEntityTemplateFromAttrObject(attrObject, name, namespace, display_name, classname)
	local outputs = {};
	local function append(text)
		outputs[#outputs +1] = text;
	end
	local singleton, worldfilter, classfile, baseclass, func_create, func_createfrom, func_remove, func_delete, func_save, func_select, func_deselect;
	if(type(name) == "table") then
		local params = name;
		name = params.name;
		display_name = params.display_name;
		classname = params.classname;
		func_create = params.func_create;
		func_createfrom = params.func_createfrom;
		func_remove = params.func_remove;
		func_delete = params.func_delete;
		func_save = params.func_save;
		func_select = params.func_select;
		func_deselect = params.func_deselect;
		baseclass = params.baseclass;
		classfile = params.classfile;
		worldfilter = params.worldfilter;
		singleton = params.singleton;
	end
	
	namespace = namespace or "PETools.EntityTemplates";
	display_name = display_name or name;
	classfile = classfile or "script/ide/IPCBinding/EntityBase.lua";
	classname = classname or (namespace.."."..name);
	baseclass = baseclass or "IPCBinding.EntityBase";
	worldfilter = worldfilter or ".*";
	singleton = (singleton==nil or singleton == "true");
	

	append(string.format("<!-- automatically generated by EntityHelper on %s -->\n", ParaGlobal.GetDateFormat("yyyy-MM-dd")));
	append([[<pe:mcml>
  <script type="text/npl" src="">
  </script>
]]);
	append(string.format([[
<pe:entity_template name="%s" namespace="%s" display_name="%s"
             worldfilter="%s" singleton="%s"
             classfile="%s"
             classname="%s"
             baseclass="%s"
             func_create="%s"
             func_createfrom="%s"
             func_remove="%s"
             func_delete="%s"
             func_save="%s"
             func_select="%s"
             func_deselect="%s"
             >
]], name, namespace, display_name, worldfilter, tostring(singleton), classfile, classname, baseclass,func_create or "", func_createfrom or "", func_remove or "", func_delete or "", func_save or "", func_select or "", func_deselect or ""));

	append("	<properties>\n");

	-- TODO: added codefile and template_file. 
	
	local att = attrObject;
	local nCount = att:GetFieldNum();
	local nIndex;
	for nIndex = 1, nCount do
		local sName = att:GetFieldName(nIndex);
		local sType = att:GetFieldType(nIndex);
		local sSchematics = att:GetSchematicsType(nIndex);
		local text;

		local prop_name, prop_type, prop_desc, get_func, set_func, type_converter, editor_ui;
		prop_name = sName;
		

		if(att:IsFieldReadOnly(nIndex)==true) then
			if(sType == "string" and sSchematics == ":script") then
				text = tostring(att:GetField(sName, ""));
				prop_type = "string";
			else
				if(sType == "vector3") then
					text=string.format("%.2f,%.2f,%.2f", unpack(att:GetField(sName, {0,0,0})));
					prop_type = "table";
					type_converter = [[converter="PETools.World.TypeConverter.NumberArrayListConverter"]]
				else
					text=tostring(att:GetField(sName, ""));
				end
			end
		else
			
			if(sType == "string") then
				if(sSchematics == ":file") then
					local filename = tostring(att:GetField(sName, ""));
					editor_ui = [[editor="System.Windows.Forms.Design.FileNameEditor"]]
				elseif(sSchematics == ":script") then
					local text = tostring(att:GetField(sName, ""));
					editor_ui = [[editor="System.Windows.Forms.Design.FileNameEditor"]]
				else
					local text=tostring(att:GetField(sName, ""));
				end
				prop_type = "string";

			elseif(sType == "float") then
				text=tostring(att:GetField(sName, ""));
				prop_type = "number";

			elseif(sType == "int") then
				local value = att:GetField(sName, 0);
				prop_type = "number";	

			elseif(sType == "bool") then
				local text=tostring(att:GetField(sName, ""));
				prop_type = "boolean";

			elseif(sType == "vector3") then
				if(sSchematics == ":rgb") then
					local rgb= att:GetField(sName, {0,0,0});
					local color = {r = 255*rgb[1],g = 255*rgb[2],b = 255*rgb[3]};
				else
					local xyz= att:GetField(sName, {0,0,0});
					local vec3 = { x = xyz[1],y = xyz[2],z = xyz[3], };
				end
				prop_type = "table";
				type_converter = [[converter="PETools.World.TypeConverter.NumberArrayListConverter"]]

			elseif(sType == "void") then
				-- TODO: this is a function. 
			else
				-- Unknown field
			end
		end
		if(prop_type) then
			prop_desc = prop_desc or "";
			if(prop_type == "table") then
				get_func = string.format([[return function(self) return IPCBinding.EntityHelper.GetField("%s.%s", {}) end]], name, prop_name);
			else
				get_func = string.format([[return function(self) return IPCBinding.EntityHelper.GetField("%s.%s") end]], name, prop_name);
			end
			
			set_func = string.format([[return function(self, value) return IPCBinding.EntityHelper.SetField("%s.%s", value) end]], name, prop_name);
			
			local nameNoramlized = prop_name.gsub(prop_name, " ", "_");
			append(string.format([[		<property name="%s" type="%s" desc="%s" %s %s
					get_func='%s' 
					set_func='%s' />
]], nameNoramlized, prop_type, prop_desc, type_converter or "", editor_ui or "", get_func, set_func));

		end
	end
	append([[	</properties>
]]);
	append([[
	</pe:entity_template>
</pe:mcml>]]);

	return table.concat(outputs);
end

local GlobalSettingsAttr;
local CameraAttr;
local SkyAttr;
local OceanAttr;
local TerrainAttr;
local SceneAttr;

-- call this function when scene is reset. if not, the cached namespaces_object may be invalid, when scene reloads 
function EntityHelper.ClearAllCachedObject()
	GlobalSettingsAttr = nil;
	CameraAttr = nil;
	SkyAttr = nil;
	OceanAttr = nil;
	TerrainAttr = nil;
	SceneAttr = nil;
end

-- cached attribute object / 
local namespaces_object = {
	["GlobalSettings"] = function()  
		if(not GlobalSettingsAttr) then
			GlobalSettingsAttr = ParaEngine.GetAttributeObject();
		end
		return GlobalSettingsAttr;
	end,
	["Camera"] = function()  
		if(not CameraAttr) then
			CameraAttr = ParaCamera.GetAttributeObject();
		end
		return CameraAttr;
	end,
	["Sky"] = function()  
		if(not SkyAttr) then
			SkyAttr = ParaScene.GetAttributeObjectSky();
		end
		return SkyAttr;
	end,
	["Terrain"] = function()  
		if(not TerrainAttr) then
			TerrainAttr = ParaTerrain.GetAttributeObject();
		end
		return TerrainAttr;
	end,
	["Ocean"] = function()  
		if(not OceanAttr) then
			OceanAttr = ParaScene.GetAttributeObjectOcean();
		end
		return OceanAttr;
	end,
	["Scene"] = function()  
		if(not SceneAttr) then
			SceneAttr = ParaScene.GetAttributeObject();
		end
		return SceneAttr;
	end,
}

-- get an object attribute by its namespace. 
local function GetObjectByNamespace(namespace)
	local func = namespaces_object[namespace];
	if(func) then
		return func();
	end
end

-- get a field name by its full name path. 
-- @param fullname: the full name of a setting parameter consists of its namespace plus field name. 
-- for well know namespaces, the object is cached, making it fast to call the next times. 
-- @param default_value: a default value if it does not exist. This can be nil.  
function EntityHelper.GetField(fullname, default_value)
	local namespace, name = string.match(fullname, "^(.+)%.([^%.]+)$");
	if(namespace) then
		local attr = GetObjectByNamespace(namespace);
		if(attr) then
			return attr:GetField(name, default_value);
		else
			commonlib.log("warning: unknown setting fields: %s\n", fullname);
		end
	end
end


-- set a field name by its full name path. 
-- @param fullname: the full name of a setting parameter consists of its namespace plus field name. 
-- for well know namespaces, the object is cached, making it fast to call the next times. 
-- @param value: value to be set. 
function EntityHelper.SetField(fullname, value)
	local namespace, name = string.match(fullname, "^(.+)%.([^%.]+)$")
	if(namespace) then
		local attr = GetObjectByNamespace(namespace);
		if(attr) then
			return attr:SetField(name, value);
		else
			commonlib.log("warning: unknown setting fields: %s\n", fullname);
		end
	end
end
