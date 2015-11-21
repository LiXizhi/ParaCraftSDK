--[[
Title: pe_if
Author(s): LiXizhi
Date: 2015/6/2
Desc: it only renders its child nodes if condition is true
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_if.lua");
Elements.pe_if:RegisterAs("pe:if");
------------------------------------------------------------
]]
local pe_if = commonlib.inherit(commonlib.gettable("System.Windows.mcml.PageElement"), commonlib.gettable("System.Windows.mcml.Elements.pe_if"));

function pe_if:LoadComponent(parentElem, parentLayout, style)
	local condition = self:GetAttributeWithCode("condition", nil, true);
	self.isConditionTrue = (condition==true or condition=="true");
	if (self.isConditionTrue) then
		for childnode in self:next() do
			childnode:LoadComponent(parentElem, parentLayout, style);
		end
	end
end

function pe_if:UpdateLayout(parentLayout)
	if (self.isConditionTrue) then
		for childnode in self:next() do
			childnode:UpdateLayout(parentLayout);
		end
	end
end

