--[[
Title: text element
Author(s): LiXizhi
Date: 2015/4/28
Desc: it handles plain text node, or HTML tags of <span>
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_text.lua");
System.Windows.mcml.Elements.pe_text:RegisterAs("text");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Windows/mcml/PageElement.lua");
NPL.load("(gl)script/ide/System/Windows/UIElement.lua");
NPL.load("(gl)script/ide/System/Windows/Controls/Label.lua");
local mcml = commonlib.gettable("System.Windows.mcml");
local Label = commonlib.gettable("System.Windows.Controls.Label");
local UIElement = commonlib.gettable("System.Windows.UIElement")

local pe_text = commonlib.inherit(commonlib.gettable("System.Windows.mcml.PageElement"), commonlib.gettable("System.Windows.mcml.Elements.pe_text"));
pe_text:Property({"class_name", "text"});
pe_text.Property({"value", nil, "GetValue", "SetValue"})

function pe_text:ctor()
end

-- public:
function pe_text:createFromString(str)
	return self:new({name="text", value = str});
end

function pe_text:GetTextTrimmed()
	local value = self.value or self:GetAttributeWithCode("value", nil, true);
	if(value) then
		value = string.gsub(value, "nbsp;", "");
		value = string.gsub(value, "^[%s]+", "");
		value = string.gsub(value, "[%s]+$", "");
	end
	return value;
end

function pe_text:LoadComponent(parentElem, parentLayout, style)
	local css = self:CreateStyle(mcml:GetStyleItem(self.class_name), style);

	local value = self:GetTextTrimmed();
	self.value = value;
	if(not value or value=="") then
		return true;
	end
	self:EnableSelfPaint(parentElem);

	css.float = true;
	local font, font_size, font_scaling = css:GetFontSettings();
	local line_padding = 2;
	
	if(css["line-height"]) then
		local line_height = css["line-height"];
		local line_height_percent = line_height:match("(%d+)%%");
		if(line_height_percent) then
			line_height_percent = tonumber(line_height_percent);
			line_padding = math.ceil((line_height_percent*font_size*0.01-font_size)*0.5);
		else
			line_height = line_height:match("(%d+)");
			line_height = tonumber(line_height);
			if(line_height) then
				line_padding = math.ceil((line_height-font_size)*0.5);
			end
		end
	end
	self.font = font;
	self.font_size = font_size;
	self.scale = scale;
	self.line_padding = line_padding;
	self.textflow = css.textflow;
end

-- this function is called automatically after page component is loaded and whenever the window resize. 
function pe_text:UpdateLayout(parentLayout)
	self:CalculateTextLayout(self:GetValue(), parentLayout);
end

-- static function: calculate text. 
function pe_text:CalculateTextLayout(labelText, parentLayout)
	self.labels = commonlib.Array:new();
	self:CalculateTextLayout_helper(labelText, parentLayout, self:GetStyle());
end

-- private function: recursively calculate
function pe_text:CalculateTextLayout_helper(labelText, parentLayout, css)
	if(not labelText or labelText=="") then
		return
	end
	-- font-family: Arial; font-size: 14pt;font-weight: bold; 
	local left, top, width, height;
	local scale = self.scale;
	local textflow = self.textflow;
	local font_size = self.font_size;
	local line_padding = self.line_padding or 2;
	
		
	local labelWidth = _guihelper.GetTextWidth(labelText, self.font);
		
	-- labelWidth = labelWidth + 3;
	if(labelWidth>0) then
		width = parentLayout:GetPreferredSize();
		if(width == 0) then
			parentLayout:NewLine();
			left, top, width, height = parentLayout:GetPreferredRect();
			width = parentLayout:GetPreferredSize();
		end
		local remaining_text_func;
		if(labelWidth>width and width>0) then
			if(css and css["display"] == "block") then
					
			else
				-- for inline block, we will display recursively in multiple line
				local trim_text, remaining_text = _guihelper.TrimUtf8TextByWidth(labelText,width,self.font)

				if(trim_text and trim_text~="" and remaining_text and remaining_text~="") then
					remaining_text_func = function()
						parentLayout:NewLine();
						local left, top, width, height = parentLayout:GetPreferredRect();
						self:CalculateTextLayout_helper(remaining_text, parentLayout, css);
					end
					labelText = trim_text;
					labelWidth = _guihelper.GetTextWidth(labelText, font);
					if(labelWidth<=0) then
						return;
					end
				end
			end
			--width = parentLayout:GetMaxSize();
			--if(labelWidth>width) then
				--labelWidth = width
			--end
		end
		left, top = parentLayout:GetAvailablePos();
		height = font_size;
		width = labelWidth;
			
		if(scale) then
			width = width * scale;
			height = height * scale;
		end	

		height = height + line_padding + line_padding;

		local _this = Label:new():init();
		_this:SetText(labelText);
		_this:setGeometry(left, top+line_padding, width, height);
		self.labels:add(_this);

		if(css) then
			if(css["text-align"]) then
				local aval_left, aval_top, aval_width, aval_height = parentLayout:GetPreferredRect();
				if(css["text-align"] == "right") then
					_this:setX(aval_width-width);
					width = aval_width; -- tricky: it will assume all width
				elseif(css["text-align"] == "center") then
					local shift_x = (aval_width - aval_left - width)/2
					_this:setX(aval_left + shift_x);
					width = width + shift_x; -- tricky: it will assume addition width
				end
			end
			if(css["text-shadow"]) then
				if(css["shadow-quality"]) then
					-- _this:GetAttributeObject():SetField("TextShadowQuality", tonumber(css["shadow-quality"]) or 0);
				end
				if(css["shadow-color"]) then
					-- _this:GetAttributeObject():SetField("TextShadowColor", _guihelper.ColorStr_TO_DWORD(css["shadow-color"]));
				end
			end	
		end
			
		-- this fixed an bug that text overrun the preferred rect.
		-- however, multiple lines of scaled font may still appear wrong, but will not affect parent layout after the fix.
		local max_width = parentLayout:GetPreferredSize();
		if(width>max_width) then
			width = max_width;
		end
		parentLayout:AddObject(width, height);

		if(remaining_text_func) then
			remaining_text_func();
		end
	end
end

-- virtual function: 
-- after child node layout is updated
function pe_text:OnAfterChildLayout(layout, left, top, right, bottom)
end

-- get value: it is usually one of the editor tag, such as <input>
function pe_text:GetValue()
	return self.value;
end

-- set value: it is usually one of the editor tag, such as <input>
function pe_text:SetValue(value)
	self.value = tostring(value);
end

-- virtual function: 
function pe_text:paintEvent(painter)
	if(self.labels) then
		local css = self:GetStyle();
		painter:SetFont(self.font);
		painter:SetPen(css.color or "#000000");

		for i = 1, #self.labels do
			local label = self.labels[i];
			if(label) then
				local text = label:GetText();
				painter:DrawTextScaled(label.crect:x(), label.crect:y(), text, self.scale);
			end
		end
	end
end
