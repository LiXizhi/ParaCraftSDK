--[[
Title: EventDispatcher(Single Listener) and EventSystem(Multiple Listener)
Author(s): Leio, refactored by LiXizhi 2009.11.6, EventSystem added by LiXizhi 2010.9.3
Date: 2008/12/24
Desc: We can use it as a base class or as a member in a class. 
EventDispatcher and EventSystem have identical interfaces. 
   * EventDispatcher only support one listener per event type, and is slightly faster than EventSystem
   * EventSystem support multiple listeners per event type, but one needs to be aware of duplicated calls to AddEventListener
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/EventDispatcher.lua");

-- Usage 1: as a member in a class
local events = commonlib.EventDispatcher:new();
local events = commonlib.EventSystem:new();

events:AddEventListener("eventType",function(self, event) commonlib.echo(event)  end, events, "global_unique_name_can_be_nil");
events:DispatchEvent({type = "eventType" , data = "as member"});

-- Usage 2: as a base class
local MyClass = commonlib.inherit(commonlib.EventSystem, commonlib.gettable("commonlib.test.event_system_test"));  
MyClass:ctor(); -- call this if singleton. 
function MyClass:MyCallBack(event)
	commonlib.echo(event)
end

local myclassInst = MyClass:new();
myclassInst:AddEventListener("eventType", MyClass.MyCallBack, myclassInst, "global_unique_name_can_be_nil");
myclassInst:DispatchEvent({type = "eventType" , data = "as base class"});
------------------------------------------------------------
]]
local EventDispatcher = commonlib.inherit(nil, commonlib.gettable("commonlib.EventDispatcher"))

--constructor
function EventDispatcher:ctor()
	self.event_pools = {}
end

-- add a new listener. Note there can only be one listener per event type
-- @param type: this is the key to event. It can be anything. It is usually string or integer. 
-- @param func: the callback function(funcHolder, event)  end. 
-- @param funcHolder: this is an object that is passed as the first parameter to the callback function.
function EventDispatcher:AddEventListener(type,func,funcHolder)
	if(not type or not func)then return end
	self.event_pools[type] = {func = func,funcHolder = funcHolder};
end

-- remove listener
function EventDispatcher:RemoveEventListener(type)
	if(not type)then return end
	self.event_pools[type] = nil;
end

-- has event listener
function EventDispatcher:HasEventListener(type)
	if(not type)then return end
	if(self.event_pools[type])then 
		return true;
	end
end

-- dispatch the event. 
-- @return: the callback return value is also returned. 
function EventDispatcher:DispatchEvent(event, ...)
	if(not event)then return end
	local listener = self.event_pools[event.type]
	if(listener)then
		local func = listener.func;
		local funcHolder = listener.funcHolder;
		return func(funcHolder,event, ...)
	end
end

-- dispatch the event. 
-- @return: the callback return value is also returned. 
function EventDispatcher:DispatchEventByType(event_type, event, ...)
	if(not event)then return end
	local listener = self.event_pools[event_type]
	if(listener)then
		local func = listener.func;
		local funcHolder = listener.funcHolder;
		return func(funcHolder,event, ...)
	end
end

function EventDispatcher:ClearAllEvents()
	self.event_pools = {};
end

-----------------------------------
-- Event system is similar to Event Dispatcher except that it support multiple listeners of the same type. 
-----------------------------------
local EventSystem = commonlib.inherit(nil, commonlib.gettable("commonlib.EventSystem"))

--constructor
function EventSystem:ctor()
	self.event_pools = {}
end

-- add a new listener. Note there can only be one listener per event type
-- @param type: this is the key to event. It can be anything. It is usually string or integer. 
-- @param func: the callback function(funcHolder, event)  end. 
-- @param funcHolder: this is an object that is passed as the first parameter to the callback function.
-- @param listener_name: this is an optional paramter. If there is already a listener of the same name, it will be overriden. 
function EventSystem:AddEventListener(type,func,funcHolder, listener_name)
	if(not type or not func)then return end
	local sinks = self.event_pools[type];
	if(not sinks) then
		sinks = {};
		self.event_pools[type] = sinks;
	end
	local index, handler;
	for index, handler in ipairs(sinks) do
		if(listener_name and handler.name == listener_name) then
			handler.func = func;
			handler.funcHolder = funcHolder;
			LOG.std("", "debug", "EventSystem", "override listener type %s, name %s", tostring(type), listener_name);
			return;
		else
			if(handler.func == func and handler.funcHolder == funcHolder and handler.name == listener_name) then
				LOG.std("", "debug", "EventSystem", "duplicated listener called for %s", tostring(type))
				return;
			end
		end
	end
	sinks[#sinks + 1] = {func = func, funcHolder = funcHolder, name=listener_name};
end

-- remove listener
function EventSystem:RemoveEventListener(type, func, funcHolder)
	if(not type)then return end
	if(not func) then
		self.event_pools[type] = nil;
	else
		local sinks = self.event_pools[type];
		if(sinks) then
			local index, handler;
			for index, handler in ipairs(sinks) do
				if(handler.func == func and handler.funcHolder == funcHolder ) then
					commonlib.removeArrayItem(sinks, index);
					return
				end
			end
		end
		LOG.std("", "debug", "EventSystem", "there is no matching event listener to remove for %s", tostring(type))
	end
end

-- has event listener
function EventSystem:HasEventListener(type, func, funcHolder)
	if(not type)then return end
	if(self.event_pools[type])then 
		if(not func) then
			return true;
		else
			local sinks = self.event_pools[type];
			if(sinks) then
				local index, handler;
				for index, handler in ipairs(sinks) do
					if(handler.func == func and handler.funcHolder == funcHolder ) then
						return true
					end
				end
			end
		end
	end
end

-- dispatch the event. 
-- @return: the callback return value is also returned. if there are multiple listeners, the returned value is the last non-nil return value of the callback function.
function EventSystem:DispatchEvent(event, ...)
	if(not event)then return end
	local sinks = self.event_pools[event.type];
	if(sinks) then
		local return_value;
		local index, handler;
		for index, handler in ipairs(sinks) do
			return_value = handler.func(handler.funcHolder, event, ...) or return_value;
		end
		return return_value;
	end
end

-- dispatch the event. 
-- @return: the callback return value is also returned. 
function EventSystem:DispatchEventByType(event_type, event, ...)
	if(not event)then return end
	local sinks = self.event_pools[event_type];
	if(sinks) then
		local index, handler;
		for index, handler in ipairs(sinks) do
			handler.func(handler.funcHolder, event, ...)
		end
	end
end

-- clear all. reseting to empty. 
function EventSystem:ClearAllEvents()
	self.event_pools = {};
end
