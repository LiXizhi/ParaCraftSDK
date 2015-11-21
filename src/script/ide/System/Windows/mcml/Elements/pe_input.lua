--[[
Title: input element
Author(s): LiXizhi
Date: 2015/5/3
Desc: html form input tags.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/mcml/Elements/pe_input.lua");
Elements.pe_input:RegisterAs("input");
------------------------------------------------------------
]]
local Elements = commonlib.gettable("System.Windows.mcml.Elements");
local pe_input = commonlib.inherit(commonlib.gettable("System.Windows.mcml.PageElement"), commonlib.gettable("System.Windows.mcml.Elements.pe_input"));

-- create according to type. 
function pe_input:createFromXmlNode(o)
	local type = pe_input.GetType(o);
	
	if(type == nil or type == "text") then
		return Elements.pe_editbox:createFromXmlNode(o);	
	elseif(type == "password") then
		return Elements.pe_editbox:createFromXmlNode(o);	
	elseif(type == "radio") then
		--return Elements.pe_radio:createFromXmlNode(o);	
	elseif(type == "checkbox") then
		--return Elements.pe_checkbox:createFromXmlNode(o);	
	elseif(type == "hidden") then
		--return Elements.pe_input_hidden:createFromXmlNode(o);	
	elseif(type == "submit" or type == "button" or type == "reset" ) then
		return Elements.pe_button:createFromXmlNode(o);	
	elseif(type == "file") then
		--return Elements.pe_fileupload:createFromXmlNode(o);	
	end

	return self:new(o);
end

-- static function. same as GetAttribute("type"). but it can operate on a pure xmlNode. 
function pe_input.GetType(self)
	if(self.attr) then
		return self.attr["type"];
	end
end

function pe_input:LoadComponent(parentElem, parentLayout, style)
	for childnode in self:next() do
		childnode:LoadComponent(parentElem, parentLayout, style);
	end
end

function pe_input:UpdateLayout(parentLayout)
	for childnode in self:next() do
		childnode:UpdateLayout(parentLayout);
	end
end

