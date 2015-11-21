--[[
Title: span element
Author(s): LiXizhi
Date: 2015/4/29
Desc: it handles HTML tags of <span>.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_span.lua");
System.Windows.mcml.Elements.pe_span:RegisterAs("span");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_div.lua");
local pe_span = commonlib.inherit(commonlib.gettable("System.Windows.mcml.Elements.pe_div"), commonlib.gettable("System.Windows.mcml.Elements.pe_span"));

function pe_span:ctor()
end

function pe_span:OnLoadComponentBeforeChild(parentElem, parentLayout, css)
	css.color = self:GetAttribute("color") or css.color;
	css.float = true;
	return pe_span._super.OnLoadComponentBeforeChild(self, parentElem, parentLayout, css)
end

