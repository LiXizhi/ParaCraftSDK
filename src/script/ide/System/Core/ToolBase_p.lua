--[[
Title: private classes 
Author(s): LiXizhi
Date: 2014/11/25
Desc: This function should only be included by ToolBase.lua
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Core/ToolBase_p.lua");
local ConnectionSynapse = commonlib.gettable("System.Core.ConnectionSynapse");
local SignalConnections = commonlib.gettable("System.Core.SignalConnections");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/STL.lua");
NPL.load("(gl)script/ide/System/Core/Event.lua");
NPL.load("(gl)script/ide/System/Core/Attribute.lua");
local Attribute = commonlib.gettable("System.Core.Attribute");
------------------------------------------------
-- signal connections.
------------------------------------------------
local SignalConnections = commonlib.inherit(nil, commonlib.gettable("System.Core.SignalConnections"));
function SignalConnections:ctor()
	self.axon_connections = {};
end

function SignalConnections:Get(signal)
	return self.axon_connections[signal];
end

function SignalConnections:Set(signal, axon_connection)
	self.axon_connections[signal] = axon_connection;
end

function SignalConnections:pairs()
	return pairs(self.axon_connections);
end

function SignalConnections:CleanConnectionLists()
	if (self.dirty) then
		-- TODO:remove all dirty ones
		self.dirty = false;
	end
end

------------------------------------------------
-- one of connection between signal and slot.
------------------------------------------------
local ConnectionSynapse = commonlib.inherit(nil, commonlib.gettable("System.Core.ConnectionSynapse"));

ConnectionSynapse.sender = nil;
ConnectionSynapse.signal = nil;
ConnectionSynapse.receiver = nil;
ConnectionSynapse.slot = nil;
ConnectionSynapse.connection_type = "";

function ConnectionSynapse:ctor()
end

function ConnectionSynapse:IsConnectedTo(receiver, slot)
	return self.receiver == receiver and self.slot == slot;
end

-- invoke the slot
function ConnectionSynapse:Activate(...)
	if(self.slot) then
		if(self.receiver) then
			self.receiver.currentSender = self.sender;
		end
		self.slot(self.receiver, ...);
		if(self.receiver) then
			self.receiver.currentSender = nil;
		end
	end
end

------------------------------------------------
-- macro functions for class declaration. 
------------------------------------------------
local ToolBase = commonlib.gettable("System.Core.ToolBase");

-- @param property: {name="visible", auto=true, private_name=nil, set="setVisible", get="isVisible", default=nil, sig=nil, type="bool", desc=nil, }
-- or shortcut {"visible", false, "isVisible", "setVisible"}
-- auto: if true, we will create setter and getter function automatically
local function InstallProperty_helper(class_def, property)
	if(not property or not class_def) then
		return;
	end
	if(property[1]) then
		property.name = property[1];
	end
	if(property[2]~=nil) then
		property.default = property[2];
	end
	if(not property.type) then
		-- auto determine type from default value if any
		local fieldType;
		local valueType = type(property.default);
		if(valueType == "table") then
			local nSize = #(property.default);
			if(nSize == 3) then
				fieldType = "vector3";
			elseif(nSize == 2) then
				fieldType = "vector2";
			elseif(nSize == 4) then
				fieldType = "vector4";
			elseif(nSize == 16) then
				fieldType = "Matrix4";
			else
				fieldType = "";
			end
		elseif(valueType == "bool" or valueType == "nil") then
			fieldType = "bool";
		elseif(valueType == "string") then
			fieldType = "string";
		else
			fieldType = "double";
		end
		property.type = fieldType;
	end
		
	if(property[3]) then
		property.get = property[3];
	end
	if(property[4]) then
		property.set = property[4];
	end
	local name = property.name;
	local getterName = property.get;
	local setterName = property.set;
	local private_name = property.private_name or property.name;
	local signal_name = property.signal_name;
	if(getterName == private_name) then
		-- if getterName is same as name, we will use m_XXX as variable name. 
		private_name = "m_"..name;
	end
	property.private_name = private_name;

	if(property.default ~= nil) then
		class_def[private_name] = property.default;
	end
	
	if(property.auto) then
		setterName = setterName or ("Set"..name);
		getterName = getterName or ("Get"..name);
		-- create setting and getter automatically
		-- setter name like self:SetValue(value), one may override
		if(signal_name) then
			class_def[setterName] = function(self, value)
				if(self[private_name] ~= value) then
					self[private_name] = value;
					-- fire signal
					self:Activate(signal_name, value);
				end
			end
		else
			class_def[setterName] = function(self, value)
				if(self[private_name] ~= value) then
					self[private_name] = value;
				end
			end
		end
		-- getter name like self:GetValue(), one may override
		class_def[getterName] = function(self)
			return self[private_name];
		end
	end
	-- add property to property fields of class_def. 
	ToolBase.AddField(class_def, name, property)
end

-- define a property with overridable get/set function. 
-- e.g.  YourClass:Property(property_name, ...);
-- @param class_def: the class table (not instance). 
-- @param name: First letter is usually in capital.  (it can also be property table. )
--   such as  {name="visible", set="setVisible", get="isVisible", default=nil, sig=nil, type="bool", desc=nil, }
--		{"visible", false, "isVisible", "setVisible"}
--		{"Enabled", false, auto=true}
-- @param getterName: if nil, default to "Get"..name.  
-- @param setterName: if nil, default to "Set"..name.
-- @param notifySignal: the signal to fire when property changed. default to nil. 
function ToolBase.Property(class_def, name, default_value, getterName, setterName, notifySignal)
	local property;
	if(type(name) == "string") then
		property = { 
			auto = true, 
			name = name,
			-- private name like self.Value_
			private_name = name.."_",
			-- default value
			default = default_value,
			get = getterName,
			set = setterName, 
			-- private signal name ValueChanged(value)
			signal_name = notifySignal,
		}
	else
		property = name;
	end
	return InstallProperty_helper(class_def, property);
end

-- define a signal
-- e.g. YourClass:Signal("OnXXXChanged", ...);
--  @param ...: parameter list is only used for documentation purpose. 
function ToolBase.Signal(class_def, name)
	local function signal_func(self, ...)
		self:Activate(signal_func, ...)
	end
	class_def[name] = signal_func;
end

-------------------------------------
-- implement Attribute Fields interface
-------------------------------------
-- store all class definitions that support attribute interface to classes 
NPL.load("(gl)script/ide/System/Core/Classes.lua");
local Classes = commonlib.gettable("System.Core.Classes");

function ToolBase.AddField(class_def, name, property)
	local propertyFields = rawget(class_def, "_propertyfields");
	if(not propertyFields) then
		propertyFields = commonlib.ArrayMap:new();
		if(class_def._propertyfields) then
			-- duplicate parent property
			for key, property in class_def._propertyfields:pairs() do
				propertyFields:add(key, property);
			end
		end
		class_def._propertyfields = propertyFields;
		Classes:Add(class_def);
	end
	propertyFields:add(name, property);
end

function ToolBase:IsValid()
	return true;
end

-- find and return a given attribute plug object. 
-- this is a public helper function. 
function ToolBase:findPlug(name)
	return self:GetAttributeObject():findPlug(name);
end

function ToolBase:GetFieldNum()
	return self._propertyfields:size();
end

function ToolBase:GetFieldIndex(name)
	return self._propertyfields:getIndex(name);
end

function ToolBase:GetFieldName(valueIndex)
	local field = self._propertyfields:at(valueIndex);
	if(field) then
		return field.name;
	end
end

function ToolBase:GetFieldType(nIndex)
	local field = self._propertyfields:at(valueIndex);
	if(field) then
		return field.type;
	end
end

-- same as SetField, except that some implementation may not send signals like valueChanged even data is modified. 
-- it will automatically fallback to SetField if not such implementation is provided by the attribute object.  
function ToolBase:SetFieldInternal(name, value)
	self:SetField(name, value);
end

function ToolBase:SetField(name, value)
	local property = self._propertyfields:get(name);
	if(property and property.set) then
		if(type(property.set) == "string") then
			local func = self[property.set];
			if(func) then
				func(self, value);
			end
		end
	elseif(property and property.private_name)then
		self[property.private_name] = value;
	end
end

function ToolBase:GetField(name, defaultValue)
	local property = self._propertyfields:get(name);
	if(property and property.get) then
		if(type(property.get) == "string") then
			local func = self[property.get];
			if(func) then
				return func(self);
			end
		end
		return defaultValue;
	elseif(property and property.private_name)then
		return self[property.private_name] or defaultValue;
	else
		return defaultValue;
	end
end

NPL.load("(gl)script/ide/System/Core/ToolBaseAttributeObject.lua");
local ToolBaseAttributeObject = commonlib.gettable("System.Core.ToolBaseAttributeObject");

function ToolBase:GetAttributeObject()
	if(not rawget(self, "attrObject")) then
		self.attrObject = ToolBaseAttributeObject:new():init(self);
	end
	return self.attrObject
end

