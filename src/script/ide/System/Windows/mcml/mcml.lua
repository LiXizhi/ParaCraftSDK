--[[
Title: mcml
Author(s): LiXizhi
Date: 2015/4/27
Desc:singleton class for control registration, etc. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/mcml/mcml.lua");
local mcml = commonlib.gettable("System.Windows.mcml");
mcml:StaticInit();
mcml:RegisterPageElement("pe:div", Elements.pe_div);
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Windows/mcml/PageElement.lua");
NPL.load("(gl)script/ide/System/Windows/mcml/StyleDefault.lua");
local PageElement = commonlib.gettable("System.Windows.mcml.PageElement");
local Elements = commonlib.gettable("System.Windows.mcml.Elements");
local mcml = commonlib.gettable("System.Windows.mcml");
local type = type;

-- control mapping: from tag name to page element
local element_map = {};

-- register a given mcml tag with a custom user control.
-- @param tag_name: the mcml tag name, such as "pe:my_user_control"
-- @param tag_class: the tag class table used to create the control at runtime. At minimum it should be a table containing a create() function
--   i.e. {create = function(rootName,mcmlNode, bindingContext, _parent, left, top, width, height, style, parentLayout)  end, }
--   please see the rich number existing tag classes for examples. 
function mcml:RegisterPageElement(tag_name, tag_class)
	element_map[tag_name] = tag_class;
end

-- unregister a tag
function mcml:UnRegisterPageElement(tag_name)
	element_map[tag_name] = nil;
end

-- get page element class by its registered name. 
function mcml:GetClassByTagName(tag_name) 
	return element_map[tag_name] or Elements[tag_name] or PageElement;
end

local isInited;
function mcml:StaticInit()
	if(isInited) then
		return
	end
	isInited = true;

	if(not self.style) then
		self:SetStyle(mcml.StyleDefault:new());
	end

	self:LoadAllElements();
end

function mcml:GetStyle()
	return self.style;
end

function mcml:SetStyle(style)
	self.style = style;
end

-- @param itemname: such as "div", "button"
function mcml:GetStyleItem(itemname)
	return self.style:GetItem(itemname);
end


-- load all element class. call this at least once during startup. 
-- add all predefined page elements here. 
function mcml:LoadAllElements()
	if(element_map["pe:mcml"]) then
		-- already loaded
		return true;
	end
	
	NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_text.lua");
	Elements.pe_text:RegisterAs("text", "pe:text");
	NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_div.lua");
	Elements.pe_div:RegisterAs("pe:mcml", "div", "pe:div");
		NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_font.lua");
		Elements.pe_font:RegisterAs("font");
		NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_span.lua");
		Elements.pe_span:RegisterAs("span");
		NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_container.lua");
		Elements.pe_container:RegisterAs("pe:container");
		NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_custom.lua");
		Elements.pe_custom:RegisterAs("pe:custom");
	NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_script.lua");
	Elements.pe_script:RegisterAs("script", "pe:script", "unknown"); -- "unknown" will handle <% %>, etc. 
		NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_unknown.lua");
		Elements.pe_unknown:RegisterAs("pe:flushnode", "pe:fallthrough");
	NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_input.lua");
	Elements.pe_input:RegisterAs("input");
		NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_editbox.lua");
		Elements.pe_editbox:RegisterAs("editbox");
		NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_button.lua");
		Elements.pe_button:RegisterAs("button");
	NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_if.lua");
	Elements.pe_if:RegisterAs("pe:if");
	NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_identicon.lua");
	Elements.pe_identicon:RegisterAs("pe:identicon");
	-- TODO: add all system defined page element here
end

-- create page element from xml node by its name. 
function mcml:createFromXmlNode(xmlNode)
	self:StaticInit();
	local class_type = self:GetClassByTagName(xmlNode.name or "div");
	if(class_type) then
		return class_type:createFromXmlNode(xmlNode);
	else
		LOG.std(nil, "warn", "mcml", "can not find tag name %s", xmlNode.name or "");
	end
end
