--[[
Title: div element
Author(s): LiXizhi
Date: 2015/4/27
Desc: div element
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_div.lua");
System.Windows.mcml.Elements.pe_div:RegisterAs("pe:mcml", "div", "pe:div");
------------------------------------------------------------
]]

NPL.load("(gl)script/ide/System/Windows/mcml/PageElement.lua");
NPL.load("(gl)script/ide/System/Windows/Shapes/Rectangle.lua");
NPL.load("(gl)script/ide/System/Windows/Controls/Button.lua");
local Button = commonlib.gettable("System.Windows.Controls.Button");
local Rectangle = commonlib.gettable("System.Windows.Shapes.Rectangle");

local pe_div = commonlib.inherit(commonlib.gettable("System.Windows.mcml.PageElement"), commonlib.gettable("System.Windows.mcml.Elements.pe_div"));

function pe_div:ctor()
	
end

function pe_div:OnLoadComponentBeforeChild(parentElem, parentLayout, css)
	local ignore_onclick, ignore_tooltip, ignore_background;
	local onclick, ontouch;
	local onclick_for;
	if(not ignore_onclick) then
		onclick = self:GetString("onclick");
		if(onclick == "") then
			onclick = nil;
		end
		onclick_for = self:GetString("for");
		if(onclick_for == "") then
			onclick_for = nil;
		end
		ontouch = self:GetString("ontouch");
		if(ontouch == "") then
			ontouch = nil;
		end
	end
	local tooltip
	if(not ignore_tooltip) then
		tooltip = self:GetAttributeWithCode("tooltip",nil,true);
		if(tooltip == "") then
			tooltip = nil;
		end
	end
	local background;
	if(not ignore_background) then
		background = self:GetAttribute("background") or css.background;
	end
	if(css["background-color"] and not ignore_background) then
		if(not background and not css.background2) then
			background = "Texture/whitedot.png";
		end
	end

	if(onclick_for or onclick or tooltip or ontouch) then
		-- if there is onclick event, the inner nodes will not be interactive.
		local _this = Button:new():init(parentElem);
		self:SetControl(_this);
		if(background) then
			_this:SetBackground(background);
			if(background~="") then
				if(css["background-color"]) then
					_this:SetBackgroundColor(css["background-color"]);
				end	
				if(css["background-rotation"]) then
					_this:SetRotation(tonumber(css["background-rotation"]));
				end
				if(css["background-repeat"] == "repeat") then
					_this:SetRotation("UVWrappingEnabled", true);
				end
			end
		end
		local zorder = self:GetNumber("zorder");
		if(zorder) then
			_this.zorder = zorder;
		end
	else
		if(background) then
			local _this = Rectangle:new():init(parentElem);
			self:SetControl(_this)
			if(background) then
				_this:SetBackground(background);
				if(background~="") then
					if(css["background-color"]) then
						_this:SetBackgroundColor(css["background-color"]);
					end	
					if(css["background-rotation"]) then
						_this:SetRotation(tonumber(css["background-rotation"]));
					end
					if(css["background-repeat"] == "repeat") then
						_this:SetRotation("UVWrappingEnabled", true);
					end
				end
			end
			local zorder = self:GetNumber("zorder");
			if(zorder) then
				_this.zorder = zorder;
			end
		end
	end
end

-- virtual function: 
-- after child node layout is updated
function pe_div:OnAfterChildLayout(layout, left, top, right, bottom)
	if(self.control) then
		self.control:setGeometry(left, top, right-left, bottom-top);
	end
end