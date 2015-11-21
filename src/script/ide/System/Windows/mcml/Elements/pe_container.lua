--[[
Title: container element
Author(s): LiXizhi
Date: 2015/4/29
Desc: it create parent child relationship
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_container.lua");
Elements.pe_container:RegisterAs("pe:container");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_div.lua");
NPL.load("(gl)script/ide/System/Windows/Controls/Canvas.lua");
local Canvas = commonlib.gettable("System.Windows.Controls.Canvas");

local pe_container = commonlib.inherit(commonlib.gettable("System.Windows.mcml.Elements.pe_div"), commonlib.gettable("System.Windows.mcml.Elements.pe_container"));

function pe_container:ctor()
end

function pe_container:LoadComponent(parentElem, parentLayout, style)
	local _this = Canvas:new():init(parentElem);
	self:SetControl(_this);
	pe_container._super.LoadComponent(self, _this, parentLayout, style);
	_this:ApplyCss(self:GetStyle());
end

function pe_container:OnLoadComponentBeforeChild(parentElem, parentLayout, css)
end

function pe_container:OnLoadComponentAfterChild(parentElem, parentLayout, css)
end

function pe_container:OnBeforeChildLayout(layout)
	if(#self ~= 0) then
		local myLayout = layout:new();
		local css = self:GetStyle();
		local width, height = layout:GetPreferredSize();
		local padding_left, padding_top = css:padding_left(),css:padding_top();
		myLayout:reset(padding_left,padding_top,width+padding_left, height+padding_top);
		for childnode in self:next() do
			childnode:UpdateLayout(myLayout);
		end
		width, height = myLayout:GetUsedSize();
		width = width - padding_left;
		height = height - padding_top;
		layout:AddObject(width, height);
	end
	return true;
end

function pe_container:OnAfterChildLayout(layout, left, top, right, bottom)
	if(self.control) then
		self.control:setGeometry(left, top, right-left, bottom-top);
	end
end