--[[
Title: Label
Author(s): LiXizhi
Date: 2015/4/29
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/Controls/Label.lua");
local Label = commonlib.gettable("System.Windows.Controls.Label");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Windows/UIElement.lua");
local Label = commonlib.inherit(commonlib.gettable("System.Windows.UIElement"), commonlib.gettable("System.Windows.Controls.Label"));
Label:Property("Name", "Label");
Label:Property({"Text", auto=true})
Label:Property({"Font", "System;14;norm", auto=true})
Label:Property({"Color", "#000000", auto=true})
Label:Property({"Scale", nil, "GetScale", "SetScale", auto=true})

function Label:ctor()
end

function Label:paintEvent(painter)
	local text = self:GetText();
	if(text and text~="") then
		painter:SetFont(self:GetFont());
		painter:SetPen(self:GetColor());
		local scale = self:GetScale();
		painter:DrawTextScaled(self.crect:x(), self.crect:y(), text, scale);
	end
end

