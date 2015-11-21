--[[
Title: emulating operating system message queue, windows hook, and windows behavior
Author(s): LiXizhi
Date: 2007/10/7
Revised: 2008/1/13 hook implemented. see doc in code. 
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/os.lua");
local app = CommonCtrl.os.CreateGetApp("MyAPP");
local wnd = app:RegisterWindow("MainWindow", nil, function (window, msg) 
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		-- Do your code
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		-- Do your code
	end
end);

local childwnd = app:RegisterWindow("ChildWindow", "MainWindow", function (window, msg) 
	if(msg.type == CommonCtrl.os.MSGTYPE.WM_CLOSE) then
		-- Do your code
	elseif(msg.type == CommonCtrl.os.MSGTYPE.WM_SIZE) then
		-- Do your code
	end
end);

-- send using a window object
childwnd:SendMessage("MainWindow", CommonCtrl.os.MSGTYPE.WM_CLOSE);
-- send a message to this window
childwnd:SendMessage(nil, {type = CommonCtrl.os.MSGTYPE.WM_CLOSE});
-- or one can send a message using app object
app:SendMessage({type = CommonCtrl.os.MSGTYPE.WM_CLOSE});

-- one can unregister at any time
app:UnRegisterWindow("ChildWindow");

-- one can delete app. if it is not used. 
CommonCtrl.os.DestroyApp("MyApp")
--------------------------------------------------------
-- sample: hook into the "scene" app
local hook = CommonCtrl.os.hook.SetWindowsHook({hookType=CommonCtrl.os.hook.HookType.WH_CALLWNDPROC, 
callback = function(nCode, appName, msg)
	-- return the nCode to be passed to the next hook procedure in the hook chain. 
	-- in most cases, if nCode is nil, the hook procedure should do nothing. 
	if(nCode==nil) then return end
	-- TODO: do your code here
	_guihelper.MessageBox("hook called "..msg.wndName.."\n");
	return nCode
end, 
hookName = "myhook", appName="scene", wndName = "object"});
-- release the hook by calling hook:release() or 
-- CommonCtrl.os.hook.UnhookWindowsHook({hookName="myhook", hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC})
-------------------------------------------------------
-- Normally, hook functions are called automatically when message are sent. Advanced users can call hook.Invoke manually. 
-- it will invoke hook chain wherever you want to enable hooks for application developers, such as in your platform mouse and key event handlers. 
-- Notes: the paraworld platform will create a default "input" application, with windows "mouse_down", "mouse_up","mouse_move", "key_down", "onsize". 
-- other applications can hook to the "input" application to process message. The platform developers needs to manually invoke hook in their 
-- event handlers such as in ParaScene.RegisterEvent("_mdown_XXX", ";XXX.OnMouseDown();");
CommonCtrl.os.hook.Invoke(CommonCtrl.os.hook.HookType.WH_CALLWNDPROC, nCode, appName, msg);
-------------------------------------------------------
]]
-- common library
NPL.load("(gl)script/ide/common_control.lua");

local i=0;
local function BeginEnum()
	i=0; return i;
end
local function AutoEnum() 
	i=i+1; return i; 
end

CommonCtrl.os = {
	-- a mapping from <appName, app>
	apps = {},
	-- predefined messages
	MSGTYPE = 
	{
		---------------------
		-- system messages.
		WM_CLOSE = BeginEnum(), 
		WM_SIZE = AutoEnum(), 
		WM_MINIMIZE = AutoEnum(), 
		WM_MAXIMIZE = AutoEnum(), 
		WM_HIDE = AutoEnum(), 
		WM_SHOW = AutoEnum(), 
		WM_UPDATE = AutoEnum(),
		WM_COMMAND = AutoEnum(),
		WM_NOTIFY = AutoEnum(),
		WM_CHAT = AutoEnum(),
		-- NOTE by andy 2009/1/12: onactivate, this message is sent when the window frame is brought above all others, when:
		--		on mouse down activate 
		--		function invokes
		--		automatic BringToFront show call
		WM_ACTIVATE = AutoEnum(), 
		
		---------------------
		-- add more system messages here
		
		-- user defined messages should be larger than WM_USER to avoid overriding system message.
		WM_USER = 10000, 
		WM_TOGGLE = 10001, -- NOTE by Andy: for chat window tab bar
	},
	-- message struct template
	message = 
	{
		-- target window name. If this is "*", it will send to all windows in the application. If nil, it will only send to the main application. 
		wndName = nil, 
		-- from window name: which window send the message, it can be nil.
		fromWndName = nil, 
		-- int value of message type. above WM_USER is user defined messages. 
		type = nil, 
		param1 = nil, 
		param2 = nil,
		-- anything else here
	},
	-- window struct template
	window = 
	{
		-- window name
		name = nil,
		-- parent name
		parentName = nil,
		-- function MsgProc(os.window, os.message)
		msg_handler = nil,
		-- application table,
		app = nil,
	},
	-- app struct template
	app = 
	{
		name = nil,
		-- the main window name. each app can has only one main window. if this is nil, app name is returned. 
		MainWindowName = nil, 
		-- array of os.message
		msg_queue = {},
		-- mapping of <name,  CommonCtrl.os.window instance> 
		windows = {},
	},
}

-- for hook definitions. 
CommonCtrl.os.hook = {
	HookType = {
		-- Installs a hook procedure that monitors messages before the system sends them to the destination window procedure. 
		WH_CALLWNDPROC = 1, 
		-- Installs a hook procedure that monitors messages after they have been processed by the destination window procedure. 
		WH_CALLWNDPROCRET = 2,
		-- Installs a hook procedure that receives notifications useful to a computer-based training (CBT) application. 
		WH_CBT = 3, 
		-- Installs a hook procedure useful for debugging other hook procedures. 
		WH_DEBUG = 4, 
		-- Installs a hook procedure that monitors keystroke messages. 
		WH_KEYBOARD = 5, 
		-- Installs a hook procedure that monitors mouse messages.
		WH_MOUSE = 6,
		-- Installs a hook procedure that receives notifications useful to shell applications.
		WH_SHELL = 7,
		-- last one
		WH_LAST = 8,
	},
	
	-- single hook object template
	Hook = {
		-- Specifies the type of hook procedure to be installed. see CommonCtrl.os.hook.HookType
		hookType = nil,
		-- Pointer to the hook procedure, see CommonCtrl.os.hook.HookType for how each hook type's call back should be defined. 
		callback = nil,
		-- unique identifier of this hook, this will prevent hook of the same name to be created multiple times. 
		hookName = nil,
		-- application name for which we are hooking, if nil it will hook to all active apps. 
		appName = nil,
		-- window name for which we are hooking, if nil we will hook to all windows of a given app. 
		wndName = nil,
	},
	
	-- all hook chains. it is 2 dimentional array first by appName and then by wndName
	HookChains = {},
	
	-- a template hook call back function. 
	HookProc = function (nCode, appName, msg)	
		-- return the nCode to be passed to the next hook procedure in the hook chain. 
		-- in most cases, if nCode is nil, the hook procedure should do nothing. 
		if(nCode==nil) then return end
		-- TODO: do your code here
		return nCode 
	end,
};
local hook_class = CommonCtrl.os.hook;
local HookType = CommonCtrl.os.hook.HookType;

-------------------------------------------------------------
-- os.window functions: public
-------------------------------------------------------------
-- send and process a message immediately
-- @param targetWndName: if nil, the current window is used. 
-- @param typeOrMsg: 
--	if it is an integer, it will be treated like message type, and param1, param2, ... will be used to construct the message. 
--	if it is a table, all paramN are ignored and this is the msg object. 
-- @return: result is returned
function CommonCtrl.os.window:SendMessage(targetWndName, typeOrMsg, param1, param2, param3, param4)
	if(self.app~=nil) then
		if(type(typeOrMsg) == "table") then
			if(not typeOrMsg.wndName) then
				typeOrMsg.wndName = targetWndName or self.name;
			end	
			return self.app:SendMessage(typeOrMsg);
		else
			return self.app:SendMessage({wndName = targetWndName or self.name, fromWndName = self.name, type = typeOrMsg, param1 = param1, param2 = param2, param3 = param3, param4 = param4});
		end	
	end	
end

-- get parent window struct. it may return nil
function CommonCtrl.os.window:GetParent()
	if(self.app~=nil) then
		return self.app:FindWindow(self.parentName);
	end
end

-- get parent window name. it may return nil
function CommonCtrl.os.window:GetParentName()
	if(self.app~=nil) then
		local parent = self.app:FindWindow(self.parentName);
		if(parent~=nil) then
			return parent.name;
		end
	end
end

--------------------------------------------
-- windows frame related functions
--------------------------------------------

-- get the windows frame object for displaying a UI windows for the window object. 
-- more information, please see ide/windowframe.lua
function CommonCtrl.os.window:GetWindowFrame()
	if(not CommonCtrl.WindowFrame) then
		NPL.load("(gl)script/ide/WindowFrame.lua");
	end
	return CommonCtrl.WindowFrame.GetWindowFrame2(self.app.name, self.name);
end

-- get whether the windows frame is visible
-- more information, please see ide/windowframe.lua
function CommonCtrl.os.window:IsVisible()
	local winFrame = self:GetWindowFrame();
	if(winFrame)then
		return winFrame:IsVisible();
	end
	return false;
end

-- toggle show/hide 
-- @param bShow: true to show, false to hide, nil to toggle. 
-- @param bSilent: if true, no window message is sent.
function CommonCtrl.os.window:ToggleShowHide(bShow, bSilent)
	local winFrame = self:GetWindowFrame();
	if(winFrame)then
		if(bSilent) then
			local _wnd = winFrame:GetWindowUIObject();
			if(_wnd) then
				if(bShow~=nil) then
					_wnd.visible = bShow;
				else
					_wnd.visible = not _wnd.visible;
				end
			end
		else
			if(bShow~=nil) then
				winFrame:SetVisible(bShow);
			else
				winFrame:SetVisible(not winFrame:GetVisible());
			end
		end
	end
end


-- destroy windows frame. so that self:GetWindowFrame() will return nil. both UI and window frame parameters will be destoryed. 
-- if you just want to hide the windows, use ShowWindowFrame().
function CommonCtrl.os.window:DestroyWindowFrame()
	local winFrame = self:GetWindowFrame();
	if(winFrame)then
		winFrame:Destroy();
	end
end

-- Create a new windows frame for the current window. You can not create multiple window frames for the same window. 
-- @param winParams: windows frame parameters. 
-- it is the same as first parameter passed to WindowFrame:new2() in ide/windowframe.lua. Except that winParams.wnd does not needs to be specified. 
-- @return: the created window frame object is returned if succeed. 
function CommonCtrl.os.window:CreateWindowFrame(winParams)
	NPL.load("(gl)script/ide/WindowFrame.lua");
	if(winParams) then
		winParams.wnd = self;
		return CommonCtrl.WindowFrame:new2(winParams);
	end	
end

-- send the WM_CLOSE message to the target window. 
-- it's up to the message processor to define its behavior either Destroy() or Show(false) of its associated window frame
function CommonCtrl.os.window:CloseWindow()
	self:SendMessage(nil, CommonCtrl.os.MSGTYPE.WM_CLOSE);
end

-- show or hide the windows frame UI. 
-- @param bShow: boolean, show or hide the window
function CommonCtrl.os.window:ShowWindowFrame(bShow)
	local winFrame = self:GetWindowFrame();
	if(winFrame)then
		winFrame:Show2(bShow);
	else
		if(bShow) then
			commonlib.log("warning: no window frame found with %s when calling ShowWindowFrame\n", self.name);
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
function CommonCtrl.os.window:MoveWindow(x, y, width, height, bAllowOutsideScreen)
	NPL.load("(gl)script/ide/WindowFrame.lua");
	local winFrame = self:GetWindowFrame();
	if(winFrame)then
		winFrame:MoveWindow(x, y, width, height, bAllowOutsideScreen);
	else
		commonlib.log("warning: no window frame found with %s when calling ShowWindowFrame\n", self.name);
	end
end

-- same as Reposition() except that it supports alignment style. 
-- @param all inputs can be nil. If nil the old value when window is created is used. 
function CommonCtrl.os.window:Reposition(align, x, y, width, height)
	NPL.load("(gl)script/ide/WindowFrame.lua");
	local winFrame = self:GetWindowFrame();
	if(winFrame)then
		winFrame:Reposition(align, x, y, width, height);
	else
		commonlib.log("warning: no window frame found with %s when calling ShowWindowFrame\n", self.name);
	end
end

-- set window frame text and icon
-- @param text: windows title text. 
function CommonCtrl.os.window:SetWindowText(text, icon)
	if(text) then
		NPL.load("(gl)script/ide/WindowFrame.lua");
		local winFrame = self:GetWindowFrame();
		if(winFrame)then
			if(text)then
				winFrame:SetText(text);
			end	
			if(icon) then
				winFrame:SetIcon(icon);
			end	
		end
	end
end

-------------------------------------------------------------
-- os.app functions:public
-------------------------------------------------------------

-- get the main application's main window name.
function CommonCtrl.os.app:GetMainAppWndName()
	return self.MainWindowName or self.name;
end

-- send and process a message immediately
-- @return: result is returned
function CommonCtrl.os.app:SendMessage(msg)
	return self:ProcessMessage(msg);
end

-- post to message queue and return, it does not process it immediately
function CommonCtrl.os.app:PostMessage(msg)
	self.msg_queue[table.getn(self.msg_queue)+1] = msg
end

-- find a window by its name
-- @param wndName: nil or string. if nil, the GetMainAppWndName() is used. 
-- @return: the window struct is returned. 
function CommonCtrl.os.app:FindWindow(wndName)
	return self.windows[wndName or self:GetMainAppWndName()];
end

-- register a window. 
-- @param wndName: the window name to register. 
-- @param parentWndName: the parent window name of wndName. it can be nil, which means no parent
-- @param msg_handler: nil or function: function MsgProc(message:{wndName, type, param1, param2, ...})
-- @return window is returned;
function CommonCtrl.os.app:RegisterWindow(wndName, parentWndName, msg_handler)
	-- create the window using the template
	local o = {name=wndName, parentName = parentWndName, msg_handler = msg_handler, app = self};
	setmetatable(o, CommonCtrl.os.window)
	CommonCtrl.os.window.__index = CommonCtrl.os.window;
	
	-- register window in applications	
	self.windows[wndName] = o;
	return o;
end
-- unregister a window. 
function CommonCtrl.os.app:UnRegisterWindow(wndName)
	self.windows[wndName] = nil;
end

-- CODE is NOT TESTED
-- called as many times as possible in each frame
-- @return: return the number of messages processed.
function CommonCtrl.os.app:run()
	
	local index, msg;
	local nSize = table.getn(self.msg_queue);
	for index = 1, nSize do
		local msg = self.msg_queue[index]
		-- Note: during processing, the user may have added new mesages to the queue
		self.ProcessMessage(msg);
	end
	local nNewSize = table.getn(self.msg_queue);
	-- remove nSize messages from the front, since we have processed them. 
	for index = nSize+1, nNewSize do 
		self.msg_queue[index-nSize] = self.msg_queue[nSize];
	end
	-- set new size
	table.resize(self.msg_queue, nNewSize-nSize);
	return nSize;
end

-------------------------------------------------------------
-- os.app functions: private
-------------------------------------------------------------

-- process a single message
function CommonCtrl.os.app:ProcessMessage(msg)
	-- call the hook 
	if(hook_class.Invoke(HookType.WH_CALLWNDPROC, 0, self.name, msg) == nil) then
		return;
	end
	
	if(msg.wndName == "*") then
		local _, window;
		for _, window in pairs(self.windows) do
			if(window~=nil)	 then
				if(window.msg_handler~=nil) then
					window:msg_handler(msg);
				end
			end
		end
	else
		local window = self:FindWindow(msg.wndName);
		if(window~=nil)	 then
			if(window.msg_handler~=nil) then
				window:msg_handler(msg);
			end
		end
	end
	
	-- call the hook 
	hook_class.Invoke(HookType.WH_CALLWNDPROCRET, 0, self.name, msg);
end

-------------------------------------------------------------
-- os functions:public
-------------------------------------------------------------
-- @param o: string or an os.app table 
-- e.g. CommonCtrl.os.CreateApp({name="3dscene"})  or CommonCtrl.os.CreateApp("3dscene");
function CommonCtrl.os.CreateApp(o)
	if(type(o) == "string") then
		o = {name = o};
	else
		o = o or {}   -- create object if user does not provide one
	end
	setmetatable(o, CommonCtrl.os.app)
	CommonCtrl.os.app.__index = CommonCtrl.os.app;
	
	-- create instance tables.
	o.msg_queue = {};
	o.windows = {};
	
	CommonCtrl.os.apps[o.name] = o;
	return o
end

-- Get App. it may return nil
function CommonCtrl.os.GetApp(name)
	return CommonCtrl.os.apps[name];
end

-- Destory App
function CommonCtrl.os.DestroyApp(name)
	CommonCtrl.os.apps[name] = nil;
end

-- first get app and if it does not exist, we will create a new one. 
-- @param name: string: app name
function CommonCtrl.os.CreateGetApp(name)
	return CommonCtrl.os.GetApp(name) or CommonCtrl.os.CreateApp(name);
end

-------------------------------------------------------------
--[[ Hook: 
A hook is a point in the system message-handling mechanism where an application can install a subroutine to 
monitor the message traffic in the system (including all other applicatoins) and process certain types of messages before they reach the target 
window procedure or after it. 

About hook: 
Hooks tend to slow down the system because they increase the amount of processing the system must perform for each message. 
You should install a hook only when necessary, and remove it as soon as possible. 

>> Hook Chains
The system supports many different types of hooks; each type provides access to a different aspect of its message-handling mechanism.
For example, an application can use the WH_MOUSE Hook to monitor the message traffic for mouse messages. 
The system maintains a separate hook chain for each type of hook. A hook chain is a list of pointers to special, 
application-defined callback functions called hook procedures. When a message occurs that is associated with a particular 
type of hook, the system passes the message to each hook procedure referenced in the hook chain, one after the other. 
The action a hook procedure can take depends on the type of hook involved. The hook procedures for some types of hooks can 
only monitor messages; others can modify messages or stop their progress though the chain, preventing them from reaching 
the next hook procedure or the destination window. 

>> Hook Procedures
To take advantage of a particular type of hook, the developer provides a hook procedure and uses the SetWindowsHookEx function to 
install it into the chain associated with the hook. A hook procedure must have the following syntax: 
function HookProc(nCode, appName, msg) end
]]
-------------------------------------------------------------
-- mapping from hook name to hook object for fast index
local hook_name_maps = {};
-- create a new hook
function CommonCtrl.os.hook.Hook:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o	
end

-- remove this hook from the hook chain. 
function CommonCtrl.os.hook.Hook:release()
	local chain = hook_class.GetHookChain(self.hookType, self.appName, self.wndName);
	if(chain) then
		chain:DeleteHook(self);
	end
end

---------------------------------
-- create a new hook chain
---------------------------------
local HookChain = {};
function HookChain:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o	
end

-- add a new hook to the chain, it will override hook with the same hookName(swap the new hook to the beginning as well). 
-- @param priority: if nil, it is the default 0 priority, the larger the number the earlier that the hook is executed. 
-- return the hook added or nil.
function HookChain:AddHook(hook, priority)
	local bExistingIndex;
	local force_index = 1;
	
	priority = priority or 0;
	hook.priority = priority;
	for i,value in ipairs(self) do
		if(priority < value.priority) then
			force_index = i+1;
		elseif(value.hookName == hook.hookName) then
			self[i] = hook;
			bExistingIndex = i;
		end
	end
	if(not bExistingIndex) then
		-- add hook to the front
		commonlib.insertArrayItem(self, force_index, hook);
		LOG.std("", "system", "os", "hook %s of type %d is created", tostring(hook.hookName), hook.hookType)
	else
		commonlib.moveArrayItem(self, math.min(#self, force_index), bExistingIndex);
	end
	hook_name_maps[hook.hookName] = hook;

	return hook;
end

-- delete a hook from the chain. 
-- @param hook: it needs to contain {hookName="MyHook"} or the hook object returned by SetWindowsHook()
function HookChain:DeleteHook(hook)
	local i, value;
	for i,value in ipairs(self) do
		if(value.hookName == hook.hookName) then
			LOG.std("", "system", "os", "hook %s is removed", tostring(hook.hookName))
			commonlib.removeArrayItem(self, i);
			hook_name_maps[value.hookName] = nil;
			break;
		end
	end
end

-- invoke hook chain
function HookChain:Invoke(nCode, appName, msg)
	local i, value;
	local wndName = msg.wndName;
	for i,value in ipairs(self) do
		--if( (value.appName == nil or value.appName == appName) and 
		--	(value.wndName == nil or value.wndName == wndName)) then
			if(value.callback) then
				-- @param value: added by leio 2009/1/13
				nCode = value.callback(nCode, appName, msg, value);
			end
		--end
	end
	return nCode;
end

-- return nil if hook chain is empty. 
function CommonCtrl.os.hook.Invoke(hookType, nCode, appName, msg)
	local chain;
	chain = hook_class.GetHookChain(hookType);
	if(chain) then
		nCode = chain:Invoke(nCode, appName, msg);
	end
	chain = hook_class.GetHookChain(hookType,appName);
	if(chain) then
		nCode = chain:Invoke(nCode, appName, msg);
	end
	chain = hook_class.GetHookChain(hookType, appName, msg.wndName);
	if(chain) then
		nCode = chain:Invoke(nCode, appName, msg);
	end
	return nCode;
end


-- create/get the parent hook chain according to the input hook setting
-- @param hookType: this should be between [1, HookType.WH_LAST]
-- @param appName: app name or nil. 
-- @param wndName: window name or nil. 
-- @param bCreateGet: true to create get
-- @return nil or the hook chain table. 
function CommonCtrl.os.hook.GetHookChain(hookType, appName, wndName, bCreateGet)
	if(not hookType or hookType<1 or hookType>= HookType.WH_LAST) then
		return 
	end

	local HookChains = hook_class.HookChains;
	local HookChainsTypes = HookChains[hookType];
	if(HookChainsTypes == nil) then
		HookChainsTypes = HookChain:new();
		HookChains[hookType] = HookChainsTypes
	end
	local chain;
	if(not appName) then
		chain = HookChainsTypes._all;
		if(not chain) then
			if(not bCreateGet) then
				return
			end
			chain = HookChain:new();
			HookChainsTypes._all = chain;
		end
		return chain;
	else
		local HookChainsTypesApps = HookChainsTypes[appName];
		if(not HookChainsTypesApps) then
			if(not bCreateGet) then
				return
			end
			HookChainsTypesApps = HookChain:new();
			HookChainsTypes[appName] = HookChainsTypesApps;
		end

		if(not wndName) then
			chain = HookChainsTypesApps._all;
			if(not chain) then
				if(not bCreateGet) then
					return
				end
				chain = HookChain:new();
				HookChainsTypesApps._all = chain;
			end
			return chain;
		else
			chain = HookChainsTypesApps[wndName];
			if(not chain) then
				if(not bCreateGet) then
					return
				end
				chain = HookChain:new();
				HookChainsTypesApps[wndName] = chain;
			end
			return chain;
		end
	end
end

-- get hook by its name
function CommonCtrl.os.hook.GetHookByName(hookName)	
	return hook_name_maps[hookName];
end

-- it installs an application-defined hook procedure at the beginning of a hook chain. You would install a hook procedure to 
-- monitor the system for certain types of events. These events are associated either with a specific app or window or with all apps in the desktop.
-- @param hook: the init hook parameters. see CommonCtrl.os.hook.Hook. e.g. {hookType=CommonCtrl.os.hook.HookType.WH_CALLWNDPROC, callback = MyHookProc, hookName = "myhook", appName="paraworld", wndName = "creation"}
-- @param priority: if nil, it is the default lowest priority, the larger the number the earlier that the hook is executed. 
-- @return: If the function succeeds, the return value is the hook object. otherwise nil is returned. 
function CommonCtrl.os.hook.SetWindowsHook(hook, priority)
	if(hook.hookType ~= nil) then
		hook = hook_class.Hook:new(hook);
		
		local chain = hook_class.GetHookChain(hook.hookType, hook.appName, hook.wndName, true);
		if(chain) then
			return chain:AddHook(hook, priority);
		else
			LOG.std("", "error", "os", "failed creating hook, because hookType is invalid.");
		end
	else
		LOG.std("", "error", "os", "failed creating hook, because hookType is nil.");
	end	
end

-- removes a hook procedure installed in a hook chain by the SetWindowsHook function
-- @param hook: it needs to contain {hookName="myhook", hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC} or the hook object returned by SetWindowsHook()
function CommonCtrl.os.hook.UnhookWindowsHook(hook)
	if(hook.hookName) then
		hook = hook_class.GetHookByName(hook.hookName) or hook;
	end
	local chain = hook_class.GetHookChain(hook.hookType, hook.appName, hook.wndName);
	if(chain) then
		chain:DeleteHook(hook);
	end
end

