
--[[
Title: multiline textbox from a treeview. It supports readonly, show line number and syntax highlighting
Author(s): LiXizhi
Date: 2007/3/7
Note: if you use an auto strench alignment, auto strench is only enabled on creation. which means that if one change the window size after creation, it does not work out as expected.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/MultiLineEditbox.lua");
local ctl = CommonCtrl.MultiLineEditbox:new{
	name = "MultiLineEditbox1",
	alignment = "_lt",left=0, top=0,width = 256,height = 90, parent = nil,
	WordWrap = false,
};
ctl:Show(true);
ctl:SetText("line 1\r\nline2");
log(ctl:GetText());
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");
NPL.load("(gl)script/ide/TreeView.lua");
NPL.load("(gl)script/ide/System/Windows/KeyEvent.lua");
local KeyEvent = commonlib.gettable("System.Windows.KeyEvent");

-- define a new control in the common control libary

-- default member attributes
local MultiLineEditbox = commonlib.inherit(commonlib.gettable("CommonCtrl.TreeView"), commonlib.createtable("CommonCtrl.MultiLineEditbox", {
	-- the top level control name
	name = "MultiLineEditbox1",
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 512,
	height = 390, 
	parent = nil,
	-- whether it is readonly. 
	ReadOnly = nil,
	-- Note: Only implemented with SingleLineEdit set to true. It is too complicated to implement word wrapping with multiple line edit. 
	WordWrap = nil,
	-- whether we will only allow editing on the first line
	SingleLineEdit = nil,
	-- this is space between each line. 
	DefaultNodeHeight = 20,
	-- text to show when text is empty. such as "click to enter text..."
	empty_text = nil,
	-- vertical scrollbar step
	VerticalScrollBarStep = 20,
	-- spacing from top for each line. 
	linetop_spacing = 3,
	-- max number of lines. If nil there are no limit. 
	max_lines = nil,
	-- boolean: whether to show line number
	ShowLineNumber = nil,
	-- the width of grey area to display line number. Only used when ShowLineNumber is true. 
	LineNumberWidth = 20,
	-- appearance
	container_bg = "Texture/3DMapSystem/common/ThemeLightBlue/container_bg.png: 4 4 4 4",
	-- the background of each line. the texture height should be height of each line. 
	line_bg = "",
	-- text color such as "#52dff4"
	textcolor = nil,
	-- if nil, it is default. such as 20 pixels
	fontsize = nil,
	-- called when user right click on the text. function(self, lineNode) or string. 
	-- Use CommonCtrl.MultiLineEditbox.OnContextMenuDefault for common copy and paste.  
	OnContextMenu = nil, 
	-- nil or the syntax highlighting map. Use CommonCtrl.MultiLineEditbox.syntax_map_NPL
	syntax_map = nil,
	onkeyup = nil,
	--+++++++++++++++++++
	AutoHorizontalScrollBar=false;
	HorizontalScrollBarHeight=20,
	--+++++++++++++++++++
}))

-- NPL syntax highlighting rules
MultiLineEditbox.syntax_map_NPL = {
	{"<", [[&lt;]]},
	{">", [[&gt;]]},
	{"\"", [[&quot;]]},
	{"'", [[&apos;]]},
	{"^(%s*)(function)(%W+.*)$", [[%1&fts;%2&fte;%3]]},
	{"^(%s*)(local)(%W+.*)$", [[%1&fts;%2&fte;%3]]},
	{"^(%s*)(if)([%s%(].*)$", [[%1&fts;%2&fte;%3]]},
	{"^(%s*)(elseif)([%s%(].*)$", [[%1&fts;%2&fte;%3]]},
	{"^(%s*)(else)(%s*)$", [[%1&fts;%2&fte;%3]]},
	{"^(%s*)(for)(%W+.*)$", [[%1&fts;%2&fte;%3]]},
	{"^(%s*)(return)(.*)$", [[%1&fts;%2&fte;%3]]},
	{"^(%s.*%s)(then)(%s*)$", [[%1&fts;%2&fte;%3]]},
	{"^(%s*)(end)(%s*)$", [[%1&fts;%2&fte;%3]]},
	{"\t", [[&nbsp;&nbsp;&nbsp;]]},
	{"^ ", [[&nbsp;]]},
	{" ", [[&#32;]]},
	{"&fts;", [[<span style="color:#0000CC">]]},
	{"&fte;", [[</span>]]},
	{"(%-%-.*)$", [[<span style="color:#00AA00">%1</span>]]},
}
-- pure text, just replace tab with space
MultiLineEditbox.syntax_map_PureText = {
	{"\t", [[   ]]}
}
---------------------------------------
-- public functions
---------------------------------------
--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function MultiLineEditbox:Show(bShow)
	CommonCtrl.TreeView.Show(self, bShow);
end

-- get line count of the text. 
function MultiLineEditbox:GetLineCount()
	return self.RootNode:GetChildCount();
end

-- set the text, we will reuse the treenode as necessary. 
function MultiLineEditbox:SetText(text, bForceNoUpdate)
	local line_text;	
	local i = 0;
	
	local currentLineCount = self.RootNode:GetChildCount();
	local breaker_text;
	for line_text, breaker_text in string.gfind(text or "", "([^\r\n]*)(\r?\n?)") do
		-- DONE: the current one will not ignore empty lines. such as \r\n\r\n. Empty lines are recognised.  
		if(breaker_text ~= "" or line_text~="") then
			i = i + 1;
			local lineNode;
			if(i<=currentLineCount) then
				lineNode = self.RootNode:GetChild(i);
				lineNode.Text = line_text
			else
				if(self.SingleLineEdit and i>1) then
					break;
				end
				self.RootNode:AddChild( CommonCtrl.TreeNode:new({Text = line_text}) );	
			end
		end	
	end
	
	-- remove additional lines. 
	if(currentLineCount>i) then
		self.RootNode:Resize(i);
	end

	if(self.empty_text) then
		local currentLineCount = self.RootNode:GetChildCount();
		if(currentLineCount == 0)then
			-- at least create one line
			self.RootNode:AddChild( CommonCtrl.TreeNode:new({Text = ""}));
		end
	end

	if(not bForceNoUpdate) then
		self:Update();
	end	
end

-- return the concartenated text
function MultiLineEditbox:GetText()
	local text="";
	local currentLineCount = self:GetLineCount();
	local i;
	for i = 1, currentLineCount do
		local line_text = self.RootNode:GetChild(i).Text;
		if(line_text and line_text ~= "") then
			if(self.WordWrap) then
				-- NOT TESTED
				line_text = string.gsub(line_text, "([^\r\n]+)", "%1");
				text = text..line_text;
			else
				text = text..line_text.."\r\n";
			end	
		else
			text = text.."\r\n"
		end
	end
	-- remove the last empty lines. \r\n
	text = string.gsub(text, "[\r\n]+$","");
	return text;
end

-------------------------------------------
-- below are all private functions: 
-------------------------------------------

-- draw each line treenode handler
function MultiLineEditbox.DrawNodeHandler(_parent, treeNode)
	if(_parent == nil or treeNode == nil) then
		return
	end
	local _this;
	local left = 2;
	local height = treeNode:GetHeight();
	
	-- line number
	if(treeNode.TreeView.ShowLineNumber) then
		_this=ParaUI.CreateUIObject("button",treeNode.TreeView.name..treeNode.index,"_lt",1,0,treeNode.TreeView.LineNumberWidth,height);
		_this.background = "Texture/whitedot.png";
		_guihelper.SetUIColor(_this, "192 192 192 128");
		_this.text = tostring(treeNode.index);
		_parent:AddChild(_this);
		left = left + treeNode.TreeView.LineNumberWidth;
	end
	-- text
	if(treeNode.Selected and not treeNode.TreeView.ReadOnly) then
		_parent.background = "Texture/alphadot.png"; -- high the selected line. 
		_parent.onmousedown="";
		_this=ParaUI.CreateUIObject("imeeditbox","s", "_fi",left,-1,0,-2);
		_this.text=treeNode.Text or "";	
		if(treeNode.TreeView.fontsize) then
			_this.font = format("System;%d;norm", treeNode.TreeView.fontsize);
		end
		_this.background = "";
		_this.onkeyup = string.format(";CommonCtrl.MultiLineEditbox.OnEditLineKeyUp(%q,%d)", treeNode.TreeView.name, treeNode.index);
		_this.onmodify = string.format(";CommonCtrl.MultiLineEditbox.OnLineModify(%q,%d)", treeNode.TreeView.name, treeNode.index);
		-- _this.onchange = string.format(";CommonCtrl.MultiLineEditbox.OnEditLineTextChange(%q,%d)", treeNode.TreeView.name, treeNode.index);
		if(treeNode.TreeView.OnContextMenu) then
			_this.onclick = string.format(";CommonCtrl.MultiLineEditbox.OnClick_private(%q,%d)", treeNode.TreeView.name, treeNode.index);
		end
		if(treeNode.TreeView.textcolor) then
			_guihelper.SetFontColor(_this, treeNode.TreeView.textcolor)
		end
		_parent:AddChild(_this);
		treeNode.editor_id = _this.id;
	else
		_parent.background = treeNode.TreeView.line_bg;
		if(not treeNode.TreeView.ReadOnly or treeNode.TreeView.OnContextMenu) then
			_parent.onmousedown=string.format(";CommonCtrl.MultiLineEditbox.OnClick_private(%q,%d,%d)", treeNode.TreeView.name, treeNode.index, 0);
		else
			_parent.onmousedown="";
		end	
		local text;
		if(treeNode.TreeView.empty_text and treeNode.index == 1 and (treeNode.TreeView:GetText() or "") == "") then
			text=treeNode.TreeView.empty_text;	
		else
			text=treeNode.Text;	
		end
		if(text and text~="") then
			
			local width = 1000
			if(treeNode.TreeView.SingleLineEdit) then
				height = treeNode.TreeView.height;
				if(treeNode.TreeView.WordWrap) then
					width = treeNode.TreeView.width - treeNode.TreeView.linetop_spacing * 2;
				end	
			end
			
			if(treeNode.TreeView.syntax_map) then
				-- render with syntax highlighting
				local mcmlText = treeNode.TreeView:GenTextMarkup(text);
				if(mcmlText) then
					if(treeNode.TreeView.fontsize) then
						mcmlText = string.format("<div style='font-size:%d;base-font-size:%d'>%s</div>", treeNode.TreeView.fontsize, treeNode.TreeView.fontsize, mcmlText);
					else
						mcmlText = string.format("<div>%s</div>", mcmlText);
					end
					
					--mcmlText = ParaMisc.EncodingConvert("", "HTML", mcmlText); -- format to html anscii code page
					local xmlNode = ParaXML.LuaXML_ParseString(mcmlText);
					--log(mcmlText.."\n")
					--commonlib.log(xmlNode)
					if(xmlNode) then
						NPL.load("(gl)script/kids/3DMapSystemApp/mcml/mcml_controls.lua");
						local xmlNode = Map3DSystem.mcml.buildclass(xmlNode);
						Map3DSystem.mcml_controls.create("s", xmlNode, nil, _parent, left+3, 0, width, height)
					end
				end
			else
				-- render WITHOUT syntax highlighting
				width = treeNode.TreeView.width - treeNode.TreeView.linetop_spacing * 2;
				_this=ParaUI.CreateUIObject("button", "s", "_lt",left+3,treeNode.TreeView.linetop_spacing,width,height-treeNode.TreeView.linetop_spacing);				
				_this.enabled = false;
				_this.background = "";
				_this.text = treeNode.TreeView:GenTextMarkup(text, MultiLineEditbox.syntax_map_PureText);
				-- single line, this causes it to blink at creation frame, perhaps a directx bug. 
				if(treeNode.TreeView.fontsize) then
					_this.font = format("System;%d;norm", treeNode.TreeView.fontsize);
				end
				if(treeNode.TreeView.WordWrap and treeNode.TreeView.SingleLineEdit) then
					-- wrap to first line. 
					_guihelper.SetUIFontFormat(_this, 16); 
				else
					_guihelper.SetUIFontFormat(_this, 36); 
				end
				if(treeNode.TreeView.textcolor) then
					_guihelper.SetFontColor(_this, treeNode.TreeView.textcolor)
				end
				_parent:AddChild(_this);
			end	
		end	
	end
end

function MultiLineEditbox.GetCtrlAndLineNode(sCtrlName, nLineIndex)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting IDE's MultiLineEditbox instance "..sCtrlName.."\r\n");
		return;
	end
	-- get the treeNode for the line. 
	local lineNode = self.RootNode:GetChild(nLineIndex);
	return self, lineNode;
end	

-- Set Caret Position
function MultiLineEditbox.SetCaretPosition(sCtrlName, nLineIndex,caretPosition)
	local self, lineNode = MultiLineEditbox.GetCtrlAndLineNode(sCtrlName, nLineIndex);
	if(lineNode) then
		-- if there is input, switch to the next line.
		if(self.SelectedNode) then
			-- save text to node.Text, in case it has changed. 
			local thisLine = ParaUI.GetUIObject(self.SelectedNode.editor_id);
			if(thisLine:IsValid()) then
				self.SelectedNode.Text = thisLine.text;
			end
		end	
		
		lineNode:SelectMe();
		-- update and auto scroll to position. 
		self:Update(nil, lineNode);
		local thisLine = ParaUI.GetUIObject(lineNode.editor_id);
		if(thisLine:IsValid())then
			thisLine:Focus();
			thisLine:SetCaretPosition(caretPosition);
		end
	end
end

-- when ever the line text changes. 
function MultiLineEditbox.OnEditLineTextChange(sCtrlName, nLineIndex)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting IDE's MultiLineEditbox instance "..sCtrlName.."\r\n");
		return;
	end
	
	-- get the treeNode for the line. 
	local lineNode = self.RootNode:GetChild(nLineIndex);
	if(not lineNode) then 
		log("line "..tostring(nLineIndex).." does not exist\n");
		return 
	end
	
	local thisLine = ParaUI.GetUIObject(lineNode.editor_id);
	if(thisLine:IsValid()) then
		lineNode.Text = thisLine.text;
	end	
end

-- the content of the edit box has changed, either from pasting or IME. 
-- this fixed a bug when GetText() does not return the current text when using pasting or IME. 
function MultiLineEditbox.OnLineModify(sCtrlName, nLineIndex)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting IDE's MultiLineEditbox instance "..sCtrlName.."\r\n");
		return;
	end
	-- get the treeNode for the line. 
	local lineNode = self.RootNode:GetChild(nLineIndex);
	if(not lineNode) then 
		log("line "..tostring(nLineIndex).." does not exist\n");
		return 
	end

	local thisLine = ParaUI.GetUIObject(lineNode.editor_id);
	if(thisLine:IsValid()) then
		if(lineNode.Text ~= thisLine.text) then
			lineNode.Text = thisLine.text;
			self.modified_since_keystroke = true;

			if(self.onchange and (type(self.onchange) == "function" ))then
				self:onchange();
			end
		end
	end
end

-- add to undo history
function MultiLineEditbox:AddToHistory()
	-- TODO: 
end

function MultiLineEditbox:Undo()
	-- TODO: 
end

function MultiLineEditbox:Redo()
	-- TODO: 
end

-- process user key strokes inside the editbox. 
function MultiLineEditbox.OnEditLineKeyUp(sCtrlName, nLineIndex)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting IDE's MultiLineEditbox instance "..sCtrlName.."\r\n");
		return;
	end
	if(self.onkeyup and (type(self.onkeyup) == "function" ))then
		self.onkeyup();
	end
	-- get the treeNode for the line. 
	local lineNode = self.RootNode:GetChild(nLineIndex);
	if(not lineNode) then 
		log("line "..tostring(nLineIndex).." does not exist\n");
		return 
	end
	
	local event = KeyEvent:init("keyPressedEvent");
	local keyname = event.keyname;

	local line_count = self:GetLineCount(); 
	if(keyname == "DIK_DOWN") then
		-- if the user pressed the down-arrow key, jump to the next line.
		if(nLineIndex < line_count) then
			local thisLine = ParaUI.GetUIObject(lineNode.editor_id);
			if(thisLine:IsValid()) then
				MultiLineEditbox.SetCaretPosition(sCtrlName, (nLineIndex+1), thisLine:GetCaretPosition());
			end	
		end
		
	elseif(keyname == "DIK_RETURN" ) then
		-- insert return key
		if(self.SingleLineEdit) then
			-- for single line, just deselect
			lineNode.Selected = false;
			self:Update();
		else
			self:ProcessLine(nLineIndex, 2);
			MultiLineEditbox.SetCaretPosition(sCtrlName, (nLineIndex+1), 0);	
		end
		
	elseif(keyname == "DIK_UP")	then
		-- if the user pressed the up-arrow key, jump to the previous line.
		if(nLineIndex >=2 ) then
			local thisLine = ParaUI.GetUIObject(lineNode.editor_id);
			if(thisLine:IsValid()) then
				MultiLineEditbox.SetCaretPosition(sCtrlName, (nLineIndex-1), thisLine:GetCaretPosition());
			end
		end
	elseif(event:IsKeySequence("Undo"))	then
		self:Undo();
	elseif(event:IsKeySequence("Redo"))	then
		self:Redo();
	elseif(keyname == "DIK_BACKSPACE" or keyname == "DIK_DELETE")	then
		local thisLine = ParaUI.GetUIObject(lineNode.editor_id);
		
		if(thisLine:IsValid()) then
			local thisCharPos = thisLine:GetCaretPosition();
			local thisLineCharCount = thisLine:GetTextSize();
			if(not self.modified_since_keystroke and lineNode.Text == "") then
				-- only delete the current line if it is already empty
				if(self:ProcessLine(nLineIndex, 5)) then
					self:Update();
				end
				if(keyname == "DIK_BACKSPACE") then
					-- move to the previous line, set caret at end of line (-1)
					if(nLineIndex >=2 ) then
						MultiLineEditbox.SetCaretPosition(sCtrlName, (nLineIndex-1), -1);
					end
				else
					local lineCount = self:GetLineCount();
					if( nLineIndex <= lineCount) then
						MultiLineEditbox.SetCaretPosition(sCtrlName, nLineIndex, 0);
					else
						MultiLineEditbox.SetCaretPosition(sCtrlName, lineCount, -1);
					end
				end
			elseif(not self.modified_since_keystroke and lineNode.Text == thisLine.text) then -- this ensure that the key does not change the text. 
				if(keyname == "DIK_BACKSPACE" and thisCharPos ==0) then
					-- backspace key when the caret is at beginning, and this line is not empty
					-- we need to concartinate this line with the previous one. 
					if(nLineIndex>=2) then
						-- calculate the caret position before concartination
						thisLine.text = self.RootNode:GetChild(nLineIndex-1).Text;
						local caretPos = thisLine:GetTextSize();
						-- setting to nil will mark the line to be deleted. 
						local oldtext = lineNode.Text;
						lineNode.Text = nil;
						self:ProcessLine(nLineIndex-1, 4, oldtext);
						MultiLineEditbox.SetCaretPosition(sCtrlName, (nLineIndex-1), caretPos);
					end	
				elseif(keyname == "DIK_DELETE" and thisCharPos ==thisLineCharCount) then
					-- delete key when the caret is at ending and this line is not empty
					-- we need to concartinate the next line to this line. 
					if(nLineIndex < line_count) then
						local caretPos = thisLine:GetCaretPosition();
						local nextLineNode = self.RootNode:GetChild(nLineIndex+1);
						if(nextLineNode) then
							local oldtext = nextLineNode.Text;
							-- setting to nil will mark the nextline to be deleted. 
							nextLineNode.Text = nil;
							if(self:ProcessLine(nLineIndex, 4, oldtext)) then
								local thisLine = ParaUI.GetUIObject(lineNode.editor_id);
								if(thisLine:IsValid()) then
									thisLine.text = lineNode.Text;
								end
							end
							MultiLineEditbox.SetCaretPosition(sCtrlName, nLineIndex, caretPos);
						end
					end	
				end
			else
				lineNode.Text = thisLine.text;
			end
		end
	else
		-- if there is input, switch to the next line.
		local thisLine = ParaUI.GetUIObject(lineNode.editor_id);
		if(thisLine:IsValid()) then
			lineNode.Text = thisLine.text;
		end
		if(self:ProcessLine(nLineIndex, 0, true)) then
			-- TODO: restore the caret position for the current line. 
			self:Update();
		end
	end	
	self.modified_since_keystroke = nil;
end

-- update the given line; if necessary, it will also update subsequent lines recursively.
-- @param nLineIndex: line index
-- @param command: 
--   0: update the line. If param1 is nil, it will not change the focus, otherwise change the focus if necessary.
--   1: prepend text(param1) to the given line
--   4: append text(param1) to the given line
--   2: insert return key at the current caret position.If param1 is nil, it will not change the focus, otherwise change the focus if necessary.
--   3: insert a new line of text(param1) at the current line
--   5: delete a given line
-- @return : return true if needs to update 
function MultiLineEditbox:ProcessLine(nLineIndex, command, param1)
	local bNeedUpdate;
	local thisLine = self.RootNode:GetChild(nLineIndex);
	if(thisLine or command == 3) then
		if(command == 0)then
			local oldtext = thisLine.Text;
			if(self.WordWrap) then
				-- TODO: for word wrapping
			else
				-- tricky: we will always look ahead one line. 
				local nextLine = self.RootNode:GetChild(nLineIndex+1);
				if(nextLine and not nextLine.Text) then
					bNeedUpdate = self:ProcessLine(nLineIndex+1, 5);
				end
				-- no word wrapping.  Find the first \r or \n in the text and move the rest to the next line
				local nFrom, nTo = string.find(oldtext, "[\r\n]+");
				if(nFrom~=nil) then
					if(nFrom>1) then
						thisLine.Text = string.sub(oldtext, 1, nFrom-1)
					else
						thisLine.Text = "";
					end
					-- insert text after \r\n to a new line below the current line. 
					bNeedUpdate = self:ProcessLine(nLineIndex+1, 3, string.sub(oldtext, nTo+1, -1));
				end
			end
			
		elseif(command == 1)then
			--   1: prepend text(param1) to the given line
			if(type(param1) == "string") then
				thisLine.Text = param1..thisLine.Text;
				bNeedUpdate = self:ProcessLine(nLineIndex, 0);
			end	
		elseif(command == 4)then
			--   1: append text(param1) to the given line
			if(type(param1) == "string") then
				thisLine.Text = thisLine.Text..param1;
				bNeedUpdate = self:ProcessLine(nLineIndex, 0);
			end
		elseif(command == 2)then
			--   2: insert return key at the current caret position.
			-- only break, if it is not the last line
			if(nLineIndex <= self:GetLineCount()) then
				local thisLineEditBox = ParaUI.GetUIObject(thisLine.editor_id);
				if(thisLineEditBox:IsValid()) then
					local oldtext = thisLine.Text;
					local CharCount = ParaMisc.GetUnicodeCharNum(oldtext); -- need a unicode version for Chinese characters.
					local CaretPos = thisLineEditBox:GetCaretPosition();
					if(CaretPos < (CharCount))then
						thisLine.Text = ParaMisc.UniSubString(oldtext, 1, CaretPos);
						thisLineEditBox.text = thisLine.Text
						local leftovertext = ParaMisc.UniSubString(oldtext, CaretPos+1,-1);
						bNeedUpdate = self:ProcessLine(nLineIndex+1, 3, leftovertext);
					else
						bNeedUpdate = self:ProcessLine(nLineIndex+1, 3, "");	
					end
				end	
			end	
		elseif(command == 3)then
			--   3: insert a new line of text(param1) at the current line
			if(self.max_lines and self.max_lines>nLineIndex) then
				log("warning: multiline editbox exceed max line allowed\n");
			elseif(self.SingleLineEdit) then
			else
				if(nLineIndex <= self:GetLineCount()) then
					self.RootNode:AddChild( CommonCtrl.TreeNode:new({Text = param1}), nLineIndex);	
				else
					-- append at the end
					self.RootNode:AddChild( CommonCtrl.TreeNode:new({Text = param1}));	
				end	
				self:ProcessLine(nLineIndex, 0);
				bNeedUpdate = true;
			end
		elseif(command == 5)then
			--   5: delete a given line
			if(nLineIndex > 1 or (nLineIndex==1 and self:GetLineCount() > 1) ) then
				thisLine:Detach();
				bNeedUpdate = true;
			end	
		else
			-- TODO: 
		end
	end
	return bNeedUpdate
end

-- private: user click. call the user handler if any. 
function MultiLineEditbox.OnClick_private(sCtrlName, nLineIndex, nCaretPos)
	if(mouse_button=="left") then
		if(nCaretPos) then
			MultiLineEditbox.SetCaretPosition(sCtrlName, nLineIndex, nCaretPos)
		end
	elseif(mouse_button=="right") then
		local self, lineNode = MultiLineEditbox.GetCtrlAndLineNode(sCtrlName, nLineIndex);
		if(lineNode) then
			if(type(lineNode.TreeView.OnContextMenu) == "string") then
				NPL.DoString(lineNode.TreeView.OnContextMenu);
			elseif(type(lineNode.TreeView.OnContextMenu) == "function") then
				lineNode.TreeView.OnContextMenu(self, lineNode);
			end
		end
	end
end	

-- called when user clicks the empty space to begin editing
function MultiLineEditbox.onmouseup_parent(self)
	local currentLineCount = self.RootNode:GetChildCount();
	if(currentLineCount == 0)then
		-- at least create one line
		self.RootNode:AddChild( CommonCtrl.TreeNode:new({Text = ""}));
	end
	MultiLineEditbox.SetCaretPosition(self.name, 1, 0)
end

-- generate the markup text to display text with syntax highlighting (using mcml). 
function MultiLineEditbox:GenTextMarkup(text, map)
	map = map or self.syntax_map
	if(text and map) then
		local i,v;
		for i,v in ipairs(map) do
			text = string.gsub(text, v[1], v[2]);
		end
	end	
	return text;
end

-- TODO: default context menu handler
function MultiLineEditbox.OnContextMenuDefault(self, lineNode)
	local ctl = CommonCtrl.GetControl(self.name.."ContextMenu");
	if(not ctl)then
		ctl = CommonCtrl.ContextMenu:new{
			name = self.name.."ContextMenu",
			width = 130,
			height = 150,
			container_bg = "Texture/3DMapSystem/ContextMenu/BG2.png:8 8 8 8",
		};
	end
	ctl.RootNode:ClearAllChildren();
	ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "cut", Name = "cut", onclick = function ()
	end});
	ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "copy", Name = "copy", onclick = function ()
	end});
	ctl.RootNode:AddChild(CommonCtrl.TreeNode:new{Text = "paste", Name = "paste", onclick = function ()
	end});
	ctl:Show();
end
-- get the max width from existed nodes
function MultiLineEditbox:GetMaxWidth(existNodeList,treeViewWidth,nodeWidth)
    --在多层节点时使用
	--if(existNodeList==nil)then return end
	--local temp={};
	--for nodePath,v in  existNodeList do	
		----log(string.format("%s,%s\n",nodePath,v));
		--local node=self:GetNodeByPath(nodePath);
		--local level=node.Level;
		--table.insert(temp,level);
		----log(string.format("%s,%s\n",nodePath,level));
	--end	
	--if(existNodeList)then
		--table.sort(temp,function (a,b)return tonumber(a)>tonumber(b) ; end);
	--end	
	--local left,level=2,temp[1];	
	--if(level==nil)then level=0; end
	----left = left + self.DefaultIndentation*level ;
	--left=left+nodeWidth-treeViewWidth;		
	--return left;
	
	----
	local count = ParaMisc.GetUnicodeCharNum(oldtext); -- need a unicode version for Chinese characters.
	if(existNodeList==nil)then return end
	local temp={};
	for nodePath,v in  existNodeList do	
		local node=self:GetNodeByPath(nodePath);
		local count=ParaMisc.GetUnicodeCharNum(node.Text)
		table.insert(temp,count);
	end	
	if(existNodeList)then
		table.sort(temp,function (a,b)return tonumber(a)>tonumber(b) ; end);
	end	
	local maxCount=temp[1];
	local maxWith=0;
	if(maxCount)then maxWith=maxCount*5; end
	maxWith=self.LineNumberWidth+maxWith;
	return maxWith;
end
-- ++++++++++++++++++++++
-- override parent method
function MultiLineEditbox:CreatHorizontalScrollBar(existNodeList)
	
		if(self.AutoHorizontalScrollBar)then			
			local _this=ParaUI.GetUIObject("MultiLineEditbox.HScrollBar");	
			local _parent = ParaUI.GetUIObject(self.name);	
			local _,_, TreeViewWidth,TreeViewHeight = _parent:GetAbsPosition();	
			
			local MaxNodeWidth=self:GetMaxWidth(existNodeList,TreeViewWidth,self.NodeWidth);
			
			--log(string.format("Max:%s,%s\n",MaxNodeWidth,TreeViewWidth));
			if(MaxNodeWidth> TreeViewWidth) then	
					local left=0;
					local top=TreeViewHeight-self.HorizontalScrollBarHeight;
					local width=TreeViewWidth;
					if(self.RootNode.LogicalBottom>TreeViewHeight and self.AutoVerticalScrollBar )then
						width=width-self.VerticalScrollBarWidth;
					end
					local height=self.HorizontalScrollBarHeight;
				if(not _this:IsValid())then				
					_this=ParaUI.CreateUIObject("slider","MultiLineEditbox.HScrollBar","_lt",left,top,width,height);
					_parent:AddChild(_this);	
								
					_this.value=0;
					_this.onchange=string.format(";CommonCtrl.MultiLineEditbox.OnHScrollBarChanged(%q)", self.name);				
					self.ClientHeight = TreeViewHeight - self.HorizontalScrollBarHeight;
				end	
					if(_this.visible==false)then _this.visible=true; end
					_this:SetTrackRange(0,MaxNodeWidth-TreeViewHeight);
				
			else
				self.ClientHeight = TreeViewHeight;
				if(_this:IsValid())then
					self.ClientX =0;
					_this.visible=false;
				end
			end
	  end
end
-- ++++++++++++++++++++++
function MultiLineEditbox.OnHScrollBarChanged(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting TreeView_Test instance "..sCtrlName.."\r\n");
		return;
	end
	local _parent = ParaUI.GetUIObject(self.name);
	if(not _parent:IsValid()) then
		log("error getting Tree View parent\n");
		return
	end
	
	local tmp = _parent:GetChild("MultiLineEditbox.HScrollBar");
	if(tmp:IsValid()) then
		self.ClientX = tmp.value;
		self:RefreshUI();
	end
end
