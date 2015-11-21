--[[
Title: Button
Author(s): LiXizhi
Date: 2015/4/23
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/Controls/Button.lua");
local Button = commonlib.gettable("System.Windows.Controls.Button");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Windows/Controls/Primitives/ButtonBase.lua");
local Button = commonlib.inherit(commonlib.gettable("System.Windows.Controls.Primitives.ButtonBase"), commonlib.gettable("System.Windows.Controls.Button"));
Button:Property("Name", "Button");
Button:Property({"Background", "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;456 396 16 16:4 4 4 4"});
Button:Property({"BackgroundDown", "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;473 396 16 16:4 4 4 4"});
Button:Property({"BackgroundChecked", nil});
Button:Property({"BackgroundOver", "Texture/Aries/Creator/Theme/GameCommonIcon_32bits.png;496 400 1 1"});

function Button:ctor()
end

-- virtual: 
function Button:mousePressEvent(mouse_event)
	-- self:CaptureMouse();
	Button._super.mousePressEvent(self, mouse_event);
end

-- virtual: 
function Button:mouseReleaseEvent(mouse_event)
	-- self:ReleaseMouseCapture();
	Button._super.mouseReleaseEvent(self, mouse_event);
end

function Button:paintEvent(painter)
	local background = self.Background;
	local x, y = self:x(), self:y();
	if (self.down or self.menuOpen) then
		-- suken state
		background = self.BackgroundDown or background;
	end
	if(self.checked) then
		-- checked state
		background = self.BackgroundChecked or background;
	else
		-- normal raised
	end
	if(background and background~="") then
		painter:SetPen(self:GetBackgroundColor());
		painter:DrawRectTexture(x, y, self:width(), self:height(), background);
	end

	if(self:underMouse()) then
		if(self.BackgroundOver) then
			painter:SetPen("#ffffff");
			painter:DrawRectTexture(x+2, y+2, self:width()-4, self:height()-4, self.BackgroundOver);
		end
	end
	
	local text = self:GetText();
	if(text and text~="") then
		painter:SetFont(self:GetFont());
		painter:SetPen(self:GetColor());
		painter:DrawTextScaledEx(x+self.padding_left, y+self.padding_top, self:width()-self.padding_left-self.padding_right, self:height()-self.padding_top-self.padding_bottom, text, self:GetAlignment(), self:GetFontScaling());
	else
		local icon = self:GetIcon();
		if(icon and icon~="") then
			painter:SetPen(self:GetColor());
			painter:DrawRectTexture(x+self.padding_left, y+self.padding_top, self:width()-self.padding_left-self.padding_right, self:height()-self.padding_top-self.padding_bottom, icon);
		end
	end
end

function Button:ApplyCss(css)
	Button._super.ApplyCss(self, css);

	self.BackgroundChecked = css.background_checked;
	self.BackgroundDown = css.background_down;
	self.BackgroundOver = css.background_over;
end