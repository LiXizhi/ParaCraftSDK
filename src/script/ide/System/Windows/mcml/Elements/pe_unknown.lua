--[[
Title: unknown element
Author(s): LiXizhi
Date: 2015/5/3
Desc: it only renders its child nodes as if this node does not exist. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_unknown.lua");
Elements.pe_unknown:RegisterAs("pe:flushnode", "pe:fallthrough");
------------------------------------------------------------
]]
local pe_unknown = commonlib.inherit(commonlib.gettable("System.Windows.mcml.PageElement"), commonlib.gettable("System.Windows.mcml.Elements.pe_unknown"));

function pe_unknown:LoadComponent(parentElem, parentLayout, style)
	for childnode in self:next() do
		childnode:LoadComponent(parentElem, parentLayout, style);
	end
end

function pe_unknown:UpdateLayout(parentLayout)
	for childnode in self:next() do
		childnode:UpdateLayout(parentLayout);
	end
end

