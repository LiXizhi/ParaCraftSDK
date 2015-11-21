--[[
Title: base class of css style sheet
Author(s): LiXizhi
Date: 2015/5/4
Desc: css style contains a collection of StyleItem.
To change mcml default style, call mcml:SetStyle() before mcml page is loaded. We usually do this on startup.

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/mcml/Style.lua");
local Style = commonlib.gettable("System.Windows.mcml.Style");
local styles = {
	["pe:button"] = {padding=5}
}
mcml:SetStyle(Style:new():LoadFromTable(styles));
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Windows/mcml/StyleItem.lua");
local StyleItem = commonlib.gettable("System.Windows.mcml.StyleItem");

local Style = commonlib.inherit(nil, commonlib.gettable("System.Windows.mcml.Style"));

function Style:ctor()
	self.items = {};
end

-- @param name: the css class name
function Style:GetItem(name)
	if(name) then
		return self.items[name];
	end
end

-- @param name: the css class name
-- @param bOverwrite: true to overwrite if exist
function Style:SetItem(name, style, bOverwrite)
	if(bOverwrite or not self:GetItem(name)) then
		self.items[name] = style;
	end
end

function Style:LoadFromTable(styles)
	if(styles) then
		for name, style in pairs(styles) do
			self:SetItem(name, StyleItem:new(style), true);
		end
	end
	return self;
end

-- TODO: touch all textures used in the style. 
function Style:PreloadAllTextures()
	
end