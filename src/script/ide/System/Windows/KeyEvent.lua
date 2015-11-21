--[[
Title: KeyEvent
Author(s): LiXizhi
Date: 2015/4/21
Desc: KeyEvent is singleton object
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/KeyEvent.lua");
local KeyEvent = commonlib.gettable("System.Windows.KeyEvent");
local event = KeyEvent:init("keyPressedEvent");
echo({event.x, event.y, event.button});
echo(event:IsKeySequence("Undo");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Windows/Keyboard.lua");
local Keyboard = commonlib.gettable("System.Windows.Keyboard");
local KeyEvent = commonlib.inherit(commonlib.gettable("System.Core.Event"), commonlib.gettable("System.Windows.KeyEvent"));

function KeyEvent:ctor()
end

-- return current mouse event object. 
-- @param event_type: "keyDownEvent", "keyPressedEvent"
function KeyEvent:init(event_type, vKey)
	self._super.init(self, event_type);
	-- global position. 
	self.virtual_key = vKey or virtual_key;
	-- key string.
	self.keyname = VirtualKeyToScaneCodeStr[virtual_key];
	self.shift_pressed = Keyboard:IsShiftKeyPressed();
	self.ctrl_pressed = Keyboard:IsCtrlKeyPressed();
	self.alt_pressed = Keyboard:IsAltKeyPressed();
	self.key_sequence = self:GetKeySequence();
	self.accepted = nil;
	return self;
end

local ctrl_seq_map = {
	["DIK_Z"] = "Undo",
	["DIK_Y"] = "Redo",
	["DIK_A"] = "SelectAll",
	["DIK_C"] = "Copy",
	["DIK_V"] = "Paste",
	["DIK_HOME"] = "MoveToStartOfWord",
	["DIK_END"] = "MoveToEndOfWord",
	["DIK_RIGHT"] = "MoveToNextWord",
	["DIK_LEFT"] = "MoveToPreviousWord",
}

local shift_seq_map = {
	["DIK_HOME"] = "SelectStartOfLine",
	["DIK_END"] = "SelectEndOfLine",
	["DIK_RIGHT"] = "SelectNextChar",
	["DIK_LEFT"] = "SelectPreviousChar",
	["DIK_DELETE"] = "Cut",
}

local ctrl_shift_seq_map = {
	["DIK_HOME"] = "SelectStartOfBlock",
	["DIK_END"] = "SelectEndOfBlock",
	["DIK_RIGHT"] = "SelectNextWord",
	["DIK_LEFT"] = "SelectPreviousWord",
}

local std_seq_map = {
	["DIK_HOME"] = "MoveToStartOfLine",
	["DIK_END"] = "MoveToEndOfLine",
	["DIK_RIGHT"] = "MoveToNextChar",
	["DIK_LEFT"] = "MoveToPreviousChar",
	["DIK_DELETE"] = "Delete",
}

-- win32 sequence map
function KeyEvent:GetKeySequence()
	if(self.ctrl_pressed and self.shift_pressed) then
		return ctrl_shift_seq_map[self.keyname];
	elseif(self.ctrl_pressed) then
		return ctrl_seq_map[self.keyname];
	elseif(self.shift_pressed) then
		return shift_seq_map[self.keyname];
	else
		return std_seq_map[self.keyname];
	end
end

-- @param keySequence: "Undo", "Redo", "SelectAll", "Copy", "Paste"
function KeyEvent:IsKeySequence(keySequence)
	return self.key_sequence == keySequence;
end



