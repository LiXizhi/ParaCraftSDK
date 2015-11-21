--[[
Title: Default Attribute Object model for all Toolbase derived class
Author(s): LiXizhi
Date: 2015/8/21
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Core/ToolBaseAttributeObject.lua");
local ToolBaseAttributeObject = commonlib.gettable("System.Core.ToolBaseAttributeObject");
local attrObject = ToolBaseAttributeObject:new():init({});
echo(type(attrObject.GetClassName));
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Core/AttributeObject.lua");
NPL.load("(gl)script/ide/System/Core/Attribute.lua");
local Attribute = commonlib.gettable("System.Core.Attribute");
local ToolBaseAttributeObject = commonlib.inherit(commonlib.gettable("System.Core.AttributeObject"), commonlib.gettable("System.Core.ToolBaseAttributeObject"));

ToolBaseAttributeObject.Name = "ToolBaseAttributeObject";

function ToolBaseAttributeObject:ctor()
end

function ToolBaseAttributeObject:init(obj)
	self.obj = obj;
	return self;
end

function ToolBaseAttributeObject:QueryObject()
	return self.obj;
end

-- check if the object is valid
function ToolBaseAttributeObject:IsValid()
	return self.obj~=nil;
end

function ToolBaseAttributeObject:GetClassName()
	if(self.obj) then
		return self.obj:GetName() or self.Name;
	else
		return self.Name;
	end
end

-- find and return a given attribute plug object. 
-- this is a public helper function. 
function ToolBaseAttributeObject:findPlug(name)
	if(self:GetFieldIndex(name)) then
		return Attribute:new():init(self, name);
	end
end

function ToolBaseAttributeObject:GetFieldNum()
	return self.obj:GetFieldNum();
end

function ToolBaseAttributeObject:GetFieldName(valueIndex)
	return self.obj:GetFieldName(valueIndex);
end

function ToolBaseAttributeObject:GetFieldType(nIndex)
	return self.obj:GetFieldType(nIndex);
end

function ToolBaseAttributeObject:SetField(name, value)
	return self.obj:SetField(name, value);
end

function ToolBaseAttributeObject:SetFieldInternal(name, value)
	return self.obj:SetFieldInternal(name, value);
end

function ToolBaseAttributeObject:GetField(name, defaultValue)
	return self.obj:GetField(name, defaultValue);
end

function ToolBaseAttributeObject:GetFieldIndex(name)
	return self.obj:GetFieldIndex(name);
end