--[[
Title: 
Author(s): Leio
Date: 2010/5/12
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/IPCBinding/BindableObject.lua");
------------------------------------------------------
]]
NPL.load("(gl)script/ide/EventDispatcher.lua");
local tostring = tostring
local tonumber = tonumber
local type = type
local format = format;

local BindableObject = commonlib.inherit(nil,{
})
commonlib.setfield("IPCBinding.BindableObject",BindableObject);

local classTitle = {label = "BindableObject",};
local props = {
	{ label = "uid",},
};

function BindableObject:ctor()
	if(not self.uid)then
		self.uid = ParaGlobal.GenerateUniqueID();
	end
	self.eventDispatcher = commonlib.EventDispatcher:new();
end

function BindableObject:GetUID()
	return self.uid;
end

-- call this function to set value due to user operation on the NPL side. 
-- It will use the property the proper set function according to entity template.
-- It will also mark the object as modified and send the property changed event to the IDE framework.   
-- @param silent_mode: if true, we will not mark as modified, and neither will it send the property change event.  
function BindableObject:SetValue(name, value, silent_mode)
	local v = self:GetPropertyClassByKey(name);
	if(v) then
		-- call the setter if available 
		if(v.set_func) then
			self[name] = value;
			v.set_func(self, value);
		else
			self[name] = value;
		end
	end

	if(not silent_mode) then
		if(self.UpdateView) then
			self:UpdateView();
		end
		self.is_modified = true;
		self:OnPropertyChanged();
	end
end

-- call this function to get value from a given property
function BindableObject:GetValue(name, default_value)
	local v = self:GetPropertyClassByKey(name);
	if(v) then
		-- call the setter if available 
		if(v.get_func) then
			return v.get_func(self, self[name] or default_value);
		end
	end
	return self[name] or default_value;
end

-- SetValue to a group of name, value pairs.
-- only a single PropertyChange event is fired, which saved bandwidth if there are many property changes. 
-- @param silent_mode: if true, we will not mark as modified, and neither will it send the property change event.  
function BindableObject:SetParams(params, silent_mode)
	if(not params)then return end
	local k,v;
	for k,v in pairs(params) do
		self:SetValue(k, v, true);
	end
	if(not silent_mode) then
		if(self.UpdateView) then
			self:UpdateView();
		end
		self.is_modified = true;
		self:OnPropertyChanged();
	end
end

-- TODO: 
function BindableObject:GetParams()

end

-- get class descriptor. 
function BindableObject:GetClassDescriptor()
	return self.classTitle or classTitle, self.props or props;
end

-- get property class. 
function BindableObject:GetPropertyClassByKey(key)
	local props = self.props or props;

	local prop_map = props.map;
	if(not prop_map) then
		prop_map = {};
		props.map = prop_map;
	end

	-- cache it in property map, so that we do not need to look it up every time. 
	local prop_ = prop_map[key];
	if (prop_) then
		return prop_;
	end

	local _, prop;
	for _, prop in ipairs(props) do
		if(prop.label == key)then
			prop_ = prop;
			prop_map[key] = prop;
			break;
		end
	end
	return prop_;
end

function BindableObject:ToXML()
	local classTitle,props = self:GetClassDescriptor();
	local xml = BindableObject.NPLToXML(self,classTitle,props)
	return xml;
end
function BindableObject:OnPropertyChanged()
	self:DispatchEvent({
		type = "propertychanged",
		sender = self,
	});
end
function BindableObject:AddEventListener(type,func,funcHolder)
	self.eventDispatcher:AddEventListener(type,func,funcHolder);
end
function BindableObject:RemoveEventListener(type)
	self.eventDispatcher:RemoveEventListener(type);
end
function BindableObject:DispatchEvent(event, ...)
	self.eventDispatcher:DispatchEvent(event);
end
------------------------------------------------------------------------------
function BindableObject.NPLToXML(self,classTitle,props)
	if(self and classTitle and props)then
		local k,v;
		local props_str = "";
		for k,v in ipairs(props) do
			local label = v.label;
			local _type = v.type or "string";
			local value = self[label];
			if(_type == "table")then
				--以节点形式描述table
				--<object><property id="x"><number>0</number></property></object>
				--or
				--<array><property id="0"><number>0</number></property></array>
				if(value == nil) then
					-- tricky: for null value we will check to see if the template provide a default value, if so, we will use it. 
					if(v.default_value) then
						if(not v.default_value_) then
							v.default_value_ = NPL.LoadTableFromString(v.default_value)
						end
					end
					value = v.default_value_ or {}; -- default to empty table
				end
				value = commonlib.serialize_toflash_internal(value);

			elseif(_type == "number")then
				if(value == nil) then
					value = v.default_value or "0"; ---- default to 0
				else
					value = tostring(value); 
				end
			elseif(_type == "string")then
				if(value == nil) then
					value = v.default_value or ""; -- default to empty
				else
					value = tostring(value);
				end
				
			elseif(_type == "boolean")then
				if(value == nil) then
					value = v.default_value or "false"; -- default to false
				else
					value = tostring(value);
				end
			else
				value = tostring(value);
			end
			if(value ~= nil)then
				local prop = format("<%s>%s</%s>",label,value,label);
				props_str = props_str .. prop;
			end
		end
		local class_title = classTitle.label;
		if(class_title)then
			local class_str = format([[<?xml version="1.0" encoding="utf-8"?>
<%s xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">%s</%s>]],class_title,props_str,class_title);
			class_str = format("<![CDATA[%s]]>",class_str);
			return class_str;
		end
	end
end

function BindableObject.SetPropertyFromMsg(obj,msg)
	if(not obj or not msg or type(msg) ~= "table")then return end
	local key = msg.key;
	local value = msg.value;
	local type = msg.type;
	local classTitle,props = obj:GetClassDescriptor();
	if(classTitle and props)then
		local v = obj:GetPropertyClassByKey(key);
		if(v) then
			local obj_type = v.type or "string";--default value is string
			local obj_key = v.label;
			if(obj_type == "string")then
				value = tostring(value);
			elseif(obj_type == "number")then
				value = tonumber(value);
			elseif(obj_type == "boolean")then
				value = (value == "true") or (value=="True");
			elseif(obj_type == "table")then
				value = commonlib.deserialize_tonpl_onlydatatype(value);
			end
			--commonlib.echo("======value");
			--commonlib.echo(value);
			-- call the setter if available 
			if(v.set_func) then
				obj[obj_key] = value;
				v.set_func(obj, value);
			else
				obj[obj_key] = value;
			end
		end
		if(obj.UpdateView) then
			obj:UpdateView();
		end
		obj.is_modified = true;
	end
end

