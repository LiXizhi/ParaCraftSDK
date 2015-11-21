--[[ 
Title: Default message box and dialog box 
Author(s): LiXizhi
Date: 2005/10, revised 2008.5.8, revised to MCML 2009.8.7
desc: This class is part of guihelper
------------------------------------------------------
NPL.load("(gl)script/ide/MessageBox.lua");
_guihelper.MessageBox("Hello ParaEngine!")
_guihelper.MessageBox("Hello ParaEngine!", function()
	-- pressed OK
end);
_guihelper.MessageBox("Hello ParaEngine!", function(res)
	if(res and res == _guihelper.DialogResult.Yes) then
		-- pressed YES
		_guihelper.CloseMessageBox(true); -- fast close without animation
	end
end, _guihelper.MessageBoxButtons.YesNo);

_guihelper.MessageBox("Did you press OK?", function(res)
	if(res and res == _guihelper.DialogResult.OK) then
		-- pressed OK
	end
end, _guihelper.MessageBoxButtons.OK,nil,{OK = "OKed"});

_guihelper.MessageBox("Nothing",nil, _guihelper.MessageBoxButtons.Nothing, nil, "script/ide/styles/ThinFrameMessageBox.html")
_guihelper.MessageBox("YesNo Custom Page Template",nil, _guihelper.MessageBoxButtons.YesNo, _guihelper.MessageBoxIcon.Error, "script/ide/styles/ThinFrameMessageBox.html")

_guihelper.MessageBox("Error",nil, _guihelper.MessageBoxButtons.OK, _guihelper.MessageBoxIcon.Error)
_guihelper.MessageBox("Asterisk",nil, _guihelper.MessageBoxButtons.AbortRetryIgnore, _guihelper.MessageBoxIcon.Asterisk)
_guihelper.MessageBox("Exclamation",nil, _guihelper.MessageBoxButtons.RetryCancel, _guihelper.MessageBoxIcon.Exclamation)
_guihelper.MessageBox("Question",nil, _guihelper.MessageBoxButtons.YesNo, _guihelper.MessageBoxIcon.Question)
_guihelper.MessageBox("Information",nil, _guihelper.MessageBoxButtons.YesNoCancel, _guihelper.MessageBoxIcon.Information)
_guihelper.MessageBox("Warning",nil, _guihelper.MessageBoxButtons.Nothing, _guihelper.MessageBoxIcon.Warning)
_guihelper.MessageBox("Custom icon",nil, _guihelper.MessageBoxButtons.OK, "Texture/Aries/Profile/Profession_Empty.png")

_guihelper.MessageBox("rotating icon", nil, nil, {src="Texture/Aquarius/Common/Waiting_32bits.png; 0 0 24 24", animstyle=39}, "script/ide/styles/ThinFrameMessageBox.html");

_guihelper.MessageBox("<div style='color:#0000ff'>MCML code here</div>",nil, _guihelper.MessageBoxButtons.YesNoCancel)
------------------------------------------------------
]]

local L;
if(CommonCtrl.Locale) then
	L = CommonCtrl.Locale("IDE");
else
	L = function(o) return o end
end

NPL.load("(gl)script/ide/UIAnim/UIAnimManager.lua");

if(_guihelper==nil) then _guihelper={} end

---------------------------------------------------------------
-- message box (top level)
---------------------------------------------------------------
-- bWindowClosed ensures that "IDE_HELPER_MSGBOX" is deleted, in case closing animation interlaced with a new message box. 
local LastParentWindowID;

-- the dialog background to used. if nil, it will be the default container background. 
_guihelper.MessageBox_BG = nil;
-- how a message box is poped up. if nil, it is just displayed as a top level window. 
-- If 1, it will gradually grey out the background and pops up with an animation. 
-- If 2, it will grey out the background and pops up WITHOUT animations. 
_guihelper.MessageBox_PopupStyle = 1;

-- Specifies constants defining which buttons to display on a MessageBox. 
_guihelper.MessageBoxButtons = {
	--The message box contains Abort, Retry, and Ignore buttons.  
	AbortRetryIgnore = 1, 
	--  The message box contains an OK button.  
	OK = 2, 
	-- The message box contains OK and Cancel buttons.  
	OKCancel = 3,
	-- The message box contains Retry and Cancel buttons.  
	RetryCancel = 4, 
	-- The message box contains Yes and No buttons.  
	YesNo = 5, 
	-- The message box contains Yes, No, and Cancel buttons.  
	YesNoCancel = 6,
	-- The message box contains no buttons at all. This is useful when displaying system generated message sequence
	-- Used in Aquarius login procedure
	Nothing = 7,
};

-- Specifies identifiers to indicate the return value of a dialog box. 
_guihelper.DialogResult = {
	-- The dialog box return value is Abort (usually sent from a button labeled Abort).  
	Abort = 1,
	-- The dialog box return value is Cancel (usually sent from a button labeled Cancel).  
	Cancel = 2,
	-- The dialog box return value is Ignore (usually sent from a button labeled Ignore).  
	Ignore = 3, 
	-- The dialog box return value is No (usually sent from a button labeled No).  
	No = 4,
	-- Nothing is returned from the dialog box. This means that the modal dialog continues running.  
	None = 5,
	-- The dialog box return value is OK (usually sent from a button labeled OK).  
	OK = 6,
	-- The dialog box return value is Retry (usually sent from a button labeled Retry).  
	Retry = 7,
	-- The dialog box return value is Yes (usually sent from a button labeled Yes).  
	Yes = 8,
};
-- Specifies constants defining which information to display. 
_guihelper.MessageBoxIcon = {
	-- The message box contains a symbol consisting of a lowercase letter i in a circle.  
	Asterisk = 1,
	-- The message box contains a symbol consisting of white X in a circle with a red background.  
	Error = 2,
	-- The message box contains a symbol consisting of an exclamation point in a triangle with a yellow background.  
	Exclamation = 3,
	-- The message box contains a symbol consisting of a white X in a circle with a red background.  
	Hand = 4,
	-- The message box contains a symbol consisting of a lowercase letter i in a circle.  
	Information = 5,
	-- The message box contain no symbols.  
	None = 6,
	-- The message box contains a symbol consisting of a question mark in a circle.  
	Question = 7,
	-- The message box contains a symbol consisting of white X in a circle with a red background.  
	Stop = 8,
	-- The message box contains a symbol consisting of an exclamation point in a triangle with a yellow background.  
	Warning = 9,
};

-- get the last parent window object. it may return nil if no previous window is found. 
local function GetLastParentWindow()
	if(type(LastParentWindowID) == "number") then
		local obj = ParaUI.GetUIObject(LastParentWindowID);
		if(obj:IsValid()) then
			return obj;
		else
			LastParentWindowID = nil;
		end
	end
end

local templates = {};
_guihelper.values= {};

-- default MCML message box template
_guihelper.defaultMsgBoxMCMLTemplate = "script/ide/styles/DefaultMessageBox.html";

function _guihelper.SetDefaultMsgBoxMCMLTemplate(template)
	_guihelper.defaultMsgBoxMCMLTemplate = template;
end

_guihelper.MessageBoxClass = _guihelper.MessageBoxClass or {};

-- funcCallback will be called after the last message box is closed by the user
-- if there is no message box currently displayed, funcCallback will be called immediately. 
-- there can be only one caller at any given time. 
function _guihelper.MessageBoxClass.CheckShow(funcCallback)
	local wnd = GetLastParentWindow();
	if(not wnd) then
		funcCallback();
	else
		_guihelper.MessageBoxClass.CheckShowCallback = funcCallback;
	end
end

--[[
display a message box based on MCML template. 
@param content: string: the text to be displayed. it can be pure text or mcml code. code that needs dynamic refresh is supported. If nil, it will close the previous one.
@param MsgBoxClick_CallBack: [optional] string or function or nil; the script or function to be executed when user clicked OK or Yes. if it is a function, the first input will be _guihelper.DialogResult 
@param buttons: [optional] type of _guihelper.MessageBoxButtons
@param icon: [optional] type of _guihelper.MessageBoxIcon. Some mcmlTemplate also support image path string, or a table {src, animstyle, }
@param mcmlTemplate: if nil, it default to "script/ide/styles/DefaultMessageBox.html"
@return true if created. or nil if there is a previous MessageBox that has not been closed. 
]]
function _guihelper.MessageBox(content,MsgBoxClick_CallBack, buttons, icon, mcmlTemplate, isNotTopLevel, zorder)
	if(not content) then
		_guihelper.CloseMessageBox();
		return true;
	end
	if(type(content)~="string") then
		content = commonlib.serialize(content);
	end

	local bPlayAnimation = true;		
	local _this = GetLastParentWindow();
	if(not _this) then 
		-- create the mcml container.
		_this=ParaUI.CreateUIObject("container","IDE_HELPER_MSGBOX", "_fi",0,0,0,0);
		_this:AttachToRoot();
		_this.background = "";
		_this.zorder = 1000;
		_this:SetTopLevel(true); -- _this.candrag and TopLevel and not be true simultanously 
		LastParentWindowID = _this.id;
	else
		if(_guihelper.values.buttons == _guihelper.MessageBoxButtons.OK or _guihelper.values.buttons == _guihelper.MessageBoxButtons.Nothing) then
			bPlayAnimation = false;
		else
			-- we should not create a new message box if previous one is not closed and contains selection buttons. 	
			return;	
		end
	end	

	if(isNotTopLevel) then
		_this:SetTopLevel(false);
	end
	
	_this.zorder = 1000;
	if(zorder) then
		_this.zorder = zorder;
	end
	
	local width, height = 370, 250;
	if(System.options.IsMobilePlatform and System.options.mc) then
		width, height = 590, 320;
	end
	if(type(mcmlTemplate) ~= "string") then
		mcmlTemplate = _guihelper.defaultMsgBoxMCMLTemplate;
	end	
	templates[mcmlTemplate] = templates[mcmlTemplate] or Map3DSystem.mcml.PageCtrl:new({url=mcmlTemplate});
	local pageCtrl = templates[mcmlTemplate];
	_guihelper.values.content = content;
	if(buttons == nil) then
		if(MsgBoxClick_CallBack) then
			buttons = _guihelper.MessageBoxButtons.OKCancel;
		else
			buttons = _guihelper.MessageBoxButtons.OK;
		end
	end
	_guihelper.MsgBoxClick_CallBack = MsgBoxClick_CallBack;
	_guihelper.values.buttons = buttons;
	_guihelper.values.icon = icon;
	_guihelper.values.IsInitialized = false; -- tricky: this causes the content to be evaluated only once. 
	if(Map3DSystem.options.IsMobilePlatform) then
		pageCtrl:Create("IDE_HELPER_MSGBOX_PANEL", _this, "_ct",-width/2,-height/2,width, height);
	else
		pageCtrl:Create("IDE_HELPER_MSGBOX_PANEL", _this, "_ct",-width/2,-height/2-50,width+80, height);
	end
	
	_guihelper.values.IsInitialized = true; -- tricky: this causes the content to be evaluated only once. 
	
	if (bPlayAnimation) then
		_guihelper.PlayOpenAnimation(_this);
	end
	
	if(KidsUI~=nil and KidsUI.PushState~=nil) then
		KidsUI.PushState({name = "MessageBox", OnEscKey = "_guihelper.CloseMessageBox();"});
	end
		
	if(Map3DSystem~=nil and Map3DSystem.PushState~=nil) then
		Map3DSystem.PushState({name = "MessageBox", OnEscKey = "_guihelper.OnMessageBoxClick(\"Cancel\");"});
	end
	
	return true;
end

-- switch the default to _guihelper.MessageBoxEx
function _guihelper.MessageBoxEx(...)
	return _guihelper.MessageBox(...);
end

-- Message Box. 
function _guihelper.OnMessageBoxClick(name)
	_guihelper.CloseMessageBox()
	local dialogResult;
	if(type(name) == "string") then
		dialogResult = _guihelper.DialogResult[name]
	else
		dialogResult = name;
	end	

	if(_guihelper.MessageBoxClass.CheckShowCallback) then
		_guihelper.MessageBoxClass.CheckShowCallback(dialogResult);
		_guihelper.MessageBoxClass.CheckShowCallback = nil;
	end

	if(not dialogResult) then
		return
	elseif(dialogResult == _guihelper.DialogResult.Cancel and _guihelper.values.buttons ~= _guihelper.MessageBoxButtons.YesNoCancel) then
		return;
	end
	
	if(_guihelper.MsgBoxClick_CallBack~=nil) then
		if(type(_guihelper.MsgBoxClick_CallBack) == "string") then
			NPL.DoString(_guihelper.MsgBoxClick_CallBack);
		elseif(type(_guihelper.MsgBoxClick_CallBack) == "function") then
			_guihelper.MsgBoxClick_CallBack(dialogResult);
		end	
	end
end

-- play open window animation, 
-- @param _this: the top level container. 
-- @param style: if nil, it defaults to _guihelper.MessageBox_PopupStyle
function _guihelper.PlayOpenAnimation(_this, style)
	style = style or _guihelper.MessageBox_PopupStyle;
	if(style == 2) then
		-- grey without animation
		_guihelper.SetUIColor(_this, "90 90 90 150");
	elseif(style == 1) then
		-- show the window, the window frame is already BringToFront()
		local block = UIDirectAnimBlock:new();
		block:SetUIObject(_this);
		block:SetTime(200);
		block:SetScalingXRange(0.9, 1);
		block:SetScalingYRange(0.9, 1);
		block:SetAlphaRange(0.6, 1);
		block:SetApplyAnim(true); 
		UIAnimManager.PlayDirectUIAnimation(block);
	end
end

_guihelper.MsgBoxClick_CallBack = nil;
local LastDestroyedWindowID;
-- close the messagebox 
-- @param bForceDestory: if true, no animation will be played. 
function _guihelper.CloseMessageBox(bForceDestory)
	if(Map3DSystem~=nil and Map3DSystem.GetState~=nil) then
		local state = Map3DSystem.GetState();
		if(type(state) == "table" and state.name=="MessageBox") then
			Map3DSystem.PopState(state.name);
		end
	end	
	
	if(bForceDestory and LastDestroyedWindowID) then
		ParaUI.Destroy(LastDestroyedWindowID);
		LastDestroyedWindowID = nil;
	end

	local _msgbox = GetLastParentWindow();
	if ( not _msgbox) then
		return;
	end

	local parent_id = LastParentWindowID;
	if(bForceDestory and _guihelper.MessageBox_PopupStyle == nil) then
		ParaUI.Destroy(parent_id);
	elseif(_guihelper.MessageBox_PopupStyle == 1 or _guihelper.MessageBox_PopupStyle == 2) then
		-- hide the message box
		_msgbox.visible = true;
		LastDestroyedWindowID = parent_id;
		local block = UIDirectAnimBlock:new();
		block:SetUIObject(_msgbox);
		block:SetTime(200);
		block:SetScalingXRange(1, 1.1);
		block:SetScalingYRange(1, 1.1);
		block:SetAlphaRange(1, 0);
		block:SetApplyAnim(true);
		block:SetCallback(function ()
			-- destroy the messagebox
			ParaUI.Destroy(parent_id);
			if(LastDestroyedWindowID == parent_id) then
				LastDestroyedWindowID = nil;
			end
		end)
		UIAnimManager.PlayDirectUIAnimation(block);
	end
	LastParentWindowID = nil;
end

---------------------------------------------
-- The following code is old plain message box implementation (about to be deprecated)
---------------------------------------------

--[[display a simple message box. Contents in previous displayed box will be appended to the new one
@param content: string: the text to be displayed
@param MsgBoxClick_CallBack: [optional] string or function or nil; the script or function to be executed when user clicked OK or Yes. if it is a function, the first input will be _guihelper.DialogResult 
@param buttons: [optional] type of _guihelper.MessageBoxButtons
@param icon: [optional] type of _guihelper.MessageBoxIcon 
@param customLabels:[optional] 自定义按钮名称
	customLabels = {
		Abort = "Abort",
		Cancel = "Cancel",
		Ignore = "Ignore",
		No = "No",
		None = "None",
		OK = "OK",
		Retry = "Retry",
		Yes = "Yes",
	}
]]
function _guihelper.MessageBox_Plain(content,MsgBoxClick_CallBack, buttons, icon ,customLabels)
	if(type(content)~="string") then
		content = commonlib.serialize(content);
	end
	_guihelper.MsgBoxClick_CallBack = MsgBoxClick_CallBack;
	
	local temp = GetLastParentWindow();
	
	if(not temp) then 
		local _this,_parent, _panel;
		local width, height = 370,150
		if(_guihelper.MessageBox_PopupStyle == nil) then 
			-- standard message box window
			_this=ParaUI.CreateUIObject("container","IDE_HELPER_MSGBOX", "_ct",-width/2,-height/2-50,width, height);
			_this:AttachToRoot();
			if(_guihelper.MessageBox_BG ~=nil) then
				_this.background = _guihelper.MessageBox_BG;
			end	
			_this.zorder = 1000;
			_this:SetTopLevel(true); -- _this.candrag and TopLevel and not be true simultanously 
			_parent = _this;
			_panel = _this;
			LastParentWindowID = _this.id;
			
		elseif(_guihelper.MessageBox_PopupStyle == 1 or _guihelper.MessageBox_PopupStyle == 2) then
			-- grey out the background and pops up with/without an animation. 
			_this=ParaUI.CreateUIObject("container","IDE_HELPER_MSGBOX", "_fi",0,0,0,0);
			_this:AttachToRoot();
			--_this.background = "Texture/whitedot.png";
			_this.background = "";
			_this.zorder = 1000;
			_this:SetTopLevel(true); -- _this.candrag and TopLevel and not be true simultanously 
			_parent = _this;
			LastParentWindowID = _this.id;
			
			_this=ParaUI.CreateUIObject("container","IDE_HELPER_MSGBOX_PANEL", "_ct",-width/2,-height/2-50,width, height);
			_parent:AddChild(_this);
			if(_guihelper.MessageBox_BG ~=nil) then
				_this.background = _guihelper.MessageBox_BG;
			end	
			_parent = _this;
			_panel = _this;
			
			if(_guihelper.MessageBox_PopupStyle == 2) then
				-- grey without animation
				_guihelper.SetUIColor(_this, "90 90 90 150");
			else
				if(not _guihelper.PopupMotion_) then
					-- show the window, the window frame is already BringToFront()
					local block = UIDirectAnimBlock:new();
					block:SetUIObject(_this);
					block:SetTime(200);
					block:SetScalingXRange(0.9, 1);
					block:SetScalingYRange(0.9, 1);
					block:SetAlphaRange(0.6, 1);
					block:SetApplyAnim(true); 
					UIAnimManager.PlayDirectUIAnimation(block);
					
					if(false) then
						NPL.load("(gl)script/ide/Motion/AnimatorEngine.lua");
						_guihelper.PopupMotion_ = CommonCtrl.Motion.AnimatorEngine:new({framerate=24});
						local groupManager = CommonCtrl.Motion.AnimatorManager:new();
						local layerManager = CommonCtrl.Motion.LayerManager:new();
						local layerBGManager = CommonCtrl.Motion.LayerManager:new();
						local PopupAnimator = CommonCtrl.Motion.Animator:new();
						PopupAnimator:Init("script/ide/styles/WindowPopupMotionData.xml", "IDE_HELPER_MSGBOX_PANEL");
						local BgGreyOutAnimator = CommonCtrl.Motion.Animator:new();
						BgGreyOutAnimator:Init("script/ide/styles/BackgroundGreyOutMotionData.xml", "IDE_HELPER_MSGBOX");
						
						layerManager:AddChild(PopupAnimator);
						layerBGManager:AddChild(BgGreyOutAnimator);
						groupManager:AddChild(layerManager);
						groupManager:AddChild(layerBGManager);
						_guihelper.PopupMotion_:SetAnimatorManager(groupManager);
					end
				end	
			end
			
			if(_guihelper.MessageBox_PopupStyle == 1 and _guihelper.PopupMotion_)then
				-- play animation
				_guihelper.PopupMotion_:doPlay();
			end
		end	
		
		_this = ParaUI.CreateUIObject("button", "IDE_HELPER_ICON", "_lt", 16, 25, 64, 64);
		_guihelper.SetUIColor(_this, "255 255 255");
		_parent:AddChild(_this);
	
		-- TODO: icon
		if(_guihelper.MsgBoxClick_CallBack ~= nil) then
			if(_guihelper.QuestionMark_BG ~= nil) then
				_this.background = _guihelper.QuestionMark_BG;
			else
				_this.text = "?";
				_this.background = "";
			end
		else
			if(_guihelper.ExclamationMark_BG ~= nil) then
				_this.background = _guihelper.ExclamationMark_BG;
			else
				_this.text = "!";
				_this.background = "";
			end
		end
		
		-- content text
		ParaUI.Destroy("IDE_HELPER_MSGBOX_textcontainer"); -- this ensure multiple mcml page instances to coexist.
		width,height = width - 105, height - 70
		_this=ParaUI.CreateUIObject("container","IDE_HELPER_MSGBOX_textcontainer", "_lt",96,25,width,height);
		_parent:AddChild(_this);
		_this.scrollable=true;
		_this.background="Texture/whitedot.png;0 0 0 0";
		_parent = _this;
		
		-- message content now support MCML string as content, and displays as an MCML page
		-- old plain text messagebox is deparacated
		CommonCtrl.DeleteControl("IDE_HELPER_MSGBOX_TreeView");
		NPL.load("(gl)script/ide/TreeView.lua");
		local ctl = CommonCtrl.GetControl("IDE_HELPER_MSGBOX_TreeView");
		if(ctl == nil) then
			ctl = CommonCtrl.TreeView:new{
				name = "IDE_HELPER_MSGBOX_TreeView",
				alignment = "_fi",
				left = 0,
				top = 0,
				width = 0,
				height = 0,
				parent = _parent,
				--container_bg = "",
				DefaultIndentation = 0,
				DefaultNodeHeight = 24,
				VerticalScrollBarStep = 24,
				VerticalScrollBarPageSize = 24 * 6,
				-- lxz: this prevent clipping text and renders faster
				NoClipping = false,
				HideVerticalScrollBar = false,
				DrawNodeHandler = function (_parent, treeNode)
					if(_parent == nil or treeNode == nil) then
						return;
					end
					
					local contentMCML = string.gsub(content, "\n", "<br/>");
					
					local textbuffer = "<pe:mcml><pe:editor style=\"background:;\">"..contentMCML.."</pe:editor></pe:mcml>";
					--textbuffer = ParaMisc.EncodingConvert("", "HTML", textbuffer);
					local xmlRoot = ParaXML.LuaXML_ParseString(textbuffer);
					if(type(xmlRoot)=="table" and table.getn(xmlRoot)>0) then
						local xmlRoot = Map3DSystem.mcml.buildclass(xmlRoot);
						mcmlNode = xmlRoot[1];
						
						local myLayout = Map3DSystem.mcml_controls.layout:new();
						myLayout:reset(0, 0, width, height);
						Map3DSystem.mcml_controls.create("IDE_Helper_MCML", mcmlNode, nil, _parent, 0, 0, width, height, nil, myLayout);
						
						local _, usedHeight = myLayout:GetUsedSize();
						treeNode.NodeHeight = usedHeight;
					else
						local _this = ParaUI.CreateUIObject("text","IDE_HELPER_MSGBOX_text", "_lt",0,0,width,20);
						_parent:AddChild(_this);
						_this.text=content;
						_this.autosize=true;
						_this:DoAutoSize();
						_parent:InvalidateRect();
					end
				end,
			};
		end
		ctl.RootNode:AddChild(CommonCtrl.TreeNode:new({}));
		ctl:Show();
		ctl:Update();
		
		width = width-20
		
		_parent=_panel;
		
		if(not buttons)then
			if(_guihelper.MsgBoxClick_CallBack ~= nil) then
				buttons = _guihelper.MessageBoxButtons.OKCancel
			else
				buttons = _guihelper.MessageBoxButtons.OK
			end
		end
		local Abort_label,Cancel_label,Ignore_label,No_label,None_label,OK_label,Retry_label,Yes_label
		if(customLabels)then
			Abort_label = customLabels["Abort"]; 
			Cancel_label = customLabels["Cancel"]; 
			Ignore_label = customLabels["Ignore"]; 
			No_label = customLabels["No"];
			None_label = customLabels["None"];
			OK_label = customLabels["OK"];
			Retry_label = customLabels["Retry"];
			Yes_label = customLabels["Yes"];
		end
		local left, top, width, height = -84, -42, 60, 22;
		
		-- for speed, we use numbers
		if(buttons == 3 or buttons == 4 or buttons == 6) then
			-- cancel 
			_this=ParaUI.CreateUIObject("button","IDE_HELPER_MSGBOX_CANCEL", "_rb",left, top,width, height);
			_parent:AddChild(_this);
			_this.text = Cancel_label or L"Cancel";
			_this.onclick=";_guihelper.CloseMessageBox();";
			
			left = left - width -10;
		end
		
		if(buttons == 5 or buttons == 6) then
			-- NO
			_this=ParaUI.CreateUIObject("button","IDE_HELPER_MSGBOX_NO", "_rb",left, top,width, height);
			_parent:AddChild(_this);
			_this.text = No_label or L"No";
			_this.onclick=";_guihelper.OnMessageBoxClick(_guihelper.DialogResult.No);";
			
			left = left - width -10;
			
			-- Yes
			_this=ParaUI.CreateUIObject("button","IDE_HELPER_MSGBOX_YES", "_rb",left, top,width, height);
			_parent:AddChild(_this);
			_this.text = Yes_label or L"Yes";
			_this.onclick=";_guihelper.OnMessageBoxClick(_guihelper.DialogResult.Yes);";
			
			left = left - width -10;
		end
		
		if(buttons == 2 or buttons == 3) then
			-- OK
			_this=ParaUI.CreateUIObject("button","IDE_HELPER_MSGBOX_OK", "_rb",left, top,width, height);
			_parent:AddChild(_this);
			_this.text = OK_label or L"OK";
			_this.onclick=";_guihelper.OnMessageBoxClick(_guihelper.DialogResult.OK);";
			
			left = left - width -10;
		end
		
		if(buttons == 1) then
			-- Ignore
			_this=ParaUI.CreateUIObject("button","b", "_rb",left, top,width, height);
			_parent:AddChild(_this);
			_this.text = Ignore_label or L"Ignore";
			_this.onclick=";_guihelper.OnMessageBoxClick(_guihelper.DialogResult.Ignore);";
			
			left = left - width -10;
			
			-- Retry
			_this=ParaUI.CreateUIObject("button","b", "_rb",left, top,width, height);
			_parent:AddChild(_this);
			_this.text = Retry_label or L"Retry";
			_this.onclick=";_guihelper.OnMessageBoxClick(_guihelper.DialogResult.Retry);";
			
			left = left - width -10;
			
			-- Abort
			_this=ParaUI.CreateUIObject("button","b", "_rb",left, top,width, height);
			_parent:AddChild(_this);
			_this.text = Abort_label or L"Abort";
			_this.onclick=";_guihelper.OnMessageBoxClick(_guihelper.DialogResult.Abort);";
			
			left = left - width -10;
		end
		
		if(buttons == 4) then
			-- Retry
			_this=ParaUI.CreateUIObject("button","b", "_rb",left, top,width, height);
			_parent:AddChild(_this);
			_this.text = Retry_label or L"Retry";
			_this.onclick=";_guihelper.OnMessageBoxClick(_guihelper.DialogResult.Retry);";
			
			left = left - width -10;
		end
		
		if(buttons == 7) then
			-- Nothing
		end
		
	else
		-- temp:BringToFront();
		temp = ParaUI.GetUIObject("IDE_HELPER_MSGBOX_text");
		if (temp:IsValid()) then
			local text = temp.text;
			if(text==nil or text== "") then
				temp.text = content;
			else
				temp.text = content.."\n"..text;
			end	
			temp:DoAutoSize();
			temp.parent:InvalidateRect();
		else
			commonlib.applog("_guihelper.MessageBox does not support appending text, because we use MCML text now")	
		end
	end	
		
	if(KidsUI~=nil and KidsUI.PushState~=nil) then
		KidsUI.PushState({name = "MessageBox", OnEscKey = "_guihelper.CloseMessageBox();"});
	end
		
	if(Map3DSystem~=nil and Map3DSystem.PushState~=nil) then
		Map3DSystem.PushState({name = "MessageBox", OnEscKey = "_guihelper.CloseMessageBox();"});
	end
end


---------------------------------------------------------------
-- dialog box (top level)
---------------------------------------------------------------

--[[ display a top level dialog. Use windows.dialog for advanced dialog. this function is only for displaying a very simple (usually databinding) dialog control. 
@param title: string of title text or nil. 
@param x,y,width, height: position and size of the client area of the dialog. if x,y is nil, it is displayed at the center of the screen. 
@param ShowUI_func: function (_parent) end. this function is called to create UIs in the dialog but excluding the OK|cancel buttons. UI created in it will be automatically destroyed when dialog closes.  
@param OnClick_CallBack: [optional] function (dialogResult) end or the function name string. The first input will be _guihelper.DialogResult.This function will be called when the dialog returns but before UI is destoryed. If function returns true, the dialog will be closed; otherwise dialog is not closed. 
@param buttons; [optional] type of _guihelper.MessageBoxButtons
e.g.
	function SomeFunctionToCreateUIToGetherData()
		local package = Map3DSystem.App.Assets.CreatePackage({text="未命名资源包"});
		local bindingContext = commonlib.BindingContext:new();
		bindingContext:AddBinding(package, "text", "AssetManager.NewAsset#packageName", commonlib.Binding.ControlTypes.ParaUI_editbox, "text")
		bindingContext:AddBinding(package, "icon", "AssetManager.NewAsset#textBoxIconPath", commonlib.Binding.ControlTypes.ParaUI_editbox, "text")
		bindingContext:AddBinding(package, "Category", "AssetManager.comboBoxCategory", commonlib.Binding.ControlTypes.IDE_dropdownlistbox, "text")
		bindingContext:AddBinding(package, "bDisplayInMainBar", "AssetManager.checkBoxShowInMainbar", commonlib.Binding.ControlTypes.IDE_checkbox, "value")
		
		_guihelper.ShowDialogBox("Add a new package", nil, nil, 263, 114, 
		function(_parent)
			_this = ParaUI.CreateUIObject("container", "AssetManager.NewAsset", "_fi", 0,0,0,0)
			_this.background = "";
			_parent:AddChild(_this);
			_parent = _this;

			_this = ParaUI.CreateUIObject("editbox", "packageName", "_mt", 85, 3, 3, 23)
			_parent:AddChild(_this);

			_this = ParaUI.CreateUIObject("editbox", "textBoxIconPath", "_mt", 85, 58, 3, 23)
			_parent:AddChild(_this);

			NPL.load("(gl)script/ide/dropdownlistbox.lua");
			local ctl = CommonCtrl.dropdownlistbox:new{
				name = "AssetManager.comboBoxCategory",
				alignment = "_mt",
				left = 85,
				top = 32,
				width = 3,
				height = 22,
				dropdownheight = 106,
				parent = _parent,
				text = "",
				items = {"Creations.BCS.doors", "Creations.BCS.windows", "Creations.Normals.Trees", },
			};
			ctl:Show();

			NPL.load("(gl)script/ide/CheckBox.lua");
			local ctl = CommonCtrl.checkbox:new{
				name = "AssetManager.checkBoxShowInMainbar",
				alignment = "_lt",
				left = 3,
				top = 91,
				width = 166,
				height = 18,
				parent = _parent,
				isChecked = false,
				text = "添加到我的创作工具栏",
			};
			ctl:Show();
			
			bindingContext:UpdateDataToControls();
		end, 
		function(dialogResult)
			if(dialogResult == _guihelper.DialogResult.OK) then
				bindingContext:UpdateControlsToData();
				-- add to package list and update UI controls.
				Map3DSystem.App.Assets.AddPackage(package);
			end
			return true;
		end)
	end	
]]
function _guihelper.ShowDialogBox(title, x,y,width, height, ShowUI_func,OnClick_CallBack, buttons)
	if(type(OnClick_CallBack) == "string") then
		local pFunc = commonlib.getfield(OnClick_CallBack);
		if(type(pFunc) == "function") then
			OnClick_CallBack = pFunc;
		else
			log("warning: _guihelper.ShowDialogBox's OnClick_CallBack:"..OnClick_CallBack.." is not a valid function. \n")	
		end
	end
	_guihelper.Dialog_OnClick_CallBack = OnClick_CallBack;
	
	local temp = ParaUI.GetUIObject("IDE_HELPER_DIALOGBOX");
	if(temp:IsValid()) then 
		ParaUI.Destory("IDE_HELPER_DIALOGBOX");
	end
	
	local _this,_parent;
	local align = "_lt";
	if(x == nil or y==nil) then
		align = "_ct";
		x = -width/2;
		y = -height/2-50;
	end
	local boaderwidth = 5;
	_this=ParaUI.CreateUIObject("container","IDE_HELPER_DIALOGBOX", align,x,y,width+boaderwidth*2, height+60);
	_this:AttachToRoot();
	if(_guihelper.DialogBox_BG ~=nil) then
		_this.background = _guihelper.DialogBox_BG;
	end	
	_this.zorder = 1000;
	_this:SetTopLevel(true); -- _this.candrag and TopLevel and not be true simultanously 
	_parent = _this;
	
	local top = boaderwidth;
	if(title~=nil) then
		_this=ParaUI.CreateUIObject("text","b", "_lt",boaderwidth+10, boaderwidth,width-boaderwidth*2, 13);
		_parent:AddChild(_this);
		_guihelper.SetUIFontFormat(_this, 32);
		_this.text=title;
		top = top + 15;
	end
	-- the user content here
	_this=ParaUI.CreateUIObject("container","content", "_fi",boaderwidth, top,boaderwidth, 60-top);
	_this.background = "";
	_parent:AddChild(_this);
	if(ShowUI_func~=nil) then
		-- create user content
		ShowUI_func(_this);
	end
	
	if(not buttons)then
		buttons = _guihelper.MessageBoxButtons.OKCancel;
	end
	
	local left, top, width, height = -80, -34, 60, 22
	
	-- for speed, we use numbers
	if(buttons == 3 or buttons == 4 or buttons == 6) then
		-- cancel 
		_this=ParaUI.CreateUIObject("button","b", "_rb",left, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"Cancel";
		_this.onclick=";_guihelper.OnDialogBoxClick(_guihelper.DialogResult.Cancel);";
		
		left = left - width -10;
	end
	
	if(buttons == 5 or buttons == 6) then
		-- NO
		_this=ParaUI.CreateUIObject("button","b", "_rb",left, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"No";
		_this.onclick=";_guihelper.OnDialogBoxClick(_guihelper.DialogResult.No);";
		
		left = left - width -10;
		
		-- Yes
		_this=ParaUI.CreateUIObject("button","b", "_rb",left, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"Yes";
		_this.onclick=";_guihelper.OnDialogBoxClick(_guihelper.DialogResult.Yes);";
		
		left = left - width -10;
	end
	
	if(buttons == 2 or buttons == 3) then
		-- OK
		_this=ParaUI.CreateUIObject("button","b", "_rb",left, top,width, height);
		_parent:AddChild(_this);
		_this.text=L"OK";
		_this.onclick=";_guihelper.OnDialogBoxClick(_guihelper.DialogResult.OK);";
		
		left = left - width -10;
	end
	
end

-- dialog box call back. 
function _guihelper.OnDialogBoxClick(dialogResult)
	if(type(_guihelper.Dialog_OnClick_CallBack) == "function") then
		if(_guihelper.Dialog_OnClick_CallBack(dialogResult)) then
			ParaUI.Destroy("IDE_HELPER_DIALOGBOX");
		end
	else
		ParaUI.Destroy("IDE_HELPER_DIALOGBOX");	
	end	
end
