--[[
Title: Tooltip
Author(s): LiXizhi
Date: 2015/10/4
Desc: Singleton object, only created on first use. For displaying tooltip in the application. 
One can call setTooltip() on UIElement to enable tooltip. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/Tooltip.lua");
local Tooltip = commonlib.gettable("System.Windows.Tooltip");
Tooltip:showText(nil, "this is a tip");
Tooltip:showText(pos, text, widget, rect, msecShowTime)
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Core/ToolBase.lua");
NPL.load("(gl)script/ide/math/Point.lua");
NPL.load("(gl)script/ide/System/Windows/Screen.lua");
NPL.load("(gl)script/ide/System/Windows/Mouse.lua");
local Application = commonlib.gettable("System.Windows.Application");
local Mouse = commonlib.gettable("System.Windows.Mouse");
local Screen = commonlib.gettable("System.Windows.Screen");
local Point = commonlib.gettable("mathlib.Point");

local Tooltip = commonlib.inherit(commonlib.gettable("System.Core.ToolBase"), commonlib.gettable("System.Windows.Tooltip"));
Tooltip:Property("Name", "Tooltip");
Tooltip:Property({"background", "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;453 45 8 8:2 2 2 2"});
Tooltip:Property({"screen_padding_bottom", 5});
Tooltip:Property({"text", ""});
Tooltip:Property({"fontColor", "#cccccc"});
Tooltip:Property({"BackgroundColor", "#ffffffff"});
Tooltip:Property({"cursorHeight", 28});

function Tooltip:ctor()
	Application:installEventFilter(self);
end

local cancelTooltipEvents = {
	mousePressEvent = true, mouseReleaseEvent = true, mouseWheelEvent = true, mouseLeaveEvent = true,
};

function Tooltip:eventFilter(object, event)
	local type = event:GetType();

	if(cancelTooltipEvents[type]) then
		self:hideText();
	end
end

-- Shows text as a tool tip, with the global position pos as the point of interest.
-- If \a text is empty the tool tip is hidden. If the text is the
-- same as the currently shown tooltip, the tip will not move.
-- You can force moving by first hiding the tip with an empty text,
-- and then showing the new tip at the new position.
-- @param pos: Point of interest. 
-- @param text: nil or text to shown. if nil, to hide
function Tooltip:showText(pos, text, widget, rect, msecShowTime)
	text = text or "";
	if(self.text~=text) then
		-- load singleton
		Tooltip:InitSingleton();
		self.text = text;
		local tipLabel = self.tipLabel;
		if(not self.tipLabel or not self.tipLabel:IsValid()) then
			tipLabel = ParaUI.CreateUIObject("text", "_tipLabel_", "_lt", 0, 0, 0, 32);
			tipLabel.background = self.background;
			self.tipLabel = tipLabel;
			tipLabel.zorder = 5000;
			tipLabel:SetField("Spacing", 4);
			tipLabel.enabled = false;
			_guihelper.SetFontColor(tipLabel, self.fontColor);
			_guihelper.SetUIColor(tipLabel, self.BackgroundColor);
			_guihelper.SetUIFontFormat(tipLabel, 36); -- single line
			tipLabel:AttachToRoot();
		end
		if(text == "") then
			tipLabel.visible = false;
		else
			tipLabel.width = 0;
			tipLabel.text = text;
			tipLabel.visible = true;

			-- auto position the tooltip
			pos = pos or Mouse:pos();
			self:placeTip(tipLabel, pos[1], pos[2], tipLabel.width, tipLabel.height, screen_padding_bottom)
		end
	end
end

function Tooltip:placeTip(container, x, y, used_width, used_height, screen_padding_bottom)
	local resWidth, resHeight = Screen:GetWidth(), Screen:GetHeight();
	resHeight = resHeight - (screen_padding_bottom or 0);
	x = x + 2;
	y = y + self.cursorHeight;
	if((x + used_width) > resWidth) then
		x = x - (used_width + 4);
	end
	if(x<0) then x = 0 end
			
	if((y + used_height) > resHeight) then
		y = y - (used_height + self.cursorHeight + 2);
	end
	if(y<0) then y = 0 end
	container.translationx = x;
	container.translationy = y;
end

function Tooltip:hideText()
	self:showText(nil, nil);
end

function Tooltip:text()
	return self.text;
end

function Tooltip:isVisible()
end

function Tooltip:font()
end

function Tooltip:setFont(font)
end
