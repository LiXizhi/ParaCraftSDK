--[[
Title: OBSOLETED use MultiLineEditbox: multiline editbox from a collection of single line editbox
Author(s): LiXizhi
Date: 2007/2/7
Note: if you use an auto strench alignment, auto strench is only enabled on creation. which means that if one change the window size after creation, it does not work out as expected.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/MultiLineEditbox.lua");
local ctl = CommonCtrl.MultiLineEditbox:new{
	name = "MultiLineEditbox1",
	alignment = "_lt",
	left=0, top=0,
	width = 256,
	height = 90,
	line_count = 3,
	parent = nil,
};
ctl:Show(true);
-------------------------------------------------------
]]

-- common control library
NPL.load("(gl)script/ide/common_control.lua");

-- define a new control in the common control libary

-- default member attributes
local MultiLineEditbox = {
	-- the top level control name
	name = "MultiLineEditbox1",
	-- normal window size
	alignment = "_lt",
	left = 0,
	top = 0,
	width = 512,
	height = 290, 
	textwidth = nil, 
	WordWrap = true,
	line_count = 3,
	line_height = 26,
	line_spacing = 2,
	parent = nil,
	-- appearance
	main_bg = "Texture/EBook/text_bg.png",
	editbox_bg = "Texture/EBook/line.png",
}
CommonCtrl.MultiLineEditbox = MultiLineEditbox;

-- constructor
function MultiLineEditbox:new (o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Destroy the UI control
function MultiLineEditbox:Destroy ()
	ParaUI.Destroy(self.name);
end

--@param bShow: boolean to show or hide. if nil, it will toggle current setting. 
function MultiLineEditbox:Show(bShow)
	local _this,_parent;
	if(self.name==nil)then
		log("MultiLineEditbox instance name can not be nil\r\n");
		return
	end
	
	_this=ParaUI.GetUIObject(self.name);
	if(_this:IsValid() == false) then
		if(bShow == false) then return	end
		bShow = true;
		
		_this=ParaUI.CreateUIObject("container",self.name,self.alignment,self.left,self.top,self.width,self.height);
		_this.background=self.main_bg;
		-- note: uncomment the following line to enable auto scrolling. It does not work correctly at the moment.
		--if( (self.line_height+self.line_spacing)*self.line_count > self.height ) then
			--_this.scrollable = true;
		--end
		_parent = _this;
		
		if(self.parent==nil) then
			_this:AttachToRoot();
		else
			self.parent:AddChild(_this);
		end
		CommonCtrl.AddControl(self.name, self);

		local _,_, absWidth, absHeight = _parent:GetAbsPosition();
		if(not self.textwidth) then
			self.textwidth = absWidth - self.line_spacing*2-12;
		end
		-- item count
		local i;
		for i=0, self.line_count-1 do
			_this=ParaUI.CreateUIObject("imeeditbox",self.name.."EditBoxLine"..(i+1),"_mt",self.line_spacing,i*(self.line_height+self.line_spacing), self.line_spacing, self.line_height);
			_this.onkeyup=string.format([[;CommonCtrl.MultiLineEditbox.OnText("%s", %d);]], self.name, i+1);
			_this.background=self.editbox_bg;
			_parent:AddChild(_this);
		end
	else
		if(bShow == nil) then
			bShow = (_this.visible == false);
		end
		_this.visible = bShow;
	end	
end

-- close the given control
function MultiLineEditbox.OnClose(sCtrlName)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting MultiLineEditbox instance "..sCtrlName.."\r\n");
		return;
	end
	ParaUI.Destroy(self.name);
end

-- called when the text changes
function MultiLineEditbox.OnText(sCtrlName, nLineIndex)
	local self = CommonCtrl.GetControl(sCtrlName);
	if(self==nil)then
		log("error getting MultiLineEditbox instance "..sCtrlName.."\r\n");
		return;
	end
	if(virtual_key == Event_Mapping.EM_KEY_DOWN) then
		-- if the user pressed the enter key, change to the next line.
		if(nLineIndex < self.line_count) then
			local nextLine = ParaUI.GetUIObject(self.name.."EditBoxLine"..(nLineIndex+1));
			local thisLine = ParaUI.GetUIObject(self.name.."EditBoxLine"..nLineIndex);
			if(thisLine:IsValid() and nextLine:IsValid()) then
				nextLine:Focus();
				nextLine:SetCaretPosition(thisLine:GetCaretPosition());
			end	
			ParaUI.GetUIObject(self.name.."EditBoxLine"..(nLineIndex+1)):Focus();
		end
	elseif(virtual_key == Event_Mapping.EM_KEY_RETURN or virtual_key == Event_Mapping.EM_KEY_NUMPADENTER ) then
		-- insert return key
		self:ProcessLine(nLineIndex, 2, true);
	elseif(virtual_key == Event_Mapping.EM_KEY_UP)	then
		-- if the user pressed the up key, change to the previous line.
		if(nLineIndex >=2 ) then
			local lastLine = ParaUI.GetUIObject(self.name.."EditBoxLine"..(nLineIndex-1));
			local thisLine = ParaUI.GetUIObject(self.name.."EditBoxLine"..nLineIndex);
			if(thisLine:IsValid() and lastLine:IsValid()) then
				lastLine:Focus();
				lastLine:SetCaretPosition(thisLine:GetCaretPosition());
			end	
		end
	elseif(virtual_key == Event_Mapping.EM_KEY_BACKSPACE or virtual_key == Event_Mapping.EM_KEY_DELETE)	then	
		
		local thisLine = ParaUI.GetUIObject(self.name.."EditBoxLine"..nLineIndex);
		if(thisLine:IsValid()) then
			local thisCharPos = thisLine:GetCaretPosition();
			local thisLineCharCount = thisLine:GetTextSize();
			if(thisLine.text == "") then
				-- only delete the current line if it is already empty
				self:ProcessLine(nLineIndex, 5);
				if(virtual_key == Event_Mapping.EM_KEY_BACKSPACE) then
					-- move to the previous line
					if(nLineIndex >=2 ) then
						local lastLine = ParaUI.GetUIObject(self.name.."EditBoxLine"..(nLineIndex-1));
						if(lastLine:IsValid()) then
							lastLine:Focus();
							lastLine:SetCaretPosition(-1);
						end	
					end	
				end
			else
				if(virtual_key == Event_Mapping.EM_KEY_BACKSPACE and thisCharPos ==0) then
					-- backspace key when the caret is at beginning.
					if(nLineIndex>=2) then
						local lastLine = ParaUI.GetUIObject(self.name.."EditBoxLine"..(nLineIndex-1));
						if(lastLine:IsValid()) then
							local caretPos = lastLine:GetTextSize();
							local oldtext = thisLine.text;
							thisLine.text = "";
							self:ProcessLine(nLineIndex-1, 4, oldtext);
							lastLine:SetCaretPosition(caretPos);
							lastLine:Focus();
						end
					end	
				elseif(virtual_key == Event_Mapping.EM_KEY_DELETE and thisCharPos ==thisLineCharCount) then
					-- delete key when the caret is at ending.
					if(nLineIndex < self.line_count) then
						local nextLine = ParaUI.GetUIObject(self.name.."EditBoxLine"..(nLineIndex+1));
						if(nextLine:IsValid()) then
							local caretPos = thisLine:GetCaretPosition();
							local oldtext = nextLine.text;
							nextLine.text = "";
							self:ProcessLine(nLineIndex, 4, oldtext);
							thisLine:SetCaretPosition(caretPos);
						end
					end	
				end
			end
		end
	else
		-- if there is input, switch to the next line.
		-- GetFirstVisibleCharIndex	
		self:ProcessLine(nLineIndex, 0, true);
	end	
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
function MultiLineEditbox:ProcessLine(nLineIndex, command, param1)
	local thisLine = ParaUI.GetUIObject(self.name.."EditBoxLine"..nLineIndex);
	if(thisLine:IsValid()) then
		if(command == 0)then
			local oldtext = thisLine.text;
			
			if(self.WordWrap) then
				-- for word wrapping
				local nCharsCount = thisLine:GetTextSize();
				local nTrailPos = nCharsCount;
				
				if(nTrailPos>0) then
					-- find the last word position that can be displayed within self.textwidth
					while true do
						local x,y = thisLine:CPtoXY(nTrailPos, true, 0,0);
						if(x<=self.textwidth or x==0) then
							break;
						end
						local nTestTrailPos = thisLine:GetPriorWordPos(nTrailPos, 0);
						
						--log(string.format("trailpos=%s, testPriorWordPos=%s, charcount = %s\r\n", nTrailPos, nTestTrailPos, nCharsCount))
						x=0;
						if(nTestTrailPos<nTrailPos) then
							if(nTestTrailPos == 0) then
								nTrailPos = nCharsCount;
								break;
							end
						else
							if(nTestTrailPos == 0) then
								nTrailPos = nCharsCount;
							end
							break;
						end
						
						-- if the last word has trailing space characters, just regard each space as a word and try again.
						local wordTextLastChar = ParaMisc.UniSubString(oldtext, nTrailPos, nTrailPos);
						--log(string.format("wordTextLastChar = %s oldtext = <%s>\r\n", tostring(wordTextLastChar), oldtext))
						if(wordTextLastChar == " ") then
							nTrailPos = nTrailPos -1;
						else
							nTrailPos = nTestTrailPos;	
						end	
					end	
				end
				
				-- if the line is full, break to the next line
				if(nTrailPos<nCharsCount) then
					-- only break, if it is not the last line
					if(nLineIndex < self.line_count) then
						local CharCount = ParaMisc.GetUnicodeCharNum(oldtext); -- need a unicode version for Chinese characters.
						local oldCaretPosThisLine = thisLine:GetCaretPosition();
						thisLine.text = ParaMisc.UniSubString(oldtext, 1, nTrailPos);
						local leftovertext = ParaMisc.UniSubString(oldtext, nTrailPos+1,-1);
						
						self:ProcessLine(nLineIndex+1, 1, leftovertext);
						
						if(param1) then
							local newSize = thisLine:GetTextSize();
							if(oldCaretPosThisLine >= newSize) then
								local nextline = ParaUI.GetUIObject(self.name.."EditBoxLine"..(nLineIndex+1));
								if(nextline:IsValid()) then
									nextline:Focus();
									nextline:SetCaretPosition(oldCaretPosThisLine-nTrailPos);
								end	
							else
								thisLine:SetCaretPosition(oldCaretPosThisLine);
							end	
						end	
					end	
				end
			else
				-- no word wrapping.  Find the first \r or \n in the text and move the rest to the next line
				local nFrom, nTo = string.find(oldtext, "[\r\n]+");
				if(nFrom~=nil) then
					if(nFrom>1) then
						thisLine.text = string.sub(oldtext, 1, nFrom-1)
					else
						thisLine.text = "";
					end	
					self:ProcessLine(nLineIndex+1, 1, string.sub(oldtext, nTo+1, -1));
				end
			end
			
		elseif(command == 1)then
			--   1: prepend text(param1) to the given line
			if(type(param1) == "string") then
				thisLine.text = param1..thisLine.text;
				--thisLine:SetCaretPosition(-1); -- this is tricky: set caret to the end of the string for firstCharIndex updating
				self:ProcessLine(nLineIndex, 0);
			end	
		elseif(command == 4)then
			--   1: append text(param1) to the given line
			if(type(param1) == "string") then
				thisLine.text = thisLine.text..param1;
				self:ProcessLine(nLineIndex, 0);
			end
		elseif(command == 2)then
			--   2: insert return key at the current caret position.
			-- only break, if it is not the last line
			if(nLineIndex < self.line_count) then
				if(param1) then
					ParaUI.GetUIObject(self.name.."EditBoxLine"..(nLineIndex+1)):Focus();
				end	
				local oldtext = thisLine.text;
				local CharCount = ParaMisc.GetUnicodeCharNum(oldtext); -- need a unicode version for Chinese characters.
				local CaretPos = thisLine:GetCaretPosition();
				if(CaretPos < (CharCount))then
					thisLine.text = ParaMisc.UniSubString(oldtext, 1, CaretPos);
					local leftovertext = ParaMisc.UniSubString(oldtext, CaretPos+1,-1);
					self:ProcessLine(nLineIndex+1, 3, leftovertext);
				else
					self:ProcessLine(nLineIndex+1, 3, "");	
				end
			end	
		elseif(command == 3)then
			--   3: insert a new line of text(param1) at the current line
			if(nLineIndex < self.line_count) then
				if(type(param1) == "string") then
					local oldtext = thisLine.text;
					thisLine.text = param1;
					self:ProcessLine(nLineIndex+1, 3, oldtext);
				end	
			else
				if(type(param1) == "string") then
					thisLine.text = param1..thisLine.text;
				end	
			end
		elseif(command == 5)then
			--   5: delete a given line
			local i;
			for i = nLineIndex, self.line_count-1 do
				ParaUI.GetUIObject(self.name.."EditBoxLine"..i).text = ParaUI.GetUIObject(self.name.."EditBoxLine"..(i+1)).text;
			end
			ParaUI.GetUIObject(self.name.."EditBoxLine"..self.line_count).text = ""
		else
			-- TODO: 
		end
	end
end

-- set the text
function MultiLineEditbox:SetText(text)
	local line_text;
	local i = 1;
	for line_text in string.gfind(text, "([^\r\n]+)") do
		if(i<=self.line_count) then
			ParaUI.GetUIObject(self.name.."EditBoxLine"..i).text = line_text;
			i=i+1;
		else
			break
		end
	end
	local k;
	for k=i,self.line_count do
		ParaUI.GetUIObject(self.name.."EditBoxLine"..k).text = "";
	end
end

-- return the concartenated text
function MultiLineEditbox:GetText()
	local text="";
	local i;
	for i = 1, self.line_count do
		local line_text = ParaUI.GetUIObject(self.name.."EditBoxLine"..i).text;
		if(line_text ~= nil and line_text ~= "") then
			if(self.WordWrap) then
				line_text = string.gsub(line_text, "([^\r\n]+)", "%1");
				text = text..line_text;
			else
				text = text..line_text.."\r\n";
			end	
		else
			if(i<self.line_count) then
				text = text.."\n"
			end	
		end
	end
	--log(text.." gettext\r\n"..self.line_count.." numbers\r\n")
	return text;
end
