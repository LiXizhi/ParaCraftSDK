--[[
Title: Attribute Object
Author(s): LiXizhi, 
Date: 2015/7/1
Desc: Attribute Object is the unified data access interface in ParaEngine/NPL. 
This class has the exact same interface as C++'s ParaAttributeObject, 
thus it is possible that a child of NPL attribute object is a C++ attribute object. 

There are two ways to implement attribute object. 
1. the class model: your class derive from the base class. 
	When creating NPL class, one can also choose not to inherit from this class, but implement some of its virtual functions by adding its interface. 
	commonlib.add_interface(target_class, commonlib.gettable("System.Core.AttributeObject"))
2. the proxy model: The attribute object keeps a reference to the underlying data object and serve data as a proxy. 
	see System.Core.TableAttribute for example.

See also: System.Core.DOM, System.Core.ToolBase

vitual functions that must be implemented in proxy model:
	IsValid()
	equals(obj)
	
	GetChild(sName)
	GetChildAt(nRowIndex, nColumnIndex)
	GetChildCount(nColumnIndex)
	GetColumnCount()

	GetClassName()
	GetClassID()
	GetClassDescription()

	GetFieldNum()
	GetFieldName(nIndex)
	GetFieldType(nIndex)
	GetFieldSchematics(nIndex)
	IsFieldReadOnly(nIndex)

	SetField(sFieldname, input)
	GetField(sFieldname, output)
	CallField(sFieldname)

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Core/AttributeObject.lua");
local target_class = commonlib.inherit(nil, {});
commonlib.add_interface(target_class, commonlib.gettable("System.Core.AttributeObject"))

local AttributeObject = commonlib.gettable("System.Core.AttributeObject");
local attr = AttributeObject:new();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Core/Attribute.lua");
local Attribute = commonlib.gettable("System.Core.Attribute");
local AttributeObject = commonlib.inherit(nil, commonlib.gettable("System.Core.AttributeObject"));

function AttributeObject:ctor()
end

function AttributeObject:GetAttributeObject()
	return self;
end

function AttributeObject:QueryObject()
	return self;
end

-- find and return a given attribute plug object. 
-- this is a public helper function. 
function AttributeObject:findPlug(name)
	if(self:GetFieldIndex(name)) then
		return Attribute:new():init(self, name);
	end
end

-- return true, if this object is the same as the given object.
function AttributeObject:equals(obj)
	return self == obj;
end
		
-- get child attribute object. this can be regarded as an intrusive data model of a given object. 
-- once you get an attribute object, you can use this model class to access all data in the hierarchy.
function AttributeObject:GetChild(sName)
end

-- @param nColumnIndex: nil to default to 0;
function AttributeObject:GetChildAt(nRowIndex, nColumnIndex)
end

-- @param nColumnIndex: if nil, default to 0. 
function AttributeObject:GetChildCount(nColumnIndex)
	return 0;
end

-- we support multi-dimensional child object. by default objects have only one column. 
function AttributeObject:GetColumnCount()
	return 1;
end

-- check if the object is valid
function AttributeObject:IsValid()
	return true;
end

function AttributeObject:GetClassID()
end

-- class name
function AttributeObject:GetClassName()
	return self.Name or "AttributeObject";
end

-- class description
function AttributeObject:GetClassDescription()
	return "";
end

-- Set which order fields are saved. 
AttributeObject.Field_Order = {
	Sort_ByName = 0,
	Sort_ByCategory = 1,
	Sort_ByInstallOrder = 2,
};

function AttributeObject:SetOrder(order)
end

-- get which order fields are saved.
function AttributeObject:GetOrder()
end

-- get the total number of field.
function AttributeObject:GetFieldNum()
	return 0;
end
-- get field at the specified index. "" will be returned if index is out of range.
function AttributeObject:GetFieldName(nIndex)
	return "";
end

-- get field index of a given field name. -1 will be returned if name not found. 
-- @param sFieldname 
-- @return index or -1
function AttributeObject:GetFieldIndex(sFieldname)
	return -1;
end

-- get the field type as string
-- @param nIndex : index of the field
-- @return one of the following type may be returned 
-- "void" "bool" "string" "int" "float" "float_float" "float_float_float" "double" "vector2" "vector3" "vector4" "enum" "deprecated" ""
function AttributeObject:GetFieldType(nIndex)
	return "";
end

-- whether the field is read only. a field is ready only if and only if it has only a get method.
-- @param nIndex : index of the field
-- @return true if it is ready only or field does not exist
function AttributeObject:IsFieldReadOnly(nIndex)
	
end

-- Get Field Schematics string 
-- @param nIndex: index of the field
-- @return "" will be returned if index is out of range
function AttributeObject:GetFieldSchematics(nIndex)
	return "";
end

-- parse the schema type from the schema string.
-- @return : simple schema type. it may be any of the following value. 
--   unspecified: ""
--   color3	":rgb" 
--   file	":file" 
--   script	":script"
--   integer	":int"
function AttributeObject:GetSchematicsType(nIndex)
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
function AttributeObject:GetField(sFieldname, output)
	return output;
end

		
-- set field by name 
-- e.g. suppose att is the attribute object.
-- 	att:SetField("facing", 3.14);
-- 	att:SetField("position", {100,0,0});
-- @param sFieldname: field name
-- @param input: input value. if field type is vectorN, input is a table with N items.--
function AttributeObject:SetField(sFieldname, input)
end

		
-- call field by name. This function is only valid when The field type is void. 
-- It simply calls the function associated with the field name.
function AttributeObject:CallField(sFieldname)
end

function AttributeObject:PrintObject(file)
end

-- Reset the field to its initial or default value. 
-- @param nFieldID : field ID
-- @return true if value is set; false if value not set. 
function AttributeObject:ResetField(nFieldID)
end

-- Invoke an (external) editor for a given field. This is usually for NPL script field
-- @param nFieldID : field ID
-- @param sParameters : the parameter passed to the editor
-- @return true if editor is invoked, false if failed or field has no editor. 
function AttributeObject:InvokeEditor(nFieldID, sParameters)
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
function AttributeObject:GetDynamicField(sFieldnameOrIndex, output)
	return output;
end


-- get field name by index
function AttributeObject:GetDynamicFieldNameByIndex(nIndex)
end

-- how many dynamic field this object currently have.
function AttributeObject:GetDynamicFieldCount()
end

-- set field by name 
-- e.g. suppose att is the attribute object.
-- att:SetDynamicField("URL", 3.14);
-- att:SetDynamicField("Title", {100,0,0});
-- @param sFieldname: field name
-- @param input: input value. can be value or string type--
function AttributeObject:SetDynamicField(sFieldname, input)
end
		
-- remove all dynamic fields
function AttributeObject:RemoveAllDynamicFields()
end

-- add dynamic field and return field index
-- @return field index or -1
function AttributeObject:AddDynamicField(sName, dwType)
	return -1;
end