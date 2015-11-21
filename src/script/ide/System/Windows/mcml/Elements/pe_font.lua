--[[
Title: font element
Author(s): LiXizhi
Date: 2015/4/29
Desc: it handles HTML tags of <font> . <font> is considered deprecated by HTML, so use span to format inline text instead. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_font.lua");
System.Windows.mcml.Elements.pe_font:RegisterAs("font");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_div.lua");
local pe_font = commonlib.inherit(commonlib.gettable("System.Windows.mcml.Elements.pe_div"), commonlib.gettable("System.Windows.mcml.Elements.pe_font"));

function pe_font:ctor()
end

function pe_font:OnLoadComponentBeforeChild(parentElem, parentLayout, css)
	css.color = self:GetAttribute("color") or css.color;
	css.float = true;
	return pe_font._super.OnLoadComponentBeforeChild(self, parentElem, parentLayout, css)
end

