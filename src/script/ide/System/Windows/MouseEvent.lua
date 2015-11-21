--[[
Title: MouseEvent
Author(s): LiXizhi
Date: 2015/4/21
Desc: MouseEvent is singleton object
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/MouseEvent.lua");
local MouseEvent = commonlib.gettable("System.Windows.MouseEvent");
local MouseLeaveEvent = commonlib.gettable("System.Windows.MouseLeaveEvent");
local MouseEnterEvent = commonlib.gettable("System.Windows.MouseEnterEvent");
local event = MouseEvent:init("mouse_down");
echo({event.x, event.y, event.mouse_button});
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/Point.lua");
local Point = commonlib.gettable("mathlib.Point");

------------------------------
-- MouseEvent
------------------------------
local MouseEvent = commonlib.inherit(commonlib.gettable("System.Core.Event"), commonlib.gettable("System.Windows.MouseEvent"));
MouseEvent.event_type = "mouseEvent";
MouseEvent.global_pos = Point:new();
MouseEvent.local_pos = Point:new();

function MouseEvent:ctor()
	self.global_pos = Point:new();
	self.local_pos = Point:new();
end

function MouseEvent:updateModifiers()
	MouseEvent.shift_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LSHIFT) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RSHIFT);
	MouseEvent.ctrl_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LCONTROL) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RCONTROL);
	MouseEvent.alt_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_LMENU) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_RMENU);
	MouseEvent.buttons_state = 0;
	-- left button
	if(ParaUI.IsMousePressed(0)) then
		MouseEvent.buttons_state = MouseEvent.buttons_state + 1;
	end
	-- right button
	if(ParaUI.IsMousePressed(1)) then
		MouseEvent.buttons_state = MouseEvent.buttons_state + 2;
	end
end	

-- any shift, ctrl, alt key is pressed. 
function MouseEvent:IsCtrlKeysPressed()
	return self.shift_pressed or self.ctrl_pressed or self.alt_pressed;
end

-- return current mouse event object. 
-- @param event_type: "mousePressEvent", "mouseReleaseEvent", "mouseMoveEvent", "mouseWheelEvent"
-- @param window: the window that is receiving this event. 
function MouseEvent:init(event_type, window, localPos, windowPos, screenPos)
	self._super.init(self, event_type);
	-- global pos
	if(event_type == "mouseMoveEvent") then
		self.x, self.y = ParaUI.GetMousePosition();
	else
		if(not mouse_x) then
			mouse_x, mouse_y = ParaUI.GetMousePosition();
		end
		self.x, self.y = mouse_x, mouse_y;
	end
	
	if(window) then
		-- global position. 
		if(screenPos)then
			self.global_pos = screenPos;
		else
			self.global_pos:set(self.x, self.y);
		end
		if(windowPos) then
			self.window_pos = windowPos;
		end
		-- local pos
		if(localPos)then
			self.local_pos = localPos;
		else
			self.local_pos:set(window:mapFromGlobal(self.global_pos));
		end
	end
	self.mouse_button = mouse_button;
	self.mouse_wheel = mouse_wheel;
	self.accepted = nil;
	return self;
end

function MouseEvent:pos()
	return self.local_pos;
end

-- mouse drag distance, usually used in mouseReleaseEvent
function MouseEvent:GetDragDist()
	return self.dragDist or 0;
end

-- mouse wheel delta
function MouseEvent:GetDelta()
	return self.mouse_wheel or 0;
end

function MouseEvent:localPos()
	return self.local_pos;
end

function MouseEvent:windowPos()
	return self.window_pos;
end

function MouseEvent:globalPos()
	return self.global_pos;
end

function MouseEvent:screenPos()
	return self.global_pos;
end

-- @return "left", "right", "middle"
function MouseEvent:button()
	return self.mouse_button;
end

-- return 1 if left button is pressed. 2 if right button. and 3 if both. 
function MouseEvent:buttons()
	return self.buttons_state;
end

-- return true if left button is pressed. 
function MouseEvent:LeftButton()
	return self:buttons() == 1;
end

-- return true if right button is pressed. 
function MouseEvent:RightButton()
	return self:buttons() == 2;
end

------------------------------
-- MouseLeaveEvent
------------------------------
local MouseLeaveEvent = commonlib.inherit(commonlib.gettable("System.Windows.MouseEvent"), commonlib.gettable("System.Windows.MouseLeaveEvent"));
MouseLeaveEvent.event_type = "mouseLeaveEvent";
-- static function: singleton
function MouseLeaveEvent:GetInstance()
	return self;
end

------------------------------
-- MouseEnterEvent
------------------------------
local MouseEnterEvent = commonlib.inherit(commonlib.gettable("System.Windows.MouseEvent"), commonlib.gettable("System.Windows.MouseEnterEvent"));
MouseEnterEvent.event_type = "mouseEnterEvent";

function MouseEnterEvent:init(localPos, windowPos, globalPos)
	self.local_pos = localPos;
	self.win_pos = windowPos;
	self.global_pos = globalPos;
	return self;
end