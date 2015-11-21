--[[
Title: editbox
Author(s): LiXizhi
Date: 2015/5/3
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_editbox.lua");
Elements.pe_editbox:RegisterAs("editbox");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Windows/Controls/EditBox.lua");
local EditBox = commonlib.gettable("System.Windows.Controls.EditBox");

local pe_editbox = commonlib.inherit(commonlib.gettable("System.Windows.mcml.PageElement"), commonlib.gettable("System.Windows.mcml.Elements.pe_editbox"));

function pe_editbox:OnLoadComponentBeforeChild(parentElem, parentLayout, css)
	css.float = css.float or true;

	local _this = EditBox:new():init(parentElem);
	self:SetControl(_this);
	_this:ApplyCss(css);
	_this:SetText(self:GetAttributeWithCode("value", nil, true));
end

function pe_editbox:OnAfterChildLayout(layout, left, top, right, bottom)
	if(self.control) then
		self.control:setGeometry(left, top, right-left, bottom-top);
	end
end

-- get UI value: get the value on the UI object with current node
-- @param instName: the page instance name. 
function pe_editbox:GetUIValue(pageInstName)
	if(self.control) then
		return self.control:GetText();
	end
end

-- set UI value: set the value on the UI object with current node
function pe_editbox:SetUIValue(pageInstName, value)
	if(self.control) then
		return self.control:SetText(value);
	end
end