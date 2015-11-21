--[[
Title: Touch event
Author(s): LiXizhi
Date: 2014/4/24
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/GUIEngine/TouchEvent.lua");
local TouchEvent = commonlib.gettable("commonlib.GUIEngine.TouchEvent")
local event = TouchEvent:new():init(event_type, x, y, id);
-------------------------------------------------------
]]
-- local TouchEventType = commonlib.gettable("commonlib.GUIEngine.TouchEventType");

local TouchEvent = commonlib.inherit(nil, commonlib.gettable("commonlib.GUIEngine.TouchEvent"));

-- event type: "touch_begin", "touch_end", "touch_move"
TouchEvent.type = nil;

local translate_win32_msgs = {
	["WM_POINTERENTER"] = "ontouchbegin",
	["WM_POINTERUPDATE"] = "ontouchmove",
	["WM_POINTERLEAVE"] = "ontouchend",
};

function TouchEvent:ctor()
end

-- translate from system event type to internal event type. 
-- @return event 
function TouchEvent:TranslateTouchEvent()
	self.type = translate_win32_msgs[self.type] or event.type;
	self.event_type = self.type;
	return self;
end

-- initialize event
function TouchEvent:init(event_type, x, y, id)
	--self.type = event_type;
	--self.id = id;
	--self.x = x;
	--self.y = y;
	--self:TranslateTouchEvent();
	return self;
end

-- return true if event is successfully merged. 
-- event with same id is always merged. 
function TouchEvent:TryMergeEvent(new_event)
	if(self.id == new_event.id) then
		if(self.type == "touch_end") then
			-- ignore all other new messages
			return true;
		elseif(new_event.type == "touch_begin") then
			self.begin_x = new_event.x;
			self.begin_y = new_event.y;
		else
			if(not self.begin_x) then
				self.begin_x = self.x;
				self.begin_y = self.y;
			end
			self.prev_x = self.prev_x or self.x;
			self.prev_y = self.prev_y or self.y;
			self.x = new_event.x;
			self.y = new_event.y;
		end
		self.type = new_event.type;
		self.event_type = new_event.event_type;
		return true;
	end
end

-- private: only called to reset previous position after the event has been dispatched. 
function TouchEvent:ResetPrevPos()
	self.prev_x, self_prev_y = nil, nil;
end

-- current position. 
function TouchEvent:GetPos()
	return self.x, self.y;
end

-- if torch is ended. 
function TouchEvent:IsEnd()
	return self.type == "touch_end";
end

-- get previous position since last dispatched message.
function TouchEvent:GetPrevPos()
	return self.prev_x or self.x, self.prev_y or sself.y;
end

-- get the position where the touch begins. 
function TouchEvent:GetBeginPos()
	return self.begin_x or self.x, self.begin_y or sself.y;
end

-- return the delta position. 
function TouchEvent:GetDeltaPos()
	local prev_x, prev_y = self:GetPrevPos();
	return self.x - prev_x, self.y - prev_y;
end
