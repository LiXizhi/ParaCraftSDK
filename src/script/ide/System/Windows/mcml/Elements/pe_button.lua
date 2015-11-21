--[[
Title: button
Author(s): LiXizhi
Date: 2015/5/3
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_button.lua");
Elements.pe_button:RegisterAs("button");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Windows/Controls/Button.lua");
local Button = commonlib.gettable("System.Windows.Controls.Button");

local pe_button = commonlib.inherit(commonlib.gettable("System.Windows.mcml.PageElement"), commonlib.gettable("System.Windows.mcml.Elements.pe_button"));
pe_button:Property({"class_name", "pe:button"});

function pe_button:OnLoadComponentBeforeChild(parentElem, parentLayout, css)
	css.float = css.float or true;

	local _this = Button:new():init(parentElem);
	self:SetControl(_this);
	_this:ApplyCss(css);
	_this:SetText(self:GetAttributeWithCode("value", nil, true));
	_this:SetTooltip(self:GetAttributeWithCode("tooltip", nil, true));

	local onclick = self.onclickscript or self:GetString("onclick");
	if(onclick == "")then
		onclick = nil;
	end
	local onclick_for = self:GetString("for");
	if(onclick_for == "") then
		onclick_for = nil;
	end
	local ontouch = self:GetString("ontouch");
	if(ontouch == "")then
		ontouch = nil;
	end

	if(onclick or onclick_for or ontouch) then
		_this:Connect("clicked", self, self.OnClick)
	end
end

function pe_button:OnBeforeChildLayout(layout)
	if(self.control) then
		local css = self:GetStyle();
		local width, height;
		if(not css.width) then
			width = self.control:CalculateTextWidth();
		end
		if(not css.height) then
			height = self.control:CalculateTextHeight();
		end
		if(width or height) then
			layout:AddObject(width or 0, height or 0);
		end
	end
end

function pe_button:OnAfterChildLayout(layout, left, top, right, bottom)
	if(self.control) then
		self.control:setGeometry(left, top, right-left, bottom-top);
	end
end

function pe_button:SetValue(value)
	self:SetAttribute("value", value);
end

function pe_button:GetValue()
	return self:GetAttribute("value");
end

function pe_button:OnClick()
	local bindingContext;
	local onclick = self.onclickscript or self:GetString("onclick");
	if(onclick == "")then
		onclick = nil;
	end
	local onclick_for = self:GetString("for");
	if(onclick_for == "") then
		onclick_for = nil;
	end
	local result;
	local buttonName = self:GetAttribute("name");
	if(onclick) then
		local btnType = self:GetString("type");
		if( btnType=="submit") then
			-- user clicks the normal button. 
			-- the callback function format is function(buttonName, values, bindingContext, self) end
			local values;
			--if(bindingContext) then
				--bindingContext:UpdateControlsToData();
				--values = bindingContext.values
			--end	
			result = self:DoPageEvent(onclick, buttonName, self);
		else
			-- user clicks the button, yet without form info
			-- the callback function format is function(buttonName, self) end
			result = self:DoPageEvent(onclick, buttonName, self)
		end
	end
	if(onclick_for) then
		-- call the OnClick method of the mcml control by id or name
		local pageCtrl = self:GetPageCtrl();
		if(pageCtrl) then
			local target_node = pageCtrl:GetNodeByID(onclick_for);
			if(target_node) then
				if(target_node ~= self) then
					target_node:InvokeMethod("HandleClickFor", self, bindingContext);
				else
					LOG.std(nil, "warn", "mcml", "the for target of %s can not be itself", onclick_for);	
				end
			else
				LOG.std(nil, "warn", "mcml", "the for target of %s is not found in the page", onclick_for);
			end
		end
	end
	return result;
end

