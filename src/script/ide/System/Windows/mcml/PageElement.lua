--[[
Title: PageElement
Author(s): LiXizhi
Date: 2015/4/27
Desc: base class to all page elements. 
Page element is responsible for creation, layout, editing(via external mcml editors) of UIElements. 
Each page element may be associated with zero or more UI elements. 

virtual functions:
	LoadComponent(parentElem, parentLayout, style) 
		OnLoadComponentBeforeChild(parentElem, parentLayout, css)
		OnLoadComponentAfterChild(parentElem, parentLayout, css)
	UpdateLayout(layout) 
		OnBeforeChildLayout(layout)
		OnAfterChildLayout(layout, left, top, right, bottom)
	paintEvent(painter)

---++ Guideline for subclass PageElement. 
Whenever a page is first loaded or refreshed, LoadComponent() is called once.
You need to overload either LoadComponent, OnLoadComponentBeforeChild, or OnLoadComponentAfterChild 
to create any inner UI Element and attach them properly to the passed-in parent UI element. 
Remember to keep a reference of the UI element on the page element as well, so that you can re-position them 
during UpdateLayout(). If there is only one UI element, we usually call SetControl() to assign it to self.control. 

After all page component is loaded, the UpdateLayout will be called. 
You need to override either UpdateLayout, OnBeforeChildLayout or OnAfterChildLayout,
 to setGeometry of any loaded components(i.e. UI Element). UpdateLayout may be called recursively. 
It is also called when the top level layout resizes due to user interaction or resize event. 

If your page element handles paintEvent, you must call EnableSelfPaint() during one of the LoadComponent overrides.
It will create a dummy UIElement which redirect paintEvent to the pageElement. 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/mcml/PageElement.lua");
local PageElement = commonlib.gettable("System.Windows.mcml.PageElement");
local elem = PageElement:new();
------------------------------------------------------------
]]
NPL.load("(gl)script/kids/3DMapSystemApp/localserver/UrlHelper.lua");
NPL.load("(gl)script/ide/System/Windows/mcml/StyleItem.lua");
local StyleItem = commonlib.gettable("System.Windows.mcml.StyleItem");
local mcml = commonlib.gettable("System.Windows.mcml");
local Elements = commonlib.gettable("System.Windows.mcml.Elements");
local PageElement = commonlib.inherit(commonlib.gettable("System.Core.ToolBase"), commonlib.gettable("System.Windows.mcml.PageElement"));
-- default style sheet
PageElement:Property("Name", "PageElement");
PageElement:Property({"class_name", nil});
local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local tonumber = tonumber
local type = type
local string_find = string.find;
local string_format = string.format;
local string_gsub = string.gsub;
local string_lower = string.lower
local string_match = string.match;
local LOG = LOG;
local NameNodeMap_ = {};
local commonlib = commonlib.gettable("commonlib");

function PageElement:ctor()
end

-- virtual public function: create a page element (and recursively all its children) according to input xmlNode o.
-- generally one do not need to override this function, unless you want to control how child nodes are initialized. 
-- @param o: pure xml node table. 
-- @return the input o is returned. 
function PageElement:createFromXmlNode(o)
	o = self:new(o);
	o:createChildRecursive_helper();
	return o;
end

-- static public function
function PageElement:createChildRecursive_helper()
	if(#self ~= 0) then
		for i, child in ipairs(self) do
			if(type(child) == "table") then
				local class_type = mcml:GetClassByTagName(child.name or "div");
				if(class_type) then
					class_type:createFromXmlNode(child);
				else
					LOG.std(nil, "warn", "mcml", "can not find tag name %s", child.name or "");
				end
			else
				-- for inner text of xml
				child = Elements.pe_text:createFromString(child);
				self[i] = child;
			end
			child.parent = self;
			child.index = i;
		end
	end
end

-- static function: register as a given tag name. 
-- @param name1, name2, name3, name4: can be nil, or alias name. 
function PageElement:RegisterAs(name, name1, name2, name3, name4)
	mcml:RegisterPageElement(name, self);
	if(name1) then
		mcml:RegisterPageElement(name1, self);
		if(name2) then
			mcml:RegisterPageElement(name2, self);
			if(name3) then
				mcml:RegisterPageElement(name3, self);
				if(name4) then
					mcml:RegisterPageElement(name4, self);
				end
			end
		end
	end
end

-- @param src: can be relative to current file or global filename.
function PageElement:LoadScriptFile(src)
	if(src ~= nil and src ~= "") then
		src = string.gsub(src, "^(%(.*%)).*$", "");
		src = self:GetAbsoluteURL(src);
		--if(ParaIO.DoesFileExist(src, true) or ParaIO.DoesFileExist(string.gsub(src, "(.*)lua", "bin/%1o"), true)) then
		-- SECURITY NOTE: load script in global environment
		NPL.load("(gl)"..src);
		--else
			--log("warning: MCML script does not exist locally :"..src.."\n");
		--end	
	end
end

-- virtual function: load component recursively. 
-- generally one do not need to override this function, override 
--  OnLoadComponentBeforeChild and OnLoadComponentAfterChild instead. 
-- @param parentLayout: only for casual initial layout. 
-- @return used_width, used_height
function PageElement:LoadComponent(parentElem, parentLayout, style)
	if(self:GetAttribute("display") == "none") then 
		return 
	end
	-- process any variables that is taking place. 
	self:ProcessVariables();
	
	if(self:GetAttribute("trans")) then
		-- here we will translate all child nodes recursively, using the given lang 
		-- unless any of the child attribute disables or specifies a different lang
		self:TranslateMe();
	end

	local css = self:CreateStyle(mcml:GetStyleItem(self.class_name or self.name), style);

	self:OnLoadComponentBeforeChild(parentElem, parentLayout, css);

	for childnode in self:next() do
		childnode:LoadComponent(parentElem, parentLayout, css);
	end

	self:OnLoadComponentAfterChild(parentElem, parentLayout, css);

	-- call onload(self) function if any. 
	local onloadFunc = self:GetString("onload");
	if(onloadFunc and onloadFunc~="") then
		Elements.pe_script.BeginCode(self);
		local pFunc = commonlib.getfield(onloadFunc);
		if(type(pFunc) == "function") then
			pFunc(self);
		else
			LOG.std("", "warn", "mcml", "%s node's onload call back: %s is not a valid function.", self.name, onloadFunc)	
		end
		Elements.pe_script.EndCode(rootName, self, bindingContext, _parent, left, top, width, height,style, parentLayout);
	end
end

-- private: redirector
local function paintEventRedirectFunc(uiElement, painter)
	if(uiElement._page_element) then
		uiElement._page_element:paintEvent(painter);
	end
end

-- enable self.paintEvent for this page element by creating a delegate UIElement and attach it to parentElem. 
-- only call this function once during LoadComponent.
function PageElement:EnableSelfPaint(parentElem)
	if(not self.control) then
		local _this = System.Windows.UIElement:new():init(parentElem);
		_this._page_element = self;
		_this.paintEvent = paintEventRedirectFunc;
		self:SetControl(_this);
	else
		if(self.control._page_element == self) then
			self.control:SetParent(parentElem);
		else
			LOG.std("", "error", "mcml", "self paint can only be enabled when there is no control created for the page element");
		end
	end
end

-- virtual function: only called if EnableSelfPaint() is called during load component. 
function PageElement:paintEvent(painter)
end

-- this function is called automatically after page component is loaded and whenever the window resize. 
function PageElement:UpdateLayout(parentLayout)
	if(self:GetAttribute("display") == "none") then 
		return 
	end
	local css = self:GetStyle();
	if(not css) then
		return;
	end
	local padding_left, padding_top, padding_right, padding_bottom = css:paddings();
	local margin_left, margin_top, margin_right, margin_bottom = css:margins();
	local availWidth, availHeight = parentLayout:GetPreferredSize();
	local maxWidth, maxHeight = parentLayout:GetMaxSize();
	local left, top;
	local width, height = self:GetAttribute("width"), self:GetAttribute("height");
	if(width) then
		css.width = tonumber(string.match(width, "%d+"));
		if(css.width and string.match(width, "%%$")) then
			if(css.position == "screen") then
				css.width = ParaUI.GetUIObject("root").width * css.width/100;
			else	
				css.width=math.floor((maxWidth-margin_left-margin_right)*css.width/100);
				if(availWidth<(css.width+margin_left+margin_right)) then
					css.width=availWidth-margin_left-margin_right;
				end
				if(css.width<=0) then
					css.width = nil;
				end
			end	
		end	
	end
	if(height) then
		css.height = tonumber(string.match(height, "%d+"));
		if(css.height and string.match(height, "%%$")) then
			if(css.position == "screen") then
				css.height = ParaUI.GetUIObject("root").height * css.height/100;
			else	
				css.height=math.floor((maxHeight-margin_top-margin_bottom)*css.height/100);
				if(availHeight<(css.height+margin_top+margin_bottom)) then
					css.height=availHeight-margin_top-margin_bottom;
				end
				if(css.height<=0) then
					css.height = nil;
				end
			end	
		end	
	end
	-- whether this control takes up space
	local bUseSpace; 
	if(css.float) then
		if(css.width) then
			if(availWidth<(css.width+margin_left+margin_right)) then
				parentLayout:NewLine();
			end
		end	
	else
		parentLayout:NewLine();
	end
	local myLayout = parentLayout:clone();
	myLayout:ResetUsedSize();

	local align = self:GetAttribute("align") or css["align"];
	local valign = self:GetAttribute("valign") or css["valign"];

	if(css.position == "absolute") then
		-- absolute positioning in parent
		if(css.width and css.height and css.left and css.top) then
			-- if all rect is provided, we will do true absolute position. 
			myLayout:reset(css.left, css.top, css.left + css.width, css.top + css.height);
		else
			-- this still subject to parent rect. 
			myLayout:SetPos(css.left, css.top);
		end
		myLayout:ResetUsedSize();
	elseif(css.position == "relative") then
		-- relative positioning in next render position. 
		myLayout:OffsetPos(css.left, css.top);
	elseif(css.position == "screen") then	
		-- relative positioning in screen client area
		local offset_x, offset_y = 0, 0;
		local left, top = self:GetAttribute("left"), self:GetAttribute("top");
		if(left) then
			left = tonumber(string.match(left, "(%d+)%%$"));
			offset_x = ParaUI.GetUIObject("root").width * left/100;
		end
		if(top) then
			top = tonumber(string.match(top, "(%d+)%%$"));
			offset_y = ParaUI.GetUIObject("root").height * top/100;
		end
		local px,py = _parent:GetAbsPosition();
		myLayout:SetPos((css.left or 0)-px + offset_x, (css.top or 0)-py + offset_y); 
	else
		myLayout:OffsetPos(css.left, css.top);
		bUseSpace = true;	
	end
	
	left,top = myLayout:GetAvailablePos();
	myLayout:SetPos(left,top);
	width,height = myLayout:GetSize();
	
	if(css.width) then
		myLayout:IncWidth(left+margin_left+margin_right+css.width-width)
	end
	
	if(css.height) then
		myLayout:IncHeight(top+margin_top+margin_bottom+css.height-height)
	end	
	
	-- for inner control preferred size
	myLayout:OffsetPos(margin_left+padding_left, margin_top+padding_top);
	myLayout:IncWidth(-margin_right-padding_right)
	myLayout:IncHeight(-margin_bottom-padding_bottom)

	-- self.m_left, self.m_top = left+margin_left, top+margin_top;
	-----------------------------
	-- self and child layout recursively.
	-----------------------------
	if(not self:OnBeforeChildLayout(myLayout)) then
		for childnode in self:next() do
			childnode:UpdateLayout(myLayout);
		end
	end
	
	local width, height = myLayout:GetUsedSize()
	width = width + padding_right + margin_right
	height = height + padding_bottom + margin_bottom
	if(css.width) then
		width = left + css.width + margin_left + margin_right;
	end	
	if(css.height) then
		height = top + css.height + margin_top + margin_bottom;
	end
	if(css["min-width"]) then
		local min_width = css["min-width"];
		if((width-left - margin_left-margin_right) < min_width) then
			width = left + min_width + margin_left + margin_right;
		end
	end
	if(css["min-height"]) then
		local min_height = css["min-height"];
		if((height-top - margin_top - margin_bottom) < min_height) then
			height = top + min_height + margin_top + margin_bottom;
		end
	end
	if(css["max-height"]) then
		local max_height = css["max-height"];
		if((height-top) > max_height) then
			height = top + max_height;
		end
	end
	myLayout:SetUsedSize(width, height);
	-- self.m_right, self.m_bottom = width-margin_right, height-margin_bottom;

	-- call virtual function for final size calculation. 
	self:OnAfterChildLayout(myLayout, left+margin_left, top+margin_top, width-margin_right, height-margin_bottom);
	width, height = myLayout:GetUsedSize();

	local size_width, size_height = width-left, height-top;
	local offset_x, offset_y = 0, 0;
	
	-- align at center. 
	if(align == "center") then
		offset_x = (maxWidth - size_width)/2
	elseif(align == "right") then
		offset_x = (maxWidth - size_width);
	end	
	
	if(valign == "center") then
		offset_y = (maxHeight - size_height)/2
	elseif(valign == "bottom") then
		offset_y = (maxHeight - size_height);
	end	
	if(offset_x~=0 or offset_y~=0) then
		-- offset and recalculate if there is special alignment. 
		myLayout = parentLayout:clone();
		local left, top = left+offset_x, top+offset_y;
		myLayout:SetPos(left, top);
		myLayout:SetSize(left+size_width, top+size_height);
		myLayout:OffsetPos(margin_left+padding_left, margin_top+padding_top);
		myLayout:IncWidth(-margin_right-padding_right);
		myLayout:IncHeight(-margin_bottom-padding_bottom);
		myLayout:ResetUsedSize();
		self:OnBeforeChildLayout(myLayout);
		for childnode in self:next() do
			childnode:UpdateLayout(myLayout);
		end
		local right, bottom = left+size_width, top+size_height
		myLayout:SetUsedSize(right, bottom);
		self:OnAfterChildLayout(myLayout, left+margin_left, top+margin_top, right-margin_right, bottom-margin_bottom);
	end

	if(bUseSpace) then
		parentLayout:AddObject(width-left, height-top);
		if(not css.float) then
			parentLayout:NewLine();
		end	
	end
end

-- virtual function: adjust control size according to preferred rect of layout. 
-- before child node layout is updated.
-- @return normally return nil. if return true, child nodes will be skipped. 
function PageElement:OnBeforeChildLayout(layout)
	
end

-- virtual function: 
-- after child node layout is updated
-- @param left, top, right, bottom: may be nil. it can also be preferred size of the control after child layout is calculated (margins are already removed). 
function PageElement:OnAfterChildLayout(layout, left, top, right, bottom)
	
end

-- virtual function: 
-- @param css: style
function PageElement:OnLoadComponentBeforeChild(parentElem, parentLayout, css)
end

function PageElement:OnLoadComponentAfterChild(parentElem, parentLayout, css)
end

-- set the value of an attribute of this node. This function is rarely used. 
function PageElement:SetAttribute(attrName, value)
	self.attr = self.attr or {};
	self.attr[attrName] = value;
	if(attrName == "style") then
		-- tricky code: since we will cache style table on the node, we need to delete the cached style when it is changed. 
		self.style = nil;
	end
end

-- set the attribute if attribute is not code. 
function PageElement:SetAttributeIfNotCode(attrName, value)
	self.attr = self.attr or {};
	local old_value = self.attr[attrName];
	if(type(old_value) == "string") then
		local code = string_match(old_value, "^[<%%]%%(=.*)%%[%%>]$")
		if(not code) then
			self.attr[attrName] = value;
		end
	else
		self.attr[attrName] = value;
	end
end

-- get the value of an attribute of this node as its original format (usually string)
function PageElement:GetAttribute(attrName,defaultValue)
	if(self.attr) then
		return self.attr[attrName];
	end
	return defaultValue;
end

-- get the value of an attribute of this node (usually string)
-- this differs from GetAttribute() in that the attribute string may contain embedded code block which may evaluates to a different string, table or even function. 
-- please note that only the first call of this method will evaluate embedded code block, subsequent calls simply return the previous evaluated result. 
-- in most cases the result is nil or string, but it can also be a table or function. 
-- @param bNoOverwrite: default to nil. if true, the code will be reevaluated the next time this is called, otherwise the evaluated value will be saved and returned the next time this is called. 
-- e.g. attrName='<%="string"+Eval("index")}%>' attrName1='<%={fieldname="table"}%>'
function PageElement:GetAttributeWithCode(attrName,defaultValue, bNoOverwrite)
	if(self.attr) then
		local value = self.attr[attrName];
		if(type(value) == "string") then
			local code = string_match(value, "^[<%%]%%(=.*)%%[%%>]$")
			if(code) then
				value = Elements.pe_script.DoPageCode(code, self:GetPageCtrl());
				if(not bNoOverwrite) then
					self.attr[attrName] = value;
				end	
			end
		end
		if(value ~= nil) then
			return value;
		end
	end
	return defaultValue;
end


-- get an attribute as string
function PageElement:GetString(attrName,defaultValue)
	if(self.attr) then
		return self.attr[attrName];
	end
	return defaultValue;
end

-- get an attribute as number
function PageElement:GetNumber(attrName,defaultValue)
	if(self.attr) then
		return tonumber(self.attr[attrName]);
	end
	return defaultValue;
end

-- get an attribute as integer
function PageElement:GetInt(attrName, defaultValue)
	if(self.attr) then
		return math.floor(tonumber(self.attr[attrName]));
	end
	return defaultValue;
end


-- get an attribute as boolean
function PageElement:GetBool(attrName, defaultValue)
	if(self.attr) then
		local v = string_lower(tostring(self.attr[attrName]));
		if(v == "false") then
			return false
		elseif(v == "true") then
			return true
		end
	end
	return defaultValue;
end

-- get all pure text of only text child node
function PageElement:GetPureText()
	local nSize = #(self);
	local text = "";
	for i=1, nSize do
		node = self[i];
		if(node) then
			if(type(node) == "string") then
				text = text..node;
			end
		end
	end
	return text;
end

-- get all inner text recursively (i.e. without tags) as string. 
function PageElement:GetInnerText()
	local node;
	local text = "";
	for i=1, #(self) do
		node = self[i];
		if(node) then
			if(type(node) == "string") then
				text = text..node;
			elseif(type(node) == "table") then
				text = text..node:GetInnerText();
			elseif(type(node) == "number") then
				text = text..tostring(node);
			end
		end
	end
	return text;
end

-- set inner text. It will replace all child nodes with a text node
function PageElement:SetInnerText(text)
	self[1] = text;
	commonlib.resize(self, 1);
end

-- get value: it is usually one of the editor tag, such as <input>
function PageElement:GetValue()
end

-- set value: it is usually one of the editor tag, such as <input>
function PageElement:SetValue(value)
end

-- get UI value: get the value on the UI object with current node
-- @param instName: the page instance name. 
function PageElement:GetUIValue(pageInstName)
end

-- set UI value: set the value on the UI object with current node
function PageElement:SetUIValue(pageInstName, value)
end


-- set UI enabled: set the enabled on the UI object with current node
function PageElement:SetUIEnabled(pageInstName, value)
end

-- get UI value: get the value on the UI object with current node
-- @param instName: the page instance name. 
function PageElement:GetUIBackground(pageInstName)
end

-- set UI value: set the value on the UI object with current node
function PageElement:SetUIBackground(pageInstName, value)
end

-- call a control method
-- @param instName: the page instance name. 
-- @param methodName: name of the method.
-- @return: the value from method is returned
function PageElement:CallMethod(pageInstName, methodName, ...)
	if(self[methodName]) then
		return self[methodName](self, pageInstName, ...);
	else
		LOG.warn("CallMethod (%s) on object %s is not supported\n", tostring(methodName), self.name)
	end
end

-- return true if the page node contains a method called methodName
function PageElement:HasMethod(pageInstName, methodName)
	if(self[methodName]) then
		return true;
	end
end

-- invoke a control method. this is same as CallMethod, except that pageInstName is ignored. 
-- @param methodName: name of the method.
-- @return: the value from method is returned
function PageElement:InvokeMethod(methodName, ...)
	if(self[methodName]) then
		return self[methodName](self, ...);
	else
		LOG.warn("InvokeMethod (%s) on object %s is not supported\n", tostring(methodName), self.name)
	end
end

function PageElement:SetObjId(id)
	self.uiobject_id = id;
end

function PageElement:SetControl(control)
	self.control = control;
end

-- get the control associated with this node. 
-- if self.uiobject_id is not nil, we will fetch it using this id, if self.control is not nil, it will be returned, otherwise we will use the unique path name to locate the control or uiobject by name. 
-- @param instName: the page instance name. if nil, we will ignore global control search in page. 
-- @return: It returns the ParaUIObject or CommonCtrl object depending on the type of the control found.
function PageElement:GetControl(pageName)
	if(self.uiobject_id) then
		local uiobj = ParaUI.GetUIObject(self.uiobject_id);
		if(uiobj:IsValid()) then
			return uiobj;
		end
	elseif(self.control) then
		return self.control;
	elseif(pageName) then
		local instName = self:GetInstanceName(pageName);
		if(instName) then
			local ctl = CommonCtrl.GetControl(instName);
			if(ctl == nil) then
				local uiobj = ParaUI.GetUIObject(instName);
				if(uiobj:IsValid()) then
					return uiobj;
				end
			else
				return ctl;	
			end
		end
	end
end

-- return font: "System;12;norm";  return nil if not available. 
function PageElement:CalculateFont(css)
	local font;
	if(css and (css["font-family"] or css["font-size"] or css["font-weight"]))then
		local font_family = css["font-family"] or "System";
		-- this is tricky. we convert font size to integer, and we will use scale if font size is either too big or too small. 
		local font_size = math.floor(tonumber(css["font-size"] or 12));
		local font_weight = css["font-weight"] or "norm";
		font = string.format("%s;%d;%s", font_family, font_size, font_weight);
	end
	return font;
end

-- get UI control 
function PageElement:GetUIControl(pageName)
	if(self.uiobject_id) then
		local uiobj = ParaUI.GetUIObject(self.uiobject_id);
		if(uiobj:IsValid()) then
			return uiobj;
		end
	else
		local instName = self:GetInstanceName(pageName);
		if(instName) then
			local uiobj = ParaUI.GetUIObject(instName);
			if(uiobj:IsValid()) then
				return uiobj;
			end
		end
	end
end

-- print information about the parent nodes
function PageElement:printParents()
	log(tostring(self.name).." is a child of ")
	if(self.parent == nil) then
		log("\n")
	else
		self.parent:printParents();
	end
end

-- print this node to log file for debugging purposes. 
function PageElement:print()
	log("<"..tostring(self.name));
	if(self.attr) then
		local name, value
		for name, value in pairs(self.attr) do
			commonlib.log(" %s=\"%s\"", name, value);
		end
	end	
	local nChildSize = #(self);
	if(nChildSize>0) then
		log(">");
		local i, node;
		local text = "";
		for i=1, nChildSize do
			node = self[i];
			if(type(node) == "table") then
				log("\n")
				node:print();
			elseif(type(node) == "string") then
				log(node)
			end
		end
		log("</"..self.name..">\n");
	else
		log("/>\n");
	end
end

-- set the value of a css style attribute after mcml node is evaluated. This function is rarely used. 
-- @note: one can only call this function when the mcml node is evaluated at least once, calling this function prior to evaluation will cause the style not to inherit its parent style 
-- alternatively, we can use self:SetAttribute("style", value) to change the entire attribute. 
-- @return true if succeed. 
function PageElement:SetCssStyle(attrName, value)
	if(type(self.style) == "table") then
		self.style[attrName] = value;
		return true
	else
		local style = self:CreateStyle();
		style[attrName] = value;
	end
end

-- get the ccs attribute of a given css style attribute value. 
function PageElement:GetCssStyle(attrName)
	if(type(self.style) == "table") then
		return self.style[attrName];
	end
end

function PageElement:InvalidateStyle()
	self.style = nil;
end

function PageElement:GetStyle()
	return self.style;
end

-- get the css style object if any. Style will only be evaluated once and saved to self.style as a table object, 
-- unless style attribute is changed by self:SetAttribute("style", value) method. 
-- order of style inheritance: base_baseStyle, baseStyle, style specified by attr.class.
-- @param baseStyle: nil or usually the default style with which the current node's style is merged.
-- @param base_baseStyle: this is optional. where to copy inheritable fields, usually from parent element's style object. 
-- @return: style table is a table of name value pairs. such as {color=string, href=string}
function PageElement:CreateStyle(baseStyle, base_baseStyle)
	local style = StyleItem:new();
	self.style = style;

	style:MergeInheritable(base_baseStyle);
	style:Merge(baseStyle);
	--
	-- apply class if any
	--
	if(self.attr and self.attr.class) then
		local class_name = self:GetAttributeWithCode("class", nil, true);
		style:Merge(mcml:GetStyleItem(class_name));
	end
	--
	-- apply instance if any
	--
	if(self.attr and self.attr.style) then
		local style_code = self:GetAttributeWithCode("style", nil, true);
		style:Merge(style_code);
	end
	return style;
end

-- @param child: it can be mcmlNode or string node. 
-- @param index: 1 based index, at which to insert the item. if nil, it will be inserted to the end
function PageElement:AddChild(child, index)
	if(type(child)=="table") then
		local nCount = #(self) or 0;
		child.index = commonlib.insertArrayItem(self, index, child)
		child.parent = self;
	elseif(type(child)=="string") then	
		local nCount = #(self) or 0;
		commonlib.insertArrayItem(self, index, child)
	end	
end

-- detach this node from its parent node. 
function PageElement:Detach()
	local parentNode = self.parent
	if(parentNode == nil) then
		return
	end
	
	local nSize = #(parentNode);
	local i, node;
	
	if(nSize == 1) then
		parentNode[1] = nil; 
		parentNode:ClearAllChildren();
		return;
	end
	
	local i = self.index;
	local node;
	if(i<nSize) then
		local k;
		for k=i+1, nSize do
			node = parentNode[k];
			parentNode[k-1] = node;
			if(node~=nil) then
				node.index = k-1;
				parentNode[k] = nil;
			end	
		end
	else
		parentNode[i] = nil;
	end	
end

-- check whether this baseNode has a parent with the given name. It will search recursively for all ancesters. 
-- @param name: the parent name to search for. If nil, it will return parent regardless of its name. 
-- @return: the parent object is returned. 
function PageElement:GetParent(name)
	if(name==nil) then
		return self.parent
	end
	local parent = self.parent;
	while (parent~=nil) do
		if(parent.name == name) then
			return parent;
		end
		parent = parent.parent;
	end
end

-- get the root node, it will find in ancestor nodes until one without parent is found
-- @return root node.
function PageElement:GetRoot()
	local parent = self;
	while (parent.parent~=nil) do
		parent = parent.parent;
	end
	return parent;
end

-- Get the page control(PageCtrl) that loaded this mcml page. 
function PageElement:GetPageCtrl()
	return self:GetAttribute("page_ctrl") or self:GetParentAttribute("page_ctrl");
end	

-- search all parent with a given attribute name. It will search recursively for all ancesters.  
-- this function is usually used for getting the "request_url" field which is inserted by MCML web browser to the top level node. 
-- @param attrName: the parent field name to search for
-- @return: the nearest parent object field is returned. it may return, if no such parent is found. 
function PageElement:GetParentAttribute(attrName)
	local parent = self.parent;
	while (parent~=nil) do
		if(parent:GetAttribute(attrName)~=nil) then
			return parent:GetAttribute(attrName);
		end
		parent = parent.parent;
	end
end

-- get the url request of the mcml node if any. It will search for "request_url" attribtue field in the ancestor of this node. 
-- PageCtrl and BrowserWnd will automatically insert "request_url" attribtue field to the root MCML node before instantiate them. 
-- @return: nil or the request_url is returned. we can extract requery string parameters using regular expressions or using GetRequestParam
function PageElement:GetRequestURL()
	return self:GetParentAttribute("request_url") or self:GetAttribute("request_url");
end

-- get request url parameter by its name. for example if page url is "www.paraengine.com/user?id=10&time=20", then GetRequestParam("id") will be 10.
-- @return: nil or string value.
function PageElement:GetRequestParam(paramName)
	local request_url = self:GetRequestURL();
	return Map3DSystem.localserver.UrlHelper.url_getparams(request_url, paramName)
end

-- convert a url to absolute path using "request_url" if present
-- it will replace %NAME% with their values before processing next. 
-- @param url: it is any script, image or page url path which may be absolute, site root or relative path. 
--  relative to url path can not contain "/", anotherwise it is regarded as client side relative path. such as "Texture/whitedot.png"
-- @return: it always returns absolute path. however, if path cannot be resolved, the input is returned unchanged. 
function PageElement:GetAbsoluteURL(url)
	if(not url or url=="") then return url end
	-- it will replace %NAME% with their values before processing next. 
	url = paraworld.TranslateURL(url);
	
	if(string_find(url, "^([%w]*)://"))then
		-- already absolute path
	else	
		local request_url = self:GetRequestURL();
		if(request_url) then
			NPL.load("(gl)script/kids/3DMapSystemApp/localserver/security_model.lua");
			local secureOrigin = Map3DSystem.localserver.SecurityOrigin:new(request_url)
			
			if(string_find(url, "^/\\")) then
				-- relative to site root.
				if(secureOrigin.url) then
					url = secureOrigin.url..url;
				end	
			elseif(string_find(url, "[/\\]")) then
				-- if relative to url path contains "/", it is regarded as client side SDK root folder. such as "Texture/whitedot.png"
			elseif(string_find(url, "^#")) then	
				-- this is an anchor
				url = string_gsub(request_url,"^([^#]*)#.-$", "%1")..url
			else
				-- relative to request url path
				url = string_gsub(string_gsub(request_url, "%?.*$", ""), "^(.*)/[^/\\]-$", "%1/")..url
			end
		end	
	end
	return url;
end

-- get the user ID of the owner of the profile. 
function PageElement:GetOwnerUserID()
	local profile = self:GetParent("pe:profile") or self;
	if(profile) then
		return profile:GetAttribute("uid");
	end
end

-- Get child count
function PageElement:GetChildCount()
	return #(self);
end

-- Clear all child nodes
function PageElement:ClearAllChildren()
	commonlib.resize(self, 0);
end

-- generate a less compare function according to a node field name. 
-- @param fieldName: the name of the field, such as "text", "name", etc
function PageElement.GenerateLessCFByField(fieldName)
	fieldName = fieldName or "name";
	return function(node1, node2)
		if(node1[fieldName] == nil) then
			return true
		elseif(node2[fieldName] == nil) then
			return false
		else
			return node1[fieldName] < node2[fieldName];
		end	
	end
end

-- generate a greater compare function according to a node field name. 
-- @param fieldName: the name of the field, such as "text", "name", etc
--   One can also build a compare function by calling PageElement.GenerateLessCFByField(fieldName) or PageElement.GenerateGreaterCFByField(fieldName)
function PageElement.GenerateGreaterCFByField(fieldName)
	fieldName = fieldName or "name";
	return function(node1, node2)
		if(node2[fieldName] == nil) then
			return true
		elseif(node1[fieldName] == nil) then
			return false
		else
			return node1[fieldName] > node2[fieldName];
		end	
	end
end

-- sorting the children according to a compare function. Internally it uses table.sort().
-- Note: child indices are rebuilt and may cause UI binded controls to misbehave
-- compareFunc: if nil, it will compare by node.name. 
function PageElement:SortChildren(compareFunc)
	compareFunc = compareFunc or PageElement.GenerateLessCFByField("name");
	-- quick sort
	table.sort(self, compareFunc)
	-- rebuild index. 
	local i, node
	for i,node in ipairs(self) do
		node.index = i;
	end
end

-- get a string containing the node path. such as "1/1/1/3"
-- as long as the baseNode does not change, the node path uniquely identifies a baseNode.
function PageElement:GetNodePath()
	local path = tostring(self.index);
	while (self.parent ~=nil) do
		path = tostring(self.parent.index).."/"..path;
		self = self.parent;
	end
	return path;
end

-- @param rootName: a name that uniquely identifies a UI instance of this object, usually the userid or app_key. The function will generate a sub control name by concartinating this rootname with relative baseNode path. 
function PageElement:GetInstanceName(rootName)
	return tostring(rootName)..self:GetNodePath();
end

-- get the first occurance of first level child node whose name is name
-- @param name: if can be the name of the node, or it can be a interger index. 
function PageElement:GetChild(name)
	if(type(name) == "number") then
		return self[name];
	else
		local nSize = #(self);
		local node;
		for i=1, nSize do
			node = self[i];
			if(type(node)=="table" and name == node.name) then
				return node;
			end
		end
	end	
end

-- get the first occurance of first level child node whose name is name
-- @param name: if can be the name of the node, or it can be a interger index. 
-- @return nil if not found
function PageElement:GetChildWithAttribute(name, value)
	local nSize = #(self);
	local i, node;
	for i=1, nSize do
		node = self[i];
		if(type(node)=="table") then
			if(value == node:GetAttribute(name)) then
				return node;
			end	
		end
	end
end

-- get the first occurance of child node whose attribute name is value. it will search for all child nodes recursively. 
function PageElement:SearchChildByAttribute(name, value)
	local nSize = #(self);
	local i, node;
	for i=1, nSize do
		node = self[i];
		if(type(node)=="table") then
			if(value == node:GetAttribute(name)) then
				return node;
			else
				node = node:SearchChildByAttribute(name, value);
				if(node) then
					return node;
				end
			end	
		end
	end
end

-- return an iterator of all first level child nodes whose name is name
-- a more advanced way to tranverse mcml tree is using ide/Xpath
-- @param name: if name is nil, all child is returned. 
function PageElement:next(name)
	local nSize = #(self);
	local i = 1;
	return function ()
		local node;
		while i <= nSize do
			node = self[i];
			i = i+1;
			if(not name or (type(node) == "table" and name == node.name)) then
				return node;
			end
		end
	end	
end


-- this is a jquery meta table, if one wants to add jquery-like function calls, just set this metatable as the class array table. 
-- e.g. setmetatable(some_table, jquery_metatable)
local jquery_metatable = {
	-- each invocation will create additional tables and closures, hence the performance is not supper good. 
	__index = function(t, k)
		if(type(k) == "string") then
			local func = {};
			setmetatable(func, {
				-- the first parameter is always the mcml_node. 
				-- the return value is always the last node's result
				__call = function(self, ...)
					local output;
					local i, node
					for i, node in ipairs(t) do
						if(type(node[k]) == "function")then
							output = node[k](node, ...);
						end
					end
					return output;
				end,
			});
			return func;
		elseif(type(k) == "number") then
			return t[k];
		end
	end,
}

-- provide jquery-like syntax to find all nodes that match a given name pattern and then use the returned object to invoke a method on all returned nodes. 
--  e.g. node:jquery("a").show();
-- @param pattern: The valid format is [tag_name][#name_id][.class_name]. 
--  e.g. "div#name.class_name", "#some_name", ".some_class", "div"
function PageElement:jquery(pattern)
	local output = {}
	if(pattern) then
		local tag_name, pattern = pattern:match("^([^#%.]*)(.*)");
		if(tag_name == "") then
			tag_name = nil;
		end
		local id;
		if(pattern) then
			id = pattern:match("#([^#%.]+)");
		end
		local class_name;
		if(pattern) then
			class_name = pattern:match("%.([^#%.]+)");
		end
		self:GetAllChildWithNameIDClass(tag_name, id, class_name, output);
	end
	setmetatable(output, jquery_metatable)
	return output;
end

-- show this node. one may needs to refresh the page if page is already rendered
function PageElement:show()
	self:SetAttribute("display", nil)
end

-- hide this node. one may needs to refresh the page if page is already rendered
function PageElement:hide()
	self:SetAttribute("display", "none")
end

-- return the inner text or empty string. 
function PageElement:text()
	local inner_text = self[1];
	if(type(inner_text) == "string") then
		return inner_text;
	else
		return ""
	end
end

-- return a table containing all child nodes whose name is name. (it will search recursively)
-- a more advanced way to tranverse mcml tree is using ide/Xpath
-- @param name: the tag name. if nil it matches all
-- @param id: the name attribute. if nil it matches all
-- @param class: the class attribute. if nil it matches all
-- @param output: nil or a table to receive the result. child nodes with the name is saved to this table array. if nil, a new table will be created. 
-- @return output: the output table containing all children. It may be nil if no one is found and input "output" is also nil.
function PageElement:GetAllChildWithNameIDClass(name, id, class, output)
	local nSize = #(self);
	local i = 1;
	local node;
	while i <= nSize do
		node = self[i];
		i = i+1;
		if(type(node) == "table") then
			if( (not name or name == node.name) and
				(not id or id == node:GetAttribute("name")) and
				(not class or class==node:GetAttribute("class")) ) then
				output = output or {};
				table.insert(output, node);
			else
				output = node:GetAllChildWithNameIDClass(name, id, class, output)
			end	
		end
	end
	return output;
end

-- return a table containing all child nodes whose name is name. (it will search recursively)
-- a more advanced way to tranverse mcml tree is using ide/Xpath
-- @param name: the tag name
-- @param output: nil or a table to receive the result. child nodes with the name is saved to this table array. if nil, a new table will be created. 
-- @return output: the output table containing all children. It may be nil if no one is found and input "output" is also nil.
function PageElement:GetAllChildWithName(name, output)
	local nSize = #(self);
	local i = 1;
	local node;
	while i <= nSize do
		node = self[i];
		i = i+1;
		if(type(node) == "table") then
			if(name == node.name) then
				output = output or {};
				table.insert(output, node);
			else
				output = node:GetAllChildWithName(name, output)
			end	
		end
	end
	return output;
end

-- return an iterator of all child nodes whose attribtue attrName is attrValue. (it will search recursively)
-- a more advanced way to tranverse mcml tree is using ide/Xpath
-- @param name: if name is nil, all child is returned. 
-- @param output: nil or a table to receive the result. child nodes with the name is saved to this table array. if nil, a new table will be created. 
-- @return output: the output table containing all children. It may be nil if no one is found and input "output" is also nil.
function PageElement:GetAllChildWithAttribute(attrName, attrValue, output)
	local nSize = #(self);
	local i = 1;
	local node;
	while i <= nSize do
		node = self[i];
		i = i+1;
		if(type(node) == "table") then
			if(node:GetAttribute(attrName) == attrValue) then
				output = output or {};
				table.insert(output, node);
			else
				output = node:GetAllChildWithAttribute(attrName, attrValue, output)
			end	
		end
	end
	return output;
end

-- this function will apply self.pre_values to current page scope during rendering.
-- making it accessible to XPath and Eval function.  
function PageElement:ApplyPreValues()
	if(type(self.pre_values) == "table") then
		local pageScope = self:GetPageCtrl():GetPageScope();
		if(pageScope) then
			for name, value in pairs(self.pre_values) do
				pageScope[name] = value;
			end
		end
	end
end

-- apply a given pre value to this node, so that when the node is rendered, the name, value pairs will be
-- written to the current page scope. Not all mcml node support pre values. it is most often used by databinding template node. 
function PageElement:SetPreValue(name, value)
	self.pre_values = self.pre_values or {};
	self.pre_values[name] = value;
end

-- get a prevalue by name. this function is usually called on data binded mcml node 
-- @param name: name of the pre value
-- @param bSearchParent: if true, it will search parent node recursively until name is found or root node is reached. 
function PageElement:GetPreValue(name, bSearchParent)
	if(self.pre_values) then
		return self.pre_values[name];
	elseif(bSearchParent) then
		local parent = self.parent;
		while (parent~=nil) do
			if(parent.pre_values) then
				return parent.pre_values[name];
			end
			parent = parent.parent;
		end
	end
end

-- here we will translate current node and all of its child nodes recursively, using the given langTable 
-- unless any of the child attribute disables or specifies a different lang using the trans attribute
-- @note: it will secretly mark an already translated node, so it will not be translated twice when the next time this method is called.
-- @param langTable: this is a translation table from CommonCtrl.Locale(transName); if this is nil, 
-- @param transName: the translation name of the langTable. 
function PageElement:TranslateMe(langTable, transName)
	local trans = self:GetAttribute("trans");
	if(trans) then
		if(trans == "no" or trans == "none") then 
			return
		elseif(trans ~= transName) then
			langTable = CommonCtrl.Locale(trans);
			transName = trans;
			if(not langTable) then
				LOG.warn("lang table %s is not found for the mcml page\n", trans);
			end
		end	
		-- secretly mark an already translated node, so it will not be translated twice when the next time this method is called.
		if(self.IsTranslated) then
			return
		else
			self.IsTranslated = true;
		end
	end	
	-- translate this and all child nodes recursively
	if(langTable) then
		-- translate attributes of current node. 
		if(self.attr) then
			local name, value 
			for name, value in pairs(self.attr) do
				-- we will skip some attributes. 
				if(name~="style" and name~="id" and name~="name") then
					if(type(value) == "string") then
						-- TRANSLATE: translate value
						if(langTable:HasTranslation(value)) then
							--commonlib.echo(langTable(value))
							self.attr[name] = langTable(value);
						end	
					end
				end	
			end
		end
	
		-- translate child nodes recursively. 	
		local nSize = #(self);
		local i = 1;
		local node;
		while i <= nSize do
			node = self[i];
			if(type(node) == "table") then
				node:TranslateMe(langTable, transName)
			elseif(type(node) == "string") then
				-- only translate if the node is not unknown and not script node.
				if(self.name ~= "script" and self.name ~= "unknown" and self.name ~= "pe:script") then
					-- TRANSLATE: translate inner text
					if(langTable:HasTranslation(node)) then
						--commonlib.echo(langTable(node))
						self[i] = langTable(node)
					end
				end	
			end
			i = i+1;
		end
	end
end

-- if there an attribute called variables. 
-- variables are frequently used for localization in mcml. Both table based localization and commonlib.Locale based localization are supported. 
function PageElement:ProcessVariables()
	local variables_str = self:GetAttribute("variables");
	if(variables_str and not self.__variable_processed) then
		self.__variable_processed = true;

		--  a table containing all variables
		local variables = {};

		local var_name, var_value
		for var_name, var_value in string.gmatch(variables_str, "%$(%w*)=([^;%$]+)") do
			local func = commonlib.getfield(var_value) or commonlib.Locale:GetByName(var_value);
			variable = {
					var_name=var_name, 
					match_exp="%$"..var_name.."{([^}]*)}", 
					gsub_exp="%$"..var_name.."{[^}]*}", 
				};
			if(not func) then
				-- try to find a locale file with value under the given folder
				-- suppose var_value is "locale.mcml.IDE", then we will first try "locale/mcml/IDE.lua" and then try "locale/mcml/IDE_enUS.lua"
				local filename = var_value:gsub("%.", "/");
				local locale_file1 = format("%s.lua", filename);
				local locale_file2 = format("%s_%s.lua", filename, ParaEngine.GetLocale());
				if(ParaIO.DoesFileExist(locale_file1)) then
					filename = locale_file1;
				elseif(ParaIO.DoesFileExist(locale_file2)) then
					filename = locale_file2;
				else
					filename = nil;
				end
				if(filename) then
					NPL.load("(gl)"..filename);
					LOG.std(nil, "system", "mcml", "loaded variable file %s for %s", filename, var_value);
					func = commonlib.getfield(var_value) or commonlib.Locale:GetByName(var_value);
					if(not func) then
						func = commonlib.gettable(var_value);
						LOG.std(nil, "warn", "mcml", "empty table is created and used for variable %s. Ideally it should be %s or %s", var_value, locale_file1, locale_file2);
					end
				else
					LOG.std(nil, "warn", "mcml", "can not find variable table file for %s. It should be %s or %s", var_value, locale_file1, locale_file2);
				end
			end

			if(type(func) == "function") then
				variable.func = func
				variables[#variables+1] = variable;
			elseif(type(func) == "table") then
				local meta_table = getmetatable(func);
				if(meta_table and meta_table.__call) then
					variable.func = func
				else
					variable.func = function(name)
						return func[name];
					end
				end
				variables[#variables+1] = variable;
			else
				LOG.std(nil, "warn", "mcml", "unsupported $ %s params", var_name);
			end
		end

		if(#variables>0) then
			self:ReplaceVariables(variables);
		end
	end
end

function PageElement:ReplaceVariables(variables)
	if(variables) then
		-- translate this and all child nodes recursively
		-- translate attributes of current node. 
		if(self.attr) then
			local name, value 
			for name, value in pairs(self.attr) do
				-- we will skip some attributes. 
				if(type(value) == "string") then
					-- REPLACE
					local k;
					for k=1, #variables do
						local variable = variables[k];
						local var_value = value:match(variable.match_exp)
						if(var_value) then
							value = value:gsub(variable.gsub_exp, variable.func(var_value) or var_value);
							self.attr[name] = value;
						end
					end
				end
			end
		end
	
		-- translate child nodes recursively. 	
		local nSize = #(self);
		local i = 1;
		local node;
		while i <= nSize do
			node = self[i];
			if(type(node) == "table") then
				node:ReplaceVariables(variables)
			elseif(type(node) == "string") then
				local value = node;
				-- REPLACE
				local k;
				for k=1, #variables do
					local variable = variables[k];
					local var_value = value:match(variable.match_exp)
					if(var_value) then
						value = value:gsub(variable.gsub_exp, variable.func(var_value) or var_value); 
						self[i] = value;
					end
				end
			end
			i = i+1;
		end
	end
end

-- fire a given page event
-- @param handlerScript: the call back script function name or function itself.
--  the script function will be called with function(...) end
-- @param ... : event parameter
function PageElement:DoPageEvent(handlerScript, ...)
	local pageEnv, result;
	if(self) then
		-- get the page env table where the inline script function is defined, it may be nil if there is no page control or there is no inline script function. 
		local pageCtrl = self:GetPageCtrl();
		if(pageCtrl) then
			pageEnv = pageCtrl._PAGESCRIPT
		end
		
		Elements.pe_script.BeginCode(self);
	end
	if(type(handlerScript) == "string") then
		if(string.find(handlerScript, "http://")) then
			-- TODO: post values using http post. 
		else
			-- first search function in page script environment and then search in global environment. 
			local pFunc;
			if(pageEnv) then
				pFunc = commonlib.getfield(handlerScript, pageEnv);
			end
			if(type(pFunc) ~= "function") then
				pFunc = commonlib.getfield(handlerScript);
			end	
			if(type(pFunc) == "function") then
				result = pFunc(...);
			else
				log("warning: MCML page event call back "..handlerScript.." is not a valid function. \n")	
			end
		end	
	elseif(type(handlerScript) == "function") then
		result = pFunc(...);
	end
	if(self) then
		Elements.pe_script.EndCode();
	end
	return result;
end

