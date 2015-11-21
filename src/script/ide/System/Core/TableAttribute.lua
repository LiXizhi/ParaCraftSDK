--[[
Title: Table Attribute Object
Author(s): LiXizhi, 
Date: 2015/7/1
Desc: using the proxy model to provide attribute of any table object. 
column 0 is raw data.
column 1 is the meta table if any. i.e. GetChildAt(0,1) contains the meta table
column 2 is the object returned by data.GetAttributeObject if any.  i.e. GetChildAt(0,2) is the attribute object. 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Core/TableAttribute.lua");
local TableAttribute = commonlib.gettable("System.Core.TableAttribute")
local attr = TableAttribute:create({name="value", "hello", mytable = {subname="sub"}});
assert(attr:GetField("name") == "value" and attr:GetField(1) == "hello");
attr:SetField("name", "value1");
assert(attr:GetField("name") == "value1");
assert(attr:GetChildCount() == 1);
local child_attr = attr:GetChildAt(1);
assert(child_attr:GetClassName() == "mytable");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Core/AttributeObject.lua");

local TableAttribute = commonlib.inherit(commonlib.gettable("System.Core.AttributeObject"), commonlib.gettable("System.Core.TableAttribute"));

function TableAttribute:ctor()
end

-- static function: create attribute wrapper from a given table data.
-- @param proxydata: any table object. 
-- @param class_name: if nil, it is "table"
function TableAttribute:create(proxydata, class_name)
	if(type(proxydata) == "table") then
		return self:new():init(proxydata, class_name);
	end
end

function TableAttribute:init(proxydata, class_name)
	self.proxydata = proxydata;
	if(class_name) then
		self.class_name = class_name;
	end
	return self;
end

-- return true, if this object is the same as the given object.
function TableAttribute:equals(obj)
	return obj and self.proxydata == obj.proxydata;
end

-- private: all data, children, and meta are pre-computed and has an index. 
function TableAttribute:SyncObject()
	if(not self.fields) then
		local fields = {};
		local fieldnames = {};
		local child_fields = {};
		local child_fieldnames = {};
		
		-- data field and child. any table value is a child.
		for name, value in pairs(self.proxydata) do
			local type_name = type(name);
			if(type_name == "string" or type_name == "number") then
				if(type(value) == "table") then
					child_fields[#child_fields+1] = name;
					child_fieldnames[name] = #child_fields-1;
				else
					fields[#fields+1] = name;
					fieldnames[name] = #fields-1;
				end
			end
		end
		self.fields = fields;
		self.fieldnames = fieldnames;
		self.child_fields = child_fields;
		self.child_fieldnames = child_fieldnames;
		self.children = {};
	end
end

-- private:
function TableAttribute:SyncMetaObject()
	-- meta table
	if(self.meta_table == nil) then
		local meta = getmetatable(self.proxydata);
		if(type(meta) == "table") then
			if(type(meta.__index) == "table") then
				self.meta_table = self:create(meta.__index);
				self.meta_table.class_name = "meta_table_index";
			else
				self.meta_table = self:create(meta);
				self.meta_table.class_name = "meta_table";
			end
		end
		self.meta_table = self.meta_table or false;
	end
end

-- private: 
function TableAttribute:GetDataFields()
	self:SyncObject();
	return self.fields;
end

-- private: 
function TableAttribute:GetChildFields()
	self:SyncObject();
	return self.child_fields;
end

		
-- get child attribute object. this can be regarded as an intrusive data model of a given object. 
-- once you get an attribute object, you can use this model class to access all data in the hierarchy.
function TableAttribute:GetChild(sFieldname)
	local nIndex = self:GetFieldIndex(sFieldname);
	if(nIndex and nIndex >=0) then
		return self:GetChildAt(nIndex);
	end
end

-- column 0 is raw data, (0,1) contains the meta table if any. 
-- child result is cached for further invocation. 
-- @param nColumnIndex: nil to default to 0;
-- @return TableAttribute or false. 
function TableAttribute:GetChildAt(nRowIndex, nColumnIndex)
	nColumnIndex = nColumnIndex or 0;
	if(nColumnIndex == 0) then
		local fields = self:GetChildFields();
		local field_name = fields[nRowIndex+1];
		if(field_name) then
			local child_attr = self.children[nRowIndex+1];
			if(child_attr == nil) then
				local child = rawget(self.proxydata, field_name);
				if(type(child) == "table") then
					child_attr = self:create(child);
					child_attr.class_name = field_name;
				end
				self.children[nRowIndex+1] = child_attr or false;
			end
			return child_attr;
		end
	elseif(nColumnIndex == 1 and nRowIndex==0) then
		-- meta table.
		self:SyncMetaObject();
		return self.meta_table;
	elseif(nColumnIndex == 2 and nRowIndex==0) then
		if(self.proxydata.GetAttributeObject) then
			return self.proxydata:GetAttributeObject();
		end
	end
end

-- @param nColumnIndex: if nil, default to 0. 
function TableAttribute:GetChildCount(nColumnIndex)
	nColumnIndex = nColumnIndex or 0;
	if(nColumnIndex == 0) then
		return #(self:GetChildFields());
	elseif(nColumnIndex == 1) then
		local meta = getmetatable(self.proxydata);
		if(meta) then
			return 1;
		else
			return 0;
		end
	elseif(nColumnIndex == 2) then
		if(self.proxydata.GetAttributeObject) then
			return 1;
		else
			return 0;
		end
	end
end

-- we support multi-dimensional child object. by default objects have only one column. 
function TableAttribute:GetColumnCount()
	if(self:GetChildCount(2) > 0) then
		return 3;
	elseif(self:GetChildCount(1) > 0) then
		return 2;
	else
		return 1;
	end
end

-- check if the object is valid
function TableAttribute:IsValid()
	return self.proxydata ~= nil;
end

function TableAttribute:GetClassID()
	return 0;
end

-- class name
function TableAttribute:GetClassName()
	return self.class_name or "table";
end

function TableAttribute:SetClassName(class_name)
	self.class_name = class_name;
end

-- class description
function TableAttribute:GetClassDescription()
end

-- Set which order fields are saved. 
TableAttribute.Field_Order = {
	Sort_ByName = 0,
	Sort_ByCategory = 1,
	Sort_ByInstallOrder = 2,
};

function TableAttribute:SetOrder(order)
end

-- get which order fields are saved.
function TableAttribute:GetOrder()
end

-- get the total number of field.
function TableAttribute:GetFieldNum()
	return #(self:GetDataFields());
end

-- get field at the specified index. "" will be returned if index is out of range.
function TableAttribute:GetFieldName(nIndex)
	local fields = self:GetDataFields();
	return fields[nIndex] or "";
end

-- get field index of a given field name. -1 will be returned if name not found. 
-- @param sFieldname 
-- @return index or -1
function TableAttribute:GetFieldIndex(sFieldname)
	local fields = self:GetChildFields();
	return self.fieldnames[sFieldname] or -1;
end

-- get the field type as string
-- @param nIndex : index of the field
-- @return one of the following type may be returned 
-- "void" "bool" "string" "int" "float" "float_float" "float_float_float" "double" "vector2" "vector3" "vector4" "enum" "deprecated" ""
function TableAttribute:GetFieldType(nIndex)
	return type(self:GetField(self:GetFieldName(nIndex)));
end

-- whether the field is read only. a field is ready only if and only if it has only a get method.
-- @param nIndex : index of the field
-- @return true if it is ready only or field does not exist
function TableAttribute:IsFieldReadOnly(nIndex)
end

-- Get Field Schematics string 
-- @param nIndex: index of the field
-- @return "" will be returned if index is out of range
function TableAttribute:GetFieldSchematics(nIndex)
	return "";
end

-- parse the schema type from the schema string.
-- @return : simple schema type. it may be any of the following value. 
--   unspecified: ""
--   color3	":rgb" 
--   file	":file" 
--   script	":script"
--   integer	":int"
function TableAttribute:GetSchematicsType(nIndex)
end

-- get field by name.
-- e.g. suppose att is the attribute object.
-- 	local bGloble = att:GetField("global", true);
-- 	local facing = att:GetField("facing", 0);
-- 	local pos = att:GetField("position", {0,0,0});
-- 	pos[1] = pos[1]+100;pos[2] = 0;pos[3] = 10;
-- 
-- @param sFieldname: field name
-- @param output: default value. if field type is vectorN, output is a table with N items.
-- @return: return the field result. If field not found, output will be returned. 
-- 	if field type is vectorN, return a table with N items.Please note table index start from 1
function TableAttribute:GetField(sFieldname, output)
	return rawget(self.proxydata, sFieldname) or output;
end

		
-- set field by name 
-- e.g. suppose att is the attribute object.
-- 	att:SetField("facing", 3.14);
-- 	att:SetField("position", {100,0,0});
-- @param sFieldname: field name
-- @param input: input value. if field type is vectorN, input is a table with N items.--
function TableAttribute:SetField(sFieldname, input)
	self.proxydata[sFieldname] = input;
end

		
-- call field by name. This function is only valid when The field type is void. 
-- It simply calls the function associated with the field name.
function TableAttribute:CallField(sFieldname, ...)
	local func = rawget(self.proxydata, sFieldname);
	if(type(func) == "function") then
		return func(...);
	end
end

function TableAttribute:PrintObject(file)
	echo({"name", self:GetClassName()})
	local nColCount = self:GetColumnCount();
	for cols=0, nColCount-1 do
		local nRowCount = self:GetChildCount(cols);
		if(nRowCount > 0) then
			for rows = 0, nRowCount-1  do
				local child = self:GetChildAt(rows, cols);
				if(child and child:IsValid()) then
					local local_path;
					if(nColCount>1) then
						local_path = format("%d,%d", rows, cols);
					else
						local_path = tostring(rows);
					end
					echo({local_path, child:GetClassName()});
				end
			end
		end
	end
end

-- Reset the field to its initial or default value. 
-- @param nFieldID : field ID
-- @return true if value is set; false if value not set. 
function TableAttribute:ResetField(nFieldID)
end

-- Invoke an (external) editor for a given field. This is usually for NPL script field
-- @param nFieldID : field ID
-- @param sParameters : the parameter passed to the editor
-- @return true if editor is invoked, false if failed or field has no editor. 
function TableAttribute:InvokeEditor(nFieldID, sParameters)
end


--------------------
-- dynamic fields
--------------------

-- get field by name or index.
-- e.g. suppose att is the attribute object.
-- local bGloble = att:GetField("URL", nil);
-- local facing = att:GetField("Title", "default one");
-- 		
-- @param sFieldname: field name string or number index
-- @param output: default value. if field type is vectorN, output is a table with N items.
-- @return: return the field result. If field not found, output will be returned. 
-- if field type is vectorN, return a table with N items.Please note table index start from 1
function TableAttribute:GetDynamicField(sFieldnameOrIndex, output)
	return output;
end


-- get field name by index
function TableAttribute:GetDynamicFieldNameByIndex(nIndex)
end

-- how many dynamic field this object currently have.
function TableAttribute:GetDynamicFieldCount()
end

-- set field by name 
-- e.g. suppose att is the attribute object.
-- att:SetDynamicField("URL", 3.14);
-- att:SetDynamicField("Title", {100,0,0});
-- @param sFieldname: field name
-- @param input: input value. can be value or string type--
function TableAttribute:SetDynamicField(sFieldname, input)
end
		
-- remove all dynamic fields
function TableAttribute:RemoveAllDynamicFields()
end

-- add dynamic field and return field index
-- @return field index or -1
function TableAttribute:AddDynamicField(sName, dwType)
	return -1;
end
