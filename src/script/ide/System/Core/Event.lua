--[[
Title: Event
Author(s): LiXizhi, 
Date: 2015/4/23
Desc: Event class is the base class of all event classes.

references: QEvent interface in QT. 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Core/Event.lua");
local Event = commonlib.gettable("System.Core.Event");
local e = Event:new():init("mouseDownEvent");
local event = Event:new_static("LayoutRequestEvent");
------------------------------------------------------------
]]

------------------------------------------------
-- Event: the base class of all event classes.
------------------------------------------------
local Event = commonlib.inherit(nil, commonlib.gettable("System.Core.Event"));
Event.event_type = "unknownEvent"
-- whether it is posted; default is spontanous. 
Event.posted = nil;
Event.spont = true;
-- whether event is accepted
Event.accepted = nil;

function Event:ctor()
end

function Event:init(event_type)
	self.event_type = event_type;
	return self;
end

local all_static_events = {};

-- get a singleton event by its types
-- event will be set to unaccepeted. 
function Event:new_static(event_type)
	local event = all_static_events[event_type];
	if(not event) then
		event = self:new():init(event_type);
		event:use_static_new();
		all_static_events[event_type] = event;
	end
	-- this actually invokes the static new method. 
	return event:new();
end

local function static_new(self)
	self.posted = nil;
	self.accepted = nil;
	return self;
end

-- static function: after calling this, Event:new() will no longer create new object, but return the singleton class object instead. 
-- this is useful, if you send event without paramaters and without nested calls that depends on self:accept(). 
function Event:use_static_new()
	self.new = static_new;
end

function Event:GetType() 
	return self.event_type;
end

function Event:GetHandlerFuncName()
	return self.event_type;
end

function Event:accept()
	self.accepted = true;
end

function Event:ignore()
	self.accepted = false;
end

function Event:setAccepted(accepted) 
	self.accepted = accepted;
end

function Event:isAccepted() 
	return self.accepted;
end

-- whether it is sent spontneously instead of posted. 
function Event:spontaneous() 
	return self.spont;
end

-- return true if event should be removed. 
function Event:OnTick(deltaTime)
	return true;
end

function Event:tostring()
	return self.event_type;
end

------------------------------------------------
-- EventTickFunc
------------------------------------------------
local EventTickFunc = commonlib.inherit(commonlib.gettable("System.Core.Event"), commonlib.gettable("System.Core.EventTickFunc"));

EventTickFunc.event_type = "EventTickFunc";

function EventTickFunc:ctor()
	self.time = 0;
end

-- @param ms_delay_time: in ms seconds.
-- @param sender: nil or a class object. 
-- @param slot: the slot function. 
function EventTickFunc:init(ms_delay_time, sender, slot)
	self.ms_delay_time = ms_delay_time or 0;
	self.sender = sender;
	self.slot = slot;
	return self;
end

function EventTickFunc:OnTick(deltaTime)
	self.time = self.time + deltaTime;
	if(self.time >= self.ms_delay_time) then
		if(type(self.slot) == "function") then
			self.slot(self.sender);
		end
		return true;
	end
end

------------------------------------------------
-- TimerEvent
------------------------------------------------
local TimerEvent = commonlib.inherit(commonlib.gettable("System.Core.Event"), commonlib.gettable("System.Core.TimerEvent"));
TimerEvent.event_type = "TimerEvent";

function TimerEvent:ctor()
	self.id = self.id or 0;
end

function TimerEvent:init(timerId)
	self.id = id;
end
    
function TimerEvent:timerId() 
	return id; 
end

------------------------------------------------
-- LogEvent
------------------------------------------------
local LogEvent = commonlib.inherit(commonlib.gettable("System.Core.Event"), commonlib.gettable("System.Core.LogEvent"));
LogEvent.event_type = "logEvent";

