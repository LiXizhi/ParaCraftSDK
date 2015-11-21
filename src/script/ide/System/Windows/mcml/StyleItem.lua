--[[
Title: StyleItem object
Author(s): LiXizhi
Date: 2015/4/28
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/mcml/StyleItem.lua");
local StyleItem = commonlib.gettable("System.Windows.mcml.StyleItem");
local style = StyleItem:new();
------------------------------------------------------------
]]
local type = type;
local tonumber = tonumber;
local string_gsub = string.gsub;
local string_lower = string.lower
local string_match = string.match;
local string_find = string.find;

local StyleItem = commonlib.inherit(nil, commonlib.gettable("System.Windows.mcml.StyleItem"));

-- merge style with current style. 
function StyleItem:Merge(style)
	if(style) then
		if(type(style) == "table") then
			for key, value in pairs(style) do
				self[key] = value;
			end
		elseif(type(style) == "string") then
			self:AddString(style);
		end
	end
end

local inheritable_fields = {
	["color"] = true,
	["font-family"] = true,
	["font-size"] = true,
	["font-weight"] = true,
	["text-shadow"] = true,
};

-- only merge inheritable style like font, color, etc. 
function StyleItem:MergeInheritable(style)
	if(style) then
		self.color = self.color or style.color;
		self["font-family"] = self["font-family"] or style["font-family"];
		self["font-size"] = self["font-size"] or style["font-size"];
		self["font-weight"] = self["font-weight"] or style["font-weight"];
		self["text-shadow"] = self["text-shadow"] or style["text-shadow"];
	end
end


local number_fields = {
	["height"] = true,
	["min-height"] = true,
	["max-height"] = true,
	["width"] = true,
	["min-width"] = true,
	["max-width"] = true,
	["left"] = true,
	["top"] = true,
	["font-size"] = true,
	["base-font-size"] = true,
};

-- @param style_code: mcml style attribute string like "background:url();margin:10px;"
function StyleItem:AddString(style_code)
	local name, value;
	for name, value in string.gfind(style_code, "([%w%-]+)%s*:%s*([^;]*)[;]?") do
		name = string_lower(name);
		value = string_gsub(value, "%s*$", "");
		if(number_fields[name] or string_find(name,"^margin") or string_find(name,"^padding")) then
			local _, _, selfvalue = string_find(value, "([%+%-]?%d+)");
			if(selfvalue~=nil) then
				value = tonumber(selfvalue);
			else
				value = nil;
			end
		elseif(string_match(name, "^background[2]?$") or name == "background-image") then
			value = string_gsub(value, "url%((.*)%)", "%1");
			value = string_gsub(value, "#", ";");
		end
		self[name] = value;
	end
end

function StyleItem:padding_left()
	return (self["padding-left"] or self["padding"] or 0);
end

function StyleItem:padding_right()
	return (self["padding-right"] or self["padding"] or 0);
end

function StyleItem:padding_top()
	return (self["padding-top"] or self["padding"] or 0);
end

function StyleItem:padding_bottom()
	return (self["padding-bottom"] or self["padding"] or 0);
end

-- return left, top, right, bottom
function StyleItem:paddings()
	return self:padding_left(), self:padding_top(), self:padding_right(), self:padding_bottom();
end

function StyleItem:margin_left()
	return (self["margin-left"] or self["margin"] or 0);
end

function StyleItem:margin_right()
	return (self["margin-right"] or self["margin"] or 0);
end

function StyleItem:margin_top()
	return (self["margin-top"] or self["margin"] or 0);
end

function StyleItem:margin_bottom()
	return (self["margin-bottom"] or self["margin"] or 0);
end

-- return left, top, right, bottom
function StyleItem:margins()
	return self:margin_left(), self:margin_top(), self:margin_right(), self:margin_bottom();
end

-- the user may special many font size, however, some font size is simulated with a base font and scaling. 
-- @return font, base_font_size, font_scaling: font may be nil if not specified. font_size is the base font size.
function StyleItem:GetFontSettings()
	local font;
	local scale;
	local font_size = 12;
	if(self["font-family"] or self["font-size"] or self["font-weight"])then
		local font_family = self["font-family"] or "System";
		-- this is tricky. we convert font size to integer, and we will use scale if font size is either too big or too small. 
		font_size = math.floor(tonumber(self["font-size"] or 12));
		local max_font_size = tonumber(self["base-font-size"]) or 14;
		local min_font_size = tonumber(self["base-font-size"]) or 11;
		if(font_size>max_font_size) then
			scale = font_size / max_font_size;
			font_size = max_font_size;
		end
		if(font_size<min_font_size) then
			scale = font_size / min_font_size;
			font_size = min_font_size;
		end
		local font_weight = self["font-weight"] or "norm";
		font = string.format("%s;%d;%s", font_family, font_size, font_weight);
	end
	return font, font_size, scale;
end

function StyleItem:GetTextAlignment()
	local alignment = 1;	-- center align
	if(self["text-align"]) then
		if(self["text-align"] == "right") then
			alignment = 2;
		elseif(self["text-align"] == "left") then
			alignment = 0;
		end
	end
	if(self["text-singleline"] ~= "false") then
		alignment = alignment + 32;
	else
		if(self["text-wordbreak"] == "true") then
			alignment = alignment + 16;
		end
	end
	if(self["text-noclip"] ~= "false") then
		alignment = alignment + 256;
	end
	if(self["text-valign"] ~= "top") then
		alignment = alignment + 4;
	end
	return alignment;
end