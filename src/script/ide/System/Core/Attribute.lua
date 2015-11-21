--[[
Title: A single Attribute on Attribute Object
Author(s): LiXizhi, 
Date: 2015/8/21
Desc: Attribute is a wrapper for a single attribute field on a given attribute object. 
We can store and pass attributes and later set or get its values. 
See also: AttributeObject.lua

Attribute is sometimes called plug, since it is usually used for connecting dependent attribute fields together. 
There is a convient helper function called AttributeObject:findPlug(name) which returns attribute field(plug) object.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Core/Attribute.lua");
local Attribute = commonlib.gettable("System.Core.Attribute");
local plugText = Attribute:new():init(ParaEngine.GetAttributeObject(), "WindowText");
echo(plugText:GetValue());

-- use findPlug helper function 
local plugText = ParaEngine.GetAttributeObject():findPlug("WindowText");
plugText:SetValue("HelloWorld");
------------------------------------------------------------
]]

local Attribute = commonlib.inherit(nil, commonlib.gettable("System.Core.Attribute"));

Attribute.name = "";

function Attribute:ctor()
end

-- @param attr: the attribute object
-- @param name: field name string. 
function Attribute:init(attr, name)
	self.attr = attr;
	self.name = name;
	return self;
end

function Attribute:IsValid()
	if(self.attr and self.attr:IsValid() and self.name) then
		return true;
	end
end

-- get the underlying attribute object. 
function Attribute:GetAttributeObject()
	if(self.attr and self.attr:IsValid()) then
		return self.attr;
	else
		self.attr = nil;
	end
end

-- get the underlying object 
function Attribute:GetObject()
	if(self.attr and self.attr.QueryObject) then
		return self.attr:QueryObject();
	end
end

function Attribute:GetName()
	return self.name;
end

function Attribute:GetIndex()
	if(self.attr) then
		self.attr:GetFieldIndex(self.name);
	else
		return -1;
	end
end

function Attribute:GetType()
	if(self.attr) then
		return self.attr:GetFieldType(self.name);
	else
		return "";
	end
end

function Attribute:IsFieldReadOnly()
	if(self.attr) then
		return self.attr:IsFieldReadOnly(self.name);
	end
end

function Attribute:GetSchematics()
	if(self.attr) then
		return self.attr:GetFieldSchematics(self.name);
	else
		return "";
	end
end

function Attribute:GetSchematicsType()
	if(self.attr) then
		return self.attr:GetSchematicsType(self.name);
	end
end

-- call field by name. This function is only valid when The field type is void. 
-- It simply calls the function associated with the field name.
function Attribute:Call()
	if(self.attr) then
		return self.attr:CallField();
	end
end


-- Reset the field to its initial or default value. 
function Attribute:Reset()
	if(self.attr) then
		return self.attr:ResetField(self:GetIndex());
	end
end

-- Invoke an (external) editor for a given field. This is usually for NPL script field
function Attribute:InvokeEditor(sParameters)
	if(self.attr) then
		return self.attr:InvokeEditor(self:GetIndex()), sParameters;
	end
end


function Attribute:GetValue(output)
	if(self.attr) then
		return self.attr:GetField(self.name, output);
	else
		return output;
	end
end

function Attribute:SetValue(input)
	if(self.attr) then
		self.attr:SetField(self.name, input);
	end
end

-- same as SetValue, except that some implementation may not send signals like valueChanged even data is modified. 
-- it will automatically fallback to SetValue if not such implementation is provided by the attribute object.  
function Attribute:SetValueInternal(input)
	if(self.attr) then
		self.attr:SetFieldInternal(self.name, input);
	end
end
		