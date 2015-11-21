--[[
Title: identicon
Author(s): LiXizhi
Date: 2015/10/1
Desc: identicon is 5*5 color icons mirrored on the center. 
This little library will produce the same shape and (roughly) the same color as GitHub when given the same hash value. 
Code is based on https://github.com/stewartlord/identicon.js
The creative visual design is borrowed from Jason Long of Git and GitHub fame.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/Controls/Identicon.lua");
local Identicon = commonlib.gettable("System.Windows.Controls.Identicon");

-- create the native window
NPL.load("(gl)script/ide/System/Windows/Window.lua");
local Window = commonlib.gettable("System.Windows.Window");
local window = Window:new();

-- test icon
local icon = Identicon:new():init(window);
icon:setGeometry(10,10,64,64);
icon:SetText("LiXizhi");

-- show the window natively
window:Show("my_window", nil, "_mt", 0,0, 200, 200);

-------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Windows/UIElement.lua");
NPL.load("(gl)script/ide/System/Core/Color.lua");
local Color = commonlib.gettable("System.Core.Color");
local tonumber = tonumber;

local Identicon = commonlib.inherit(commonlib.gettable("System.Windows.UIElement"), commonlib.gettable("System.Windows.Controls.Identicon"));
Identicon:Property("Name", "Identicon");
Identicon:Property({"BackgroundColor", "#eeeeee", auto=true});
-- percentage of image margin
Identicon:Property({"Margin", 0.08, auto=true});
-- set text will automatically set the hash to be MD5 of the text.
Identicon:Property({"Text", "", "GetText", "SetText"})
-- 32 hex letters hash, only the first 15 chars and the last 7 char is used however.
Identicon:Property({"Hash", "1234567890abcdef", auto=true})

function Identicon:ctor()
	
end

function Identicon:GetText()
	return self.Text;
end

function Identicon:SetText(value)
	value = value or "";
	if(self.Text~=value) then
		self.Text = value;
		local hash = ParaMisc.md5(value);
		self:SetHash(hash);
	end
end

-- virtual: render everything here
-- @param painter: painterContext
function Identicon:paintEvent(painter)
	painter:SetPen(self:GetBackgroundColor());
	local dx, dy = self:x(), self:y();
	painter:Translate(dx, dy);
	painter:DrawRect(0, 0, self:width(), self:height());
	local size = self:width();
	local margin = math.floor(size*self:GetMargin());
	local cell = math.floor((size - (margin *2))/5);
	local hash = self:GetHash() or "1234567890abcdef";
	if(#hash < 16) then
		return;
	end

	-- foreground is last 7 chars as hue at 50% saturation, 70% brightness
    local r, g, b = Color.hsl2rgb(tonumber(hash:sub(-7), 16) / 0xfffffff, 0.5, 0.7);
	local fg = Color.RGBA_TO_DWORD(r, g, b, 255);
	
	-- the first 15 characters of the hash control the pixels (even/odd)
    -- they are drawn down the middle first, then mirrored outwards
    for i = 0, 14 do
		if(tonumber(hash:sub(i+1,i+1), 16) % 2 == 1) then
			local color = fg;
			painter:SetPen(color);
			if (i < 5) then
				painter:DrawRect(2 * cell + margin, i * cell + margin, cell, cell);
			elseif (i < 10) then
				painter:DrawRect(1 * cell + margin, (i - 5) * cell + margin, cell, cell);
				painter:DrawRect(3 * cell + margin, (i - 5) * cell + margin, cell, cell);
			elseif (i < 15) then
				painter:DrawRect(0 * cell + margin, (i - 10) * cell + margin, cell, cell);
				painter:DrawRect(4 * cell + margin, (i - 10) * cell + margin, cell, cell);
			end
		end
    end
	painter:Translate(-dx, -dy);
end
