--[[
Title: event classes
Author(s): LiXizhi
Date: 2015/4/22
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/Events.lua");
local SizeEvent = commonlib.gettable("System.Windows.SizeEvent");
local FocusEvent = commonlib.gettable("System.Windows.FocusEvent");
local ShowEvent = commonlib.gettable("System.Windows.ShowEvent");
local HideEvent = commonlib.gettable("System.Windows.HideEvent");
local InputMethodEvent = commonlib.gettable("System.Windows.InputMethodEvent");
local e = FocusEvent:new():init("focusIn");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Core/Event.lua");
NPL.load("(gl)script/ide/System/Windows/KeyEvent.lua");
NPL.load("(gl)script/ide/System/Windows/MouseEvent.lua");
NPL.load("(gl)script/ide/math/Rect.lua");
local Rect = commonlib.gettable("mathlib.Rect");

------------------------------------------------
-- FocusEvent
------------------------------------------------
local FocusEvent = commonlib.inherit(commonlib.gettable("System.Core.Event"), commonlib.gettable("System.Windows.FocusEvent"));
FocusEvent.event_type = "focusInEvent";

function FocusEvent:ctor()
end

-- event_type is "focusInEvent" or "focusOutEvent" or "focusAboutToChangeEvent" 
function FocusEvent:init(event_type, reason)
	self._super.init(self, event_type);
	self.reason = reason;
	return self;
end

function FocusEvent:gotFocus() 
	return self:GetType() == "focusInEvent";
end

function FocusEvent:lostFocus() 
	return self:GetType() == "focusOutEvent";
end

------------------------------------------------
-- SizeEvent
------------------------------------------------
local SizeEvent = commonlib.inherit(commonlib.gettable("System.Core.Event"), commonlib.gettable("System.Windows.SizeEvent"));
SizeEvent.event_type = "sizeEvent";

function SizeEvent:init(newSize)
	self.s = newSize;
	return self;
end

function SizeEvent:size()
	return self.s;
end

function SizeEvent:width()
	return self.s:width();
end

function SizeEvent:height()
	return self.s:height();
end

function SizeEvent:tostring()
	return format("%s:%d %d", self.event_type, self:width(), self:height());
end

------------------------------------------------
-- ShowEvent
------------------------------------------------
local ShowEvent = commonlib.inherit(commonlib.gettable("System.Core.Event"), commonlib.gettable("System.Windows.ShowEvent"));
ShowEvent.event_type = "showEvent";
ShowEvent:use_static_new();

------------------------------------------------
-- ShowEvent
------------------------------------------------
local HideEvent = commonlib.inherit(commonlib.gettable("System.Core.Event"), commonlib.gettable("System.Windows.HideEvent"));
HideEvent.event_type = "hideEvent";
HideEvent:use_static_new();

------------------------------------------------
-- InputMethodEvent
------------------------------------------------
local InputMethodEvent = commonlib.inherit(commonlib.gettable("System.Core.Event"), commonlib.gettable("System.Windows.InputMethodEvent"));
InputMethodEvent.event_type = "inputMethodEvent";
InputMethodEvent.preedit = nil;
InputMethodEvent.commit = nil;
InputMethodEvent.replace_from = 0;
InputMethodEvent.replace_length = 0;

function InputMethodEvent:init(commitString)
	self:setCommitString(commitString);
	return self;
end

function InputMethodEvent:setCommitString(commitString, replaceFrom,replaceLength)
	self.commit = commitString or "";
	self.replace_from = replaceFrom or 0;
	self.replace_length = replaceLength or 0;
end
    
function InputMethodEvent:preeditString()
	 return self.preedit;
end

function InputMethodEvent:commitString() 
	return self.commit;
end

function InputMethodEvent:replacementStart() 
	return self.replace_from; 
end

function InputMethodEvent:replacementLength()
	return self.replace_length;
end

