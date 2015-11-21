--[[
Title: A sequence of text rendered from an image
Author:LiXizhi
Date : 2008.11.22
Desc: A sequence of text rendered from an image. We usually use it render big numbers in games. It is also possible to render english letters. 
Do not use this class to render large number of text. because it will create and reuse a button control for each visible letter in the text.
If there is no image font found, we will ordinary text to render. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/TextSprite.lua");
local ctl = CommonCtrl.TextSprite:new{
	name = "TextSprite1",
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 150,
	height = 31,
	parent = nil,
	color = "#FFFF00", -- "255 255 0 128"
	text = "0123456789 ABCDEF",
	-- the height of the font. the width is determined according to the font image.
	fontsize = 31,
	-- in case there is no image sprite for any of the text characters, we will use system's default font with this font size. if not specified, the fontsize is used. 
	default_fontsize = 18,
	-- sprite info, below are default settings. 
	image = "Texture/16number.png",
	-- rect is "left top width height"
	sprites = {
		["1"] = {rect = "0 0 20 31", width = 20, height = 32},
		["2"] = {rect = "32 0 19 31", width = 19, height = 32},
		["3"] = {rect = "64 0 19 31", width = 19, height = 32},
		["4"] = {rect = "96 0 19 31", width = 19, height = 32},
		["5"] = {rect = "0 32 20 31", width = 20, height = 32},
		["6"] = {rect = "32 32 19 32", width = 19, height = 32},
		["7"] = {rect = "64 32 19 31", width = 19, height = 32},
		["8"] = {rect = "96 32 19 31", width = 19, height = 32},
		["9"] = {rect = "0 64 19 31", width = 19, height = 32},
		["0"] = {rect = "32 64 19 31", width = 19, height = 32},
		["A"] = {rect = "64 64 22 31", width = 22, height = 32},
		["B"] = {rect = "96 64 20 31", width = 20, height = 32},
		["C"] = {rect = "0 96 19 31", width = 19, height = 32},
		["D"] = {rect = "32 96 19 31", width = 19, height = 32},
		["E"] = {rect = "64 96 19 31", width = 19, height = 32},
		["F"] = {rect = "96 96 19 31", width = 19, height = 32},
	},
};
ctl:Show(true);

-- call update UI function whenever you have changed the properties. 
ctl:UpdateUI();
ctl:SetText("256");
-------------------------------------------------------
]]

NPL.load("(gl)script/ide/common_control.lua");

local TextSprite = {
	-- name: the global ui object name. 
	name = "TextSprite1",
	-- layout
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 120,
	height = 31,
	parent = nil,
	background = "",
	-- properties
	text = nil,
	-- the height of the font. the width is determined according to the font image.
	fontsize = 31,
	-- if not nil, all fonts are of this fixed width, otherwise font width is determined from the sprites info. 
	fontwidth = nil,
	-- font color
	color = "255 255 0 128",
	-- sprite info, below are default settings. 
	image = "Texture/16number.png",
	-- rect is "left top width height"
	sprites = {
		["1"] = {rect = "0 0 20 31", width = 20, height = 32},
		["2"] = {rect = "32 0 19 31", width = 19, height = 32},
		["3"] = {rect = "64 0 19 31", width = 19, height = 32},
		["4"] = {rect = "96 0 19 31", width = 19, height = 32},
		["5"] = {rect = "0 32 20 31", width = 20, height = 32},
		["6"] = {rect = "32 32 19 32", width = 19, height = 32},
		["7"] = {rect = "64 32 19 31", width = 19, height = 32},
		["8"] = {rect = "96 32 19 31", width = 19, height = 32},
		["9"] = {rect = "0 64 19 31", width = 19, height = 32},
		["0"] = {rect = "32 64 19 31", width = 19, height = 32},
		["A"] = {rect = "64 64 22 31", width = 22, height = 32},
		["B"] = {rect = "96 64 20 31", width = 20, height = 32},
		["C"] = {rect = "0 96 19 31", width = 19, height = 32},
		["D"] = {rect = "32 96 19 31", width = 19, height = 32},
		["E"] = {rect = "64 96 19 31", width = 19, height = 32},
		["F"] = {rect = "96 96 19 31", width = 19, height = 32},
	},
}
CommonCtrl.TextSprite = TextSprite;

function TextSprite:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

function TextSprite:Destroy ()
	if(self.id) then
		ParaUI.Destroy(self.id);
	end
end

function TextSprite:Show(bShow)
	local _this,_parent;
	if(self.name == nil)then
		log("TextSprite instance name can not be nil\r\n");
		return;
	end
	
	if(self.id) then
		_this = ParaUI.GetUIObject(self.id);
	end
	if(not _this or not _this:IsValid())then
		_this = ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		_this.background = self.background;
		_parent = _this;
		
		if(self.parent == nil)then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		
		self.id = _this.id;
				
		CommonCtrl.AddControl(self.name,self);

		-- update the control
		self:UpdateUI();
		
		-- update the width with the UsedWidth
		_this.width = self.UsedWidth;
	else
		if(bShow == nil) then
			_this.visible = not _this.visible;
		else
			_this.visible = bShow;
		end		
	end
end

-- Update UI according to the current text
-- it will reuse sprite button controls. 
function TextSprite:UpdateUI()
	if(not self.id) then
		return;
	end
	local _this = ParaUI.GetUIObject(self.id);
	if(_this:IsValid()) then
		if(not self.text or self.text=="") then
			_this:RemoveAll();
		end
		local nChildCount = _this:GetChildCount();
		local letter
		local nIndex = 0;
		local left = 0;
		local len = ParaMisc.GetUnicodeCharNum(tostring(self.text));
		local chars = {};
		local i;
		for i = 1, len do
			letter = ParaMisc.UniSubString(tostring(self.text), i, i);
			if(letter ~= " ") then
				local info = self.sprites[letter];
				if(not info) then
					chars = nil;
					break;
				end
			end
			chars[#chars+1] = letter;
		end
		if(chars) then
			for i = 1, len do
				letter = chars[i];
				if(letter == " ") then
					-- white space is always half of the fontwidth
					left = left + (self.fontwidth or self.fontsize/2);
				else
					local info = self.sprites[letter];
					if(info) then
						local temp;
						local width = self.fontwidth or math.floor(info.width/info.height*self.fontsize) 
						if(nIndex<nChildCount) then
							temp = _this:GetChild(tostring(nIndex));
							temp.x = left;
							temp.width = width;
							if(not temp.visible) then
								temp.visible=true;
							end	
						else
							temp = ParaUI.CreateUIObject("button",tostring(nIndex), "_lt", left,0, width, self.fontsize);
							if(self.tooltip) then
								temp.tooltip = self.tooltip;
							end
							_this:AddChild(temp);
						end
						temp.background = self.image..";"..info.rect;
						_guihelper.SetUIColor(temp, self.color);
						left = left + width;
						nIndex = nIndex + 1;
					end
				end
			end
			local temp = _this:GetChild("text");
			if(temp:IsValid() and temp.visible) then
				temp.visible = false;
			end
		else
			if (self.text and self.text~="") then
				local temp = _this:GetChild("text");
				local font_size = self.default_fontsize or self.fontsize;
				left = font_size*len;
				if(not temp:IsValid()) then
					temp = ParaUI.CreateUIObject("text", "text", "_lt", 0,0, left, self.fontsize);
					-- _guihelper.SetUIFontFormat(temp, 256+32); -- single line left top align. 
					temp:GetFont("text").format = 256+32; -- center and no clip
					temp.font = format("System;%s;bold", tostring(font_size));
					temp.shadow = true;
					_this:AddChild(temp);
				else
					temp.visible = true;
				end
				temp.text = self.text;
				_guihelper.SetFontColor(temp, self.color);
			end
		end
		self.UsedWidth = left;
		-- hide all unused letters.
		if(nIndex<nChildCount) then
			local i;
			for i=nIndex, nChildCount-1 do
				_this:GetChild(tostring(i)).visible=false;
			end
		end
	end
end		

-- set the text and update the UI
function TextSprite:SetText(text)
	self.text= text;
	self:UpdateUI();
end

function TextSprite:GetText()
	return self.text;
end

function TextSprite:GetUsedWidth()
	return self.UsedWidth or 0;
end