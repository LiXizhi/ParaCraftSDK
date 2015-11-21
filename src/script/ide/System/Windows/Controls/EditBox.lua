--[[
Title: EditBox
Author(s): LiXizhi
Date: 2015/5/26
Desc: a one-line plain text editor.

Reference: qlineedit widget in QT framework.

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/Controls/EditBox.lua");
local EditBox = commonlib.gettable("System.Windows.Controls.EditBox");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Windows/UIElement.lua");
NPL.load("(gl)script/ide/System/Core/UniString.lua");
NPL.load("(gl)script/ide/math/Rect.lua");
local Rect = commonlib.gettable("mathlib.Rect");
local UniString = commonlib.gettable("System.Core.UniString");
local Application = commonlib.gettable("System.Windows.Application");
local FocusPolicy = commonlib.gettable("System.Core.Namespace.FocusPolicy");
local EditBox = commonlib.inherit(commonlib.gettable("System.Windows.UIElement"), commonlib.gettable("System.Windows.Controls.EditBox"));
EditBox:Property("Name", "EditBox");
EditBox:Property({"Background", "", auto=true});
EditBox:Property({"BackgroundColor", "#cccccc", auto=true});
EditBox:Property({"m_text", nil, "GetText", "SetText"})
EditBox:Property({"Color", "#000000", auto=true})
EditBox:Property({"CursorColor", "#33333388", auto=true})
EditBox:Property({"SelectedBackgroundColor", "#00006680", auto=true})
EditBox:Property({"m_placeholderText", "", "placeholderText", "setPlaceholderText"})
EditBox:Property({"m_echoMode", "Normal", "echoMode", "setEchoMode"})
EditBox:Property({"m_cursor", 0, "cursorPosition", "setCursorPosition"})
EditBox:Property({"cursorVisible", false, "isCursorVisible", "setCursorVisible"})
EditBox:Property({"m_cursorWidth", 2,})
EditBox:Property({"m_maxLength", 65535, "getMaxLength", "setMaxLength", auto=true})
EditBox:Property({"m_readOnly", false, "isReadOnly", "setReadOnly"})
EditBox:Property({"m_blinkPeriod", 0, "getCursorBlinkPeriod", "setCursorBlinkPeriod"})
EditBox:Property({"Font", "System;14;norm", auto=true})
EditBox:Property({"Scale", nil, "GetScale", "SetScale", auto=true})
EditBox:Property({"horizontalMargin", 0});
EditBox:Property({"leftTextMargin", 0});
EditBox:Property({"topTextMargin", 2});
EditBox:Property({"rightTextMargin", 0});
EditBox:Property({"bottomTextMargin", 2});

EditBox:Signal("resetInputContext");
EditBox:Signal("selectionChanged");
EditBox:Signal("cursorPositionChanged", function(oldPos, newPos) end);
EditBox:Signal("textChanged");
EditBox:Signal("textEdited");
EditBox:Signal("accepted");
EditBox:Signal("editingFinished");
EditBox:Signal("updateNeeded");

-- private
EditBox.m_modifiedState = 0;
EditBox.m_undoState = 0;
EditBox.m_selend = 0;
EditBox.m_selstart = 0;
EditBox.hscroll = 0;
EditBox.vscroll = 0;


 -- undo/redo handling
local Command = commonlib.inherit(nil, {});
--@param t: Separator, Insert, Remove, Delete, RemoveSelection, DeleteSelection, SetSelection
function Command:init(cmd_type, pos, str, select_start, select_end)
    self.type = cmd_type;
    self.uc = str;
    self.pos = pos;
	self.selStart = select_start;
	self.selEnd = select_end;
	return self;
end

function EditBox:ctor()
	self.m_text = UniString:new();
	self.m_history = commonlib.Array:new();
	self:setFocusPolicy(FocusPolicy.StrongFocus);
	self:setAttribute("WA_InputMethodEnabled");
	self:setMouseTracking(true);
end

function EditBox:isReadOnly()
	return self.m_readOnly;
end

function EditBox:setReadOnly(bReadOnly)
	self.m_readOnly = bReadOnly;
	if (bReadOnly) then
        self:setCursorBlinkPeriod(0);
    else
        self:setCursorBlinkPeriod(Application:cursorFlashTime());
	end
end

function EditBox:GetText()
	return self.m_text:GetText();
end

-- Setting this property clears the selection, clears the undo/redo
-- history, moves the cursor to the end of the line and resets the
-- modified property to false. The text is not validated when inserted with setText().
function EditBox:SetText(txt)
	self:internalSetText(txt or "", -1, false);
end

function EditBox:internalSetText(txt, pos, edited)
	self:resetInputContext();
	local oldText = self.m_text;
	self.m_text:SetText(UniString.left(txt, self.m_maxLength));
	
	self.m_history:clear();
	self.m_modifiedState = 0;
	self.m_undoState = 0;
	local text_len = self.m_text:length();
	self.m_cursor = if_else(pos < 0 or pos > text_len, text_len, pos);
	self.m_textDirty = (tostring(oldText) ~= tostring(self.m_text));
	self:finishChange(-1, true, edited);
end

-- private: Adds the given command to the undo history
-- of the line control.  Does not apply the command.
function EditBox:addCommand(cmd)
    if (self.m_separator and self.m_undoState>0 and self.m_history[self.m_undoState].type ~= "Separator") then
		self.m_history:resize(self.m_undoState + 2);
		self.m_undoState = self.m_undoState + 1;
        self.m_history[self.m_undoState] = Command:new():init("Separator", self.m_cursor, "", self.m_selstart, self.m_selend);
	else
		self.m_history:resize(self.m_undoState + 1);
    end
    self.m_separator = false;
	self.m_undoState = self.m_undoState + 1;
    self.m_history[self.m_undoState] = cmd;
end

function EditBox:placeholderText()
    return self.m_placeholderText;
end

function EditBox:shouldShowPlaceholderText()
    return self:GetText() == "" and self:hasFocus();
end

function EditBox:setPlaceholderText(placeholderText)
    if (self.m_placeholderText ~= placeholderText) then
        self.m_placeholderText = placeholderText;
        if (self:shouldShowPlaceholderText()) then
            self:Update();
		end
    end
end

function EditBox:displayText()
	return self:GetText();
end


function EditBox:echoMode()
    return self.m_echoMode;
end


function EditBox:setEchoMode(mode)
	if(self.m_echoMode == mode) then
		return;
	end
    self.m_echoMode = mode;
	self:Update();
end


-- the current cursor position for this line edit. default to 0
function EditBox:cursorPosition()
    return self.m_cursor;
end

function EditBox:setCursorPosition(pos)
	if(pos <= self.m_text:length()) then
		self:moveCursor(math.max(0,pos));
	end
end

function EditBox:commitPreedit()
end

function EditBox:separate()
	self.m_separator = true;
end

function EditBox:updateDisplayText()
	
end

function EditBox:internalDeselect()
	self.m_selDirty = self.m_selDirty or (self.m_selend > self.m_selstart);
    self.m_selstart = 0;
	self.m_selend = 0;
end

-- private: Moves the cursor to the given position pos.  If mark is true will adjust the currently selected text.
function EditBox:moveCursor(pos, mark)
    self:commitPreedit();

    if (pos ~= self.m_cursor) then
        self:separate();
	end
    if (mark) then
        local anchor;
        if (self.m_selend > self.m_selstart and self.m_cursor == self.m_selstart) then
            anchor = self.m_selend;
        elseif (self.m_selend > self.m_selstart and self.m_cursor == self.m_selend) then
            anchor = self.m_selstart;
        else
            anchor = self.m_cursor;
		end
        self.m_selstart = math.min(anchor, pos);
        self.m_selend = math.max(anchor, pos);
    else
        self:internalDeselect();
    end
    self.m_cursor = pos;
	self:updateDisplayText();

    if (mark or self.m_selDirty) then
        self.m_selDirty = false;
        self:selectionChanged();
    end
    self:emitCursorPositionChanged();
end

function EditBox:removeSelectedText()
	if (self.m_selstart < self.m_selend and self.m_selend <= self.m_text:length()) then
		self:separate();
		self:addCommand(Command:new():init("SetSelection", self.m_cursor, "", self.m_selstart, self.m_selend));
		if (self.m_selstart <= self.m_cursor and self.m_cursor < self.m_selend) then
            -- cursor is within the selection. Split up the commands
            -- to be able to restore the correct cursor position
            for i = self.m_cursor, self.m_selstart, -1 do
                self:addCommand(Command:new():init("DeleteSelection", i, self.m_text:at(i+1), -1, 1));
			end
            for i = self.m_selend-1, self.m_cursor + 1, -1 do
                self:addCommand(Command:new():init("DeleteSelection", i - self.m_cursor + self.m_selstart - 1, self.m_text:at(i+1), -1, -1));
			end
        else
            for i = self.m_selend-1, self.m_selstart, -1 do
                self:addCommand(Command:new():init("RemoveSelection", i, self.m_text:at(i+1), -1, -1));
			end
        end
		self.m_text:remove(self.m_selstart+1, self.m_selend - self.m_selstart);
        
        if (self.m_cursor > self.m_selstart) then
            self.m_cursor = self.m_cursor - math.min(self.m_cursor, self.m_selend) - self.m_selstart;
		end
        self:internalDeselect();
        self.m_textDirty = true;
	end
end

function EditBox:selectedText()
	if(self:hasSelectedText()) then
		return self.m_text:substr(self.m_selstart+1, self.m_selend);
	end
end

function EditBox:hasSelectedText() 
	return not self.m_text:empty() and self.m_selend > self.m_selstart;
end

function EditBox:internalInsert(s)
	s = UniString:new(s);
	if (self:hasSelectedText()) then
        self:addCommand(Command:new():init("SetSelection", self.m_cursor, nil, self.m_selstart, self.m_selend));
	end

	local remaining = self.m_maxLength - self.m_text:length();
    if (remaining > 0) then
		s = s:left(remaining);
        self.m_text:insert(self.m_cursor, s);
        for i = 1, s:length() do
            self:addCommand(Command:new():init("Insert", self.m_cursor, s[i], -1, -1));
			self.m_cursor = self.m_cursor + 1;
		end
        self.m_textDirty = true;
    end
end

-- deletes a single character from the current text.  If wasBackspace,
-- the character prior to the cursor is removed.  Otherwise the character after the cursor is removed.
function EditBox:internalDelete(wasBackspace)
	if (self.m_cursor < self.m_text:length()) then
        if (self:hasSelectedText()) then
            self:addCommand(Command:new():init("SetSelection", self.m_cursor, "", self.m_selstart, self.m_selend));
		end
        self:addCommand(Command:new():init(if_else(wasBackspace, "Remove", "Delete"),
                   self.m_cursor, self.m_text[self.m_cursor+1], -1, -1));
		self.m_text:remove(self.m_cursor+1, 1);
        self.m_textDirty = true;
    end
end

function EditBox:backspace()
    local priorState = m_undoState;
    if (self:hasSelectedText()) then
        self:removeSelectedText();
    elseif (self.m_cursor > 0) then
        self.m_cursor = self.m_cursor - 1;
        self:internalDelete(true);
    end
    self:finishChange(priorState);
end

function EditBox:inputMethodEvent(event)
	if(self:isReadOnly()) then
		event:ignore();
		return;
	end

	local commitString = event:commitString();
	-- echo({string.byte(commitString, 1), string.byte(commitString, 2)});

	local char1 = string.byte(commitString, 1);
	if(char1 <= 31) then
		-- ignore control characters
		event:ignore();
		return;
	end
	
	local priorState = -1;
    local isGettingInput = commitString ~= "";
    local cursorPositionChanged = false;
    
    if (isGettingInput) then
        -- If any text is being input, remove selected text.
        priorState = self.m_undoState;
        self:removeSelectedText();
    end

    local c = self.m_cursor; -- cursor position after insertion of commit string
    if (event:replacementStart() <= 0) then
        c = c + ParaMisc.GetUnicodeCharNum(commitString) - math.min(-event:replacementStart(), event:replacementLength());
	end

    self.m_cursor = self.m_cursor + event:replacementStart();
    if (self.m_cursor < 0) then
        self.m_cursor = 0;
	end

    -- insert commit string
    if (event:replacementLength() > 0) then
        self.m_selstart = self.m_cursor;
        self.m_selend = self.m_selstart + event:replacementLength();
        self:removeSelectedText();
    end
    if (commitString~="") then
        self:internalInsert(commitString);
        cursorPositionChanged = true;
    end

	local textCharNum = self.m_text:length();
    self.m_cursor = math.max(0, math.min(c, textCharNum));

	self:updateDisplayText(true);
    if (cursorPositionChanged) then
        self:emitCursorPositionChanged();
	end

    if (isGettingInput) then
        self:finishChange(priorState);
	end
end

-- Completes a change to the line control text.  If the change is not valid
-- will undo the line control state back to the given validateFromState.
-- @param edited: default to true. whether it is edited by user. default to true.
function EditBox:finishChange(validateFromState, update, edited)
	validateFromState = validateFromState or -1;
	edited = edited ~= false;

	if(self.m_textDirty) then
		-- TODO: do text validation and rollback text if failed
		self:updateDisplayText();

		if (self.m_textDirty) then
            self.m_textDirty = false;
            local actualText = self:GetText();
            if (edited) then
                self:textEdited(actualText);
			end
            self:textChanged(actualText);
        end
	end

	if (self.m_selDirty) then
        self.m_selDirty = false;
        self:selectionChanged();
    end
end

-- virtual: 
function EditBox:focusInEvent(event)
	-- Application:inputMethod():show();
	self:setCursorVisible(true);
	self:setCursorBlinkPeriod(Application:cursorFlashTime());
end

-- virtual: 
function EditBox:focusOutEvent(event)
	-- Application:inputMethod():hide();
	self:setCursorVisible(false);
	self:setCursorBlinkPeriod(0);
end

function EditBox:naturalTextWidth()
	return self.m_text:GetWidth(self:GetFont());
end

function EditBox:paintEvent(painter)
	painter:SetPen(self:GetBackgroundColor());
	painter:DrawRectTexture(self:x(), self:y(), self:width(), self:height(), self:GetBackground());

	local r = self:adjustedContentsRect();
	local lineRect = Rect:new_from_pool(r:x() + self.horizontalMargin, r:y(), r:width() - 2*self.horizontalMargin, r:height());

	-- cursor position 
	local cix = math.floor(self:cursorToX()+0.5);
	local widthUsed = math.floor(self:naturalTextWidth()+0.5) + 1;
	local hasTextClipping = true;
	if ((widthUsed) <= lineRect:width()) then
		-- text fits in lineRect; use hscroll for alignment
		self.hscroll = 0;
		hasTextClipping = false;
	elseif (cix - self.hscroll >= lineRect:width()) then
        -- text doesn't fit, cursor is to the right of lineRect (scroll right)
        self.hscroll = cix - lineRect:width() + 1;
    elseif(cix - self.hscroll < 0 and self.hscroll < widthUsed) then
        -- text doesn't fit, cursor is to the left of lineRect (scroll left)
        self.hscroll = cix;
    elseif(widthUsed - self.hscroll < lineRect:width()) then
        -- text doesn't fit, text document is to the left of lineRect; align right
        self.hscroll = widthUsed - lineRect:width() + 1;
    else
        -- in case the text is bigger than the lineedit, the hscroll can never be negative
        self.hscroll = math.max(0, self.hscroll);
    end

	local textLeft = lineRect:x() - self.hscroll;
	local textTop = lineRect:y();

	local text = self:GetText();
	if(hasTextClipping) then
		-- obsoleted: we will clip the text in software, instead of doing hardware clipping. 
		-- local endClipOfText = self.m_text:xToCursor(self.hscroll+lineRect:width()-1, nil, self:GetFont());
		-- local beginClipOfText = self.m_text:xToCursor(self.hscroll, nil, self:GetFont()) + 1;
		-- local offsetX = self.m_text:cursorToX(beginClipOfText-1, self:GetFont());
		-- text = self.m_text:substr(beginClipOfText, endClipOfText);
		-- textLeft = textLeft + offsetX;
		-- cix = cix - offsetX;
		painter:Save();
		painter:SetClipRegion(self:x()+lineRect:x(), self:y()+lineRect:y(), lineRect:width(), lineRect:height());
	end


	if (self:hasSelectedText()) then
		-- render selection
		local sel_from_x = 0;
		local beforeSelectText = self.m_text:sub(1, self.m_selstart);
		if(not beforeSelectText:empty()) then
			local textWidth = beforeSelectText:GetWidth(self:GetFont());
			sel_from_x = textWidth * (self:GetScale() or 1);
		end
		local sel_width = 0;
		local selectText = self.m_text:sub(self.m_selstart+1, self.m_selend);
		if(not selectText:empty()) then
			local textWidth = selectText:GetWidth(self:GetFont());
			sel_width = textWidth * (self:GetScale() or 1);
		end
		if(sel_width>0) then
			painter:SetPen(self:GetSelectedBackgroundColor());
			painter:DrawRect(self:x() + textLeft + sel_from_x, self:y() + textTop, sel_width, lineRect:height());
		end
	end
	
	if(text and text~="") then
		-- draw text
		painter:SetPen(self:GetColor());
		painter:SetFont(self:GetFont());
		painter:SetPen(self:GetColor());
		local scale = self:GetScale();
		painter:DrawTextScaled(self:x() + textLeft, self:y() + textTop, text, scale);
	end

	if(hasTextClipping) then
		painter:Restore();
	end

	if(self.cursorVisible and self:hasFocus() and not self:isReadOnly()) then
		-- draw cursor
		if(self.m_blinkPeriod==0 or self.m_blinkStatus) then
			painter:SetPen(self:GetCursorColor());
			painter:DrawRect(self:x() + textLeft + cix, self:y() + textTop, self.m_cursorWidth, lineRect:height());
		end
	end
end

function EditBox:adjustedContentsRect()
	local r = self:rect();
	local right = r:right();
	local bottom = r:bottom();
	r:setX(r:x() + self.leftTextMargin);
    r:setY(r:y() + self.topTextMargin);
    r:setRight(right - self.rightTextMargin);
    r:setBottom(bottom - self.bottomTextMargin);
	return r;
end

function EditBox:cursorToX()
	return self.m_text:cursorToX(self.m_cursor, self:GetFont());
end

function EditBox:xToPos(x, betweenOrOn)
    local cr = self:adjustedContentsRect();
    x = x - cr:x() - self.hscroll + self.horizontalMargin;
    return self.m_text:xToCursor(x, betweenOrOn, self:GetFont());
end

function EditBox:inSelection(x)
    if (self.m_selstart >= self.m_selend) then
        return false;
	end
    local pos = self:xToPos(x, "CursorOnCharacter");
    return pos >= self.m_selstart and pos < self.m_selend;
end

function EditBox:mousePressEvent(e)
	if(e:button() == "left") then
		local mark = e.shift_pressed;
		local cursor = self:xToPos(e:pos():x());
		self:moveCursor(cursor, mark);
		e:accept();
	end
end

function EditBox:mouseMoveEvent(e)
	if(e:button() == "left") then
		local select = true;
		self:moveCursor(self:xToPos(e:pos():x()), select);
	end
end

function EditBox:mouseReleaseEvent(e)
end

-- Returns true if the given text str is valid for any validator
-- @param str: if nil, it is current text.
function EditBox:hasAcceptableInput(str)
	str = str or self:GetText();

	-- TODO: validate text?
	return true;
end

function EditBox:resetInputMethod()
	if (self:hasFocus()) then
        Application:inputMethod():reset();
    end
end

function EditBox:emitCursorPositionChanged()
	if (self.m_cursor ~= self.m_lastCursorPos) then
        local oldLast = self.m_lastCursorPos;
        self.m_lastCursorPos = self.m_cursor;
        self:cursorPositionChanged(oldLast, self.m_cursor);
	end
end

function EditBox:undo()
	self:resetInputMethod();
	self:internalUndo(); 
	self:finishChange(-1, true);
end

function EditBox:redo()
	self:resetInputMethod();
	self:internalRedo(); 
	self:finishChange();
end

-- For security reasons undo is not available in any password mode (NoEcho included)
-- with the exception that the user can clear the password with undo.
function EditBox:isUndoAvailable()
    return not self.m_readOnly and self.m_undoState>0
           and (self.m_echoMode == "Normal" or self.m_history[self.m_undoState].type == "Insert");
end

-- Same as with undo. Disabled for password modes.
function EditBox:isRedoAvailable()
    return not self.m_readOnly and self.m_echoMode == "Normal" and self.m_undoState < self.m_history:size();
end

-- @param untilPos: default to -1
function EditBox:internalUndo(untilPos)
	untilPos = untilPos or -1;
	if (not self:isUndoAvailable()) then
        return;
	end
    self:internalDeselect();

    -- Undo works only for clearing the line when in any of password the modes
    if (self.m_echoMode ~= "Normal") then
        self:clear();
        return;
    end

    while (self.m_undoState>0 and self.m_undoState > untilPos) do
        local cmd = self.m_history[self.m_undoState];
		self.m_undoState = self.m_undoState - 1;

		if(cmd.type == "Insert") then
            self.m_text:remove(cmd.pos+1, 1);
            self.m_cursor = cmd.pos;
		elseif(cmd.type == "SetSelection") then
            self.m_selstart = cmd.selStart;
            self.m_selend = cmd.selEnd;
            self.m_cursor = cmd.pos;
		elseif(cmd.type == "Remove" or cmd.type == "RemoveSelection") then
            self.m_text:insert(cmd.pos+1, cmd.uc);
            self.m_cursor = cmd.pos + 1;
		elseif(cmd.type == "Delete" or cmd.type == "DeleteSelection") then
            self.m_text:insert(cmd.pos+1, cmd.uc);
            self.m_cursor = cmd.pos;
		end
		if(cmd.type ~= "Separator") then
			if (untilPos < 0 and self.m_undoState>0) then
				local next = self.m_history[self.m_undoState];
				if (next.type ~= cmd.type 
					and (next.type == "Separator" or next.type == "Insert" or next.type == "Remove" or next.type == "Delete")
					and ((cmd.type == "Separator" or cmd.type == "Insert" or cmd.type == "Remove" or cmd.type == "Delete") or next.type == "Separator")) then
					break;
				end
			end
		end
    end
    self.m_textDirty = true;
    self:emitCursorPositionChanged();
end

function EditBox:internalRedo()
	if (not self:isRedoAvailable()) then
        return;
	end
    self:internalDeselect();
    while (self.m_undoState < self.m_history:size()) do
        local cmd = self.m_history[self.m_undoState+1];
		self.m_undoState = self.m_undoState + 1;
        if(cmd.type == "Insert") then
            self.m_text:insert(cmd.pos+1, cmd.uc);
            self.m_cursor = cmd.pos + 1;
		elseif(cmd.type == "SetSelection") then
            self.m_selstart = cmd.selStart;
            self.m_selend = cmd.selEnd;
            self.m_cursor = cmd.pos;
		elseif(cmd.type == "Remove" or cmd.type == "Delete" or cmd.type == "RemoveSelection" or cmd.type == "DeleteSelection") then
            self.m_text:remove(cmd.pos+1, 1);
            self.m_selstart = cmd.selStart;
            self.m_selend = cmd.selEnd;
            self.m_cursor = cmd.pos;
		elseif(cmd.type == "Separator") then
            self.m_selstart = cmd.selStart;
            self.m_selend = cmd.selEnd;
            self.m_cursor = cmd.pos;
        end
        if (self.m_undoState < self.m_history:size()) then
            local next = self.m_history[self.m_undoState+1];
            if (next.type ~= cmd.type 
				and ((cmd.type == "Separator" or cmd.type == "Insert" or cmd.type == "Remove" or cmd.type == "Delete") and next.type ~= "Separator")
                and ((next.type == "Separator" or next.type == "Insert" or next.type == "Remove" or next.type == "Delete") or cmd.type == "Separator")) then
                break;
			end
        end
    end
    self.m_textDirty = true;
    self:emitCursorPositionChanged();
end

function EditBox:clear()
	local priorState = self.m_undoState;
    self.m_selstart = 0;
    self.m_selend = self.m_text:length();
    self:removeSelectedText();
    self:separate();
    self:finishChange(priorState, false, false);
end

function EditBox:selectAll()
	self.m_selstart = 0;
	self.m_selend = 0;
	self.m_cursor = 0; 
	self:moveCursor(self.m_text:length(), true);
end

function EditBox:copy()
	local t = self:selectedText()
	if(t) then
		ParaMisc.CopyTextToClipboard(t);
	end
end

function EditBox:paste(mode)
	local clip = ParaMisc.GetTextFromClipboard();
	if(clip or self:hasSelectedText()) then
		clip = commonlib.Encoding.DefaultToUtf8(clip);
		self:separate(); -- make it a separate undo/redo command
        self:insert(clip);
        self:separate();
	end
end

-- Inserts the given \a newText at the current cursor position.
-- If there is any selected text it is removed prior to insertion of the new text.
function EditBox:insert(newText)
    local priorState = self.m_undoState;
    self:removeSelectedText();
    self:internalInsert(newText);
    self:finishChange(priorState);
end

function EditBox:del()
	local priorState = self.m_undoState;
    if (self:hasSelectedText()) then
        self:removeSelectedText();
    else
        self:internalDelete();
    end
    self:finishChange(priorState);
end

function EditBox:Home(mark) 
	self:moveCursor(0, mark);
end

function EditBox:End(mark)
	self:moveCursor(self.m_text:length(), mark);
end

function EditBox:selectionStart() 
	return if_else(self:hasSelectedText(), self.m_selstart, -1);
end

function EditBox:selectionEnd()
	return if_else(self:hasSelectedText(), self.m_selend, -1);
end

-- @param mark: bool, if mark for selection. 
function EditBox:cursorForward(mark, steps)
	local c = self.m_cursor;
    if (steps > 0) then
		c = c + steps;
    elseif (steps < 0) then
		c = c + steps;
	end
	c = math.max(0, math.min(self.m_text:length(), c));
    self:moveCursor(c, mark);
end

-- @param mark: bool, if mark for selection. 
function EditBox:cursorWordForward(mark)
	self:moveCursor(self.m_text:nextCursorPosition(self.m_cursor, "SkipWords"), mark);
end

-- @param mark: bool, if mark for selection. 
function EditBox:cursorWordBackward(mark)
	self:moveCursor(self.m_text:previousCursorPosition(self.m_cursor, "SkipWords"), mark);
end

function EditBox:setCursorVisible(visible)
    if (self.cursorVisible == visible) then
        return;
	end
    self.cursorVisible = visible;
    self:update();
end

function EditBox:isCursorVisible()
	return self.cursorVisible;
end

function EditBox:getCursorBlinkPeriod()
	return self.m_blinkPeriod;
end

function EditBox:setCursorBlinkPeriod(msec)
    if (msec == self.m_blinkPeriod) then
        return;
	end
    if (self.m_blinkTimer) then
        self.m_blinkTimer:Change();
    end
    if (msec > 0 and not self.m_readOnly) then
        self.m_blinkTimer = self.m_blinkTimer or commonlib.Timer:new({callbackFunc = function(timer)
			self.m_blinkStatus = not self.m_blinkStatus;
			self:updateNeeded(); -- signal
		end})
		self.m_blinkTimer:Change(msec / 2, msec / 2);
        self.m_blinkStatus = 1;
    else
        -- self.m_blinkTimer = nil;
        if (self.m_blinkStatus == 1) then
            self:updateNeeded(); -- signal
		end
    end
    self.m_blinkPeriod = msec;
end


function EditBox:keyPressEvent(event)
	local keyname = event.keyname;
	-- echo({keyname, event.key_sequence});
	local unknown = false;
	if(keyname == "DIK_RETURN") then
		if(self:hasAcceptableInput()) then
			self:accepted(); -- emit
			self:editingFinished(); -- emit
		end
	elseif(keyname == "DIK_BACKSPACE") then
		if (not self:isReadOnly()) then
			if(event.ctrl_pressed) then
				self:cursorWordBackward(true);
				self:del();
			else
				self:backspace();
			end
		end
	elseif(event:IsKeySequence("Undo")) then
		if (not self:isReadOnly()) then
			self:undo();
		end
	elseif(event:IsKeySequence("Redo")) then
		if (not self:isReadOnly()) then
			self:redo();
		end
	elseif(event:IsKeySequence("SelectAll")) then
		self:selectAll();
	elseif(event:IsKeySequence("Copy")) then
		self:copy();
	elseif(event:IsKeySequence("Paste")) then
		if (not self:isReadOnly()) then
			self:paste("Clipboard");
		end
	elseif(event:IsKeySequence("Cut")) then
		if (not self:isReadOnly()) then
			self:copy();
			self:del();
		end
	elseif (event:IsKeySequence("MoveToStartOfLine") or event:IsKeySequence("MoveToStartOfBlock")) then
        self:Home(false);
    elseif (event:IsKeySequence("MoveToEndOfLine") or event:IsKeySequence("MoveToEndOfBlock")) then
        self:End(false);
    elseif (event:IsKeySequence("SelectStartOfLine") or event:IsKeySequence("SelectStartOfBlock")) then
        self:Home(true);
    elseif (event:IsKeySequence("SelectEndOfLine") or event:IsKeySequence("SelectEndOfBlock")) then
        self:End(true);
	elseif (event:IsKeySequence("MoveToNextChar")) then
		if (self:hasSelectedText()) then
            self:moveCursor(self:selectionEnd(), false);
        else
            self:cursorForward(false, 1);
        end
	elseif (event:IsKeySequence("SelectNextChar")) then
        self:cursorForward(true, 1);
	elseif (event:IsKeySequence("MoveToPreviousChar")) then
		if (self:hasSelectedText()) then
            self:moveCursor(self:selectionStart(), false);
        else
            self:cursorForward(false, -1);
        end
	elseif (event:IsKeySequence("SelectPreviousChar")) then
        self:cursorForward(true, -1);

	elseif (event:IsKeySequence("MoveToNextWord")) then
        if (self:echoMode() == "Normal") then
            self:cursorWordForward(false);
        else
            self:End(false);
		end
    elseif (event:IsKeySequence("MoveToPreviousWord")) then
        if (self:echoMode() == "Normal") then
            self:cursorWordBackward(false);
        elseif (not self:isReadOnly()) then
            self:Home(false);
        end
    elseif (event:IsKeySequence("SelectNextWord")) then
        if (self:echoMode() == "Normal") then
            self:cursorWordForward(true);
        else
            self:End(true);
		end
    elseif (event:IsKeySequence("SelectPreviousWord")) then
        if (self:echoMode() == "Normal") then
            self:cursorWordBackward(true);
        else
            self:Home(true);
		end
    elseif (event:IsKeySequence("Delete")) then
        if (not self:isReadOnly()) then
            self:del();
		end
	else
		unknown = true;
	end

	if (unknown) then
        event:ignore();
    else
        event:accept();
	end
end