--[[
Title: Touch manager
Author(s): LiXizhi
Date: 2014/4/24
Revision: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/GUIEngine/TouchManager.lua");
local TouchManager = commonlib.gettable("commonlib.GUIEngine.TouchManager");

-- adding touch event
local event = TouchEvent:new():init(msg.type, msg.x, msg.y, msg.id);
TouchManager.AddTouchEvent(event);

-- check if device is available
local bHasTouchDevice = TouchManager.IsEnabled()

-- add event listener
TouchManager.GetEventSystem():AddEventListener("ontouch", function(), self, "unique_id_or_name")

-------------------------------------------------------
]]
NPL.load("(gl)script/ide/STL.lua");
NPL.load("(gl)script/ide/EventDispatcher.lua");

local TouchManager = commonlib.gettable("commonlib.GUIEngine.TouchManager");

local queued_events;
local touch_events;
local max_queued_msg = 10;

function TouchManager.GetEventSystem()
	if(touch_events) then
		return touch_events;
	else
		touch_events = commonlib.EventSystem:new();
		return touch_events;
	end
end

function TouchManager.GetEventQueue()
	if(queued_events) then
		return queued_events;
	else
		queued_events = commonlib.List:new();
		return queued_events;
	end
end

-- call this when you first login a world. This function will clear all cached messages. 
function TouchManager.Reset()
	local events = TouchManager.GetEventSystem();
	events:ClearAllEvents();
end

-- add event listener. 
-- @param type: "ontouchbegin", "ontouchend", "ontouchmove"
function TouchManager.AddEventListener(type, func,funcHolder, listener_name)
	return TouchManager.GetEventSystem():AddEventListener(type,func,funcHolder, listener_name);
end

-- we will queue all events until FrameMove() is called to process all event. 
function TouchManager.AddTouchEvent(new_event)
	
	local list = TouchManager.GetEventQueue();
	local event = list:first();
	while (event) do
		if(event:TryMergeEvent(new_event)) then
			return true;
		end
		event = list:next(event);
	end
	
	if(list:size() > max_queued_msg) then
		list:remove(list:first());
	end
	list:push_back(new_event);
end

local is_touch_enabled = nil;
-- whether touch api is enabled. 
-- if we ever received a touch event
function TouchManager.IsEnabled()
	return is_touch_enabled;
end

function TouchManager.SetTouchEnabled()
	is_touch_enabled = true;
end

-- the game loop supporting touch api should be responsible for this. 
function TouchManager.FrameMove()
	-- sort and dispatch all messages. 
	local events = TouchManager.GetEventSystem();

	local list = TouchManager.GetEventQueue();

	--dispatch all queued events
	local event = list:first();
	while (event) do
		TouchManager.SetTouchEnabled();
		local curEvent = event;
		event = list:remove(event);

		local old_type = curEvent.type;
		curEvent.type = "ontouch";
		-- dispatch event
		events:DispatchEvent(curEvent);
		curEvent.type = old_type;

		curEvent:ResetPrevPos();
	end
end