--[[
Title: new window frame UI for 3D Map system
Author(s): WangTian
Date: 2008/5/15
NOTE: original implementation is in script/kids/3DMapSystemUI/Windows.lua
		the old solution is deperacated
Desc: 
Use Lib:
--------------------------------------------
	NPL.load("(gl)script/ide/WindowFrame.lua");
	
	local _app = CommonCtrl.os.CreateApp("TestWindow");
	local _wnd = _app:FindWindow("Left2") or _app:RegisterWindow("Left2", nil, test.MSGProcCartoonFaceTabGrid);	
	
	local sampleWindowsParam = {
		wnd = _wnd,
		text = "LEFT2",
		icon = "Texture/checkbox.png",
		initialWidth = 300,
		initialHeight = 450,
		style = testStyle,
		alignment = "Left",
		ShowUICallback = Map3DSystem.UI.CCS.ShowAuraCartoonFace,
	};
	local frame = CommonCtrl.WindowFrame:new2(sampleWindowsParam);
	frame:Show2();
--------------------------------------------
]]
local libName = "WindowFrame";
local libVersion = "1.0";
local WindowFrame = commonlib.LibStub:NewLibrary(libName, libVersion);

CommonCtrl.WindowFrame = WindowFrame;

-- original windows class
-- TODO: currently the WindowFrame class wraps the original implementation
NPL.load("(gl)script/kids/3DMapSystemUI/Windows.lua");


local sampleWindowsParam = {
	wnd = nil, -- a CommonCtrl.os.window object
	
	--isUseUI = true,
	--mainBarIconSetID = 19, -- or nil -- DEPRECATED
	
	-- icon and text is shown in the middle on the top of the frame
	text = "Middle Text", -- text is shown in default size and font, but bold
	icon = "", -- icon size is specified in style
	
	isShowTitleBar = true, -- default show title bar
	isShowToolboxBar = false, -- default hide title bar
		--toolboxBarHeight = 48, -- default toolbar height
	isShowStatusBar = true, -- default show status bar
	
	initialWidth = 600, -- initial width of the window client area
	initialHeight = 450, -- initial height of the window client area
	
	---- we define different window style to be the default window for paraworld
	----		Application: application window contains an optional toolbar on the top and a status bar on the bottom
	----			All parameters are applicable to application window
	----		Document: document window contains an optional toolbar on the top, but no status bar
	----			All parameters are applicable to application window
	----		Dialog: dialog window contains no toolbar or status bar, and not resizable
	----			Can be nil texted, nil iconed, or without minimize/close button
	----		Panel: panel window contains no toolbar or status bar, and not resizable
	----		Container: Only dragable and showclose are applicable to container window
	----			If dragable and showclose are all false, it is a common container UI object in paraengine
	--style = "Document", -- Application|Document|Dialog|Panel|Container
	
	style = {}, -- window style, defining all the window components position
	theme = "", -- theme texture specification, please refer to wiki document
	
	alignment = "Bottom", -- Free|Left|Right|Bottom|LeftBottom
	-- NOTE: autohide will collect all the same alignment within the same application, and behave like Visual Studio
	--		enable/disable autohide will enable/disable all the windows with the same alignment in the same application
	enableautohide = false, -- only applicable to document window
	
	allowDrag = true, -- allow the window frame dragable
	allowResize = nil, -- boolean, allow the window frame sizeable, default to false. 
	
	maxWidth = 800, -- only applicable to application window and document window
	maxHeight = 600, -- only applicable to application window and document window
	minWidth = 400, -- only applicable to application window and document window, init size = initialWidth
	minHeight = 300, -- only applicable to application window and document window, init size = initialHeight
	
	opacity = 100, -- opacity value [0, 100]
	
	-- NOTE: this kind of window frame positioning is mainly for the right middle panel(Creator CCS Chat .etc)
	-- NOTE: directPosition will automaticly disable the resize and window drag but it also may send a WM_SIZE message when screen resolution changes
	directPosition = false, -- allow the windowframe to shown with the default alignment and position in ParaUI.CreateUIObject()
		-- the following is valid only when directPosition == true
		align = "_lt", -- ParaUI.CreateUIObject() alignment
		x = 50,
		y = 50,
		width = 400,
		height = 300,
	
	isShowMinimizeBox = false,
	isShowMaximizeBox = false,
	isShowAutoHideBox = false,
	isShowCloseBox = false,
	
	-- pinned window will stick on the screen regardless of appication switching
	isPinned = false,
	--isPinable = false, -- if the window pinable on the screen, show the pin box automaticly on true
	--initialPinned = false, -- initial pin status
	
	initialPosX = 200, -- if not specified, use 
	initialPosY = 150,
	
	-- whether to use fast render. default to true. 
	isFastRender = nil,
	
	-- animation file of the show process
	AnimFile_Show = "script/kids/3DMapSystemUI/styles/....xml", -- "" not using animation
	AnimFile_Hide = "script/kids/3DMapSystemUI/styles/....xml", -- "" not using animation
	
	-- set the window to top level
	-- NOTE: be careful with this setting. in some cases 
	--		top level window will ruin mouse enter-and-leave pairs 
	--		and currently drag-and-drop UI control
	isTopLevel = false, -- false or nil will set the window to normal UI container
	-- if true, the onmouseup event of the parent container will close the window. This function is usually used with isTopLevel=true, to emulate a dropdown popup window
	is_click_to_close = nil,
	-- zorder of the ParaUIObject, default value is 0, the larger the more top level.
	zorder = nil,
	
	ShowUICallback = nil,
};

-- create a window frame object
-- TODO: param sepcification
function WindowFrame:new(param)
	local _appName, _wndName, _document, _frame = Map3DSystem.UI.Windows.RegisterWindowFrame(param);
	setmetatable(_frame, self);
	self.__index = self;
	return _frame;
end

-- show the window frame according to the param in the object
function WindowFrame:Show(bShow)
	if(self.wnd == nil) then
		log("error: WindowFrame:Show(): frame object has no window information.\n");
		return;
	end
	Map3DSystem.UI.Windows.ShowWindow(bShow, self.wnd.app.name, self.wnd.name);
end

-- set the client area rect
-- NOTE: this function will automaticly reset the window position according to client area size change
function WindowFrame.SetScreenAreaRect(left, top, right, bottom)
	WindowFrame.left = left;
	WindowFrame.top = top;
	WindowFrame.right = right;
	WindowFrame.bottom = bottom;
end

-- TODO: init client area rectangle
WindowFrame.left = 0;
WindowFrame.top = 0;
WindowFrame.right = 0;
WindowFrame.bottom = 28; -- the rectangle change to 24, leaving safe pixels 24-48 for additional AppTaskBar space

-- get the client area rect
function WindowFrame.GetClientAreaRect()
	return WindowFrame.left, WindowFrame.top, WindowFrame.right, WindowFrame.bottom;
end

-- change the position of windows(free window mostly) according to the resolution
function WindowFrame.OnResolutionChange()
end


-- window set   WndSet[appname][windowname]
if(not WindowFrame.WndSet) then WindowFrame.WndSet = {}; end


-- left and right tab frames
if(not WindowFrame.LeftTabFrames) then WindowFrame.LeftTabFrames = {}; end
if(not WindowFrame.RightTabFrames) then WindowFrame.RightTabFrames = {}; end

-- add to left and right tab frames
function WindowFrame.AddToLeftTabFrames(frame)
	
	local i, node;
	for i, node in ipairs(WindowFrame.LeftTabFrames) do
		if(frame.wnd.name == node.wnd.name
			and frame.wnd.app.name == node.wnd.app.name) then
			--WindowFrame.ShowLeftFrame(i);
			WindowFrame.HideOtherLeftFrame(i);
			WindowFrame.RedrawLeftTab(i);
			return;
		end
	end
	table.insert(WindowFrame.LeftTabFrames, frame);
	--WindowFrame.ShowLeftFrame(table.getn(WindowFrame.LeftTabFrames));
	WindowFrame.HideOtherLeftFrame(table.getn(WindowFrame.LeftTabFrames));
	WindowFrame.RedrawLeftTab(table.getn(WindowFrame.LeftTabFrames));
end

function WindowFrame.AddToRightTabFrames(frame)
	local i, node;
	for i, node in ipairs(WindowFrame.RightTabFrames) do
		if(frame.wnd.name == node.wnd.name
			and frame.wnd.app.name == node.wnd.app.name) then
			WindowFrame.HideOtherRightFrame(i);
			WindowFrame.RedrawRightTab(i);
			return;
		end
	end
	table.insert(WindowFrame.RightTabFrames, frame);
	WindowFrame.HideOtherRightFrame(table.getn(WindowFrame.RightTabFrames));
	WindowFrame.RedrawRightTab(table.getn(WindowFrame.RightTabFrames));
end

function WindowFrame.RemoveFromLeftTabFrames(frame)
	
	local i, node;
	local index;
	for i, node in ipairs(WindowFrame.LeftTabFrames) do
		if(frame.wnd.name == node.wnd.name
			and frame.wnd.app.name == node.wnd.app.name) then
			index = i;
			break;
		end
	end
	
	if(index ~= nil) then
		table.remove(WindowFrame.LeftTabFrames, index);
		
		if(table.getn(WindowFrame.LeftTabFrames) ~= 0) then
			WindowFrame.RedrawLeftTab(1);
		else
			WindowFrame.RedrawLeftTab();
		end
	end
end

function WindowFrame.RemoveFromRightTabFrames(frame)
	local i, node;
	local index;
	for i, node in ipairs(WindowFrame.RightTabFrames) do
		if(frame.wnd.name == node.wnd.name
			and frame.wnd.app.name == node.wnd.app.name) then
			index = i;
			break;
		end
	end
	
	if(index ~= nil) then
		
		table.remove(WindowFrame.RightTabFrames, index);
		
		if(table.getn(WindowFrame.RightTabFrames) ~= 0) then
			WindowFrame.RedrawRightTab(1);
		else
			WindowFrame.RedrawRightTab();
		end
	end
end

-- redraw the left bar
function WindowFrame.RedrawLeftTab(i)
	if(i == nil) then
		-- hide the left tab
		local _titleBarLeft = ParaUI.GetUIObject("WindowFrame.LeftTabFrames");
		if(_titleBarLeft:IsValid() == true) then
			_titleBarLeft.visible = false;
		end
		return;
	end
	if(WindowFrame.LeftTabFrames[i] == nil) then
		return;
	end
	local frame = WindowFrame.LeftTabFrames[i];
	local _titleBarLeft = ParaUI.GetUIObject("WindowFrame.LeftTabFrames");
	if(_titleBarLeft:IsValid() == false) then
		_titleBarLeft = ParaUI.CreateUIObject("container", "WindowFrame.LeftTabFrames", "_lt", 0, 0, 0, 0);
		_titleBarLeft.background = "";
		_titleBarLeft.zorder = 1;
		_titleBarLeft:AttachToRoot();
	end
	_titleBarLeft.visible = true;
	_titleBarLeft:RemoveAll();
	_titleBarLeft.width = frame.width + frame.borderLeft + frame.borderRight;
	_titleBarLeft.height = frame.style.titleBarHeight;
	
	frame.style.titleBarOwnerDraw(_titleBarLeft, WindowFrame.LeftTabFrames);
	
	local ctl = CommonCtrl.GetControl("LeftWindowsTabs");
	if(ctl ~= nil) then
		ctl:SetLevelIndex(i, nil);
	end
end

-- redraw the right bar
function WindowFrame.RedrawRightTab(i)
	if(i == nil) then
		-- hide the left tab
		local _titleBarRight = ParaUI.GetUIObject("WindowFrame.RightTabFrames");
		if(_titleBarRight:IsValid() == true) then
			_titleBarRight.visible = false;
		end
		return;
	end
	if(WindowFrame.RightTabFrames[i] == nil) then
		return;
	end
	local frame = WindowFrame.RightTabFrames[i];
	local _titleBarRight = ParaUI.GetUIObject("WindowFrame.RightTabFrames");
	if(_titleBarRight:IsValid() == false) then
		_titleBarRight = ParaUI.CreateUIObject("container", "WindowFrame.RightTabFrames", "_rt", 0, 0, 0, 0);
		_titleBarRight.background = "";
		_titleBarRight.zorder = 1;
		_titleBarRight:AttachToRoot();
	end
	_titleBarRight.visible = true;
	_titleBarRight:RemoveAll();
	_titleBarRight.x = -(frame.width + frame.borderLeft + frame.borderRight);
	_titleBarRight.width = frame.width + frame.borderLeft + frame.borderRight;
	_titleBarRight.height = frame.style.titleBarHeight;
	
	frame.style.titleBarOwnerDraw(_titleBarRight, WindowFrame.RightTabFrames);
	
	local ctl = CommonCtrl.GetControl("RightWindowsTabs");
	if(ctl ~= nil) then
		ctl:SetLevelIndex(i, nil);
	end
end

function WindowFrame.HideOtherLeftFrame(index)
	local i, frame;
	for i, frame in ipairs(WindowFrame.LeftTabFrames) do
		if(i ~= index) then
			frame:SetVisible(false);
		end
	end
end

function WindowFrame.HideOtherRightFrame(index)
	local i, frame;
	for i, frame in ipairs(WindowFrame.RightTabFrames) do
		if(i ~= index) then
			frame:SetVisible(false);
		end
	end
end

-- clear left and right tab frames
function WindowFrame.ClearLeftTabFrames()
	WindowFrame.LeftTabFrames = {};
	
	local _titleBarLeft = ParaUI.GetUIObject("WindowFrame.LeftTabFrames");
	if(_titleBarLeft:IsValid() == true) then
		_titleBarLeft.visible = false;
	end
end

function WindowFrame.ClearRightTabFrames()
	WindowFrame.RightTabFrames = {};
	
	local _titleBarRight = ParaUI.GetUIObject("WindowFrame.RightTabFrames");
	if(_titleBarRight:IsValid() == true) then
		_titleBarRight.visible = false;
	end
end

-- create a window frame object
-- TODO: param sepcification
-- @param param: table containing the window information parameters
function WindowFrame:new2(param)
	-- table information check
	if(param.wnd == nil) then
		log("error: WindowFrame:new(): param table has no os.window information.\n");
		return;
	end
	
	if(param.ShowUICallback == nil) then
		log("error: WindowFrame:new(): param table has no ShowUICallback function.\n");
		return;
	end
	
	param.text = param.text or "Untitled"; -- default "Untitled"
	
	if(param.isShowTitleBar == nil) then
		param.isShowTitleBar = true; -- default show title bar
	end
	if(param.isShowToolboxBar == nil) then
		param.isShowToolboxBar = false; -- default hide toolbox bar
	end
	if(param.isShowStatusBar == nil) then
		param.isShowStatusBar = false; -- default hide status bar
	end
	
	-- initialWidth/Height is the old param name
	param.width = param.width or param.initialWidth or 600; -- default 600
	param.height = param.height or param.initialHeight or 450; -- default 450
	
	--param.style = param.style or "Document"; -- default document window
	--param.styleTexture = param.styleTexture or "Texture/3DMapSystem/WindowFrameStyle/1/frame.png"; -- default document window
	param.style = param.style or WindowFrame.DefaultStyle; -- default window style
	param.theme = param.theme or "Texture/3DMapSystem/WindowFrameStyle/1/frame.png"; -- default window theme
	
	param.alignment = param.alignment or "Free"; -- default window alignment
	
	if(param.enableautohide == nil) then
		param.enableautohide = false; -- default disable autohide
	end
	
	if(param.allowDrag == nil) then
		param.allowDrag = true; -- default allow drag
	end
	if(param.allowResize == nil) then
		param.allowResize = false; -- default allow resize
	end
	
	param.maxWidth = param.maxWidth or param.initialWidth; -- default initialWidth
	param.maxHeight = param.maxHeight or param.initialHeight; -- default initialHeight
	param.minWidth = param.minWidth or param.initialWidth; -- default initialWidth
	param.minHeight = param.minHeight or param.initialHeight; -- default initialHeight
	
	param.opacity = param.opacity or 100; -- default non transparent window frame background
	
	if(param.directPosition == nil) then
		param.directPosition = false;
	elseif(param.directPosition == true) then
		param.allowResize = false;
		--param.allowDrag = false; -- removed lxz:2008.11.1
	end
	
	if(param.allowResize and (maxWidth ~= minWidth or maxHeight ~= minHeight) ) then
		if(param.isShowMaximizeBox == nil) then
			param.isShowMaximizeBox = true;
		end
	else
		if(param.isShowMaximizeBox == nil) then
			param.isShowMaximizeBox = false;
		end
	end
	if(param.isShowMinimizeBox == nil) then
		param.isShowMinimizeBox = false; -- default show min box
	end
	if(param.isShowCloseBox == nil) then
		param.isShowCloseBox = true; --  default show close box
	end
	
	if(param.isPinned == nil) then
		param.isPinned = false; --  default not pinned window
	end
	
	--if(param.isPinable == nil) then
		--param.isPinable = false; --  default not pinable window
	--end
	--
	--if(param.isPinable == true and param.initialPinned == nil) then
		--param.initialPinned = false; --  default unpinned window
	--end
	
	-- isShowAutoHideBox = false
	
	param.initialPosX = param.initialPosX or 150; -- if not specified, use 150
	param.initialPosY = param.initialPosY or 150; -- if not specified, use 150
	
	---- put the window inside the screen area
	--local x, y, width, height = WindowFrame.GetInsideScreenPosition(param.initialPosX, param.initialPosY, 
			--param.initialWidth, param.initialHeight);
	--param.initialPosX, param.initialPosY = x, y;
	--param.initialWidth, param.initialHeight = width, height;
	
	if(param.isTopLevel == nil) then
		param.isTopLevel = false; -- default non top level window
	end
	
	if(param.alignment == "Free") then
		-- default animation
		param.AnimFile_Show = param.AnimFile_Show or "script/ide/WindowFrameMotion/FreeShow.xml";
		param.AnimFile_Hide = param.AnimFile_Hide or "script/ide/WindowFrameMotion/FreeHide.xml";
	elseif(param.alignment == "Left") then
		-- default animation
		param.AnimFile_Show = param.AnimFile_Show or "script/ide/WindowFrameMotion/LeftShow.xml";
		param.AnimFile_Hide = param.AnimFile_Hide or "script/ide/WindowFrameMotion/LeftHide.xml";
	elseif(param.alignment == "Right") then
		-- default animation
		param.AnimFile_Show = param.AnimFile_Show or "script/ide/WindowFrameMotion/RightShow.xml";
		param.AnimFile_Hide = param.AnimFile_Hide or "script/ide/WindowFrameMotion/RightHide.xml";
	elseif(param.alignment == "Bottom" or param.alignment == "LeftBottom") then
		-- default animation
		param.AnimFile_Show = param.AnimFile_Show or "script/ide/WindowFrameMotion/BottomShow.xml";
		param.AnimFile_Hide = param.AnimFile_Hide or "script/ide/WindowFrameMotion/BottomHide.xml";
	end
	
	local _appName = param.wnd.app.name;
	local _wndName = param.wnd.name;
	
	---- find in WndSet table if application exists
	--if(not WindowFrame.WndSet[_appName]) then
		--WindowFrame.WndSet[_appName] = {};
		--
		---- create left windows tab
		--NPL.load("(gl)script/ide/MainMenu.lua");
		--local ctl = CommonCtrl.MainMenu:new{
			--name = _appName.."_WindowFrame_LeftTab",
			--alignment = "_lb",
			--left = 0,
			--top = - WindowFrame.bottom - param.style.titleBarHeight,
			--width = 150, -- change according to the windows width
			--height = param.style.titleBarHeight,
			--parent = nil,
			--container_bg = "Texture/item.png",
			----SelectedTextColor = "190 118 0",
			--SelectedTextColor = "0 0 0",
			--MouseOverItemBG = "",
			--UnSelectedMenuItemBG = "Texture/3DMapSystem/common/ThemeLightBlue/tabitem_unselected.png: 6 6 6 2",
			--SelectedMenuItemBG = "Texture/3DMapSystem/common/ThemeLightBlue/tabitem_selected.png: 6 6 6 2",
		--};
		--
		---- create right windows tab
		--NPL.load("(gl)script/ide/MainMenu.lua");
		--local ctl = CommonCtrl.MainMenu:new{
			--name = _appName.."_WindowFrame_RightTab",
			--alignment = "_rb",
			--left = -150,
			--top = - WindowFrame.bottom - param.style.titleBarHeight,
			--width = 150, -- change according to the windows width
			--height = param.style.titleBarHeight,
			--parent = nil,
			--container_bg = "Texture/item.png",
			----SelectedTextColor = "190 118 0",
			--SelectedTextColor = "0 0 0",
			--MouseOverItemBG = "",
			--UnSelectedMenuItemBG = "Texture/3DMapSystem/common/ThemeLightBlue/tabitem_unselected.png: 6 6 6 2",
			--SelectedMenuItemBG = "Texture/3DMapSystem/common/ThemeLightBlue/tabitem_selected.png: 6 6 6 2",
		--};
		--
		---- create bottom windows tab
		--NPL.load("(gl)script/ide/MainMenu.lua");
		--local ctl = CommonCtrl.MainMenu:new{
			--name = _appName.."_WindowFrame_BottomTab",
			--alignment = "_ctb",
			--left = 0,
			--top = - WindowFrame.bottom,
			--width = 150, -- change according to the windows width
			--height = param.style.titleBarHeight,
			--parent = nil,
			--container_bg = "Texture/item.png",
			----SelectedTextColor = "190 118 0",
			--SelectedTextColor = "0 0 0",
			--MouseOverItemBG = "",
			--UnSelectedMenuItemBG = "Texture/3DMapSystem/common/ThemeLightBlue/tabitem_unselected.png: 6 6 6 2",
			--SelectedMenuItemBG = "Texture/3DMapSystem/common/ThemeLightBlue/tabitem_selected.png: 6 6 6 2",
		--};
	--end
	
	-- find in WndSet table if application exists
	if(not WindowFrame.WndSet[_appName]) then
		WindowFrame.WndSet[_appName] = {};
	end
	
	-- find in WndSet table if window exists
	if(not WindowFrame.WndSet[_appName][_wndName]) then
		WindowFrame.WndSet[_appName][_wndName] = param;
	else
		log("warning: window to be registered: app:".._appName.." window:".._wndName.." already exists. \r\n");
		-- TODO: replace with the new window param and window?
		return WindowFrame.WndSet[_appName][_wndName];
	end
	
	setmetatable(param, self);
	self.__index = self;
	return param;
end

-- whether the window frame is currently visible
function WindowFrame:IsVisible()
	local _window = ParaUI.GetUIObject(self.wnd.app.name.."_"..self.wnd.name.."_window")
	if(_window and _window:IsValid() == true) then
		return _window.visible;
	end
	return false;
end

-- destroy the window itself and the item in tab bar
-- NOTE: both the UI object AND the NPL table object, so after Destroy() called GetWindowFrame2(appName, wndName) should get nil
-- 
-- NOTE: close button click didn't Destroy() the window on click the close button
--		it's up to the message processor to define its behavior(Destroy() or Show(false))
function WindowFrame:Destroy()
	
	---- destroy the item in tab bar
	--if(self.alignment == "Left" or self.alignment == "Right" or self.alignment == "Bottom") then
		--local ctl = CommonCtrl.GetControl(self.wnd.app.name.."_WindowFrame_"..self.alignment.."Tab");
		--if(ctl ~= nil) then
			--local nCount = ctl.RootNode:GetChildCount();
			--local i;
			--for i = 1, nCount do
				--local node = ctl.RootNode:GetChild(i);
				--if(node.AppName == self.wnd.app.name and node.WndName == self.wnd.name) then
					--node.Name = "RemoveMe!";
					--ctl.RootNode:RemoveChildByName("RemoveMe!");
					--break;
				--end
			--end
			--if(nCount == 1 or nCount == 2) then
				---- hide the tab bar
				--
				--WindowFrame.PreHideWindowsTab(self.wnd.app.name, self.alignment);
				--ctl:Show(false);
				--if(nCount == 2) then
					---- set focus on the only window
					--ctl:SetSelectedIndex(1);
				--end
			--elseif(nCount >= 3) then
				--ctl:Update();
				---- set focus on the first window
				--ctl:SetSelectedIndex(1);
			--end
		--end
	--end
	
	self.MinimizedPointX = nil;
	self.MinimizedPointY = nil;
	
	self:Show2(false, true);
	
	-- NOTE: @param bDestory: only used at destroy functions, normal function call sequence will cause program crash
	--		due to the container is destroyed immediately after Show2(false); call
	--		if bDestory is true and bShow is false, the animation process will delay the destroy call at animation complete callback	
	
	---- destroy the window frame
	--ParaUI.Destroy(self.wnd.app.name.."_"..self.wnd.name.."_window");
	
	WindowFrame.WndSet[self.wnd.app.name][self.wnd.name] = nil;
end

--function WindowFrame.PreShowWindowsTab(appName, alignment)
	---- reset all window above by titleBar height
	--local k, v;
	--for k, v in pairs(WindowFrame.WndSet[appName]) do
		--local _window = ParaUI.GetUIObject(v.wnd.app.name.."_"..v.wnd.name.."_window");
		--if(_window:IsValid() == true) then
			--if(v.alignment == alignment) then
				--if(v.alignment == "Left" or v.alignment == "Right") then
					--_window.height = WindowFrame.bottom + v.style.titleBarHeight;
					--NPL.load("(gl)script/ide/os.lua");
					--local _wnd = v.wnd;
					--v.wnd:SendMessage(v.wnd.name, CommonCtrl.os.MSGTYPE.WM_SIZE);
				--elseif(v.alignment == "Bottom") then
					--_window.y = - WindowFrame.bottom - v.style.titleBarHeight;
				--end
			--end
		--end
	--end
--end


--function WindowFrame.PreHideWindowsTab(appName, alignment)
	---- reset all window below by titleBar height
	--local k, v;
	--for k, v in pairs(WindowFrame.WndSet[appName]) do
		--local _window = ParaUI.GetUIObject(v.wnd.app.name.."_"..v.wnd.name.."_window");
		--if(_window:IsValid() == true) then
			--if(v.alignment == alignment) then
				--if(v.alignment == "Left" or v.alignment == "Right") then
					--_window.height = WindowFrame.bottom; -- height doesn't change
					--NPL.load("(gl)script/ide/os.lua");
					--local _wnd = v.wnd;
					--v.wnd:SendMessage(v.wnd.name, CommonCtrl.os.MSGTYPE.WM_SIZE);
				--elseif(v.alignment == "Bottom") then
					--_window.y = - WindowFrame.bottom;
				--end
			--end
		--end
	--end
--end

-- show the window frame according to the param in the object
-- @param bShow: show or hide the window
-- 
-- NOTE: close button click didn't Show(false) the window on click the close button
--		it's up to the message processor to define its behavior(Destroy() or Show(false))
--
-- NOTE: @param bDestory: only used at destroy functions, normal function call sequence will cause program crash
--		due to the container is destroyed immediately after Show2(false); call
--		if bDestory is true and bShow is false, the animation process will delay the destroy call at animation complete callback
-- @param bSilentInit: if true, the window is init but not show, especially not using animation,
--		currently this type of windowframe is used in chat window when the user received a message that don't have a windowframe object binded
function WindowFrame:Show2(bShow, bDestory, bSilentInit)
	local _wnd = self.wnd;
	local _ShowUICallback = self.ShowUICallback;
	
	local _isShowTitleBar = self.isShowTitleBar;
	local _isShowToolboxBar = self.isShowToolboxBar;
	local _isShowStatusBar = self.isShowStatusBar;
	
	local _width = self.width;
	local _height = self.height;
	
	local _style = self.style;
	local _theme = self.theme;
	
	local _alignment = self.alignment;
	local _enableautohide = self.enableautohide;
	
	local _allowDrag = self.allowDrag;
	local _allowResize = self.allowResize;
	
	local _maxWidth = self.maxWidth;
	local _maxHeight = self.maxHeight;
	local _minWidth = self.minWidth;
	local _minHeight = self.minHeight;
	
	local _opacity = self.opacity;
	
	local _isShowMaximizeBox = self.isShowMaximizeBox;
	local _isShowMinimizeBox = self.isShowMinimizeBox;
	local _isShowCloseBox = self.isShowCloseBox;
	--local _isPinable = self.isPinable;
	--local _initialPinned = self.initialPinned;
	
	--local _isShowAutoHideBox = self.isShowAutoHideBox;
	
	local _isFastRender = self.isFastRender;
	local _initialPosX = self.initialPosX;
	local _initialPosY = self.initialPosY;
	
	local _cancelShowAnimation = self.cancelShowAnimation;
	local _frameEnabled = self.frameEnabled;
	
	local function isOnPreviousFramePos(X, Y)
		local wndName, frame;
		for wndName, frame in pairs(WindowFrame.WndSet[self.wnd.app.name]) do
			--commonlib.echo(frame);
			local _window = frame:GetWindowUIObject();
			if(wndName ~= _wnd.name and _window and _window:IsValid() == true and _window.visible == true) then
				local x, y, width, height = _window:GetAbsPosition();
				if(X == x and Y == y) then
					return true;
				end
			end
		end
		return false;
	end
	
	local offset = _style.titleBarHeight;
	while(isOnPreviousFramePos(_initialPosX, _initialPosY) == true) do
		_initialPosX = _initialPosX + _style.titleBarHeight;
		_initialPosY = _initialPosY + _style.titleBarHeight;
		local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
		if(_initialPosY > (screenHeight/2)) then
			_initialPosY = self.initialPosY; -- wrap to the original position
		end
	end
	
	local window_obj_name = _wnd.app.name.."_".._wnd.name.."_window";
	local _window = ParaUI.GetUIObject(window_obj_name);
	local _window_toplevel = ParaUI.GetUIObject(window_obj_name.."_window_toplevel");
	
	local preShowWindowVisible;
	if(_window:IsValid() == true) then
		-- stop the previous animation
		if(UIAnimManager.IsDirectAnimating(_window)) then
			UIAnimManager.StopDirectAnimation(_window)
		end
		preShowWindowVisible = _window.visible;
		if(bShow == nil) then
			bShow = not _window.visible;
		end
		
		if(_window.visible == false and bShow == true) then
			if(self.ShowMotion ~= nil) then
				-- play Show animation
				--self.ShowMotion:doPlay();
			end
		elseif(_window.visible == true and bShow == false) then
			if(self.HideMotion ~= nil) then
				-- play Hide animation
				--self.HideMotion:doPlay();
			end
		end

		if(_window.visible~=bShow) then
			_window.visible = bShow;
			if(self.wnd) then
				self.wnd:SendMessage(nil, CommonCtrl.os.MSGTYPE.WM_SHOW, bShow);
			end
		end

		if(_window_toplevel:IsValid()) then
			_window_toplevel.visible = bShow;
		end
	else
		preShowWindowVisible = false;
		if(bShow == false) then
			return;
		end
		
		local borderTop = 0;
		local borderBottom = 0;
		local borderLeft = 0;
		local borderRight = 0;
		
		if(_isShowTitleBar) then
			borderTop = borderTop + _style.titleBarHeight;
		end
		if(_isShowToolboxBar) then
			borderTop = borderTop + _style.toolboxBarHeight;
		end
		if(_isShowStatusBar) then
			borderBottom = borderBottom + _style.statusBarHeight;
		end
		borderLeft = _style.borderLeft;
		borderRight = _style.borderRight;
		if(_style.borderBottom) then
			borderBottom = borderBottom + _style.borderBottom
		end	
		if(_style.borderTop) then
			borderTop = borderTop + _style.borderTop
		end
		
		-- record the border size and window size
		self.borderLeft = borderLeft;
		self.borderRight = borderRight;
		self.borderTop = borderTop;
		self.borderBottom = borderBottom;
		
		if(self.directPosition == true) then
			-- directly create the ui object using the positions in the param
			_window = ParaUI.CreateUIObject("container", window_obj_name, 
				self.align, self.x, self.y, self.width, self.height);
		elseif(self.alignment == "Free" or self.alignment == nil) then
			-- free window mode
			-- main window UI container
			_window = ParaUI.CreateUIObject("container", window_obj_name, 
				"_lt", _initialPosX, _initialPosY, _width + borderLeft + borderRight, _height + borderTop + borderBottom);
		elseif(self.alignment == "LeftBottom") then
			-- force disable the drag and resize
			_allowResize = false;
			_allowDrag = false;
			_isShowMaximizeBox = false;
			_isShowMinimizeBox = false;
			
			-- left bottom window mode
			-- main window UI container
			_window = ParaUI.CreateUIObject("container", window_obj_name, 
				"_lb", _initialPosX, -WindowFrame.bottom - (_height + borderTop + borderBottom)-_initialPosY, 
				_width + borderLeft + borderRight, _height + borderTop + borderBottom);
		elseif(self.alignment == "Left" or self.alignment == "Right" or self.alignment == "Bottom") then
			-- force disable the drag and resize
			_allowResize = false;
			_allowDrag = false;
			_isShowMaximizeBox = false;
			_isShowMinimizeBox = false;
			
			-- main window UI container
			if(self.alignment == "Left") then
				_window = ParaUI.CreateUIObject("container", window_obj_name, 
					"_ml", 0, WindowFrame.top, _width + borderLeft + borderRight, WindowFrame.bottom);
			elseif(self.alignment == "Right") then
				_window = ParaUI.CreateUIObject("container", window_obj_name, 
					"_mr", 0, WindowFrame.top, _width + borderLeft + borderRight, WindowFrame.bottom);
			elseif(self.alignment == "Bottom") then
				_window = ParaUI.CreateUIObject("container", window_obj_name, 
					"_ctb", 0, -WindowFrame.bottom, _width + borderLeft + borderRight, _height + borderTop + borderBottom);
			end
		end
		
		if(_frameEnabled == false) then
			_window.enabled = false;
		end
		if(self.click_through ~= nil and not _allowDrag) then
			_window:GetAttributeObject():SetField("ClickThrough", self.click_through);
		end
		
		if(type(self.zorder) == "number") then
			_window.zorder = self.zorder;
		end
		_window.candrag = _allowDrag;
		_window.background = "";
		-- so that drag can be ended on any where on the screen. 
		_window.ondragbegin = [[;ParaUI.AddDragReceiver("root");]];
		_window.onactivate = ";CommonCtrl.WindowFrame.OnActivateWindowFrame();";
		_window.background = _frameBG;
		if(self.isTopLevel == true) then
			local _window_toplevel = ParaUI.CreateUIObject("container", window_obj_name.."_window_toplevel", "_fi", 0, 0, 0, 0);
			if(type(self.zorder) == "number") then
				_window_toplevel.zorder = self.zorder;
			end
			_window_toplevel.background = "";
			_window_toplevel:AttachToRoot();
			_window_toplevel:AddChild(_window);
			local _window_toplevel_response = ParaUI.CreateUIObject("button", window_obj_name.."_window_toplevel_response", "_fi", 0, 0, 0, 0);
			_window_toplevel_response.background = "";

			if(self.is_click_to_close) then
				_window_toplevel_response.onclick = string.format([[;CommonCtrl.WindowFrame.OnClickClose("%s", "%s");]], self.wnd.app.name, self.wnd.name);
			end

			_window_toplevel:AddChild(_window_toplevel_response);
		else
			_window:AttachToRoot();
		end
		
		if(bSilentInit == true) then
			_window.visible = false;
		end
		
		local _shadow = ParaUI.CreateUIObject("container", "Shadow", "_fi", 
			_style.fillShadowLeft or 0, _style.fillShadowTop or 0, _style.fillShadowWidth or 0, _style.fillShadowHeight or 0);
		_shadow.background = _style.shadow_bg or "";
		_shadow.color = "255 255 255 255";
		_shadow.enabled = false;
		_window:AddChild(_shadow);
		
		
		local _BG = ParaUI.CreateUIObject("container", "BG", "_fi", 
			_style.fillBGLeft or 0, _style.fillBGTop or 0, _style.fillBGWidth or 0, _style.fillBGHeight or 0);
		_BG.background = _style.window_bg;
		_BG.color = "255 255 255 "..math.floor(_opacity * 2.55);
		_BG.enabled = false;
		_window:AddChild(_BG);
		
		
		if(_isShowTitleBar == true) then
			if(self.style.titleBarOwnerDraw ~= nil) then
				-- user onwer draw over the window frame
			else
				if(self.style.IconBox and self.style.TextBox) then
					-- render the text and icon according to the iconbox and textbox
					local _icon = ParaUI.CreateUIObject("button", "icon", self.style.IconBox.alignment, 
							self.style.IconBox.x, self.style.IconBox.y, self.style.IconBox.size, self.style.IconBox.size);
					_icon.background = self.icon or "";
					_icon.enabled = false;
					_guihelper.SetUIColor(_icon, "255 255 255")
					_window:AddChild(_icon);
					
					local _text = ParaUI.CreateUIObject("text", "text", self.style.TextBox.alignment, 
							self.style.TextBox.x, self.style.TextBox.y, 1000, self.style.TextBox.height); -- as long as possible
					_text.background = "";
					_text.enabled = false;
					_text.text = self.text;
					_text.font = self.style.textfont or "System;12;bold"; -- bold the title text
					_window:AddChild(_text);
					if(self.style.textcolor) then
						_guihelper.SetFontColor(_text, self.style.textcolor);
					end
				else
					local _textwidth = 0;
					if(self.text ~= nil) then
						--local y = (_style.titleBarHeight - 26)/2;
						local _text = ParaUI.CreateUIObject("button", "text", "_ctt", 0, 0, 0, _style.titleBarHeight + 4);
						_text.background = "";
						_text.enabled = false;
						_text.text = self.text;
						_text.font = self.style.textfont or "System;12;bold"; -- bold the title text
						_textwidth = _guihelper.GetTextWidth(self.text)+8;
						_text.width = _textwidth + 8;
						_window:AddChild(_text);
						if(self.style.textcolor) then
							_guihelper.SetFontColor(_text, self.style.textcolor);
						end
						-- _guihelper.SetUIFontFormat(_text, 36); -- single line vertically centered. 
					end
					
					if(self.icon ~= nil) then
						local y = (_style.titleBarHeight - _style.iconSize)/2;
						local _icon = ParaUI.CreateUIObject("button", "icon", "_ctt", 
								- _style.iconSize/2 - _style.iconTextDistance - _textwidth/2, y, _style.iconSize, _style.iconSize);
						_icon.background = self.icon;
						_icon.enabled = false;
						_guihelper.SetUIColor(_icon, "255 255 255")
						_window:AddChild(_icon);
					end
				end
				
				--local _isPinable = self.isPinable;
				--local _initialPinned = self.initialPinned;
				--
				--if(_isPinable) then
					---- show the pin box automaticly on pinable window
					--local _pin = ParaUI.CreateUIObject("button", "Pin", 
						--_style.PinBox.alignment, _style.PinBox.x, _style.PinBox.y, _style.PinBox.size, _style.PinBox.size);
					--if(_initialPinned == true) then
						--_pin.background = _style.PinBox.icon_pinned;
						--self:SetWindowPinned(true);
					--else
						--_pin.background = _style.PinBox.icon_unpinned;
						--self:SetWindowPinned(false);
					--end
					--_pin.onclick = string.format([[;CommonCtrl.WindowFrame.OnClickPin("%s", "%s");]], self.wnd.app.name, self.wnd.name);
					--_window:AddChild(_pin);
				--end
				
				if(_isShowCloseBox) then
					local _close = ParaUI.CreateUIObject("button", "Close", 
						_style.CloseBox.alignment, _style.CloseBox.x, _style.CloseBox.y, 
						_style.CloseBox.sizex or _style.CloseBox.size, _style.CloseBox.sizey or _style.CloseBox.size);
					--_close.background = _style.CloseBox.icon;
					_guihelper.SetVistaStyleButton3(_close, 
							_style.CloseBox.icon, 
							_style.CloseBox.icon_over or _style.CloseBox.icon, 
							_style.CloseBox.icon, 
							_style.CloseBox.icon_pressed or _style.CloseBox.icon);
					_close.onclick = string.format([[;CommonCtrl.WindowFrame.OnClickClose("%s", "%s");]], self.wnd.app.name, self.wnd.name);
					_window:AddChild(_close);
				end
				
				if(_isShowMaximizeBox) then
					local _max = ParaUI.CreateUIObject("button", "Max", 
						_style.MaxBox.alignment, _style.MaxBox.x, _style.MaxBox.y, 
						_style.MaxBox.sizex or _style.MaxBox.size, _style.MaxBox.sizey or _style.MaxBox.size);
					--_max.background = _style.MaxBox.icon;
					_guihelper.SetVistaStyleButton3(_max, 
							_style.MaxBox.icon, 
							_style.MaxBox.icon_over or _style.MaxBox.icon, 
							_style.MaxBox.icon, 
							_style.MaxBox.icon_pressed or _style.MaxBox.icon);
					_max.onclick = string.format([[;CommonCtrl.WindowFrame.OnClickMax("%s", "%s");]], self.wnd.app.name, self.wnd.name);
					_window:AddChild(_max);
					
					if(_isShowMinimizeBox) then
						local _min = ParaUI.CreateUIObject("button", "Min", 
							_style.MinBox.alignment, _style.MinBox.x, _style.MinBox.y, 
							_style.MinBox.sizex or _style.MinBox.size, _style.MinBox.sizey or _style.MinBox.size);
						--_min.background = _style.MinBox.icon;
						_guihelper.SetVistaStyleButton3(_min, 
								_style.MinBox.icon, 
								_style.MinBox.icon_over or _style.MinBox.icon, 
								_style.MinBox.icon, 
								_style.MinBox.icon_pressed or _style.MinBox.icon);
						_min.onclick = string.format([[;CommonCtrl.WindowFrame.OnClickMin("%s", "%s");]], self.wnd.app.name, self.wnd.name);
						_window:AddChild(_min);
					end
				else
					-- if hide max button, show the min button in the max position
					if(_isShowMinimizeBox) then
						local _min = ParaUI.CreateUIObject("button", "Min", 
							_style.MaxBox.alignment, _style.MaxBox.x, _style.MaxBox.y, 
							_style.MaxBox.sizex or _style.MaxBox.size, _style.MaxBox.sizey or _style.MaxBox.size);
						--_min.background = _style.MinBox.icon;
						_guihelper.SetVistaStyleButton3(_min, 
								_style.MinBox.icon, 
								_style.MinBox.icon_over or _style.MinBox.icon, 
								_style.MinBox.icon, 
								_style.MinBox.icon_pressed or _style.MinBox.icon);
						_min.onclick = string.format([[;CommonCtrl.WindowFrame.OnClickMin("%s", "%s");]], self.wnd.app.name, self.wnd.name);
						_window:AddChild(_min);
					end
				end
			end
		end
		
		local _toolboxBar;
		if(_isShowToolboxBar == true) then
			if(_isShowTitleBar) then
				_toolboxBar = ParaUI.CreateUIObject("container", "ToolboxBar", "_mt", 0, _style.titleBarHeight, 0, _style.toolboxBarHeight);
			else
				_toolboxBar = ParaUI.CreateUIObject("container", "ToolboxBar", "_mt", 0, 0, 0, _style.toolboxBarHeight);
			end
			--_toolboxBar.candrag = _allowDrag;
			--_toolboxBar.ondragbegin = string.format([[;CommonCtrl.WindowFrame.DragParentBegin("%s", "%s");]], self.wnd.app.name, self.wnd.name);
			--_toolboxBar.ondragmove = string.format([[;CommonCtrl.WindowFrame.DragParentMove("%s", "%s");]], self.wnd.app.name, self.wnd.name);
			--_toolboxBar.ondragend = string.format([[;CommonCtrl.WindowFrame.DragParentEnd("%s", "%s");]], self.wnd.app.name, self.wnd.name);
			_window:AddChild(_toolboxBar);
		end
		
		-- dragable _m* alignment ui object distortion during dragging process
		
		--function WindowFrame.DragParentBegin(appName, wndName)
			--local x, y = ParaUI.GetMousePosition();
			--local _parent = ParaUI.GetUIObjectAtPoint(x, y);
			--if(_parent:IsValid() == true) then
				--WindowFrame.parent = _parent;
				--WindowFrame.startX = _parent.x;
				--WindowFrame.startY = _parent.y;
				--WindowFrame.startMousePosX = x;
				--WindowFrame.startMousePosY = y;
				--
				--log(WindowFrame.parent.name.." "..WindowFrame.startX.." "..WindowFrame.startY.."\n")
			--end
		--end
		--
		--function WindowFrame.DragParentMove(appName, wndName)
			--local _parent = WindowFrame.parent;
			--if(_parent:IsValid() == true) then
				--local x, y = ParaUI.GetMousePosition();
				--_parent.x = WindowFrame.startX + x - WindowFrame.startMousePosX;
				--_parent.y = WindowFrame.startY + y - WindowFrame.startMousePosY;
			--end
		--end
		--
		--function WindowFrame.DragParentEnd(appName, wndName)
			--WindowFrame.parent = nil;
			--WindowFrame.startX = nil;
			--WindowFrame.startY = nil;
			--WindowFrame.startMousePosX = nil;
			--WindowFrame.startMousePosY = nil;
		--end
		
		local _statusBar;
		if(_isShowStatusBar == true) then
			_statusBar = ParaUI.CreateUIObject("container", "StatusBar", "_mb", 0, 0, 0, _style.statusBarHeight);
			_window:AddChild(_statusBar);
		end
		
		local _client;
		_client = ParaUI.CreateUIObject("container", "Client", "_fi", borderLeft, borderTop, borderRight, borderBottom);
		if(_isFastRender~=nil) then
			_client.fastrender = _isFastRender;
		end	
		if(self.click_through ~= nil and not _allowDrag) then
			_client:GetAttributeObject():SetField("ClickThrough", self.click_through);
			if(self.click_through == false) then
				_client.onclick = ";";
			end
		end
		_client.background = "";
		_window:AddChild(_client);
		
		if(_allowResize) then
			-- resizer container
			local _resizer_BG = ParaUI.CreateUIObject("container", "resizerBG", "_rb", 
				-_style.resizerSize, -_style.resizerSize, _style.resizerSize, _style.resizerSize);
			_resizer_BG.background = _style.resizer_bg;
			_window:AddChild(_resizer_BG);
			
			local _resizer = ParaUI.CreateUIObject("container", _wnd.app.name.."_".._wnd.name.."_resizer", "_rb", 
				-_style.resizerSize, -_style.resizerSize, _style.resizerSize, _style.resizerSize);
			_resizer.background = "";
			_resizer.candrag = true;
			--_resizer.ondragbegin = string.format([[;CommonCtrl.WindowFrame.OnDragBegin("%s", "%s");]], self.wnd.app.name, self.wnd.name);
			_resizer.ondragmove = string.format([[;CommonCtrl.WindowFrame.OnDrag("%s", "%s");]], self.wnd.app.name, self.wnd.name);
			_resizer.ondragend = string.format([[;CommonCtrl.WindowFrame.OnDrag("%s", "%s");]], self.wnd.app.name, self.wnd.name);
			--_resizer.ondragend = string.format([[;CommonCtrl.WindowFrame.OnDragEnd("%s", "%s");]], self.wnd.app.name, self.wnd.name);
			_window:AddChild(_resizer);
		end
		
		-- show the internal UI
		if(_ShowUICallback) then
			_ShowUICallback(true, _client, self.wnd);
		end	
		if(self.wnd) then
			self.wnd:SendMessage(nil, CommonCtrl.os.MSGTYPE.WM_SHOW, true);
		end
		
		--[[
		if(self.AnimFile_Show ~= "" and not self.ShowMotion) then
			-- create animation if not create before. 
			NPL.load("(gl)script/ide/Motion/AnimatorEngine.lua");
			self.ShowMotion = CommonCtrl.Motion.AnimatorEngine:new({framerate=24});
			local groupManager = CommonCtrl.Motion.AnimatorManager:new();
			local layerManager = CommonCtrl.Motion.LayerManager:new();
			local layerBGManager = CommonCtrl.Motion.LayerManager:new();
			local PopupAnimator = CommonCtrl.Motion.Animator:new();
			PopupAnimator:Init(self.AnimFile_Show, window_obj_name);
			layerManager:AddChild(PopupAnimator);
			groupManager:AddChild(layerManager);
			groupManager:AddChild(layerBGManager);
			self.ShowMotion:SetAnimatorManager(groupManager);
		end	
		
		
		if(self.AnimFile_Hide ~= "" and not self.HideMotion) then
			-- create animation if not create before. 
			NPL.load("(gl)script/ide/Motion/AnimatorEngine.lua");
			self.HideMotion = CommonCtrl.Motion.AnimatorEngine:new({framerate=24});
			local groupManager = CommonCtrl.Motion.AnimatorManager:new();
			local layerManager = CommonCtrl.Motion.LayerManager:new();
			local layerBGManager = CommonCtrl.Motion.LayerManager:new();
			local PopupAnimator = CommonCtrl.Motion.Animator:new();
			PopupAnimator:Init(self.AnimFile_Hide, window_obj_name);
			layerManager:AddChild(PopupAnimator);
			groupManager:AddChild(layerManager);
			groupManager:AddChild(layerBGManager);
			self.HideMotion:SetAnimatorManager(groupManager);
		end	]]
		
		-- play Show animation
		--self.ShowMotion:doPlay();
	end
	
	-- record the order of every visible window frame
	WindowFrame.ZOrderFrame = WindowFrame.ZOrderFrame or {};
	
	local window_id = _window.id;
	local window_visible = _window.visible;
	
	if(preShowWindowVisible == true and window_visible == true) then
		
		-- bring the window frame object to front only when the window frame is visible
		_window:BringToFront();
		local _shadow = _window:GetChild("Shadow");
		_shadow.color = "255 255 255 255";
		
		-- send WM_ACTIVATE message to the os.window object
		NPL.load("(gl)script/ide/os.lua");
		local _wnd = WindowFrame.WndSet[self.wnd.app.name][self.wnd.name].wnd;
		_wnd:SendMessage(self.wnd.name, CommonCtrl.os.MSGTYPE.WM_ACTIVATE);
		
		local nCount = #(WindowFrame.ZOrderFrame);
		if(nCount > 0) then
			local top_id = WindowFrame.ZOrderFrame[nCount]
			local _top_win = ParaUI.GetUIObject(top_id);
			local _shadow = _top_win:GetChild("Shadow");
			_shadow.color = "255 255 255 200";
		end
		WindowFrame.ZOrderFrame[nCount+1] = window_id;
		
	elseif(preShowWindowVisible == false and window_visible == false) then
		if(bDestory == true) then
			-- destroy the window frame
			ParaUI.Destroy(self.wnd.app.name.."_"..self.wnd.name.."_window");
			ParaUI.Destroy(self.wnd.app.name.."_"..self.wnd.name.."_window_window_toplevel");
		end
		
	elseif(preShowWindowVisible == false and window_visible == true) then
		if(self.MinimizedPointX ~= nil and self.MinimizedPointY ~= nil) then
			_window.visible = false;
			
			local x, y, width, height = _window:GetAbsPosition();
			-- show the window from minimized
			local block = UIDirectAnimBlock:new();
			block:SetUIObject(_window);
			block:SetCallfront(function (obj) 
				obj.visible = true;
				end);
			block:SetTime(150);
			block:SetScalingXRange(0, 1);
			block:SetScalingYRange(0, 1);
			block:SetTranslationXRange(self.MinimizedPointX - x - width/2, 0);
			block:SetTranslationYRange(self.MinimizedPointY - y - height/2, 0);
			block:SetAlphaRange(0, 1);
			block:SetApplyAnim(true); 
			UIAnimManager.PlayDirectUIAnimation(block);
		else
			_window.visible = false;
			
			if(_cancelShowAnimation ~= true) then
				-- show the window, the window frame is already BringToFront()
				local block = UIDirectAnimBlock:new();
				block:SetUIObject(_window);
				block:SetCallfront(function (obj) 
					obj.visible = true;
					obj.scalingx = 0.9;
					obj.scalingy = 0.9;
					end);
				block:SetTime(150);
				block:SetScalingXRange(0.9, 1);
				block:SetScalingYRange(0.9, 1);
				block:SetAlphaRange(0, 1);
				block:SetApplyAnim(true); 
				UIAnimManager.PlayDirectUIAnimation(block);
			else
				_window.visible = true;
			end
		end
		
		-- bring the window frame object to front only when the window frame is visible
		_window:BringToFront();
		local _shadow = _window:GetChild("Shadow");
		_shadow.color = "255 255 255 255";
		
		-- send WM_ACTIVATE message to the os.window object
		NPL.load("(gl)script/ide/os.lua");
		local _wnd = WindowFrame.WndSet[self.wnd.app.name][self.wnd.name].wnd;
		_wnd:SendMessage(self.wnd.name, CommonCtrl.os.MSGTYPE.WM_ACTIVATE);
		
		local nCount = #(WindowFrame.ZOrderFrame);
		if(nCount > 0) then
			local top_id = WindowFrame.ZOrderFrame[nCount]
			local _top_win = ParaUI.GetUIObject(top_id);
			local _shadow = _top_win:GetChild("Shadow");
			_shadow.color = "255 255 255 200";
		end
		WindowFrame.ZOrderFrame[nCount+1] = window_id;
		
	elseif(preShowWindowVisible == true and window_visible == false) then
		
		-- NOTE: @param bDestory: only used at destroy functions, normal function call sequence will cause program crash
		--		due to the container is destroyed immediately after Show2(false); call
		--		if bDestory is true and bShow is false, the animation process will delay the destroy call at animation complete callback
		-- NOTE: guaranty the window animation is destroyed immediately 
		--		otherwise if a show function is called afterwards, it will crash
		if(bDestory == true) then
			-- destroy the window frame
			ParaUI.Destroy(self.wnd.app.name.."_"..self.wnd.name.."_window");
			ParaUI.Destroy(self.wnd.app.name.."_"..self.wnd.name.."_window_window_toplevel");
			--WindowFrame.WndSet[self.wnd.app.name][self.wnd.name] = nil;
		else
			if(self.MinimizedPointX ~= nil and self.MinimizedPointY ~= nil) then
				
				local x, y, width, height = _window:GetAbsPosition();
				
				-- hide the window to minimized
				
				_window.visible = true;
				
				local block = UIDirectAnimBlock:new();
				block:SetUIObject(_window);
				block:SetCallfront(function (obj)
					obj.visible = true;
					end);
				block:SetTime(150);
				block:SetScalingXRange(1, 0);
				block:SetScalingYRange(1, 0);
				block:SetTranslationXRange(0, self.MinimizedPointX - x - width/2);
				block:SetTranslationYRange(0, self.MinimizedPointY - y - height/2);
				block:SetAlphaRange(1, 0);
				block:SetApplyAnim(true);
				block:SetCallback(function ()
					_window.visible = false;
				end)
				UIAnimManager.PlayDirectUIAnimation(block);
			else
				-- hide the window
				_window.visible = true;
				
				local block = UIDirectAnimBlock:new();
				block:SetUIObject(_window);
				block:SetCallfront(function (obj)
					obj.visible = true;
					end);
				block:SetTime(150);
				block:SetScalingXRange(1, 0.9);
				block:SetScalingYRange(1, 0.9);
				block:SetAlphaRange(1, 0);
				block:SetApplyAnim(true);
				block:SetCallback(function ()
					_window.visible = false;
				end)
				UIAnimManager.PlayDirectUIAnimation(block);
			end
		end
		
		local nCount = table.getn(WindowFrame.ZOrderFrame);
		if(nCount > 0) then
			-- Note LXZ 2009.9.15: window_id is already destroyed at this moment. 
			if(window_id == WindowFrame.ZOrderFrame[nCount]) then
				WindowFrame.ZOrderFrame[nCount] = nil;
				if((nCount-1) > 0) then
					local id = WindowFrame.ZOrderFrame[nCount-1]
					-- shadow the top window frame after pop
					local _top_win = ParaUI.GetUIObject(id);
					if(_top_win:IsValid()) then
						local _shadow = _top_win:GetChild("Shadow");
						if(_shadow:IsValid()) then
							_shadow.color = "255 255 255 255";
						end
					end
				else
					-- TODO: this is the last window frame active on desktop
				end
			else
				-- usually the WindowFrame.OnActivateWindowFrame() function is called onmousedown, before the window is shown(onmouseup).
				-- this condition is reached on explicit function invoke without mouse interaction
				local k, id;
				for k, id in pairs(WindowFrame.ZOrderFrame) do
					if(id == window_id) then
						local i;
						for i = k, nCount-1 do
							WindowFrame.ZOrderFrame[i] = WindowFrame.ZOrderFrame[i+1];
						end
						WindowFrame.ZOrderFrame[nCount] = nil;
						break;
					end
				end
			end
		end
	end
end


-- WindowFrame.ZOrderFrame is a table that sorted on every show, hide and activate calls.
--		the table is a zorder index(from 1) and window frame ui object id pair
function WindowFrame.OnActivateWindowFrame()
	
	local nCount = table.getn(WindowFrame.ZOrderFrame);
	local i, top_index = 1;
	for i = 1, nCount do
		if(WindowFrame.ZOrderFrame[i] == id) then
			top_index = i;
			break;
		end
	end
	if(top_index == nil) then
		log("window frame object not found in WindowFrame.ZOrderFrame\n")
		return;
	end
	if(top_index == nCount) then
		-- click on self
		return;
	end
	
	local _active_win = ParaUI.GetUIObject(id);
	if(param1 == 1 and _active_win:IsValid()) then
		local _shadow = _active_win:GetChild("Shadow");
		if(_shadow:IsValid()) then
			_shadow.color = "255 255 255 255";
		end
		
		local _top_win = ParaUI.GetUIObject(WindowFrame.ZOrderFrame[nCount]);
		if(_top_win:IsValid()) then
			local _shadow = _top_win:GetChild("Shadow");
			if(_shadow:IsValid()) then
				_shadow.color = "255 255 255 200";
			end
		end
	end
	
	local i;
	for i = top_index, nCount-1 do
		WindowFrame.ZOrderFrame[i] = WindowFrame.ZOrderFrame[i+1];
	end
	WindowFrame.ZOrderFrame[nCount] = id;
end

-- pick the top object in window frame zorder list, and check if this window frame is top
function WindowFrame:IsTopFrame()
	local nCount = table.getn(WindowFrame.ZOrderFrame);
	--commonlib.echo(WindowFrame.ZOrderFrame)
	if(nCount >= 1) then
		local id = WindowFrame.ZOrderFrame[nCount];
		local _active_win = ParaUI.GetUIObject(id);
		if(_active_win:IsValid()) then
			log(_active_win.name.."\n");
			if(_active_win.name == self:GetWindowUIObject().name) then
				return true;
			end
		end
	end
	return false;
end

-- apply a specific theme of window frame dynamicly
-- @param style: the style table in the param table in WindowFrame:new()
function WindowFrame:ApplyTheme(style)
	local _wnd = self.wnd;
	_window = ParaUI.GetUIObject(_wnd.app.name.."_".._wnd.name.."_window");
	
	local borderTop = 0;
	local borderBottom = 0;
	local borderLeft = 0;
	local borderRight = 0;
	
	local _isShowTitleBar = self.isShowTitleBar;
	local _isShowToolboxBar = self.isShowToolboxBar;
	local _isShowStatusBar = self.isShowStatusBar;
	
	if(_isShowTitleBar) then
		borderTop = borderTop + style.titleBarHeight;
	end
	if(_isShowToolboxBar) then
		borderTop = borderTop + style.toolboxBarHeight;
	end
	if(_isShowStatusBar) then
		borderBottom = borderBottom + style.statusBarHeight;
	end
	borderLeft = style.borderLeft;
	borderRight = style.borderRight;
	if(style.borderBottom) then
		borderBottom = borderBottom + style.borderBottom
	end	
	if(style.borderTop) then
		borderTop = borderTop + style.borderTop
	end
	
	-- record the border size and window size
	self.borderLeft = borderLeft;
	self.borderRight = borderRight;
	self.borderTop = borderTop;
	self.borderBottom = borderBottom;
	
	if(_window:IsValid() == true) then
		local _client = _window:GetChild("Client");
		if(_client:IsValid() == true) then
			_client:Reposition("_fi", borderLeft, borderTop, borderRight, borderBottom)
		end
		
		local _bg = _window:GetChild("BG");
		if(_bg:IsValid() == true) then
			_bg.background = style.window_bg;
		end
		
		local _close = _window:GetChild("Close");
		if(_close:IsValid() == true) then
			_close.background = style.CloseBox.icon;
			_close:Reposition(style.CloseBox.alignment, style.CloseBox.x, style.CloseBox.y, style.CloseBox.size, style.CloseBox.size)
		end
		
		local _min = _window:GetChild("Min");
		if(_min:IsValid() == true) then
			_min.background = style.MinBox.icon;
			_min:Reposition(style.MinBox.alignment, style.MinBox.x, style.MinBox.y, style.MinBox.size, style.MinBox.size)
		end
		
		local _max = _window:GetChild("Max");
		if(_max:IsValid() == true) then
			_max.background = style.MaxBox.icon;
			_max:Reposition(style.MaxBox.alignment, style.MaxBox.x, style.MaxBox.y, style.MaxBox.size, style.MaxBox.size)
		end
		
		--local _pin = _window:GetChild("Pin");
		--if(_pin:IsValid() == true) then
			--_pin.background = style.PinBox.icon;
		--end
		
		local _resizer = _window:GetChild("resizerBG");
		if(_resizer:IsValid() == true) then
			_resizer.background = style.resizer_bg;
			_resizer.x = -style.resizerSize;
			_resizer.y = -style.resizerSize;
			_resizer.width = style.resizerSize;
			_resizer.height = style.resizerSize;
		end
		
		local _resizer = _window:GetChild(_wnd.app.name.."_".._wnd.name.."_resizer");
		if(_resizer:IsValid() == true) then
			_resizer.background = style.resizer_bg;
			_resizer.x = -style.resizerSize;
			_resizer.y = -style.resizerSize;
			_resizer.width = style.resizerSize;
			_resizer.height = style.resizerSize;
		end
	end
end

-- set icon and update the UI
function WindowFrame:SetIcon(background)
	if(self.icon == background) then
		return;
	end
	local _window = ParaUI.GetUIObject(self.wnd.app.name.."_"..self.wnd.name.."_window");
	if(_window:IsValid() == true) then
		local _icon = _window:GetChild("icon");
		if(_icon:IsValid() == true) then
			_icon.background = background;
			self.icon = background;
		else
			if(self.isShowTitleBar == true) then
				local y = (self.style.titleBarHeight - self.style.iconSize)/2;
				_icon = ParaUI.CreateUIObject("button", "icon", "_ctt", 
						- self.style.iconSize/2 - self.style.iconTextDistance - _guihelper.GetTextWidth(self.text)/2, y, 
						self.style.iconSize, self.style.iconSize);
				_icon.background = background;
				_window:AddChild(_icon);
				self.icon = background;
			end
		end
	end
end

-- get the windowframe visible
function WindowFrame:GetVisible()
	local _window = ParaUI.GetUIObject(self.wnd.app.name.."_"..self.wnd.name.."_window");
	if(_window:IsValid() == true) then
		return _window.visible;
	end
end

-- set the windowframe visible
function WindowFrame:SetVisible(bVisible)
	local _window = ParaUI.GetUIObject(self.wnd.app.name.."_"..self.wnd.name.."_window");
	if(_window:IsValid() == true) then
		if(bVisible == nil) then
			bVisible = not _window.visible;
		end
		if(_window.visible ~= bVisible) then
			_window.visible = bVisible;
			if(self.wnd) then
				self.wnd:SendMessage(nil, CommonCtrl.os.MSGTYPE.WM_SHOW, bVisible);
			end
		end
	end
end

-- get the windowframe ui object
function WindowFrame:GetWindowUIObject()
	local _window = ParaUI.GetUIObject(self.wnd.app.name.."_"..self.wnd.name.."_window");
	if(_window:IsValid() == true) then
		return _window;
	end
end

-- get the windowframe client ui object
function WindowFrame:GetWindowClientUIObject()
	local _window = ParaUI.GetUIObject(self.wnd.app.name.."_"..self.wnd.name.."_window");
	if(_window:IsValid() == true) then
		local _client = _window:GetChild("Client");
		if(_client:IsValid() == true) then
			return _client;
		end
	end
end

-- set text and update the UI
function WindowFrame:SetText(text)
	if(self.text == text) then
		return;
	end
	local _window = ParaUI.GetUIObject(self.wnd.app.name.."_"..self.wnd.name.."_window");
	if(_window:IsValid() == true) then
		local _text = _window:GetChild("text");
		if(_text:IsValid() == true) then
			_text.text = text;
			if(self.style.IconBox == nil or self.style.TextBox == nil) then
				_text.width = _guihelper.GetTextWidth(text);
				local _icon = _window:GetChild("icon");
				if(_icon:IsValid() == true) then
					_icon.x = - self.style.iconSize/2 - self.style.iconTextDistance - _guihelper.GetTextWidth(text)/2;
				end
			end
			self.text = text;
		end
	end
end

function WindowFrame:GetTextUIObject()
	local _window = ParaUI.GetUIObject(self.wnd.app.name.."_"..self.wnd.name.."_window");
	if(_window:IsValid() == true) then
		local _text = _window:GetChild("text");
		if(_text:IsValid() == true) then
			return _text;
		end
	end
end

-- Changes the position of the control.
-- NOTE: this function will send a WM_SIZE message to the os.window object
-- @param x: new position of the left side of the window.
-- @param y: new position of the top side of the window.
-- @param width: new client area width of the window
-- @param height: new client area height of the window
-- @param bAllowOutsideScreen:  whether we allow moving window ouside the screen rect. default to false(nil)
function WindowFrame:MoveWindow(x, y, width, height, bAllowOutsideScreen)
	local _window = ParaUI.GetUIObject(self.wnd.app.name.."_"..self.wnd.name.."_window");
	local sizeChanged;
	local posChanged;
	if(_window:IsValid() == true) then
		
		local wndX, wndY, wndWidth, wndHeight = _window:GetAbsPosition();
		local x_ = x or wndX;
		local y_ = y or wndY;
		local width_ = width or self.width;
		local height_ = height or self.height;
		
		if(not bAllowOutsideScreen) then
			-- put the window inside the screen area
			x_, y_, width_, height_ = WindowFrame.GetInsideScreenPosition(
					x_, y_, 
					width_ + self.borderLeft + self.borderRight, 
					height_ + self.borderTop + self.borderBottom);
		end
		if(x) then
			_window.x = x_; -- TODO: only works for "_lt"
			posChanged = true;
		end
		if(y) then
			_window.y = y_;-- TODO: only works for "_lt"
			posChanged = true;
		end
		if(width and _window.width~=width_) then
			_window.width = width_;
			sizeChanged = true;
		end
		if(height and _window.height~=height_) then
			_window.height = height_;
			sizeChanged = true;
		end
		if(self.directPosition) then
			-- fixed alignment when position changed. 
			if(self.align == "_rb") then
				if(not posChanged and sizeChanged) then
					-- TODO: this is tricky, we will readjust so that the distance to the right bottom is the same as when the window is created. 
					-- Please note:this may conflict with dragable windows. because when window is dragged, its alignment is reset to left top. 
					-- however, self.align, self.x,y,width, height, still retains the old values when window is created. 
					_window:Reposition(self.align, self.x+self.width-width_, self.y+self.height-height_, width_, height_)
				end	
			end
		end
	end
	
	if(sizeChanged) then
		-- send WM_SIZE message to the os.window object
		NPL.load("(gl)script/ide/os.lua");
		local _wnd = WindowFrame.WndSet[self.wnd.app.name][self.wnd.name].wnd;
		_wnd:SendMessage(self.wnd.name, CommonCtrl.os.MSGTYPE.WM_SIZE);
	end
end

-- same as MoveWindow() except that it supports alignment style. 
-- @param all inputs can be nil. If nil the old value when window is created is used. 
function WindowFrame:Reposition(align, x, y, width, height)
	local _window = ParaUI.GetUIObject(self.wnd.app.name.."_"..self.wnd.name.."_window");
	if(_window:IsValid()) then
		_window:Reposition(align or self.align, x or self.x, y or self.y, width or self.width, height or self.height);
		commonlib.echo({align or self.align, x or self.x, y or self.y, width or self.width, height or self.height})
		if(self.width~=width or self.height~=height) then
			-- send WM_SIZE message to the os.window object
			NPL.load("(gl)script/ide/os.lua");
			local _wnd = WindowFrame.WndSet[self.wnd.app.name][self.wnd.name].wnd;
			_wnd:SendMessage(self.wnd.name, CommonCtrl.os.MSGTYPE.WM_SIZE);
		end
	end
end

-- set whether the window is pinned
-- pinned window will stick to the screen regardless of application switching
-- @param bPinned: if true the window is pinned on the screen 
function WindowFrame:SetWindowPinned(bPinned)
	-- TODO: pin the window
	self.isPinned = bPinned;
	
	---- pinned window will stick on the screen regardless of appication switching
	--isPinable = false, -- if the window pinable on the screen, show the pin box automaticly on true
	--initialPinned = false, -- initial pin status
end


-- put the container inside the screen client area, like popup menu or context menu
-- 
-- @param x: x position of the container.
-- @param y: y position of the container.
-- @param width: width of the container
-- @param height: height of the container
-- 
-- @return (x, y, width, height): the new position of the given container
function WindowFrame.GetInsideScreenPosition(x, y, width, height)
	local left, top, right, bottom = WindowFrame.GetClientAreaRect();
	
	local _, _, resWidth, resHeight = ParaUI.GetUIObject("root"):GetAbsPosition();

	local minX, minY = left, top;
	local maxX, maxY = resWidth - right, resHeight - bottom;
	
	if(x < minX) then
		x = minX;
	end
	
	if(y < minY) then
		y = minY;
	end
	
	if((x + width) > maxX) then
		x = maxX - width;
	end
	
	if((y + height) > maxY) then
		y = maxY - height;
	end
	
	return x, y, width, height;
end

-- it will move minimum distance to ensure that a given container is inside the screen area
-- @param uiobj: the ParaUIObject to move
function WindowFrame.MoveContainerInScreenArea(uiobj)
	if(uiobj and uiobj:IsValid()) then
		local x, y, width, height = uiobj:GetAbsPosition();
		-- put the window inside the screen area
		x, y, width, height = WindowFrame.GetInsideScreenPosition(x, y, width, height);
		uiobj.x = x;
		uiobj.y = y;
	end
end
	
-- get window frame according to app name and window name
-- @param appName: os.app name
-- @param wndName: os.window name
function WindowFrame.GetWindowFrame(appName, wndName)
	Map3DSystem.UI.Windows.GetWindowFrame(appName, wndName);
end

-- get window frame according to app name and window name
-- @param appName: os.app name
-- @param wndName: os.window name
function WindowFrame.GetWindowFrame2(appName, wndName)
	if(WindowFrame.WndSet[appName]) then
		return WindowFrame.WndSet[appName][wndName];
	else
		return nil;
	end
end

-- hide all the window frames
function WindowFrame.HideAll()
	local _, app;
	for _, app in pairs(WindowFrame.WndSet) do
		local __, wnd;
		for __, wnd in pairs(app) do
			wnd:Show2(false);
		end
	end
	WindowFrame.ClearLeftTabFrames();
	WindowFrame.ClearRightTabFrames();
end

-- hide all the window frames except the pinned window frames
-- this is usually called when application switching to hide previous application window frames
function WindowFrame.HideAllExceptPinned()
	local _, app;
	for _, app in pairs(WindowFrame.WndSet) do
		local __, wnd;
		for __, wnd in pairs(app) do
			if(wnd.isPinned ~= true) then
				wnd:Show2(false);
			end
		end
	end
	WindowFrame.ClearLeftTabFrames();
	WindowFrame.ClearRightTabFrames();
end

---- ondragbegin function of window frame resizer object
--function WindowFrame.OnDragBegin(appName, wndName)
	---- record the current resizing window and resizer UI object
	--local _window = ParaUI.GetUIObject(appName.."_"..wndName.."_window");
	--WindowFrame.DraggingWindow = _window;
	--local _resizer = _window:GetChild("resizer");
	--WindowFrame.DraggingResizer = _resizer;
--end

-- ondragmove function of window frame resizer object
function WindowFrame.OnDrag(appName, wndName)
	
	local _window = ParaUI.GetUIObject(appName.."_"..wndName.."_window");
	local _resizer = ParaUI.GetUIObject(appName.."_"..wndName.."_resizer");
	
	local x_resizer, y_resizer, width_resizer, height_resizer = _resizer:GetAbsPosition();
	local x_window, y_window, width_window, height_window = _window:GetAbsPosition();
	
	local newWidth = x_resizer - x_window + width_resizer;
	local newHeight = y_resizer - y_window + height_resizer;
	
	local _param = WindowFrame.WndSet[appName][wndName];
	
	local maxWidth = _param.maxWidth + _param.borderLeft + _param.borderRight;
	local maxHeight = _param.maxHeight + _param.borderTop + _param.borderBottom;
	local minWidth = _param.minWidth + _param.borderLeft + _param.borderRight;
	local minHeight = _param.minHeight + _param.borderTop + _param.borderBottom;
	
	-- not exceed the min and max
	if(newWidth < minWidth) then
		newWidth = minWidth;
	end
	if(newWidth > maxWidth) then
		newWidth = maxWidth;
	end
	if(newHeight < minHeight) then
		newHeight = minHeight;
	end
	if(newHeight > maxHeight) then
		newHeight = maxHeight;
	end
	
	_window.width = newWidth;
	_window.height = newHeight;
	
	
	local time = ParaGlobal.GetGameTime();
	
	WindowFrame.LastSizeTime = WindowFrame.LastSizeTime or 0;
	
	-- update the control at least 80 millionsecond later
	if(time - WindowFrame.LastSizeTime) > 80 then
		NPL.load("(gl)script/ide/os.lua");
		local _wnd = WindowFrame.WndSet[appName][wndName].wnd;
		_wnd:SendMessage(wndName, {
			type = CommonCtrl.os.MSGTYPE.WM_SIZE, 
			width = newWidth - _param.borderLeft - _param.borderRight, 
			height = newHeight - _param.borderTop - _param.borderBottom,
			});
		WindowFrame.LastSizeTime = time;
		
		_param.width = newWidth - _param.borderLeft - _param.borderRight;
		_param.height = newHeight - _param.borderTop - _param.borderBottom;
	end
end

---- ondragend function of window frame resizer object
--function WindowFrame.OnDragEnd(appName, wndName)
	--
	--NPL.load("(gl)script/ide/os.lua");
	--local _wnd = WindowFrame.WndSet[appName][wndName].wnd;
	--_wnd:SendMessage(wndName, CommonCtrl.os.MSGTYPE.WM_SIZE);
--end

-- onclick function of pin box UI object
function WindowFrame.OnClickPin(appName, wndName)
	-- TODO: toggle the pin status of the current window
end

-- onclick function of minimize UI object
function WindowFrame.OnClickMin(appName, wndName)
	NPL.load("(gl)script/ide/os.lua");
	local _wnd = WindowFrame.WndSet[appName][wndName].wnd;
	_wnd:SendMessage(wndName, CommonCtrl.os.MSGTYPE.WM_MINIMIZE);
end

-- onclick function of maximize UI object
function WindowFrame.OnClickMax(appName, wndName)
	NPL.load("(gl)script/ide/os.lua");
	local _wnd = WindowFrame.WndSet[appName][wndName].wnd;
	_wnd:SendMessage(wndName, CommonCtrl.os.MSGTYPE.WM_MAXIMIZE);
end

-- onclick function of close UI object
-- NOTE: close button click didn't Destroy() or Show(false) the window on click the close button
--		it's up to the message processor to define its behavior(Destroy() or Show(false))
function WindowFrame.OnClickClose(appName, wndName)
	NPL.load("(gl)script/ide/os.lua");
	local _wnd = WindowFrame.WndSet[appName][wndName].wnd;
	_wnd:SendMessage(wndName, CommonCtrl.os.MSGTYPE.WM_CLOSE);
end

WindowFrame.DefaultStyle = {
	name = "DefaultStyle",
	
	window_bg = "Texture/3DMapSystem/WindowFrameStyle/1/frame2_32bits.png: 8 25 8 8",
	fillBGLeft = 0,
	fillBGTop = 0,
	fillBGWidth = 0,
	fillBGHeight = 0,
	
	shadow_bg = "Texture/3DMapSystem/WindowFrameStyle/1/frame_shadow.png: 24 24 24 24",
	fillShadowLeft = -10,
	fillShadowTop = -6,
	fillShadowWidth = -10,
	fillShadowHeight = -15,
	
	titleBarHeight = 25,
	toolboxBarHeight = 48,
	statusBarHeight = 32,
	borderLeft = 2,
	borderRight = 2,
	borderBottom = 2, -- added by LXZ, 2008.9.14
	
	textfont = "System;12;bold";
	textcolor = "255 255 255",
	
	iconSize = 16,
	iconTextDistance = 16, -- distance between icon and text on the title bar
	
	IconBox = {alignment = "_lt",
				x = 8, y = 4, size = 16,},
	TextBox = {alignment = "_lt",
				x = 32, y = 6, height = 16,},
				
	CloseBox = {alignment = "_rt",
				x = -24, y = 2, size = 20, sizex = 20, sizey = 20, -- the style will use sizex and sizey prior to size if provided
				icon = "Texture/3DMapSystem/WindowFrameStyle/1/close.png; 0 0 20 20",
				icon_over = "Texture/3DMapSystem/WindowFrameStyle/1/close.png; 0 0 20 20",
				icon_pressed = "Texture/3DMapSystem/WindowFrameStyle/1/close.png; 0 0 20 20",
				},
	MinBox = {alignment = "_rt",
				x = -68, y = 2, size = 20, sizex = 20, sizey = 20, -- the style will use sizex and sizey prior to size if provided
				icon = "Texture/3DMapSystem/WindowFrameStyle/1/min.png; 0 0 20 20",
				icon_over = "Texture/3DMapSystem/WindowFrameStyle/1/min.png; 0 0 20 20",
				icon_pressed = "Texture/3DMapSystem/WindowFrameStyle/1/min.png; 0 0 20 20",
				},
	MaxBox = {alignment = "_rt",
				x = -46, y = 2, size = 20, sizex = 20, sizey = 20, -- the style will use sizex and sizey prior to size if provided
				icon = "Texture/3DMapSystem/WindowFrameStyle/1/max.png; 0 0 20 20",
				icon_over = "Texture/3DMapSystem/WindowFrameStyle/1/max.png; 0 0 20 20",
				icon_pressed = "Texture/3DMapSystem/WindowFrameStyle/1/max.png; 0 0 20 20",
				},
	PinBox = {alignment = "_lt", -- TODO: pin box, set the pin box in the window frame style
				x = 2, y = 2, size = 20,
				icon_pinned = "Texture/3DMapSystem/WindowFrameStyle/1/autohide.png; 0 0 20 20",
				icon_unpinned = "Texture/3DMapSystem/WindowFrameStyle/1/autohide2.png; 0 0 20 20",},
	
	resizerSize = 24,
	resizer_bg = "Texture/3DMapSystem/WindowFrameStyle/1/resizer.png",
};

WindowFrame.ContainerStyle = {
	name = "ContainerStyle",
	
	window_bg = "",
	fillBGLeft = 0,
	fillBGTop = 0,
	fillBGWidth = 0,
	fillBGHeight = 0,
	
	shadow_bg = "",
	fillShadowLeft = 0,
	fillShadowTop = 0,
	fillShadowWidth = 0,
	fillShadowHeight = 0,
	
	titleBarHeight = 0,
	toolboxBarHeight = 0,
	statusBarHeight = 0,
	borderLeft = 0,
	borderRight = 0,
	borderBottom = 0,
	
	textfont = "System;12;bold";
	textcolor = "255 255 255",
	
	iconSize = 16,
	iconTextDistance = 16, -- distance between icon and text on the title bar
	
	IconBox = {alignment = "_lt",
				x = 8, y = 4, size = 16,},
	TextBox = {alignment = "_lt",
				x = 32, y = 6, height = 16,},
				
	CloseBox = {alignment = "_rt",
				x = -24, y = 2, size = 20, sizex = 20, sizey = 20, -- the style will use sizex and sizey prior to size if provided
				icon = "Texture/3DMapSystem/WindowFrameStyle/1/close.png; 0 0 20 20",
				icon_over = "Texture/3DMapSystem/WindowFrameStyle/1/close.png; 0 0 20 20",
				icon_pressed = "Texture/3DMapSystem/WindowFrameStyle/1/close.png; 0 0 20 20",
				},
	MinBox = {alignment = "_rt",
				x = -68, y = 2, size = 20, sizex = 20, sizey = 20, -- the style will use sizex and sizey prior to size if provided
				icon = "Texture/3DMapSystem/WindowFrameStyle/1/min.png; 0 0 20 20",
				icon_over = "Texture/3DMapSystem/WindowFrameStyle/1/min.png; 0 0 20 20",
				icon_pressed = "Texture/3DMapSystem/WindowFrameStyle/1/min.png; 0 0 20 20",
				},
	MaxBox = {alignment = "_rt",
				x = -46, y = 2, size = 20, sizex = 20, sizey = 20, -- the style will use sizex and sizey prior to size if provided
				icon = "Texture/3DMapSystem/WindowFrameStyle/1/max.png; 0 0 20 20",
				icon_over = "Texture/3DMapSystem/WindowFrameStyle/1/max.png; 0 0 20 20",
				icon_pressed = "Texture/3DMapSystem/WindowFrameStyle/1/max.png; 0 0 20 20",
				},
	PinBox = {alignment = "_lt", -- TODO: pin box, set the pin box in the window frame style
				x = 2, y = 2, size = 20,
				icon_pinned = "Texture/3DMapSystem/WindowFrameStyle/1/autohide.png; 0 0 20 20",
				icon_unpinned = "Texture/3DMapSystem/WindowFrameStyle/1/autohide2.png; 0 0 20 20",},
	
	resizerSize = 24,
	resizer_bg = "Texture/3DMapSystem/WindowFrameStyle/1/resizer.png",
};

WindowFrame.DefaultPanel = {
	name = "DefaultPanel",
	
	--window_bg = "Texture/3DMapSystem/Desktop/BottomPanel/Panel2.png: 8 8 8 8",
	--window_bg = "Texture/3DMapSystem/3DMap/MarkDescBG.png; 0 4 120 108: 80 40 32 24",
	window_bg = "";
	fillBGLeft = 0,
	fillBGTop = 0,
	fillBGWidth = 0,
	fillBGHeight = 0,
	
	titleBarHeight = 0,
	toolboxBarHeight = 0,
	statusBarHeight = 0,
	borderLeft = 0,
	borderRight = 0,
	--borderBottom = 16, -- added by LXZ, 2008.8.16
	
	iconSize = 16,
	iconTextDistance = 16, -- distance between icon and text on the title bar
	
	CloseBox = {alignment = "_rt",
				x = -22, y = 2, size = 20,
				icon = "Texture/3DMapSystem/WindowFrameStyle/1/close.png; 0 0 20 20",},
	MinBox = {alignment = "_rt",
				x = -66, y = 2, size = 20,
				icon = "Texture/3DMapSystem/WindowFrameStyle/1/min.png; 0 0 20 20",},
	MaxBox = {alignment = "_rt",
				x = -44, y = 2, size = 20,
				icon = "Texture/3DMapSystem/WindowFrameStyle/1/max.png; 0 0 20 20",},
	PinBox = {alignment = "_lt", -- TODO: pin box, set the pin box in the window frame style
				x = 2, y = 2, size = 20,
				icon_pinned = "Texture/3DMapSystem/WindowFrameStyle/1/autohide.png; 0 0 20 20",
				icon_unpinned = "Texture/3DMapSystem/WindowFrameStyle/1/autohide2.png; 0 0 20 20",},
	
	resizerSize = 24,
	resizer_bg = "",
};


WindowFrame.ParaWorldLeftPanelStyle = {
	name = "ParaWorldLeftPanelStyle",
	
	window_bg = "Texture/3DMapSystem/Desktop/LeftPanel/LeftPanel3.png: 27 386 100 119",
	fillBGLeft = 0,
	fillBGTop = 0,
	fillBGWidth = -90,
	fillBGHeight = 0,
	
	titleBarHeight = 48,
	titleBarOwnerDraw = function (_titleBar, frames)
			
			-- NOTE: secretly extend the title bar width
			_titleBar.width = _titleBar.width + 90;
			
			local _tab = ParaUI.CreateUIObject("container", "Title", "_mt", 0, 0, 0, 48);
			_tab.background = "";
			_titleBar:AddChild(_tab);
			
			NPL.load("(gl)script/kids/3DMapSystemUI/InGame/TabGrid.lua");
			CommonCtrl.DeleteControl("LeftWindowsTabs");
			local ctl = CommonCtrl.GetControl("LeftWindowsTabs");
			if(ctl == nil) then
				local param = {
					name = "LeftWindowsTabs",
					parent = _tab,
					background = "",
					wnd = wnd,
					
					----------- CATEGORY REGION -----------
					Level1 = "Top",
					Level1BG = "",
					Level1HeadBG = "Texture/3DMapSystem/Desktop/LeftPanel/TopTabLeft.png; 0 0 32 48: 16 1 0 1",
					Level1TailBG = "Texture/3DMapSystem/Desktop/LeftPanel/TopTabRight.png; 0 0 64 48: 0 1 32 1",
					Level1Offset = 16,
					Level1ItemWidth = 56,
					Level1ItemHeight = 48,
					
					Level1ItemOwnerDraw = function (_parent, level1index, bSelected, tabGrid)
						-- background
						if(bSelected) then
							local _back = ParaUI.CreateUIObject("container", "back", "_fi", 0, 0, 0, 0);
							_back.background = tabGrid.GetLevel1ItemSelectedBackImage(level1index);
							_parent:AddChild(_back);
						else
							local _back = ParaUI.CreateUIObject("container", "back", "_fi", 0, 0, 0, 0);
							_back.background = tabGrid.GetLevel1ItemUnselectedBackImage(level1index);
							_parent:AddChild(_back);
						end
						
						-- icon
						local _btn = ParaUI.CreateUIObject("button", "btn"..level1index, "_lt", 12, 8, 32, 32);
						if(bSelected) then
							_btn.background = tabGrid.GetLevel1ItemSelectedForeImage(level1index);
						else
							_btn.background = tabGrid.GetLevel1ItemUnselectedForeImage(level1index);
						end
						_btn.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnClickCategory("%s", %d, nil);]], 
								tabGrid.name, level1index);
						_parent:AddChild(_btn);
						
						-- show the text in tooltip form
						_btn.tooltip = frames[level1index].text;
						
						---- text
						--local _text = ParaUI.CreateUIObject("button", "text"..level1index, "_lt", 0, 0, 160, 48);
						--_text.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnClickCategory("%s", %d, nil);]], 
								--tabGrid.name, level1index);
						--_text.background = "";
						--_text.text = frames[level1index].text;
						--if(bSelected) then
							--_guihelper.SetFontColor(_text, "0 0 0");
						--else
							--_guihelper.SetFontColor(_text, "255 255 255");
						--end
						--_parent:AddChild(_text);
					end,
					
					----------- FUNCTION REGION -----------
					GetLevel1ItemCount = function() return table.getn(frames); end,
					GetLevel1ItemSelectedForeImage = function(index)
							return frames[index].icon;
						end,
					GetLevel1ItemSelectedBackImage = function(index)
						--return "Texture/3DMapSystem/common/ThemeLightBlue/tabitem_selected.png: 4 4 4 4";
						return "Texture/3DMapSystem/Desktop/LeftPanel/TopTabItem.png; 0 0 64 48: 26 24 26 24";
						end,
					GetLevel1ItemUnselectedForeImage = function(index)
							return frames[index].icon;
						end,
					GetLevel1ItemUnselectedBackImage = function(index)
						--return "Texture/3DMapSystem/common/ThemeLightBlue/tabitem_unselected.png: 4 4 4 4";
						return "Texture/3DMapSystem/Desktop/LeftPanel/TopTabItemUnSelected.png; 0 0 64 48: 26 24 26 24";
						end,
					
					GetGridItemCount = function() end,
					OnClickLevel1 = function(level1Index)
						--WindowFrame.ShowLeftFrame(level1Index);
						WindowFrame.LeftTabFrames[level1Index]:Show2(true);
						WindowFrame.AddToLeftTabFrames(WindowFrame.LeftTabFrames[level1Index])
					end,
				};
				ctl = Map3DSystem.UI.TabGrid:new(param);
			end
			ctl:Show(true);
		end,
	
	toolboxBarHeight = 48,
	statusBarHeight = 32,
	borderLeft = 4,
	borderRight = 0,
	
	iconSize = 16,
	iconTextDistance = 16, -- distance between icon and text on the title bar
	
	CloseBox = {alignment = "_rt",
				x = -40, y = 8, size = 32,
				icon = nil,},
	MinBox = {alignment = "_rt",
				x = -120, y = 8, size = 32,
				icon = nil,},
	MaxBox = {alignment = "_rt",
				x = -80, y = 8, size = 32,
				icon = nil,},
	resizerSize = 24,
};


WindowFrame.ParaWorldLeftPanelStyleWithText = {
	name = "ParaWorldLeftPanelStyleWithText",
	
	window_bg = "Texture/3DMapSystem/Desktop/LeftPanel/LeftPanel3.png: 27 386 100 119",
	fillBGLeft = 0,
	fillBGTop = 0,
	fillBGWidth = -90,
	fillBGHeight = 0,
	
	titleBarHeight = 48,
	titleBarOwnerDraw = function (_titleBar, frames)
	
			-- NOTE: secretly extend the title bar width
			_titleBar.width = _titleBar.width + 90;
			
			local _tab = ParaUI.CreateUIObject("container", "Title", "_mt", 0, 0, 0, 48);
			_tab.background = "";
			_titleBar:AddChild(_tab);
			
			NPL.load("(gl)script/kids/3DMapSystemUI/InGame/TabGrid.lua");
			CommonCtrl.DeleteControl("LeftWindowsTabs");
			local ctl = CommonCtrl.GetControl("LeftWindowsTabs");
			if(ctl == nil) then
				local param = {
					name = "LeftWindowsTabs",
					parent = _tab,
					background = "",
					wnd = wnd,
					
					----------- CATEGORY REGION -----------
					Level1 = "Top",
					Level1BG = "",
					Level1HeadBG = "Texture/3DMapSystem/Desktop/LeftPanel/TopTabLeft.png; 0 0 32 48: 16 1 0 1",
					Level1TailBG = "Texture/3DMapSystem/Desktop/LeftPanel/TopTabRight.png; 0 0 64 48: 0 1 63 1",
					Level1Offset = 16,
					Level1ItemWidth = 90,
					Level1ItemHeight = 48,
					
					Level1ItemOwnerDraw = function (_parent, level1index, bSelected, tabGrid)
						-- background
						if(bSelected) then
							local _back = ParaUI.CreateUIObject("container", "back", "_fi", 0, 0, 0, 0);
							_back.background = tabGrid.GetLevel1ItemSelectedBackImage(level1index);
							_parent:AddChild(_back);
						else
							local _back = ParaUI.CreateUIObject("container", "back", "_fi", 0, 0, 0, 0);
							_back.background = tabGrid.GetLevel1ItemUnselectedBackImage(level1index);
							_parent:AddChild(_back);
						end
						
						-- icon
						local _btn = ParaUI.CreateUIObject("button", "btn"..level1index, "_lt", 14, 8, 32, 32);
						if(bSelected) then
							_btn.background = tabGrid.GetLevel1ItemSelectedForeImage(level1index);
						else
							_btn.background = tabGrid.GetLevel1ItemUnselectedForeImage(level1index);
						end
						_btn.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnClickCategory("%s", %d, nil);]], 
								tabGrid.name, level1index);
						_parent:AddChild(_btn);
						
						-- text
						local _text = ParaUI.CreateUIObject("button", "text"..level1index, "_lt", 0, 0, 124, 48);
						_text.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnClickCategory("%s", %d, nil);]], 
								tabGrid.name, level1index);
						_text.background = "";
						_text.text = frames[level1index].text;
						if(bSelected) then
							_guihelper.SetFontColor(_text, "0 0 0");
						else
							_guihelper.SetFontColor(_text, "255 255 255");
						end
						_parent:AddChild(_text);
					end,
					
					----------- FUNCTION REGION -----------
					GetLevel1ItemCount = function() return table.getn(frames); end,
					GetLevel1ItemSelectedForeImage = function(index)
							return frames[index].icon;
						end,
					GetLevel1ItemSelectedBackImage = function(index)
						--return "Texture/3DMapSystem/common/ThemeLightBlue/tabitem_selected.png: 4 4 4 4";
						return "Texture/3DMapSystem/Desktop/LeftPanel/TopTabItem.png; 0 0 64 48: 31 24 31 24";
						end,
					GetLevel1ItemUnselectedForeImage = function(index)
							return frames[index].icon;
						end,
					GetLevel1ItemUnselectedBackImage = function(index)
						--return "Texture/3DMapSystem/common/ThemeLightBlue/tabitem_unselected.png: 4 4 4 4";
						return "Texture/3DMapSystem/Desktop/LeftPanel/TopTabItemUnSelected.png; 0 0 64 48: 31 24 31 24";
						end,
					
					GetGridItemCount = function() end,
					OnClickLevel1 = function(level1Index)
						--WindowFrame.ShowLeftFrame(level1Index);
						WindowFrame.LeftTabFrames[level1Index]:Show2(true);
						WindowFrame.AddToLeftTabFrames(WindowFrame.LeftTabFrames[level1Index])
					end,
				};
				ctl = Map3DSystem.UI.TabGrid:new(param);
			end
			ctl:Show(true);
		end,
	
	toolboxBarHeight = 48,
	statusBarHeight = 32,
	borderLeft = 4,
	borderRight = 0,
	
	iconSize = 16,
	iconTextDistance = 16, -- distance between icon and text on the title bar
	
	CloseBox = {alignment = "_rt",
				x = -40, y = 8, size = 32,
				icon = nil,},
	MinBox = {alignment = "_rt",
				x = -120, y = 8, size = 32,
				icon = nil,},
	MaxBox = {alignment = "_rt",
				x = -80, y = 8, size = 32,
				icon = nil,},
	resizerSize = 24,
};


WindowFrame.ParaWorldRightPanelStyle = {
	name = "ParaWorldRightPanelStyle",
	
	window_bg = "Texture/3DMapSystem/Desktop/RightPanel/RightPanel7.png: 100 386 27 119",
	fillBGLeft = -90,
	fillBGTop = 0,
	fillBGWidth = 0,
	fillBGHeight = 0,
	
	titleBarHeight = 48,
	titleBarOwnerDraw = function (_titleBar, frames)
			local _tab = ParaUI.CreateUIObject("container", "Title", "_mt", -90, 0, 0, 48);
			_tab.background = "";
			_titleBar:AddChild(_tab);
			
			NPL.load("(gl)script/kids/3DMapSystemUI/InGame/TabGrid.lua");
			CommonCtrl.DeleteControl("RightWindowsTabs");
			local ctl = CommonCtrl.GetControl("RightWindowsTabs");
			if(ctl == nil) then
				local param = {
					name = "RightWindowsTabs",
					parent = _tab,
					background = "",
					wnd = wnd,
					
					----------- CATEGORY REGION -----------
					Level1 = "Top",
					Level1BG = "",
					Level1HeadBG = "Texture/3DMapSystem/Desktop/RightPanel/TopTabLeft.png; 0 0 64 48: 63 1 0 1",
					Level1TailBG = "Texture/3DMapSystem/Desktop/RightPanel/TopTabRight.png; 0 0 32 48: 0 1 16 1",
					Level1Offset = 90,
					Level1ItemWidth = 90,
					Level1ItemHeight = 48,
					
					Level1ItemOwnerDraw = function (_parent, level1index, bSelected, tabGrid)
						-- background
						if(bSelected) then
							local _back = ParaUI.CreateUIObject("container", "back", "_fi", 0, 0, 0, 0);
							_back.background = tabGrid.GetLevel1ItemSelectedBackImage(level1index);
							_parent:AddChild(_back);
						else
							local _back = ParaUI.CreateUIObject("container", "back", "_fi", 0, 0, 0, 0);
							_back.background = tabGrid.GetLevel1ItemUnselectedBackImage(level1index);
							_parent:AddChild(_back);
						end
						
						-- icon
						local _btn = ParaUI.CreateUIObject("button", "btn"..level1index, "_lt", 14, 8, 32, 32);
						if(bSelected) then
							_btn.background = tabGrid.GetLevel1ItemSelectedForeImage(level1index);
						else
							_btn.background = tabGrid.GetLevel1ItemUnselectedForeImage(level1index);
						end
						_btn.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnClickCategory("%s", %d, nil);]], 
								tabGrid.name, level1index);
						_parent:AddChild(_btn);
						
						-- text
						local _text = ParaUI.CreateUIObject("button", "text"..level1index, "_lt", 0, 0, 124, 48);
						_text.onclick = string.format([[;Map3DSystem.UI.TabGrid.OnClickCategory("%s", %d, nil);]], 
								tabGrid.name, level1index);
						_text.background = "";
						_text.text = frames[level1index].text;
						if(bSelected) then
							_guihelper.SetFontColor(_text, "0 0 0");
						else
							_guihelper.SetFontColor(_text, "255 255 255");
						end
						_parent:AddChild(_text);
					end,
					
					----------- FUNCTION REGION -----------
					GetLevel1ItemCount = function() return table.getn(frames); end,
					GetLevel1ItemSelectedForeImage = function(index)
							return frames[index].icon;
						end,
					GetLevel1ItemSelectedBackImage = function(index)
						--return "Texture/3DMapSystem/common/ThemeLightBlue/tabitem_selected.png: 4 4 4 4";
						return "Texture/3DMapSystem/Desktop/RightPanel/TopTabItem.png; 0 0 64 48: 31 24 31 24";
						end,
					GetLevel1ItemUnselectedForeImage = function(index)
							return frames[index].icon;
						end,
					GetLevel1ItemUnselectedBackImage = function(index)
						--return "Texture/3DMapSystem/common/ThemeLightBlue/tabitem_unselected.png: 4 4 4 4";
						return "Texture/3DMapSystem/Desktop/RightPanel/TopTabItemUnSelected.png; 0 0 64 48: 31 24 31 24";
						end,
					
					GetGridItemCount = function() end,
					OnClickLevel1 = function(level1Index)
						--WindowFrame.ShowLeftFrame(level1Index);
						WindowFrame.RightTabFrames[level1Index]:Show2(true);
						WindowFrame.AddToRightTabFrames(WindowFrame.RightTabFrames[level1Index])
					end,
				};
				ctl = Map3DSystem.UI.TabGrid:new(param);
			end
			ctl:Show(true);
		end,
	
	toolboxBarHeight = 48,
	statusBarHeight = 32,
	borderLeft = 0,
	borderRight = 4,
	
	iconSize = 16,
	iconTextDistance = 16, -- distance between icon and text on the title bar
	
	CloseBox = {alignment = "_rt",
				x = -40, y = 8, size = 32,
				icon = nil,},
	MinBox = {alignment = "_rt",
				x = -120, y = 8, size = 32,
				icon = nil,},
	MaxBox = {alignment = "_rt",
				x = -80, y = 8, size = 32,
				icon = nil,},
	resizerSize = 24,
};
