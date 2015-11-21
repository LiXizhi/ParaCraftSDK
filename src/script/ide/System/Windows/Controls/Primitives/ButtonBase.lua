--[[
Title: Base class for button related
Author(s): LiXizhi
Date: 2015/4/23
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/Controls/Primitives/ButtonBase.lua");
local ButtonBase = commonlib.gettable("System.Windows.Controls.Primitives.ButtonBase");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Windows/UIElement.lua");
local ButtonBase = commonlib.inherit(commonlib.gettable("System.Windows.UIElement"), commonlib.gettable("System.Windows.Controls.Primitives.ButtonBase"));
ButtonBase:Property("Name", "ButtonBase");
ButtonBase:Property({"BackgroundColor", "#ffffff", auto=true});
ButtonBase:Property({"Icon", nil, auto=true});
ButtonBase:Property({"IconSize", nil, auto=true});
ButtonBase:Property({"Color", "#000000", auto=true});
ButtonBase:Property({"Font", nil, auto=true});
ButtonBase:Property({"FontSize", nil, auto=true});
ButtonBase:Property({"FontScaling", nil, auto=true});
ButtonBase:Property({"down", false});
ButtonBase:Property({"menuOpen", false});
ButtonBase:Property({"checked", false, "isChecked"});
ButtonBase:Property({"checkable", false});
ButtonBase:Property({"text", nil, "GetText", "SetText", auto=true});
-- text padding
ButtonBase:Property({"padding_left", 5, });
ButtonBase:Property({"padding_top", 5, });
ButtonBase:Property({"padding_right", 5, });
ButtonBase:Property({"padding_bottom", 5, });

-- default to centered and no clipping. 
ButtonBase:Property({"Alignment", 1+4+256, auto=true, desc="text alignment"});

ButtonBase:Signal("clicked");
ButtonBase:Signal("pressed");
ButtonBase:Signal("released");
ButtonBase:Signal("toggled", function(bChecked) end);

function ButtonBase:ctor()
end

-- Returns true if pos is inside the clickable button rectangle; otherwise returns false.
-- By default, the clickable area is the entire widget. Subclasses
-- may reimplement this function to provide support for clickable
-- areas of different shapes and sizes.
function ButtonBase:hitButton(pos)
    return self:rect():contains(pos) == true;
end

-- virtual: 
function ButtonBase:mousePressEvent(e)
	if (e:button() ~= "left") then
        e:ignore();
        return;
    end
    if (self:hitButton(e:pos())) then
        self:setDown(true);
        self.isPressed = true;
        self:repaint(); 
        self:emitPressed();
        e:accept();
    else
        e:ignore();
    end
end

-- inner text height without padding. 
function ButtonBase:CalculateTextHeight()
	return (self:GetFontSize() or 12) * (self:GetFontScaling() or 1);
end

-- inner text width without padding. 
function ButtonBase:CalculateTextWidth()
	return _guihelper.GetTextWidth(self:GetText(), self:GetFont()) * (self:GetFontScaling() or 1);
end

function ButtonBase:SetPaddings(padding_left, padding_top, padding_right, padding_bottom)
	self.padding_left, self.padding_top, self.padding_right, self.padding_bottom = padding_left, padding_top, padding_right, padding_bottom;
end

-- virtual: 
function ButtonBase:mouseMoveEvent(e)
	if (not (e:button() == "left") or not self.isPressed) then
        e:ignore();
        return;
    end
    if (self:hitButton(e:pos()) ~= self.down) then
        self:setDown(not self.down);
        self:repaint(); -- flush paint event before invoking potentially expensive operation
        if (self.down) then
            self:emitPressed();
        else
            self:emitReleased();
		end
        e:accept();
    elseif (not self:hitButton(e:pos())) then
        e:ignore();
    end
end

-- virtual: 
function ButtonBase:mouseReleaseEvent(e)
	self.isPressed = false;

    if (e:button() ~= "left") then
        e:ignore();
        return;
    end

    if (not self.down) then
        self:refresh();
        e:ignore();
        return;
    end

    if (self:hitButton(e:pos())) then
        -- self:repeatTimer:stop();
        self:click();
        e:accept();
    else
        self:setDown(false);
        e:ignore();
    end
end

function ButtonBase:refresh()
	self:update();
end

-- if this property is true, the button is pressed down
function ButtonBase:setDown(down)
	if (self.down == down) then
        return;
	end
	self.down = down;
	self:refresh();
end

function ButtonBase:isDown()
    return self.down;
end

-- whether the button is checkable
function ButtonBase:setCheckable(checkable)
    if (self.checkable == checkable) then
        return;
	end
    self.checkable = checkable;
    self.checked = false;
end

function ButtonBase:isCheckable()
    return self.checkable;
end

function ButtonBase:setChecked(checked)
	if (not self.checkable or self.checked == checked) then
		return;
	end
	self.checked = checked;
	self:refresh();
	if(checked) then
		self:notifyChecked();
	end
	self:emitToggled(checked);
end

function ButtonBase:isChecked()
	return self.checked;
end

function ButtonBase:notifyChecked()
end

function ButtonBase:click()
	self.down = false;
	self:refresh();
	self:emitReleased();
	self:emitClicked();
end

-- virtual: A leave event is sent to the widget when the mouse cursor leaves the widget.
function ButtonBase:mouseLeaveEvent(event)
	if(self.down or self.isPressed) then
		self.down = false;
		self.isPressed = false;
	end
end
function ButtonBase:emitClicked()
	self:clicked();
end

function ButtonBase:emitPressed()
	self:pressed();
end

function ButtonBase:emitReleased()
	self:released();
end

function ButtonBase:emitToggled(bChecked)
	self:toggled(bChecked);
end

function ButtonBase:setText(text)
    if (self.text == text) then
        return;
	end
    self.text = text;

    self:update();
    self:updateGeometry();
end

function ButtonBase:getText() 
    return self.text;
end

function ButtonBase:paintEvent(painter)
	
end

-- virtual: apply css style
function ButtonBase:ApplyCss(css)
	ButtonBase._super.ApplyCss(self, css);
	local font, font_size, font_scaling = css:GetFontSettings();
	self:SetFont(font);
	self:SetFontSize(font_size);
	self:SetFontScaling(font_scaling);
	self:SetAlignment(css:GetTextAlignment());
	self:SetPaddings(css:paddings());
	if(css.color) then
		self:SetColor(css.color);
	end
end
