--[[
Title: Scene Context Manager
Author(s): LiXizhi, 
Date: 2015/7/9
Desc: see also System.Core.SceneContext
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Core/SceneContextManager.lua");
local SceneContextManager = commonlib.gettable("System.Core.SceneContextManager");
local context = SceneContextManager:GetCurrentContext();
local context = SceneContextManager:GetContext("Default");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/os.lua");
NPL.load("(gl)script/ide/System/Windows/KeyEvent.lua");
local KeyEvent = commonlib.gettable("System.Windows.KeyEvent");
NPL.load("(gl)script/ide/System/Windows/MouseEvent.lua");
local MouseEvent = commonlib.gettable("System.Windows.MouseEvent");
NPL.load("(gl)script/ide/System/Core/ToolBase.lua");

local SceneContextManager = commonlib.inherit(commonlib.gettable("System.Core.ToolBase"), commonlib.gettable("System.Core.SceneContextManager"));

SceneContextManager:Property("Name", "SceneContextManager");
-- event hook priority. 
SceneContextManager:Property({"priority", 10});
SceneContextManager:Property({"m_bAcceptAllEvents", false, "IsAcceptAllEvents", "SetAcceptAllEvents", desc="whether to accept all events and prevent other handlers", auto=true});
SceneContextManager:Signal("contextUnselected");
SceneContextManager:Signal("contextSelected");

local registered_contexts = {};
local current_context;

function SceneContextManager:ctor()
	self:Hook();
end

-- hook to low level events. 
function SceneContextManager:Hook()
	local hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC;
	local o = {hookType = hookType, 		 
		hookName = "cm_m_down_hook", appName = "input", wndName = "mouse_down"};
	o.callback = SceneContextManager.OnMouseDown;
	CommonCtrl.os.hook.SetWindowsHook(o, self.priority);
	o = {hookType = hookType, 		 
		hookName = "cm_m_move_hook", appName = "input", wndName = "mouse_move"};
	o.callback = SceneContextManager.OnMouseMove;
	CommonCtrl.os.hook.SetWindowsHook(o, self.priority);
	o = {hookType = hookType, 		 
		hookName = "cm_m_wheel_hook", appName = "input", wndName = "mouse_wheel"};
	o.callback = SceneContextManager.OnMouseWheel;
	CommonCtrl.os.hook.SetWindowsHook(o, self.priority);
	o = {hookType = hookType, 		 
		hookName = "cm_m_up_hook", appName = "input", wndName = "mouse_up"};
	o.callback = SceneContextManager.OnMouseUp;
	CommonCtrl.os.hook.SetWindowsHook(o, self.priority);
	o = {hookType=hookType, 
		hookName = "cm_keydown", appName="input", wndName = "key_down"};
	o.callback = SceneContextManager.OnKeyDownProc;
	CommonCtrl.os.hook.SetWindowsHook(o, self.priority);
end

function SceneContextManager:UnHook()
	local hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROC;
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "cm_m_down_hook", hookType = hookType});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "cm_m_move_hook", hookType = hookType});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "cm_m_wheel_hook", hookType = hookType});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "cm_m_up_hook", hookType = hookType});
	CommonCtrl.os.hook.UnhookWindowsHook({hookName = "cm_keydown", hookType = hookType});
end

-- @param name: must be a unique name or the previous one will be deleted. if nil, "default" is used. 
-- @return the context object
function SceneContextManager:Register(name, context)
	name = name or "default";
	local last_context = registered_contexts[name];
	if(last_context and last_context~=context) then
		LOG.std(nil, "warn", "SceneContextManager", "overriding previous context: %s", name);
		if(last_context == self:GetCurrentContext()) then
			self:Unselect(last_context);
		end
	end
	registered_contexts[name] = context;
	LOG.std(nil, "info", "SceneContextManager", "new context: %s registered", name);
	return context;
end

-- get by name
function SceneContextManager:GetContext(name)
	return registered_contexts[name];
end

-- @return the current context or nil if no context is selected. 
function SceneContextManager:GetCurrentContext()
	return current_context;
end

-- return true if successfully selected, or false if not, 
-- most possibly because the current context disallowed it, such as not completing some critical tool functions. 
function SceneContextManager:Select(context)
	if(not context) then
		return self:Unselect();
	end
	local lastContext = self:GetCurrentContext();
	if(context ~= lastContext) then
		if(self:Unselect() and context) then
			-- LOG.std(nil, "debug", "SceneContextManager", "context selected");
			current_context = context;
			context:OnSelect(lastContext);
			self:contextSelected(); -- signal
			return true;
		end
	else
		return true;
	end
end

-- @param context: if nil, current context is used
-- return true if successfully unselected, or false if unselected.
function SceneContextManager:Unselect(context)
	context = context or self:GetCurrentContext();
	if(current_context == context and context) then
		if(context:OnUnselect()~=false) then
			context:DeleteManipulators();
			current_context = nil;
			self:contextUnselected(); -- signal
			return true;
		else
			return false;
		end
	end
	return true;
end

function SceneContextManager.OnMouseDown(nCode, appName, msg)
	-- return the nCode to be passed to the next hook procedure in the hook chain. 
	-- in most cases, if nCode is nil, the hook procedure should do nothing. 
	if(nCode==nil) then return end
	
	local self = SceneContextManager;
	local context = self:GetCurrentContext();
	if(context) then
		local event = MouseEvent:init("mousePressEvent");
		context:handleMouseEvent(event);
		if(event:isAccepted()) then
			if(context:isCaptureMouse()) then
				ParaEngine.GetAttributeObject():SetField("CaptureMouse", true);
			end
			-- prevent any other hooks
			return nil;
		end
	end
	if(self:IsAcceptAllEvents()) then
		-- prevent any other hooks
		return nil;
	end
	return true;
end

function SceneContextManager.OnMouseMove(nCode, appName, msg)
	-- return the nCode to be passed to the next hook procedure in the hook chain. 
	-- in most cases, if nCode is nil, the hook procedure should do nothing. 
	if(nCode==nil) then return end
	
	local self = SceneContextManager;
	local context = self:GetCurrentContext();
	if(context) then
		local event = MouseEvent:init("mouseMoveEvent");
		context:handleMouseEvent(event);
		if(event:isAccepted()) then
			-- prevent any other hooks
			return nil;
		end
	end
	if(self:IsAcceptAllEvents()) then
		-- prevent any other hooks
		return nil;
	end
	return true;
end

function SceneContextManager.OnMouseUp(nCode, appName, msg)
	-- return the nCode to be passed to the next hook procedure in the hook chain. 
	-- in most cases, if nCode is nil, the hook procedure should do nothing. 
	if(nCode==nil) then return end
	
	local self = SceneContextManager;
	local context = self:GetCurrentContext();
	if(context) then
		local event = MouseEvent:init("mouseReleaseEvent");
		event.dragDist = msg.dragDist or 0;
		context:handleMouseEvent(event);
		ParaEngine.GetAttributeObject():SetField("CaptureMouse", false);

		if(event:isAccepted() or context:IsAcceptAllEvents()) then
			-- prevent any other hooks
			return nil;
		end
	end
	if(self:IsAcceptAllEvents()) then
		-- prevent any other hooks
		return nil;
	end
	return true;
end

function SceneContextManager.OnMouseWheel(nCode, appName, msg)
	-- return the nCode to be passed to the next hook procedure in the hook chain. 
	-- in most cases, if nCode is nil, the hook procedure should do nothing. 
	if(nCode==nil) then return end
	
	local self = SceneContextManager;
	local context = self:GetCurrentContext();
	if(context) then
		local event = MouseEvent:init("mouseWheelEvent");
		context:handleMouseEvent(event);
		if(event:isAccepted()) then
			-- prevent any other hooks
			return nil;
		end
	end
	return true;
end

function SceneContextManager.OnKeyDownProc(nCode, appName, msg)
	-- return the nCode to be passed to the next hook procedure in the hook chain. 
	-- in most cases, if nCode is nil, the hook procedure should do nothing. 
	if(nCode==nil) then return end
	
	local self = SceneContextManager;
	local context = self:GetCurrentContext();
	if(context) then
		local event = KeyEvent:init("keyPressEvent", msg.virtual_key);
		context:handleKeyEvent(event);
		if(event:isAccepted()) then
			-- prevent any other hooks
			return nil;
		end
	end
	if(self:IsAcceptAllEvents()) then
		-- prevent any other hooks
		return nil;
	end
	return true;
end

SceneContextManager:InitSingleton();