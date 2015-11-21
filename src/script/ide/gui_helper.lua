--[[ 
Title: GUI helper functions for ParaEngine
Author(s): LiXizhi, WangTian
Date: 2005/10
desc: To enable helper call:
------------------------------------------------------
NPL.load("(gl)script/ide/gui_helper.lua");
------------------------------------------------------
]]
if(_guihelper==nil) then _guihelper={} end
local math_floor = math.floor

NPL.load("(gl)script/ide/MessageBox.lua");
NPL.load("(gl)script/ide/ButtonStyles.lua");
NPL.load("(gl)script/ide/System/Core/Color.lua");
local Color = commonlib.gettable("System.Core.Color");

-- deprecated: use Color.ConvertColorToRGBAString instead
-- @param color: a string of "#FFFFFF" or "255 255 255 0"
-- @return: return a string of "255 255 255 0". the alpha part may be omitted. 
function _guihelper.ConvertColorToRGBAString(color)
	if(color and string.find(color, "#")~=nil) then
		color = string.gsub(string.gsub(color, "#", ""), "(%x%x)", function (h)
			return tonumber(h, 16).." "
		end);
	end
	return color;
end
local getcolor = _guihelper.ConvertColorToRGBAString;


-- get the last UI object position. This function is usually used when in a mouse click event callback script. 
-- return x, y, width, height. all of them may be nil.
function _guihelper.GetLastUIObjectPos()
	local ui_obj = ParaUI.GetUIObject(id);
	if(ui_obj:IsValid()) then
		return ui_obj:GetAbsPosition();
	end
end

-- return true if the given ui object is clipped by any of its parent container. 
-- (just in case of a scrollable container)
-- @param margin: default to 0.2 of uiobject width. max allowed clipping width
function _guihelper.IsUIObjectClipped(uiobject, margin)
	if(uiobject) then
		local x, y, width, height = uiobject:GetAbsPosition();

		margin = margin or 0.2;

		local margin_width = 5
		if(margin < 1) then
			margin_width = math.max(5, math.floor(width*margin))
		else
			margin_width = margin_width;
		end
			
		local parent = uiobject.parent;
		while (parent and parent:IsValid()) do
			local px, py, pwidth, pheight = parent:GetAbsPosition();
			px = px - margin_width;
			py = py - margin_width;
			pwidth = pwidth + margin_width*2;
			pheight = pheight + margin_width*2;
			if(px <= x and py <= y and (px+pwidth) >= (x+width) and (py+pheight)>=(y+height)) then
				parent = parent.parent;
			else
				return true;
			end
		end
	end
end

--[[
Set all texture layers of an UI object to the specifed color
if UIobject is nil or is an invalid UI object, this function does nothing.
e.g. _guihelper.SetUIColor(uiobject, "255 0 0"); or _guihelper.SetUIColor(uiobject, "255 0 0 128");
]]
function _guihelper.SetUIColor(uiobject, color)
	if(uiobject~=nil and uiobject:IsValid())then
		color = getcolor(color);
		local texture;
		uiobject:SetCurrentState("highlight");
		uiobject.color=color;		
		uiobject:SetCurrentState("pressed");
		uiobject.color=color;	
		uiobject:SetCurrentState("disabled");
		uiobject.color=color;
		uiobject:SetCurrentState("normal");
		uiobject.color=color;	
	end
end

-- set color mask. 
-- @param color: it can be "255 255 255", "#FFFFFF", "255 255 255 100", alpha is supported. 
function _guihelper.SetColorMask(uiobject, color)
	if(uiobject and color)then
		uiobject.colormask = getcolor(color);
	end
end


-- set the text font color of a UI control.
-- @param color: it can be "255 255 255", "#FFFFFF", "255 255 255 100", alpha is supported. 
function _guihelper.SetFontColor(uiobject, color)
	if(uiobject~=nil and uiobject:IsValid())then
		color = getcolor(color);
		uiobject:SetCurrentState("highlight");
        uiobject:GetFont("text").color = color;
        uiobject:SetCurrentState("disabled");
        uiobject:GetFont("text").color = color;
		uiobject:SetCurrentState("normal");
        uiobject:GetFont("text").color = color;
	end
end

-- set the text font color of a UI control.
-- @param color: it can be "255 255 255", "#FFFFFF", "255 255 255 100", alpha is supported. 
-- @param color_highlight: nil or the highlighted color
function _guihelper.SetButtonFontColor(uiobject, color, color_highlight)
	if(uiobject~=nil and uiobject:IsValid())then
		color = getcolor(color);
		color_highlight = getcolor(color_highlight);
		uiobject:SetCurrentState("highlight");
        uiobject:GetFont("text").color = color_highlight or color;
        uiobject:SetCurrentState("disabled");
        uiobject:GetFont("text").color = color;
		uiobject:SetCurrentState("pressed");
        uiobject:GetFont("text").color = color;
		uiobject:SetCurrentState("normal");
        uiobject:GetFont("text").color = color;
	end
end

-- set the text font color of a UI control.
-- @param color: it can be "255 255 255", "#FFFFFF", "255 255 255 100", alpha is supported. 
function _guihelper.SetButtonTextColor(uiobject, color)
	if(uiobject~=nil and uiobject:IsValid())then
		color = getcolor(color);
		uiobject:SetCurrentState("highlight");
        uiobject:GetFont("text").color = color;
        uiobject:SetCurrentState("pressed");
		uiobject:GetFont("text").color=color;
        uiobject:SetCurrentState("normal");
        uiobject:GetFont("text").color = color;
        uiobject:SetCurrentState("disabled");
        uiobject:GetFont("text").color = color;
	end
end

local default_font_str = "default";

-- set the default font. 
-- @param font_name: default font string, such as "System;12". If default, it will be the default one. 
function _guihelper.SetDefaultFont(font_name)
	default_font_str = font_name or "default";
end

local font_objects = {};

-- get the cached invisible text font GUIText object
-- @param fontName: if nil, default to default_font_str
function _guihelper.GetTextObjectByFont(fontName)
	fontName = fontName or default_font_str
	local obj = font_objects[fontName];
	if(obj and obj:IsValid()) then
		return obj;
	else
		local _parent = ParaUI.GetUIObject("_fonts_");
		if(_parent:IsValid() == false) then
			_parent = ParaUI.CreateUIObject("container","_fonts_", "_lt",-100,-20,200,15);
			_parent.visible = false;
			_parent.enabled = false;
			_parent:AttachToRoot();
		end
		
		local _this = _parent:GetChild(fontName);
		if(not _this:IsValid()) then
			_this = ParaUI.CreateUIObject("editbox",fontName, "_lt",0,0,800,22);
			_this.visible = false;
			if(fontName ~= "default") then
				_this.font = fontName;
			end
			_this:GetFont("text").format = 1+256; -- center and no clip
			_parent:AddChild(_this);
			font_objects[fontName] = _this;
			return font_objects[fontName];
		end
	end
end

-- get the width of text of a given font. It internally cache the font object and UI object on first call. 
-- @param text: text for which to determine the width
-- @param fontName: font name, such as "System;12". If nil, it will use the default font of text control. 
-- @return  the width of text of a given font
function _guihelper.GetTextWidth(text, fontName)
	if(not text or text=="") then 
		return 0 
	end
	local _this = _guihelper.GetTextObjectByFont(fontName);
	_this.text = text;
	return _this:GetTextLineSize();
end

-- Automatically trim additional text so that the text can be displayed inside a given width
-- e.g. a commonly used pattern is like below: 
--		local displayText = _guihelper.AutoTrimTextByWidth(text, maxTextWidth)
--		if(displayText == text) then
--			_this.text = text
--		else
--			_this.text = string.sub(displayText, 1, string.len(displayText)-3).."...";
--		end	
-- @param text: currently it only works for english letters. TODO: for utf8 text, we can first convert to unicode and then back.
-- @param maxWidth: the max width in pixel.
-- @param fontName: font name, such as "System;12". If nil, it will use the default font of text control. 
-- @return the text which may be trimed
function _guihelper.AutoTrimTextByWidth(text, maxWidth, fontName)
	if(not text or text=="") then 
		return "" 
	end
	local nSize = #(text);
	local width = _guihelper.GetTextWidth(text,fontName);
	
	if(width < maxWidth) then return text end
	--  Initialise numbers
	local iStart,iEnd,iMid = 1,nSize, nSize
	
	-- modified binary search
	while (iStart <= iEnd) do
		-- calculate middle
		iMid = math_floor( (iStart+iEnd)/2 );
		-- get compare value
		local value2 = _guihelper.GetTextWidth(string.sub(text, 1, iMid),fontName);
		if(value2 >= maxWidth) then
			iEnd = iMid - 1;
		else
			iStart = iMid + 1;
		end
	end
	return string.sub(text, 1, iMid)
end

-- trim UTF8 text by width
-- @param text: UTF8 string. 
-- @param maxWidth: the max width in pixel.
-- @param fontName: font name, such as "System;12". If nil, it will use the default font of text control. 
-- return the trimmed text and the remaining text
function _guihelper.TrimUtf8TextByWidth(text, maxWidth, fontName)
	if(not text or text=="") then 
		return "" 
	end
	local width = _guihelper.GetTextWidth(text,fontName);
	
	if(width < maxWidth) then return text end
	--  Initialise numbers
	local nSize = ParaMisc.GetUnicodeCharNum(text);
	local iStart,iEnd,iMid = 1,nSize, nSize
	
	-- modified binary search
	while (iStart <= iEnd) do
		-- calculate middle
		iMid = math_floor( (iStart+iEnd)/2 );
		-- get compare value
		local value2 = _guihelper.GetTextWidth(ParaMisc.UniSubString(text, 1, iMid),fontName);
		if(value2 >= maxWidth) then
			iEnd = iMid - 1;
			iMid = iEnd;
		else
			iStart = iMid + 1;
		end
	end
	local leftText = ParaMisc.UniSubString(text, 1, iMid);
	local rightText = ParaMisc.UniSubString(text, iMid+1, -1);
	if(iMid > 1 and iMid < nSize) then
		-- preventing word break of english letters.
		local leftword = leftText:match("%w+$");
		local rightword = rightText:match("^%w+");
		if(leftword and rightword and leftword~=leftText) then
			leftText = string.sub(leftText, 1, -(#leftword+1));
			rightText = leftword..rightText;
		end
	end
	return leftText, rightText;
end

-- @param uiobject uiobject such as button
-- @param format: 0 for left alignment; 1 for horizontal center alignment; 4 for vertical center aligntment; 5 for both vertical and horizontal; 
--  32 for single-lined left top alignment, 36 for single-lined  vertical center alignment
-- DT_TOP                      0x00000000
-- DT_LEFT                     0x00000000
-- DT_CENTER                   0x00000001
-- DT_RIGHT                    0x00000002
-- DT_VCENTER                  0x00000004
-- DT_BOTTOM                   0x00000008
-- DT_SINGLELINE			   0x00000020
-- DT_WORDBREAK                0x00000010
-- DT_NOCLIP				   0x00000100
-- DT_EXTERNALLEADING		   0x00000200
function _guihelper.SetUIFontFormat(uiobject, format)
	if(uiobject~=nil and uiobject:IsValid())then
		uiobject:SetCurrentState("highlight");
		uiobject:GetFont("text").format=format;
		uiobject:SetCurrentState("pressed");
		uiobject:GetFont("text").format=format;
		uiobject:SetCurrentState("disabled");
		uiobject:GetFont("text").format=format;
		uiobject:SetCurrentState("normal");
		uiobject:GetFont("text").format=format;
	end
end

-- @deprecated
-- @param r, g, b, a: each in [0,255]
function _guihelper.RGBA_TO_DWORD(r, g, b, a)
	return Color.RGBA_TO_DWORD(r, g, b, a);
end

-- @deprecated
-- convert from color string to dwColor
-- if alpha is not provided. the returned wColor will also not contain alpha. 
-- @param color: can be "#FFFFFF" or "#FFFFFF00" with alpha
function _guihelper.ColorStr_TO_DWORD(color)
	return Color.ColorStr_TO_DWORD(color);
end

-- @deprecated
-- @param r, g, b, a: each in [0,255]
-- @return r, g, b, a: each in [0,255]
function _guihelper.DWORD_TO_RGBA(w)
	return Color.DWORD_TO_RGBA(w);
end

--[[ set the text of a ui control by its name.
@param objName:name of the object
@param newText: string of the new text.
]]
function _guihelper.SafeSetText(objName, newText)
	local temp = ParaUI.GetUIObject(objName);
	if(temp:IsValid()==true) then 
		temp.text = newText;
	end
end

--[[ get the text of a ui control as a number. return nil if invalid. 
@param objName:name of the object
@return: number or nil
]]
function _guihelper.SafeGetNumber(objName)
	local temp = ParaUI.GetUIObject(objName);
	if(temp:IsValid()==true) then 
		return tonumber(temp.text);
	end
	return nil;
end

--[[ get the text of a ui control as a number. return nil if invalid. 
@param objName:name of the object, such as {"name1", "name2"} 
@return: number or nil
]]
function _guihelper.SafeGetText(objName)
	local temp = ParaUI.GetUIObject(objName);
	if(temp:IsValid()==true) then 
		return temp.text;
	end
	return nil;
end

--[[
@param objList:  an array of button names. 
@param selectedName: name of the selected button. If nil, nothing will be selected.
@param color: color used for highlighting the checked button.
@param checked_bg, unchecked_bg: can be nil or the texture of the checked and unchecked state.
]]
function _guihelper.CheckRadioButtons(objList, selectedName, color, checked_bg, unchecked_bg)
	if(color == nil) then
		color = "255 255 255";
	end
	local texture;
	local key, objName;
	for key, objName in pairs(objList) do
		local temp = ParaUI.GetUIObject(objName);
		if(temp:IsValid()==true) then 
			if(temp.name == selectedName) then
				if(checked_bg~=nil) then
					temp.background = checked_bg;
				end	
				if(temp:HasLayer("background")) then
					-- for vista style buttons, we will only change the background layer
					temp:SetActiveLayer("background");
					temp:SetCurrentState("highlight");
					temp.color=color;		
					temp:SetCurrentState("pressed");
					temp.color=color;
					temp:SetCurrentState("normal");
					temp.color=color;
					temp:SetActiveLayer("artwork");
				else
					temp:SetCurrentState("highlight");
					temp.color=color;		
					temp:SetCurrentState("pressed");
					temp.color=color;
					temp:SetCurrentState("normal");
					temp.color=color;
				end
			else
				if(unchecked_bg~=nil) then
					temp.background = unchecked_bg;
				end	
				if(temp:HasLayer("background")) then
					-- for vista style buttons, we will only change the background layer
					temp:SetActiveLayer("background");
						
					temp:SetCurrentState("highlight");
					temp.color="255 255 255";		
					temp:SetCurrentState("pressed");
					temp.color="160 160 160";
					temp:SetCurrentState("normal");
					temp.color="0 0 0 0";
					
					temp:SetActiveLayer("artwork");
				else
					temp:SetCurrentState("highlight");
					temp.color="255 255 255";		
					temp:SetCurrentState("pressed");
					temp.color="160 160 160";
					temp:SetCurrentState("normal");
					temp.color="200 200 200";
				end
			end
		end
	end
end



-- NOTE: --WangTian: change background for group of buttons
--[[
@param objList:  an array of button names. 
@param selectedName: name of the selected button. If nil, nothing will be selected.
@param color: color used for highlighting the checked button.
@param checked_bg, unchecked_bg: can be nil or the texture of the checked and unchecked state.
]]
function _guihelper.CheckRadioButtons2(objList, selectedName, color, checked_bg, unchecked_bg)
	if(color == nil) then
		color = "255 255 255";
	end
	local texture;
	local key, objName;
	for key, objName in pairs(objList) do
		local temp = ParaUI.GetUIObject(objName);
		if(temp:IsValid()==true) then 
			if(temp.name == selectedName) then
				if(temp:HasLayer("background")) then
					temp:SetActiveLayer("background");
					if(checked_bg~=nil) then
						-- for vista style buttons, we will only change the background layer
						
						temp:SetCurrentState("highlight");
						temp.color="255 255 255";
						
						temp:SetCurrentState("pressed");
						temp.color="160 160 160";
						
						temp:SetCurrentState("normal");
						temp.color="200 200 200";
						
					end
					temp:SetActiveLayer("artwork");
				end
			else
			
				if(temp:HasLayer("background")) then
					temp:SetActiveLayer("background");
					if(unchecked_bg~=nil) then
						--temp.background = unchecked_bg;
						-- for vista style buttons, we will only change the background layer
						
						temp:SetCurrentState("highlight");
						temp.color="255 255 255";
						temp:SetCurrentState("pressed");
						temp.color="160 160 160";
						temp:SetCurrentState("normal");
						temp.color="200 200 200";
					end
					temp:SetActiveLayer("artwork");
				end
			end
		end
	end
end


--[[
@param objList:  an array <index, button names>, such  as {[1] = "name1", [2] ="name2",} 
@param nSelectedIndex: index of the selected button. If nil, nothing will be selected.
@param color: color used for highlighting the checked button.
@param checked_bg, unchecked_bg: can be nil or the texture of the checked and unchecked state.
]]
function _guihelper.CheckRadioButtonsByIndex(objList, nSelectedIndex, color, checked_bg, unchecked_bg)
	if(color == nil) then
		color = "255 255 255";
	end
	local texture;
	local index, objName;
	for index, objName in ipairs(objList) do
		local temp = ParaUI.GetUIObject(objName);
		if(temp:IsValid()==true) then 
			if(index == nSelectedIndex) then
				if(checked_bg~=nil) then
					temp.background = checked_bg;
				end	
				if(temp:HasLayer("background")) then
					-- for vista style buttons, we will only change the background layer
					temp:SetActiveLayer("background");
					temp:SetCurrentState("highlight");
					temp.color=color;		
					temp:SetCurrentState("pressed");
					temp.color=color;
					temp:SetActiveLayer("artwork");
					temp:SetCurrentState("normal");
					temp.color=color;
				else
					temp:SetCurrentState("highlight");
					temp.color=color;		
					temp:SetCurrentState("pressed");
					temp.color=color;
					temp:SetCurrentState("normal");
					temp.color=color;
				end
			else
				if(checked_bg~=nil) then
					temp.background = unchecked_bg;
				end	
				if(temp:HasLayer("background")) then
					-- for vista style buttons, we will only change the background layer
					temp:SetActiveLayer("background");
					
					temp:SetCurrentState("highlight");
					temp.color="255 255 255";		
					temp:SetCurrentState("pressed");
					temp.color="160 160 160";
					temp:SetCurrentState("normal");
					temp.color="0 0 0 0";
					
					temp:SetActiveLayer("artwork");
				else
					temp:SetCurrentState("highlight");
					temp.color="255 255 255";		
					temp:SetCurrentState("pressed");
					temp.color="160 160 160";
					temp:SetCurrentState("normal");
					temp.color="200 200 200";
				end
			end
		end
	end
end

--[[
for all objects in objList, only the selectedName is made visible.
@param objList:  an array of button names, such as {"name1", "name2"} 
@param selectedName: name of the selected button. If nil, nothing will be selected.
]]
function _guihelper.SwitchVizGroup(objList, selectedName)
	local key, objName;
	for key, objName in pairs(objList) do
		local temp = ParaUI.GetUIObject(objName);
		if(temp:IsValid()==true) then 
			if(temp.name == selectedName) then
				temp.visible = true;
			else
				temp.visible = false;
			end
		end
	end
end

--[[
for all objects in objList, only the selectedName is made visible.
@param objList:  an array <index, button names>, such  as {[1] = "name1", [2] ="name2",} 
@param nSelectedIndex: index of the selected button. If nil, nothing will be selected.
]]
function _guihelper.SwitchVizGroupByIndex(objList, nSelectedIndex)
	local index, objName;
	for index, objName in ipairs(objList) do
		local temp = ParaUI.GetUIObject(objName);
		if(temp:IsValid()==true) then 
			if(index == nSelectedIndex) then
				temp.visible = true;
			else
				temp.visible = false;
			end
		end
	end
end

--[[this is a message handler for placeholder buttons,etc. it will display the name of control, the texture file path, etc in the messagebox
@param ctrlName: control name
@param comments: if not nil, it is additional text that will be displayed.
]]
function _guihelper.OnClick(ctrlName, comments)
	local temp = ParaUI.GetUIObject(ctrlName);
	if(temp:IsValid()==true) then 
		local text = string.format("name: %s\r\nbg: %s\r\n", ctrlName, temp.background);
		if(comments~=nil)then
			text = text..comments.."\r\n";
		end
		_guihelper.MessageBox(text);
	else
		_guihelper.MessageBox(ctrlName.." control not found\r\n");
	end
end

-- print out the table structure
-- @param t: table to print
-- @param filename: the file name to print out the table
function _guihelper.PrintTableStructure(t, filename)
	NPL.load("(gl)script/kids/3DMapSystem_Misc.lua");
	Map3DSystem.Misc.SaveTableToFile(t, filename);
end

-- print out the ui object structure
-- @param obj: ui object to print
-- @param filename: the file name to print out the ui object
function _guihelper.PrintUIObjectStructure(obj, filename)
	
	local function portToTable(obj, t)
		local function getObjInfo(obj)
			return obj.type.." @ "..obj.x.." "..obj.y.." "..obj.width.." "..obj.height;
		end
		if(obj.type == "container") then
			t[obj.name] = {};
			local nCount = obj:GetChildCount();
			for i = 0, nCount - 1 do
				local _ui = obj:GetChildAt(i);
				portToTable(_ui, t[obj.name]);
			end
		else
			t[obj.name] = getObjInfo(obj);
		end
	end
	
	local t = {};
	portToTable(obj, t);
	_guihelper.PrintTableStructure(t, filename);
end


-- set the container enabled, this will iterately set the enabled attribute in the UI object child container
-- @param bEnabled: true or false
function _guihelper.SetContainerEnabled(obj, bEnabled)
	if(obj:IsValid() == true) then
		if(obj.type == "container") then
			local nCount = obj:GetChildCount();
			for i = 0, nCount - 1 do
				local _ui = obj:GetChildAt(i);
				_guihelper.SetContainerEnabled(_ui, bEnabled)
			end
			obj.enabled = bEnabled;
		else
			obj.enabled = bEnabled;
		end
	end
end

local align_translator = {
	["_lb"] = function(x, y, width, height, screen_width, screen_height) 
		return x, screen_height+y, width, height;
	end,
	["_ct"] = function(x, y, width, height, screen_width, screen_height) 
		return x + screen_width / 2, y + screen_height/2, width, height;
	end,
	["_ctt"] = function(x, y, width, height, screen_width, screen_height) 
		return x + screen_width / 2, y, width, height;
	end,
	["_ctb"] = function(x, y, width, height, screen_width, screen_height) 
		return x + screen_width / 2, screen_height-y-height, width, height;
	end,
	["_ctl"] = function(x, y, width, height, screen_width, screen_height) 
		return x, y + screen_height/2, width, height;
	end,
	["_ctr"] = function(x, y, width, height, screen_width, screen_height) 
		return screen_width - width - x, y + screen_height/2, width, height;
	end,
	["_rt"] = function(x, y, width, height, screen_width, screen_height) 
		return screen_width + x, y, width, height;
	end,
	["_rb"] = function(x, y, width, height, screen_width, screen_height) 
		return screen_width + x, screen_height + y, width, height;
	end,
	["_mt"] = function(x, y, width, height, screen_width, screen_height) 
		return x, y, screen_width - width - x, height;
	end,
	["_mb"] = function(x, y, width, height, screen_width, screen_height) 
		return x, screen_height-y-height, screen_width - width - x, height;
	end,
	["_ml"] = function(x, y, width, height, screen_width, screen_height) 
		return x, y, width, screen_height-height-y;
	end,
	["_mr"] = function(x, y, width, height, screen_width, screen_height) 
		return screen_width - width - x, y, width, screen_height-height-y;
	end,
	["_fi"] = function(x, y, width, height, screen_width, screen_height) 
		return x, y, screen_width - width - x, screen_height-height-y;
	end,
}
--translate from ParaUI alignment to left top alignment based on the current screen resolution. 
-- @param screen_width, screen_height: the current screen resolution. if nil, it will be refreshed using current screen resolution. 
function _guihelper.NormalizeAlignment(alignment, x, y, width, height, screen_width, screen_height)
	local func = align_translator[alignment or "_lt"];
	if(func) then
		if(not screen_width) then
			if(Map3DSystem.ScreenResolution) then
				screen_width, screen_height = Map3DSystem.ScreenResolution.screen_width, Map3DSystem.ScreenResolution.screen_height
			else 
				local _;
				_, _, screen_width, screen_height = ParaUI.GetUIObject("root"):GetAbsPosition();
			end
		end
		x, y, width, height = func(x, y, width, height, screen_width, screen_height);
	end
	return x, y, width, height, screen_width, screen_height;
end

local states = {[1] = "highlight", [2] = "pressed", [3] = "disabled", [4] = "normal"};

-- update control bar for containers, etc. 	
function _guihelper.UpdateScrollBar(_this, scrollbar_track, scrollbar_upleft, scrollbar_downright, scrollbar_thumb)
	for i = 1, 4 do
		_this:SetCurrentState(states[i]);
		if(scrollbar_track) then
			texture=_this:GetTexture("track");
			texture.texture = scrollbar_track;
		end
		if(scrollbar_upleft) then
			texture=_this:GetTexture("up_left");
			texture.texture = scrollbar_upleft;
		end
		if(scrollbar_downright) then
			texture=_this:GetTexture("down_right");
			texture.texture = scrollbar_downright;
		end
		if(scrollbar_thumb) then
			texture=_this:GetTexture("thumb");
			texture.texture = scrollbar_thumb;
		end
	end
end
