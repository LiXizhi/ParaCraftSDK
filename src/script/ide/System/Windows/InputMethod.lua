--[[
Title: Input method
Author(s): LiXizhi
Date: 2015/5/26
Desc: internally it just redirect messages from a global GUIEditbox object. 

References: QInputMethod in qt framework

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/InputMethod.lua");
local InputMethod = commonlib.gettable("System.Windows.InputMethod");
------------------------------------------------------------
]]
local InputMethodEvent = commonlib.gettable("System.Windows.InputMethodEvent");
local Application = commonlib.gettable("System.Windows.Application");
local InputMethod = commonlib.inherit(commonlib.gettable("System.Core.ToolBase"), commonlib.gettable("System.Windows.InputMethod"));
InputMethod:Property("Name", "InputMethod");
InputMethod:Property({"visible", false, "isVisible", "setVisible"});
InputMethod:Property({"cursorRectangle", });
InputMethod:Property({"locale", "en", });

InputMethod:Signal("cursorRectangleChanged");
InputMethod:Signal("visibleChanged");
InputMethod:Signal("localeChanged");

function InputMethod:ctor()
	self.inputItemTransform = mathlib.Point:new();
	self.inputRectangle= mathlib.Rect:new();
end


function InputMethod:isVisible()
	return self.visible;
end

function InputMethod:setVisible(visible)
	if(self.visible ~= visible) then
		self.visible = visible;
		self:visibleChanged();
	end
end

function InputMethod:show()
	self:setVisible(true);
end

function InputMethod:hide()
	self:setVisible(false);
end

function InputMethod:reset()
end

function InputMethod:commit()
end

function InputMethod:update(state)
	if(state == "ImEnabled") then
	else
	end
end

function InputMethod:setInputItemTransform(p)
	if(self.inputItemTransform:equals(p)) then
		return
	end
	self.inputItemTransform:set(p);
	self:cursorRectangleChanged(); -- signal
end

function InputMethod:setInputItemRectangle(rect)
	self.inputRectangle:assign(rect);
	local x = self.inputRectangle:x() + self.inputItemTransform:x();
	local y = self.inputRectangle:y() + self.inputItemTransform:y();
end