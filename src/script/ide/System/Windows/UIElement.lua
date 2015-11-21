--[[
Title: Base class to all UI objects
Author(s): LiXizhi
Date: 2015/4/21
Desc: The UIElement class is the base class of all user interface objects.
it receives mouse, keyboard and other events from the window system, and paints a representation of
itself on the screen. Every widget is rectangular, and they are sorted in a Z-order.

References: Widget class in QT framework, Visual, UIElement class in WPF controls.

virtual functions for derived classes:
	event(event): handle all kinds of events
	paintEvent(painter)
	mousePressEvent(event)
	mouseMoveEvent
	mouseReleaseEvent
	mouseWheelEvent
	focusInEvent
	focusOutEvent
	mouseLeaveEvent
	mouseEnterEvent
	keyReleaseEvent
	keyPressEvent
	logEvent
	sizeEvent
	ShowToParentEvent
	showEvent
	hideEvent
	LayoutRequestEvent

	updateGeometry
	setGeometry
	ApplyCss(css)

The events are received in following order when any control is first shown: 
	sizeEvent, showEvent, [showToParentEvent], ..., {paintEvent...}

Following are function calls when a control is first shown:
	A group of controls are created by xxx:new():init(parent). Parent-child relationships are usually initialized before control is shown. 
	When the parent window's show() is called, it will first invoke create() method for all controls recursively, 
	calculate layout of the top level window control (usually is mcml page layout), 
	send the sizeEvent and showEvent, make it visible and begins to receive paintEvent. 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Windows/UIElement.lua");
local UIElement = commonlib.gettable("System.Windows.UIElement")
local elem = UIElement:new():init(parent);
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Core/ToolBase.lua");
NPL.load("(gl)script/ide/System/Core/PainterContext.lua");
NPL.load("(gl)script/ide/System/Windows/MouseEvent.lua");
NPL.load("(gl)script/ide/System/Windows/KeyEvent.lua");
NPL.load("(gl)script/ide/math/Rect.lua");
NPL.load("(gl)script/ide/math/Point.lua");
NPL.load("(gl)script/ide/System/Windows/Mouse.lua");
NPL.load("(gl)script/ide/System/Windows/UIElement_p.lua");
NPL.load("(gl)script/ide/System/Windows/Tooltip.lua");
local Tooltip = commonlib.gettable("System.Windows.Tooltip");
local FocusPolicy = commonlib.gettable("System.Core.Namespace.FocusPolicy");
local SizeEvent = commonlib.gettable("System.Windows.SizeEvent");
local Event = commonlib.gettable("System.Core.Event");
local Mouse = commonlib.gettable("System.Windows.Mouse");
local Application = commonlib.gettable("System.Windows.Application");
local Point = commonlib.gettable("mathlib.Point");
local Rect = commonlib.gettable("mathlib.Rect");
local ShowEvent = commonlib.gettable("System.Windows.ShowEvent");
local KeyEvent = commonlib.gettable("System.Windows.KeyEvent");
local MouseEvent = commonlib.gettable("System.Windows.MouseEvent");
local UIElement = commonlib.inherit(commonlib.gettable("System.Core.ToolBase"), commonlib.gettable("System.Windows.UIElement"));
UIElement:Property("Name", "UIElement");
UIElement:Signal("SizeChanged");
UIElement:Property({"enabled", true, "isEnabled", auto=true});
UIElement:Property({"BackgroundColor", "#cccccc", auto=true});
UIElement:Property({"Background", nil, auto=true});
UIElement:Property({"tooltip", nil, "GetTooltip", "SetTooltip", auto=true});
UIElement:Property({"toolTipDuration", 5000, auto=true});

UIElement:Property({"focus_policy", FocusPolicy.NoFocus, "focusPolicy", "setFocusPolicy"});
UIElement:Property({"mouseTracking", nil, "hasMouseTracking", "setMouseTracking"});

-- number of posted events
UIElement.postedEvents = 0;

function UIElement:ctor()
	-- client rect
	self.crect = Rect:new():init(0,0,0,0);
end

-- init and return the object. 
-- If you add a child widget to an already visible widget you must
-- explicitly show the child to make it visible.
function UIElement:init(parent)
	self:SetParent(parent);
	return self;
end

function UIElement:SetParent(parent)
	local newParent = (self.parent ~= parent);
	if(newParent) then
		local oldWindow = self:GetWindow();
		if (newParent and self:isAncestorOf(self:focusWidget())) then
			self:focusWidget():clearFocus();
		end
		if(parent) then
			self.window = parent:GetWindow();
		else
			self.window = nil;
		end
		self:setParent_helper(parent);
	end
end

-- virtual: apply css style
function UIElement:ApplyCss(css)
	if(css["background-color"]) then
		self:SetBackgroundColor(css["background-color"]);
		if(not css.background) then
			self:SetBackground("Texture/whitedot.png");
		end
	end	
	if(css.background) then
		self:SetBackground(css.background);
	end
end

-- Returns true if this object is a parent, (or grandparent and so on
-- to any level), of the given child, and both objects are within
-- the same window; otherwise returns false.
function UIElement:isAncestorOf(child)
    while (child) do
        if (child == self) then
            return true;
        elseif (child:isWindow()) then
            return false;
		end
        child = child:parentWidget();
    end
    return false;
end

function UIElement:isWindow()
	return false;
end

-- the native window object at the root of parent.
function UIElement:GetWindow()
	return self.window;
end

function UIElement:parentWidget()
	return self.parent;
end

function UIElement:isHidden() 
	return self:testAttribute("WA_WState_Hidden");
end

function UIElement:isVisible()
	return self:testAttribute("WA_WState_Visible");
end

-- A hidden widget will only become visible when show() is called on
-- it. It will not be automatically shown when the parent is shown.
function UIElement:hide()
	self:setVisible(false);
end

function UIElement:hide_sys()
end

-- Shows the widget and its child widgets.
function UIElement:show()
	self:setVisible(true);
end

-- Makes the widget visible in the isVisible() meaning of the word.
-- It is only called for toplevels or widgets with visible parents.
function UIElement:show_recursive()
    if (not self:testAttribute("WA_WState_Created")) then
        self:createRecursively();
	end
    
    --if (not self:isWindow() and self:parentWidget().layout and not self:parentWidget().in_show) then
        --self:parentWidget().layout:activate();
	--end

    -- activate our layout before we and our children become visible
    if (self.layout) then
        self.layout:activate();
	end

    self:show_helper();
end

function UIElement:show_sys()
end

function UIElement:show_helper()
    self.in_show = true;
    -- make sure we receive pending move and resize events
    self:sendPendingSizeEvents();

    -- become visible before showing all children
    self:setAttribute("WA_WState_Visible");

    -- finally show all children recursively
	self:showChildren(false);

    -- send the show event before showing the window
    Application:sendEvent(self, ShowEvent:new());

    self:show_sys();

    if (Application.hidden_focus_widget == self) then
        Application.hidden_focus_widget = nil;
        self:setFocus("OtherFocusReason");
    end

    self.in_show = false; 
end

function UIElement:createRecursively()
    self:create(nil, true, true);
    local child = children:first();
	while (child) do
        if (not child:isHidden() and not child:isWindow() and not child:testAttribute("WA_WState_Created")) then
            child:createRecursively();
		end
		child = children:next(child);
    end
end

-- @param window: native window object
function UIElement:create(window, initializeWindow, destroyOldWindow)
	if (self:testAttribute("WA_WState_Created") and window == nil) then
        return;
	end
	self:create_sys(window, initializeWindow, destroyOldWindow);
	self:setAttribute("WA_WState_Created");-- set created flag
end

function UIElement:create_sys()
end

function UIElement:aboutToDestroy()
end

function UIElement:deactivateWidgetCleanup()
	if (self == Application.active_window) then
        Application:setActiveWindow(nil);
	end
	-- If the is the active mouse press widget, reset it
    if (self == Application.qt_button_down) then
        Application.qt_button_down = nil;
	end
end

-- TODO: not tested
function UIElement:destroy(destroyWindow)
    self:aboutToDestroy();
	self:deactivateWidgetCleanup();
    
    if (Application:mouseGrabber() == self) then
        Application:releaseMouse();
	end
    if (Application:keyboardGrabber() == self) then
        Application:releaseKeyboard();
	end
    self:setAttribute("WA_WState_Created", false);

	if (destroyWindow) then
        self:deleteTLSysExtra();
    else
        if (self:parentWidget() and self:parentWidget():testAttribute("WA_WState_Created")) then
            self:hide_sys();
        end
	end
    self.window = nil;
end


function UIElement:isCreated()
	return self:testAttribute("WA_WState_Created");
end

function UIElement:setVisible(visible)
	if(visible) then
		if (self:testAttribute("WA_WState_ExplicitShowHide") and not self:testAttribute("WA_WState_Hidden")) then
            return;
		end
		-- we have to at least create toplevels, but not children of non-visible parents
        local pw = self:parentWidget();
        if (not self:testAttribute("WA_WState_Created")
            and (self:isWindow() or pw:testAttribute("WA_WState_Created"))) then
            self:create();
        end
		-- remember that show was called explicitly
        self:setAttribute("WA_WState_ExplicitShowHide");
        -- we are no longer hidden
        self:setAttribute("WA_WState_Hidden", false);

		-- activate our layout before we and our children become visible
        if (self.layout) then
            self.layout:activate();
		end

		if (not self:isWindow()) then
            local parent = self:parentWidget();
            while (parent and parent:isVisible() and parent.layout and not parent.in_show) do
                parent.layout:activate();
                if (parent:isWindow()) then
                    break;
				end
                parent = parent:parentWidget();
            end
        end

		self:setAttribute("WA_KeyboardFocusChange", false);

        if (self:isWindow() or self:parentWidget():isVisible()) then
            self:show_helper();
            Application:sendSyntheticEnterLeave(self);
        end

		local showToParentEvent = Event:new_static("ShowToParentEvent");
        Application:sendEvent(self, showToParentEvent);
	else
		-- hide
		if (self:testAttribute("WA_WState_ExplicitShowHide") and self:testAttribute("WA_WState_Hidden")) then
            return;
		end

		if (Application.hidden_focus_widget == self) then
            Application.hidden_focus_widget = nil;
		end
		self:setAttribute("WA_WState_Hidden");
        self:setAttribute("WA_WState_ExplicitShowHide");

		if (self:testAttribute("WA_WState_Created")) then
            self:hide_helper();
		end

		local hideToParentEvent = Event:new_static("HideToParentEvent");
        Application:sendEvent(self, hideToParentEvent);
	end
end

-- TODO:
function UIElement:focusNextPrevChild(bNext)
end

-- called whenever an event comes. Subclass can overwrite this function. 
-- @param handlerName: "sizeEvent", "paintEvent", "mouseDownEvent", "mouseUpEvent", etc. 
-- @param event: the event object. 
function UIElement:event(event)
	if(not self:isEnabled()) then
		-- do nothing if not enabled. 
	else
		local event_type = event:GetType();
		local func = self[event:GetHandlerFuncName()];
		if(type(func) == "function") then
			func(self, event);
		end
		if(event_type == "focusInEvent" or event_type == "moveEvent" or event_type == "sizeEvent") then
			self:updateWidgetTransform(event);
		end
	end
end

-- The resize event is called whenever the window is resized in the windowing system,
-- either directly through the windowing system acknowledging a setGeometry() or resize() request,
-- or indirectly through the user resizing the window manually.
function UIElement:sizeEvent(event)
end

-- just for printing log. 
function UIElement:logEvent(event)
	LOG.std(nil, "info", "logEvent", event);
end

-- force repaint in the next frame.
function UIElement:repaint()
	if(self.window) then
		self.window:repaint();
	end
end

-- Updates the widget unless updates are disabled or the widget is hidden.
-- This function does not cause an immediate repaint; instead it schedules a paint event for processing 
-- when system returns to the main event loop. This permits us to optimize for more speed and less 
-- flicker than a call to repaint() does. Calling update() several times normally results in just one paintEvent() call.
function UIElement:update()
    if (not self:isVisible() or not self:updatesEnabled()) then
		return;
	end
	if (self:testAttribute("WA_WState_InPaintEvent")) then
        Application:postEvent(self, Event:new_static("UpdateLaterEvent"));
        return;
    end
	if(self.window) then
		self.window:markDirty();
	end
end

function UIElement:isActiveWindow()
	return (self.window and self.window == Application:activeWindow());
end

function UIElement:focusPolicy()
    return self.focus_policy;
end

function UIElement:setFocusPolicy(policy)
    self.focus_policy = policy;
    if (self.focus_proxy) then
        self.focus_proxy:setFocusPolicy(policy);
	end
end

-- Returns the last child of this widget that setFocus had been
-- called on.  For top level widgets this is the widget that will get
-- focus in case this window gets activated
function UIElement:focusWidget()
    return self.focus_child;
end

function UIElement:setFocus_sys()
	if(self.window) then
		self.window:SetFocus_sys();
	end
end

-- whether this widget has the keyboard input focus
-- By default, this property is false.
function UIElement:hasFocus()
    return (Application:focusWidget() == self);
end

-- set key focus to the UIElement. 
-- @param reason: nil
function UIElement:setFocus(reason)
	if (not self:isEnabled()) then
        return;
	end
	if(Application:focusWidget() == self) then
		return;
	end
	if (self:isActiveWindow()) then
		-- local prev = Application:focusWidget();
		self:updateFocusChild();
		Application:setFocusWidget(self, reason);
	else
		self:updateFocusChild();
	end
end

-- updates focus_child on parent widgets to point into this widget
function UIElement:updateFocusChild()
	local w = self;
	if (w:isHidden()) then
        while (w and w:isHidden()) do
            w.focus_child = self;
			if(w:isWindow()) then
				w = nil;
			else
				w = w:parentWidget();
			end
        end
    else
        while (w) do
            w.focus_child = self;
            if(w:isWindow()) then
				w = nil;
			else
				w = w:parentWidget();
			end
        end
    end
end

function UIElement:clearFocus()
    local w = self;
    while (w) do
        if (w.focus_child == self) then
            w.focus_child = nil;
		end
        w = w:parentWidget();
    end
end

-- Updates the widget unless updates are disabled or the widget is hidden.
-- This function does not cause an immediate repaint; instead it schedules a paint in the next frame.
function UIElement:Update()
	if(self.window) then
		self.window:Update();
	end
end

-- get the style object
function UIElement:GetStyle()
	-- TODO: the css object. 
	return self.style;
end

-- we can temporarily disable updates for complex UI element and render them at lower frame rate. 
function UIElement:updatesEnabled()
	return not self:testAttribute("WA_UpdatesDisabled");
end

-- render the widget and all its child objects to the current device context. 
function UIElement:Render(painterContext)
	if(not painterContext) then
		return;
	end
	-- make sure all widgets are recursively laid out properly
	self:prepareToRender();

	-- draw all widgets recursively
	local offset = Point:new_from_pool(self:x(), self:y());
	self:drawWidget(painterContext, offset);
end

function UIElement:prepareToRender()
	if(self:isVisible()) then
		-- Make sure the widget is laid out correctly.
		self:GetWindow():sendPendingSizeEvents(true, true);
	end
end

-- draw with offset and its child recursively
-- @param offset: Point of offset. 
function UIElement:drawWidget(painterContext, offset)
	if (not self:updatesEnabled()) then
		return;
	end
	-- update the "in paint event" flag
	if (self:testAttribute("WA_WState_InPaintEvent")) then
		-- log("warning: UIElement:repaint: Recursive repaint detected\n");
		return;
	else
		self:setAttribute("WA_WState_InPaintEvent", true);
		-- actually send the paint event
		Application:sendSpontaneousEvent(self, painterContext);
		self:setAttribute("WA_WState_InPaintEvent", false);	
	end

	-- now draw all children if any
	if(self.children and not self.children:empty()) then
		local widget_offset = Point:new_from_pool(self:x(), self:y());
		widget_offset:add(offset);

		painterContext:Translate(widget_offset:x(), widget_offset:y());
		local children = self.children;
		local child = children:first();
		while (child) do
			child:drawWidget(painterContext, widget_offset);
			child = children:next(child);
		end
		painterContext:Translate(-widget_offset:x(), -widget_offset:y());
	end
end

-- virtual: render everything here
-- @param painter: painterContext
function UIElement:paintEvent(painter)
	-- remove following
	-- painter:SetPen(self:GetBackgroundColor());
	-- painter:DrawRect(self:x(), self:y(), self:width(), self:height());
end

function UIElement:setMouseTracking(enable)
	self:setAttribute("WA_MouseTracking", enable);
end

function UIElement:hasMouseTracking()
	self:testAttribute("WA_MouseTracking");
end

-- virtual: 
function UIElement:mousePressEvent(mouse_event)
	-- echo(mouse_event);
	-- self:setFocus();
end

-- virtual: 
-- If mouse tracking is switched off, mouse move events only occur if
-- a mouse button is pressed while the mouse is being moved. If mouse
-- tracking is switched on, mouse move events occur even if no mouse button is pressed.
function UIElement:mouseMoveEvent(mouse_event)

end
-- virtual: 
function UIElement:mouseReleaseEvent(mouse_event)
end
-- virtual: 
function UIElement:mouseWheelEvent(mouse_event)
end
-- virtual: 
function UIElement:keyPressEvent(key_event)
end
-- virtual: 
function UIElement:keyReleaseEvent(key_event)
end

-- virtual: An event is sent to the widget when the mouse cursor enters the widget.
function UIElement:mouseEnterEvent(event)
end

-- virtual: A leave event is sent to the widget when the mouse cursor leaves the widget.
function UIElement:mouseLeaveEvent(event)
end

-- virtual: 
function UIElement:focusInEvent(event)
end

-- virtual: 
function UIElement:focusOutEvent(event)
end

-- @param p: 
-- Returns the visible child object at the position x, y in the local coordinate system, or nil if no visible child.
function UIElement:childAt(point)
	return self:childAt_helper(point);
end

function UIElement:childAt_helper(point)
	if(self.children and not self.children:empty()) then
		if (self:pointInsideRectAndMask(point)) then
			return self:childAtRecursiveHelper(point);
		end
	end
end

-- private: 
-- @param p: point in local coordinate system. 
function UIElement:childAtRecursiveHelper(p)
	if(not self.children) then
		return
	end
	local child = self.children:last();
	while (child) do
		-- Map the point 'p' from parent coordinates to child coordinates.
		local childPoint = p:clone_from_pool();
		childPoint:sub(child.crect:topLeft());

		-- Check if the point hits the child.
		if (child:pointInsideRectAndMask(childPoint)) then
			if(child.children and not child.children:empty()) then
				-- Do the same for the child's descendants.
				return child:childAtRecursiveHelper(childPoint) or child;
			else
				return child;
			end
		end
		child = self.children:prev(child);
	end
end

function UIElement:pointInsideRectAndMask(p)
	return self:rect():contains(p) and (not self.mask or self.mask:contains(p));
end

-- @param bEnabled: if nil, it is true.
function UIElement:setAttribute(name, bEnabled)
	if(bEnabled == nil) then
		bEnabled = true;
	end
	if(self:testAttribute(name) ~= bEnabled) then
		self[name] = bEnabled;
	end
end

function UIElement:testAttribute(name)
	return self[name] == true;
end

-- set the rect
function UIElement:setGeometry(ax, ay, aw, ah)
	if (self:testAttribute("WA_WState_Created")) then
        self:setGeometry_sys(ax, ay, aw, ah);
    else
		self.crect:setRect(ax, ay, aw, ah);
		self:setAttribute("WA_PendingSizeEvent");
	end
end

-- move to a given position
-- if the widget is a window, the position is that of the widget on the desktop
-- Calling move() or setGeometry() inside moveEvent() can lead to infinite recursion
function UIElement:move(x, y)
    if (self:testAttribute("WA_WState_Created")) then
		self:setGeometry_sys(x + self:geometry():x(), y + self:geometry():y(), self:width(), self:height(), true);
    else
        -- no frame yet: 
		if(not self:isWindow()) then
			self.crect:setX(x); 
			self.crect:setY(y); 
		end
        self:setAttribute("WA_PendingSizeEvent");
    end
end

-- set size
function UIElement:resize(aw, ah)
	self.crect:setSize(aw, ah);
	self:setAttribute("WA_PendingSizeEvent");
end



-- client rect. left, top is always 0,0.
-- @note: the returned rect is temporary, do not keep for long. 
function UIElement:rect()
	return Rect:new_from_pool(0,0, self.crect:width(), self.crect:height());
end

-- return left top point
function UIElement:pos()
	return Point:new_from_pool(self.crect:topLeft());
end

-- left, top is relative to its parent. 
function UIElement:geometry()
	return self.crect;
end

function UIElement:width()
	return self.crect:width();
end

function UIElement:height()
	return self.crect:height();
end

-- the x coordinate relative to its parent
function UIElement:x()
	return self.crect:x();
end

-- the y coordinate relative to its parent
function UIElement:y()
	return self.crect:y();
end


function UIElement:setX(x)
	self.crect:setX(x);
end

function UIElement:setY(y)
	self.crect:setY(y);
end

-- if the mouse is captured to this element or not.
function UIElement:IsMouseCaptured()
    return Mouse:GetCapture() == self;
end

-- Captures the mouse to this element.
function UIElement:CaptureMouse()
	local lastCaptured = Mouse:GetCapture();
	if(lastCaptured) then
		lastCaptured:ReleaseMouseCapture();
	end
	local window = self:GetWindow();
	if(window) then
		window:SetMouseCaptureEnabled(true);
	end
    return Mouse:Capture(self);
end

-- Releases the mouse capture.
function UIElement:ReleaseMouseCapture()
	if (Mouse:GetCapture() == self) then
		local window = self:GetWindow();
		if(window) then
			window:SetMouseCaptureEnabled(false);
		end
        Mouse:Capture(nil);
   end
end

function UIElement:sendSizeEvents()
    local event = SizeEvent:new():init(self:rect());
    Application:sendEvent(self, event);
    if(self.children) then
		local children = self.children;
		local child = children:first();
		while (child) do
			child:sendSizeEvents();
			child = children:next(child);
		end
	end
end

function UIElement:sendPendingSizeEvents(recursive, disableUpdates)
	disableUpdates = disableUpdates and self:updatesEnabled();
    if (disableUpdates) then
       self:setAttribute("WA_UpdatesDisabled");
	end

	if(self:testAttribute("WA_PendingSizeEvent")) then
		local event = SizeEvent:new():init(self:rect());
		Application:sendEvent(self, event);	
		self:setAttribute("WA_PendingSizeEvent", false);
	end
    
	if (disableUpdates) then
        self:setAttribute("WA_UpdatesDisabled", false);
	end

	if (recursive) then
		if(self.children) then
			local children = self.children;
			local child = children:first();
			while (child) do
				child:sendPendingSizeEvents(recursive, disableUpdates);
				child = children:next(child);
			end
		end
	end
end

-- Notifies the layout system that this widget has changed and may need to change geometry.
function UIElement:updateGeometry()
    self:updateGeometry_helper(false);
end

--  Returns the layout manager that is installed on this widget, or nil if no layout manager is installed.
-- The layout manager sets the geometry of the widget's children that have been added to the layout.
function UIElement:GetLayout()
    return self.layout;
end

-- Sets the layout manager for this widget to a layout.
-- An alternative to calling this function is to pass this widget to the layout's init function.
function UIElement:SetLayout(layout)
	if(layout) then
		layout:init(self);
	end
	self.layout = layout;
end

function UIElement:updateGeometry_helper(forceUpdate)
	if(not self:isHidden()) then
		if(forceUpdate) then
			local parent = self:parentWidget();
			if(parent) then
				if(parent.layout) then
					parent.layout:invalidate();
				elseif(parent:isVisible()) then
					Application:postEvent(parent, Event:new_static("LayoutRequestEvent"));
				end
			end
		end
	end
end

function UIElement:underMouse()
	return self:testAttribute("WA_UnderMouse");
end


-- convert to global position
-- @return the returned Point is temporary, do not hold it for long
function UIElement:mapToGlobal(pos)
    local x, y = pos:x(), pos:y();
    local w = self;
    while (w) do
		if(w:isWindow()) then
			return w:mapToGlobal(Point:new_from_pool(x, y));
		else
			x = x + w.crect:x();
			y = y + w.crect:y();
			w = w:parentWidget();
		end
    end
    return Point:new_from_pool(x, y);
end

-- convert from global to local pos. 
-- @return the returned Point is temporary, do not hold it for long
function UIElement:mapFromGlobal(pos)
    local x, y = pos:x(), pos:y();
    local w = self;
    while (w) do
		if(w:isWindow()) then
			return w:mapFromGlobal(Point:new_from_pool(x, y));
		else
			x = x - w.crect:x();
			y = y - w.crect:y();
			w = w:parentWidget();
		end
    end
    return Point:new_from_pool(x, y);
end

-- Translates the widget coordinate \a pos to a coordinate in the parent widget.
-- Same as mapToGlobal() if the widget has no parent.
function UIElement:mapToParent(pos)
	pos = Point:new_from_pool(pos:x(),pos:y());
	pos:add(self.crect:topLeft());
    return pos;
end

-- Translates the parent widget coordinate \a pos to widget coordinates.
-- Same as mapFromGlobal() if the widget has no parent.
function UIElement:mapFromParent(pos)
    pos = Point:new_from_pool(pos:x(),pos:y());
	pos:sub(self.crect:topLeft());
    return pos;
end

-- Translates the widget coordinate \a pos to the coordinate system
-- of \a parent. The \a parent must not be nil and must be a parent of the calling widget.
function UIElement:mapTo(parent, pos) 
    local p = Point:new_from_pool(pos:x(),pos:y());
    if (parent) then
        local w = self;
        while (w ~= parent) do
            p = w:mapToParent(p);
            w = w:parentWidget();
        end
    end
    return p;
end

-- Translates the widget coordinate \a pos from the coordinate system
-- of \a parent to this widget's coordinate system. The \a parent
-- must not be nil and must be a parent of the calling widget.
function UIElement:mapFrom(parent, pos) 
    local p = Point:new_from_pool(pos:x(),pos:y());
    if (parent) then
        local w = self;
        while (w ~= parent) do
            p = w:mapFromParent(p);
            w = w:parentWidget();
        end
    end
    return p;
end

function UIElement:topLevelWidget()
	return self:GetWindow();
end

function UIElement:LoadComponent(url)
	return Application.LoadComponent(self, url);	
end

function UIElement:setMouseTracking(enable)
	self:setAttribute("WA_MouseTracking", enable);
end

function UIElement:hasMouseTracking()
	self:testAttribute("WA_MouseTracking");
end

function UIElement:GetTooltip()
	return self.tooltip or "";
end

-- If you want to control a tooltip's behavior, you can intercept the
-- event() function and catch the Event::ToolTip event (e.g., if you
-- want to customize the area for which the tooltip should be shown).
function UIElement:SetTooltip(tooltip)
	self.tooltip = tooltip;
end

function UIElement:toolTipEvent(event)
	if (self.tooltip and self.tooltip~="") then
        Tooltip:showText(nil, self.tooltip, self, nil, self.toolTipDuration);
    else
        event:ignore();
	end
end