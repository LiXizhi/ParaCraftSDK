--[[
Title: Canvas
Author(s): LiXizhi
Date: 2015/4/20
Desc: draw anything custom on the canvas
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/Controls/Canvas.lua");
local Canvas = commonlib.gettable("System.Windows.Controls.Canvas");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Windows/UIElement.lua");
local Canvas = commonlib.inherit(commonlib.gettable("System.Windows.UIElement"), commonlib.gettable("System.Windows.Controls.Canvas"));
Canvas:Property("Name", "Canvas");
Canvas:Property({"BackgroundColor", "#ffffff", auto=true});
Canvas:Property({"Background", nil, auto=true});

function Canvas:ctor()
end

function Canvas:paintEvent(painter)
	local background = self:GetBackground();
	local x, y = self:x(), self:y();
	if(background and background~="") then
		painter:SetPen(self:GetBackgroundColor());
		painter:DrawRectTexture(x, y, self:width(), self:height(), self:GetBackground());
	end
end