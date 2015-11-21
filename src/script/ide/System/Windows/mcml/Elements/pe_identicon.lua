--[[
Title: identicon
Author(s): LiXizhi
Date: 2015/10/4
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_identicon.lua");
Elements.pe_identicon:RegisterAs("button");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Windows/Controls/Identicon.lua");
local Identicon = commonlib.gettable("System.Windows.Controls.Identicon");

local pe_identicon = commonlib.inherit(commonlib.gettable("System.Windows.mcml.PageElement"), commonlib.gettable("System.Windows.mcml.Elements.pe_identicon"));
pe_identicon:Property({"class_name", "pe:identicon"});

function pe_identicon:OnLoadComponentBeforeChild(parentElem, parentLayout, css)
	css.float = css.float or true;
	local _this = Identicon:new():init(parentElem);
	self:SetControl(_this);
	_this:ApplyCss(css);
	_this:SetText(self:GetAttributeWithCode("value", nil, true));
end

function pe_identicon:OnAfterChildLayout(layout, left, top, right, bottom)
	if(self.control) then
		self.control:setGeometry(left, top, right-left, bottom-top);
	end
end


function pe_identicon:SetValue(value)
	self:SetAttribute("value", value);
end

function pe_identicon:GetValue()
	return self:GetAttribute("value");
end

