--[[
Title: global UI management
Author(s): LiXizhi
Date: 2015/4/22
Desc: Application class manages the GUI application's control flow and main settings.
There is precisely one Application object, no matter whether the application has 0, 1, 2 or more windows at any given time.

References: QApplication in qt framework

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/Application.lua");
local Application = commonlib.gettable("System.Windows.Application");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Core/Namespace.lua");
NPL.load("(gl)script/ide/System/Core/ToolBase.lua");
NPL.load("(gl)script/ide/System/Windows/Events.lua");
NPL.load("(gl)script/ide/System/Core/PainterContext.lua");
NPL.load("(gl)script/ide/System/Core/PostEventList.lua");
NPL.load("(gl)script/ide/System/Windows/mcml/Page.lua");
NPL.load("(gl)script/ide/System/Windows/mcml/mcml.lua");
NPL.load("(gl)script/ide/System/Windows/Mouse.lua");
NPL.load("(gl)script/ide/System/Windows/MouseEvent.lua");
local FocusPolicy = commonlib.gettable("System.Core.Namespace.FocusPolicy");
local MouseEvent = commonlib.gettable("System.Windows.MouseEvent");
local Event = commonlib.gettable("System.Core.Event");
local Mouse = commonlib.gettable("System.Windows.Mouse");
local mcml = commonlib.gettable("System.Windows.mcml");
local Page = commonlib.gettable("System.Windows.mcml.Page");
local PostEvent = commonlib.gettable("System.Core.PostEvent");
local PostEventList = commonlib.gettable("System.Core.PostEventList");
local FocusEvent = commonlib.gettable("System.Windows.FocusEvent");
local MouseLeaveEvent = commonlib.gettable("System.Windows.MouseLeaveEvent");
local MouseEnterEvent = commonlib.gettable("System.Windows.MouseEnterEvent");

local Application = commonlib.inherit(commonlib.gettable("System.Core.ToolBase"), commonlib.gettable("System.Windows.Application"));

Application:Property("Name", "Application");
Application:Property({"tooltipWalkupDelay", 300});
Application:Property({"toolTipFallAsleepDelay", 5000});
Application:Property({"bLogEvent", nil, desc="whether to log event to log file. "});
Application:Signal("focusChanged", function(prev, focus_widget)  end);

function Application:ctor()
	self.postEventList = PostEventList:new();
	self.timer = commonlib.Timer:new({callbackFunc = function(timer)
		self:OnTick();
	end})
	self.timer:Change(1000,33);

	self.toolTipWakeUpTimer = commonlib.Timer:new({callbackFunc = function(timer)
		self:OnToolipWalkUp(timer);
	end})
	NPL.load("(gl)script/ide/System/Windows/InputMethod.lua");
	local InputMethod = commonlib.gettable("System.Windows.InputMethod");
	self.m_inputMethod = InputMethod:new();
end

-- get the IME input method object. 
function Application:inputMethod()
	return self.m_inputMethod;
end

-- get current active window
function Application:activeWindow()
	return self.active_window;
end

-- It sets the activeWindow() and focusWidget() and sends proper WindowActivate 
-- and WindowDeactivate, FocusIn, FocusOut events to all appropriate widgets. 
-- The window will then be painted in active state (e.g. cursors in line edits will blink), and it will have tool tips enabled.
function Application:setActiveWindow(act)
	local window;
	if(act) then
		window = act:GetWindow();
	end
	if(self.active_window == window) then
		return;
	end

	local toBeActivated = {};
    local toBeDeactivated = {};
	if(self.active_window) then
		toBeDeactivated[#toBeDeactivated+1] = self.active_window;
	end

	if (self.focus_widget) then
        if (self.focus_widget:testAttribute("WA_InputMethodEnabled")) then
            self:inputMethod():commit();
		end
        local focusAboutToChange = FocusEvent:new():init("FocusAboutToChange", "ActiveWindowFocusReason");
        self:sendEvent(self.focus_widget, focusAboutToChange);
    end

	self.active_window = window;

	if(self.active_window) then
		toBeActivated[#toBeActivated+1] = self.active_window;
	end

	-- fire activate/deactivate events...
	local activationChange = Event:new_static("ActivationChangeEvent");
	local windowActivate = Event:new_static("windowActivateEvent");
	local WindowDeactivate = Event:new_static("WindowDeactivateEvent");
    for i=1, #toBeActivated do
		local w = toBeActivated[i];
		self:sendSpontaneousEvent(w, windowActivate);
		self:sendSpontaneousEvent(w, activationChange);
	end

	for i=1, #toBeDeactivated do
		local w = toBeDeactivated[i];
		self:sendSpontaneousEvent(w, WindowDeactivate);
		self:sendSpontaneousEvent(w, activationChange);
	end

	-- fire focus events
	if (not self.popupWidgets) then -- not inPopupMode()
        if (not self.active_window and self.focus_widget) then
            self:setFocusWidget(nil, "ActiveWindowFocusReason");
        elseif (self.active_window) then
            local w = self.active_window:focusWidget();
            if (w and w:isVisible()) then
                w:setFocus("ActiveWindowFocusReason");
            else
                w = self:focusNextPrevChild_helper(self.active_window, true);
                if (w) then
                    w:setFocus("ActiveWindowFocusReason");
                else
                    -- If the focus widget is not in the activate_window, clear the focus
                    w = self.focus_widget;
                    if (not w and self.active_window:focusPolicy() ~= FocusPolicy.NoFocus) then
                        self:setFocusWidget(self.active_window, "ActiveWindowFocusReason");
                    elseif (not self.active_window:isAncestorOf(w)) then
                        self:setFocusWidget(nil, "ActiveWindowFocusReason");
					end
                end
            end
        end
	end
end

-- TODO: private
function Application:focusNextPrevChild_helper(window)
end

-- Returns the application widget that has the keyboard input focus, or nil
function Application:focusWidget()
    return self.focus_widget;
end

-- send to a queue to be processed next tick. 
function Application:postEvent(receiver, event, priority)
	if(not receiver or not event) then
		LOG.std(nil, "warn", "Application:postEvent", "Unexpected null receiver");
		return;
	end
	-- if this is one of the compressible events, do compression
	if(receiver.postedEvents > 0 and self:compressEvent(event, receiver, self.postEventList)) then
		return;
	end
	-- post events
	self.postEventList:addEvent(PostEvent:new_from_pool(receiver, event, priority));
	event.posted = true;
	receiver.postedEvents = receiver.postedEvents + 1;
end

-- Immediately dispatches all events which have been previously queued
-- @param receiver: if receiver is nil, the events for all objects are sent. 
--	or all the events of the given event_type are sent for specified receiver.
-- @param event_type: if nil, it means all events
function Application:sendPostedEvents(receiver, event_type)
	local postEventList = self.postEventList;
	
	if(postEventList:empty()) then
		return;
	end

	postEventList.recursion = postEventList.recursion + 1;

	-- during processing, new events may be posted to the event list. so we will set the new insertionOffset
	-- to the end of the queue for newly postly event, which will not be processed in this method.
	postEventList.insertionOffset = postEventList:size();
	local startOffset = postEventList.startOffset;

	local pe = postEventList:first();
	local i = startOffset;
	while (pe) do
		if(i>=postEventList.insertionOffset) then
			break;
		end
		if (pe.event) then
			if((receiver and receiver~=pe.receiver) or (event_type and event_type~=pe.event:GetType())) then
				-- skip this event if receiver or event_type does not match
			else
				pe.event.posted = false;
				local e = pe.event;
				local r = pe.receiver;
				r.postedEvents = r.postedEvents - 1;
				-- empty the event to mark it
				pe.event = nil;
				-- after all that work, it's time to deliver the event.
				self:sendEvent(r, e);
			end
		end
		pe = postEventList:next(pe);
		i = i + 1;
	end

	-- final clean up
	postEventList.recursion = postEventList.recursion - 1;

	-- clear the global list, i.e. remove everything that was delivered.
    if (not event_type and not receiver) then
		local pe = postEventList:first();
		for i=1, postEventList.insertionOffset do
			if(pe) then
				pe = postEventList:remove(pe);
			end
		end
        postEventList.insertionOffset = 0;
        postEventList.startOffset = 0;
    end
end

-- following events are compressed by removing duplicated ones in posted event list. 
local unique_event_names = {
	["UpdateRequestEvent"] = true,
	["LayoutRequestEvent"] = true,
	["sizeEvent"] = true,
	["moveEvent"] = true,
	["LanguageChangeEvent"] = true,
	["InputMethodEvent"] = true,
}

-- return true if event is duplicated and compressed(skipped). 
function Application:compressEvent(event, receiver, postEventList)
	local event_type = event:GetType();
	if (unique_event_names[event_type]) then
		local postEventList = self.postEventList;
		local cur = postEventList:first();
		while(cur) do
		    if (cur.receiver ~= receiver or not cur.event or cur.event:GetType() ~= event_type) then
				-- skip if no matching event found. 
			else
				local cur_type =cur.event:GetType();
				if (cur_type == "LayoutRequestEvent" or cur_type == "UpdateRequestEvent") then
					
				elseif (cur_type == "sizeEvent") then
					cur.event.s = event.s;
				elseif (cur_type == "moveEvent") then
					cur.event.p = event.p;
				elseif (cur_type == "LanguageChange") then
					
				elseif ( cur_type == "InputMethod") then
					cur.event = event;
				end
				return true;
			end
			cur = postEventList:next(cur);
        end
        return false;
    end
end

function Application:sendEvent(receiver, event)
	if(receiver and event) then
		event.spont = false;
		return self:notifyInternal(receiver, event);
	end
end

function Application:sendSpontaneousEvent(receiver, event)
	if(receiver and event) then
		event.spont = true;
		return self:notifyInternal(receiver, event);
	end
end

-- TODO: hook function 
function Application:registerCallback(Callback_type)
end

-- TODO: hook function 
function Application:unregisterCallback(Callback_type)
end

-- TODO: invoke hooking function:
function Application:activateCallbacks(Callback_type, ...)
end

local s_hook_event = {};


-- This function is here to make it possible for extensions to
-- hook into event notification without subclassing Application
function Application:notifyInternal(receiver, event)
	--[[
    -- Make it possible for NPL Script to hook into events
	s_hook_event.receiver = receiver;
	s_hook_event.event = event;
	s_hook_event.result = false;
    if (self:activateCallbacks("EventNotifyCallback", s_hook_event)) then
        return s_hook_event.result;
    end
	]]
	if(self.bLogEvent) then
		local event_type = event:GetType();
		if(event_type~="paintEvent") then
			-- skip some frequent event
			echo(event:tostring());
		end
	end
    return self:notify(receiver, event);
end

function Application:OnToolipWalkUp(timer)
	timer:Change();
    if (self.toolTipWidget) then
        local w = self.toolTipWidget:GetWindow();
        -- show tooltip if WA_AlwaysShowToolTips is set, or if
        -- any ancestor of self.toolTipWidget is the active window
        local showToolTip = w:testAttribute("WA_AlwaysShowToolTips");
        while (w and not showToolTip) do
            showToolTip = w:isActiveWindow();
            w = w:parentWidget();
			if(w) then
				w = w:GetWindow();
			end
        end
        if (showToolTip) then
			local e = Event:new():init("toolTipEvent");
            self:sendEvent(self.toolTipWidget, e);
        end
    end
end

local cancelTooltipEvents = {
	mousePressEvent = true, mouseReleaseEvent = true, mouseWheelEvent = true, mouseLeaveEvent = true,
};
function Application:notify(receiver, event)
	local type = event:GetType();
	local res;

	if(cancelTooltipEvents[type]) then
		self.toolTipWakeUpTimer:Change();
	end
	
	if(type == "keyDownEvent" or type == "keyPressedEvent") then
		local w = receiver;
		while(w) do
			res = self:notify_helper(w, event);
			if (res and event:isAccepted()) then
				break;
			end
			w = w:parentWidget();
		end
		return res;
	elseif(type == "mousePressEvent" or type == "mouseReleaseEvent" or type == "mouseMoveEvent" or type == "mouseWheelEvent") then
		local w = receiver;
		if (type == "mouseMoveEvent") then
			if(event:buttons() == 0) then
				self.toolTipWidget = w;
				if(not self.toolTipWakeUpTimer:IsEnabled()) then
					self.toolTipWakeUpTimer:Change(self.tooltipWalkupDelay, nil);
				end
			end
		else
			self:giveFocusAccordingToFocusPolicy(w, event, event:pos());
		end

		while(w) do
			if(not w:hasMouseTracking() and type == "mouseMoveEvent" and event:buttons() == 0) then
				-- skip mouseMoveEvent if mouse-tracking is off when no mouse button is pressed. 
				-- but still send them through all application event filters (normally done by notify_helper)
				self:filterEvent(w, event);
				res = true;
			else
				res = self:notify_helper(w, event);
			end
			if (res and event:isAccepted()) then
				break;
			end
			event:pos():add(w:x(), w:y());
			w = w:parentWidget();
		end
		return res;
	else
		return self:notify_helper(receiver, event);
	end
end

function Application:notify_helper(receiver, event)
	-- send to all application event filters
    if (self:filterEvent(receiver, event)) then
        return true;
	end

    if (receiver) then
		local type = event:GetType();
		if (type == "mouseEnterEvent") then
            receiver:setAttribute("WA_UnderMouse", true);
        elseif (type == "mouseLeaveEvent") then
            receiver:setAttribute("WA_UnderMouse", false);
		end
		if(receiver.layout and receiver.layout.widgetEvent) then
			receiver.layout:widgetEvent(event);
		end
		if(receiver.event) then
			-- deliver the event
			return receiver:event(event);
		end	
    else
	   LOG.std(nil, "warn", "Application:notify", "empty receiver");
    end
end

function Application:giveFocusAccordingToFocusPolicy(widget, event, localPos)
	localPos = localPos:clone_from_pool();
	local focusPolicy = FocusPolicy.ClickFocus;
	local focusWidget = widget;
    while (focusWidget) do
        if (focusWidget:isEnabled() and focusWidget:rect():contains(localPos) and self:shouldSetFocus(focusWidget, focusPolicy) ) then
            focusWidget:setFocus("MouseFocusReason");
            break;
        end
        if (focusWidget:isWindow()) then
            break;
		end

        -- find out whether this widget (or its proxy) already has focus
        local f = focusWidget.focus_proxy or focusWidget;
        
        -- if it has, stop here.
        if (f:hasFocus()) then
            break;
		end

        localPos:add(focusWidget:pos());
        focusWidget = focusWidget:parentWidget();
    end
end

function Application:shouldSetFocus(w, policy)
    local f = w;
    while (f.focus_proxy) do
        f = f.focus_proxy;
	end

    if (w:focusPolicy() < policy) then
        return false;
	end
    if (w ~= f and (f:focusPolicy()< policy)) then
        return false;
	end
    return true;
end

function Application:setFocusWidget(focus, reason)
	self.hidden_focus_widget = nil;
	if (focus ~= self.focus_widget) then
        if (focus and focus:isHidden()) then
            self.hidden_focus_widget = focus;
            return;
        end
       
        local prev = self.focus_widget;
        self.focus_widget = focus;

        if(self.focus_widget) then
            self.focus_widget:setFocus_sys();
		end

		if (reason ~= "NoFocusReason") then
			-- send events
			if (prev) then
				local focusOutEvent = FocusEvent:new():init("focusOutEvent", reason);
				self:sendEvent(prev, focusOutEvent);
			end
			if(focus and self.focus_widget == focus) then
				local focusInEvent = FocusEvent:new():init("focusInEvent", reason);
				self:sendEvent(focus, focusInEvent);
			end
			self:focusChanged(prev, focus_widget);
		end
	end
end

-- called at 30 FPS, when application is created. 
function Application:OnTick()
	self:sendPostedEvents();
end

-- internal: it will generate virtual MouseEnter/Leave messages if necessary
function Application:sendMouseEvent(receiver, event)
	if(not receiver or not event) then
		return;
	end
	local widgetUnderMouse = receiver:rect():contains(event:localPos());

	if(self.lastMouseReceiver ~= receiver or widgetUnderMouse) then
		-- Dispatch enter/leave if we move:
		self:dispatchMouseEnterLeave(receiver, self.lastMouseReceiver, event:screenPos());
	end

	-- send the mouse event
	Application:sendEvent(receiver, event);
	
	self.lastMouseReceiver = receiver;
end


-- Creates the proper Enter/Leave event when widget \a enter is entered and widget \a leave is left.
function Application:dispatchMouseEnterLeave(enter, leave, globalPos)
    if ((not enter and not leave) or (enter == leave)) then
        return;
	end

	local w;
	local leaveList = commonlib.Array:new();
    local enterList = commonlib.Array:new();

    local sameWindow = leave and enter and leave:GetWindow() == enter:GetWindow();
	if (leave and not sameWindow) then 
        w = leave;
        while(w) do
            leaveList:append(w);
			if(w:isWindow()) then
				break;
			end
			w = w:parentWidget();
        end
    end
    if (enter and not sameWindow) then
        w = enter;
        while(w) do
            enterList:prepend(w);
			if(w:isWindow()) then
				break;
			end
			w = w:parentWidget();
        end
    end

	if(sameWindow) then
		local enterDepth = 0;
        local leaveDepth = 0;
        w = enter;
        while (w and not w:isWindow()) do
			w = w:parentWidget();
            enterDepth = enterDepth + 1;
		end
        w = leave;
        while (w and not w:isWindow()) do
			w = w:parentWidget();
            leaveDepth = leaveDepth + 1;
		end
            
        local wenter = enter;
        local wleave = leave;
        while (enterDepth > leaveDepth) do
            wenter = wenter:parentWidget();
            enterDepth = enterDepth - 1;
        end
        while (leaveDepth > enterDepth) do
            wleave = wleave:parentWidget();
            leaveDepth = leaveDepth - 1;
        end
        while (not wenter:isWindow() and wenter ~= wleave) do
            wenter = wenter:parentWidget();
            wleave = wleave:parentWidget();
        end

        w = leave;
        while (w ~= wleave) do
            leaveList:append(w);
            w = w:parentWidget();
        end
        w = enter;
        while (w ~= wenter) do
            enterList:prepend(w);
            w = w:parentWidget();
        end
	end
	
	if(not leaveList:empty()) then
		local leaveEvent = MouseLeaveEvent:GetInstance();
		for i = 1, #leaveList do
			w = leaveList[i];
			self:sendEvent(w, leaveEvent);
		end
	end
	if(not enterList:empty()) then
		local windowPos = enterList:first():GetWindow():mapFromGlobal(globalPos);
		for i = 1, #enterList do
			w = enterList[i];
			local localPos = w:mapFromGlobal(globalPos);
			local enterEvent = MouseEnterEvent:new():init(localPos, windowPos, globalPos);
			self:sendEvent(w, enterEvent);
		end
	end
end

-- short cut for current mouse capture.
function Application:mouseGrabber()
	return Mouse:GetCapture();
end

function Application:releaseMouse()
	return Mouse:Capture(nil);
end

function Application:keyboardGrabber()
	return nil;
end

-- TODO: NOT tested
-- This function should only be called when the widget changes visibility, i.e.
-- when the \a widget is shown, hidden or deleted. This function does nothing
-- if the widget is a top-level or native, enter/leave events are genereated by the underlying windowing system.
function Application:sendSyntheticEnterLeave(widget)
    if (not widget or widget:isWindow()) then
        return;
	end
    local widgetInShow = widget:isVisible() and not widget.in_destructor;
    if (not widgetInShow and widget ~= self.lastMouseReceiver) then
        return; -- Widget was not under the cursor when it was hidden/deleted.
	end

    if (widgetInShow and widget:parentWidget().in_show) then
        return; -- Ingore recursive show.
	end

    local mouseGrabber = self:mouseGrabber();
    if (mouseGrabber and mouseGrabber ~= widget) then
        return; -- Someone else has the grab; enter/leave should not occur.
	end

    local tlw = widget:GetWindow();
    if (tlw.in_destructor or tlw.is_closing) then
        return; -- Closing down the business.
	end

    if (widgetInShow and (not self.lastMouseReceiver or self.lastMouseReceiver:GetWindow() ~= tlw)) then
        return; -- Mouse cursor not inside the widget's top-level.
	end

    local globalPos = Mouse:pos();
    local windowPos = tlw:mapFromGlobal(globalPos);

    -- Find the current widget under the mouse. If this function was called from
    -- the widget's destructor, we have to make sure childAt() doesn't take into
    -- account widgets that are about to be destructed.
    local widgetUnderCursor = tlw:childAt_helper(windowPos, widget.in_destructor);
    if (not widgetUnderCursor) then
        widgetUnderCursor = tlw;
	end
    local pos = widgetUnderCursor:mapFrom(tlw, windowPos);

    if (widgetInShow and widgetUnderCursor ~= widget and not widget:isAncestorOf(widgetUnderCursor)) then
        return; -- Mouse cursor not inside the widget or any of its children.
	end

    if (widget.in_destructor and self.button_down == widget) then
        self.button_down = nil;
	end

    -- Send enter/leave events followed by a mouse move on the entered widget.
	local e = MouseEvent:new():init("mouseMoveEvent", nil, pos, windowPos, globalPo);
    self:sendMouseEvent(widgetUnderCursor, e);
end

-- the time in milliseconds that a mouse button must be held down before a drag and drop operation will begin
-- The default value is 500 ms.
function Application:startDragTime()
    return 500;
end

-- The default value is 1000 ms.
function Application:cursorFlashTime()
	return 1000;
end

function Application:pickMouseReceiver(candidate, windowPos, pos, event_type, buttons, buttonDown, alienWidget)
	local mouseGrabber = Mouse:GetCapture();
	
	local receiver = candidate;

	if(not mouseGrabber) then
		-- mouse move and release event only sent to last mouse down widget
		mouseGrabber = buttonDown or alienWidget;
	end

	if (mouseGrabber and mouseGrabber ~= candidate) then
        receiver = mouseGrabber;
    end
    return receiver;
end


-- static function:
-- load components from a given mcml page or page url to uiElement.
function Application.LoadComponent(uiElement, url)
	if(uiElement) then
		local page = Page:new();
		page:Attach(uiElement);
		page:Init(url);
	end
end

-- this is a singleton class
Application:InitSingleton();