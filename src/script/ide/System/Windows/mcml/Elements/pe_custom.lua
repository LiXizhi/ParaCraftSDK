--[[
Title: creating custom UIElement
Author(s): LiXizhi
Date: 2015/4/29
Desc: 
---++ pe:custom
*property*
| *name* | *description* |
| src | external script file path. can be relative to current file. |
| classns | class namespace. |

<verbatim>
	<pe:custom src="MyCustomControl.lua" classns="MyApp.Controls.MyCustomControl"/>
</verbatim>
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_custom.lua");
Elements.pe_custom:RegisterAs("pe:custom");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_div.lua");
NPL.load("(gl)script/ide/System/Windows/Controls/Canvas.lua");
local Canvas = commonlib.gettable("System.Windows.Controls.Canvas");

local pe_custom = commonlib.inherit(commonlib.gettable("System.Windows.mcml.Elements.pe_div"), commonlib.gettable("System.Windows.mcml.Elements.pe_custom"));

function pe_custom:ctor()
end

function pe_custom:OnLoadComponentBeforeChild(parentElem, parentLayout, css)
	-- class src file
	self:LoadScriptFile(self:GetAttribute("src"));
	-- class namespace
	local classns = self:GetAttribute("classns");
	if(classns) then
		local class_def = commonlib.getfield(classns);
		if(class_def and class_def.new) then
			local _this = class_def:new():init(parentElem);
			self:SetControl(_this);
			_this:ApplyCss(self:GetStyle());
		end
	end
end

function pe_custom:OnLoadComponentAfterChild(parentElem, parentLayout, css)
end

function pe_custom:OnAfterChildLayout(layout, left, top, right, bottom)
	if(self.control) then
		self.control:setGeometry(left, top, right-left, bottom-top);
	end
end