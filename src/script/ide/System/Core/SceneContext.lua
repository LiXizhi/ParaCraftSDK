--[[
Title: Scene Context
Author(s): LiXizhi, 
Date: 2015/7/9
Desc: At most one scene context can be selected at any time. Once selected, the scene context 
will receive all key/mouse events in the 3D scene. One can derive from this class to 
write and switch to your own scene event handlers. 

The computational model for global key/mouse event in C++ Engine is:
	key/mouse input--> 2D --> (optional auto camera) --> 3D scene --> script handlers

This class simplified and modified above model with following object oriented model:
	key/mouse input--> 2D --> one of SceneContext object--> Manipulator container -->  Manipulators --> (optional auto camera manipulator)

Please note that both model can coexist, however SceneContext is now the recommended way to handle any scene event. 
SceneContext hide all dirty work of hooking into the old C++ engine callback interface, and offers more user friendly way 
of event handling. 

Virtual functions:
	mousePressEvent(event)
	mouseMoveEvent
	mouseReleaseEvent
	mouseWheelEvent
	keyReleaseEvent
	keyPressEvent
	OnSelect()
	OnUnselect()

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Core/SceneContext.lua");
local MySceneContext = commonlib.inherit(commonlib.gettable("System.Core.SceneContext"), commonlib.gettable("System.Core.MySceneContext"));
function MySceneContext:ctor()
	self:EnableAutoCamera(true);
end

function MySceneContext:mouseReleaseEvent(event)
	_guihelper.MessageBox("clicked")
end

-- method 1:
local sContext = MySceneContext:new():Register("MyDefaultSceneContext");
sContext:activate();
-- method 2:
MySceneContext:CreateGetInstance("MyDefaultSceneContext"):activate();
------------------------------------------------------------
]]

NPL.load("(gl)script/ide/System/Core/ToolBase.lua");
NPL.load("(gl)script/ide/System/Core/SceneContextManager.lua");
NPL.load("(gl)script/ide/System/Scene/Overlays/OverlayPicking.lua");
local OverlayPicking = commonlib.gettable("System.Scene.Overlays.OverlayPicking");
local SceneContextManager = commonlib.gettable("System.Core.SceneContextManager");
local SceneContext = commonlib.inherit(commonlib.gettable("System.Core.ToolBase"), commonlib.gettable("System.Core.SceneContext"));

SceneContext:Property("Name", "SceneContext");
SceneContext:Property({"m_bUseAutoCamera", true, "IsAutoCameraEnabled", "EnableAutoCamera", desc="enable auto camera"});
SceneContext:Property({"m_bAcceptAllEvents", true, "IsAcceptAllEvents", "SetAcceptAllEvents", desc="whether to accept all events and prevent other handlers", auto=true});
SceneContext:Property({"pickingPointSize", 8});
SceneContext:Property({"enabled", true, "isEnabled", auto=true});
SceneContext:Property({"m_bCaptureMouse", true, "isCaptureMouse", "setCaptureMouse", auto=true});
SceneContext:Property({"m_hasMouseTracking", nil, "hasMouseTracking", "setMouseTracking", auto=true});
-- most recent picking result id
SceneContext:Property({"m_pickingName", 0, "GetPickingName", "SetPickingName", auto=true});

SceneContext:Signal("selected")
SceneContext:Signal("unselected")

function SceneContext:ctor()
end

function SceneContext:Destroy()
	self:DeleteManipulators();
	SceneContext._super.Destroy(self);
end

-- static function: 
-- @param name: must be a unique name or the previous one will be deleted. if nil, self:GetName() or "default" is used. 
-- @return the context object
function SceneContext:Register(name)
	return SceneContextManager:Register(name, self);
end

-- static function:
-- create get an named instance of this object
-- @param name: if nil, self.Name will be used. 
function SceneContext:CreateGetInstance(name)
	name = name or self.Name;
	local context = SceneContextManager:GetContext(name);
	if(not context) then
		context = self:new():Register(name);
	end
	return context;
end

function SceneContext:IsSelected()
	return SceneContextManager:GetCurrentContext() == self;
end

-- handy function to select this scene text;
function SceneContext:activate()
	return SceneContextManager:Select(self);
end

-- return true if we successfully deactivated. otherwise we are possible in the middle of something. 
function SceneContext:deactivate()
	return SceneContextManager:Unselect(self);
end

-- auto camera is enabled by default. Auto camera is a high-performance C++ controller that use WASD key and mouse 
-- to control the camera view and move the target scene object. 
-- If you want to implement your own camera or player controller, simply call self:EnableAutoCamera(false) 
-- in the constructor of your SceneContext. 
-- The C++ auto camera controller is actually very intelligent to avoid collision with the scene, and have a number of configurations to customize. 
function SceneContext:EnableAutoCamera(bEnabled)
	if(self.m_bUseAutoCamera~=bEnabled) then
		self.m_bUseAutoCamera = bEnabled;
		if(self:IsSelected()) then
			self:UpdateAutoCameraManipulator();
		end
	end
end

function SceneContext:IsAutoCameraEnabled()
	return self.m_bUseAutoCamera;
end

-- private: 
function SceneContext:UpdateAutoCameraManipulator()
	ParaCamera.GetAttributeObject():SetField("BlockInput", not self:IsAutoCameraEnabled());
end

-- virtual function: 
-- try to select this context. 
function SceneContext:OnSelect(lastContext)
	self:UpdateAutoCameraManipulator();
	self:selected();
end

-- virtual function: 
-- return true (or nil) if we are not in the middle of any operation and fire unselected signal. 
-- or false, if we can not unselect the scene tool context at the moment. 
function SceneContext:OnUnselect()
    self.last_button_down_obj = nil;
	self:unselected();
	return true;
end

function SceneContext:FetchPickingResult()
	local bHasPicking;
	if(self.manipulators) then
		for i, manip in pairs(self.manipulators) do
			if(manip.EnablePicking) then
				-- TODO: only set dirty when camera has moved. 
				OverlayPicking:SetResultDirty(true);
				OverlayPicking:Pick(nil, nil, self.pickingPointSize, self.pickingPointSize)
				self:SetPickingName(OverlayPicking:GetActivePickingName());
				bHasPicking = true;
				break;
			end
		end
	end
	if(not bHasPicking) then
		self:SetPickingName(0);
	end
end

-- get the object at the current mouse position. 
function SceneContext:GetObjectAtMousePos()
	local pickingName = self:GetPickingName();
	local obj;
	if(pickingName and pickingName~=0) then
		if(self.manipulators) then
			for i, manip in pairs(self.manipulators) do
				if(manip.EnablePicking) then
					obj = manip:GetChildByPickingName(pickingName); 
					if(not obj and manip:HasPickingName(pickingName)) then
						obj = manip;
					end
					if(obj) then
						break;
					end
				end
			end
		end
	end
	return obj;
end

-- we will always send event to last button down object. 
-- @param buttonDown: last button down object
function SceneContext:pickMouseReceiver(candidate, event_type, buttons, buttonDown)
	-- mouse move and release event only sent to last mouse down widget
	local receiver = buttonDown or candidate;
	return receiver;
end


function SceneContext:handleMouseEvent(event)
	event:updateModifiers();
	self:FetchPickingResult();

	local widget = self:GetObjectAtMousePos() or self;

	if(event:GetType() == "mousePressEvent") then
		self.last_button_down_obj = widget;
	end

	local receiver = self:pickMouseReceiver(widget, event:GetType(), event:buttons(), self.last_button_down_obj)
	if(receiver) then
		if(receiver == self) then
			-- let the manipulators to process it first, before passing to self. 
			if(self.manipulators) then
				for i, manip in pairs(self.manipulators) do
					if(manip.EnablePicking) then
						self:notify(manip, event);
						if(event:isAccepted()) then
							break;
						end
					end
				end
			end
		end
		self:notify(receiver, event);
		-- in case no manipulators have processed it, we will process it. 
		if(not event:isAccepted() and (not self:isAncestorOf(receiver))) then
			self:notify(self, event);
		end
	end
	
end

function SceneContext:handleKeyEvent(event)
	-- it just send events to all manipulators. 
	if(self.manipulators) then
		for i, manip in pairs(self.manipulators) do
			manip:handleKeyEvent(event);
			if(event:isAccepted()) then
				break;
			end
		end
	end
	if(not event:isAccepted()) then
		self:event(event);
	end
end

function SceneContext:notify(receiver, event)
	local type = event:GetType();
	local w = receiver;
	while(w) do
		if(not w:hasMouseTracking() and type == "mouseMoveEvent" and event:buttons() == 0) then
			-- skip mouseMoveEvent if mouse-tracking is off when no mouse button is pressed. 
			res = true;
		else
			res = self:notify_helper(w, event);
		end
		if (res and event:isAccepted()) then
			break;
		end
		w = w.parent;
	end
end

--private:
function SceneContext:notify_helper(receiver, event)
	if (receiver) then
		if(receiver.event) then
			-- deliver the event
			return receiver:event(event);
		end	
	else
		LOG.std(nil, "warn", "SceneContext:notify", "empty receiver");
	end
end

-- called whenever an event comes. Subclass can overwrite this function. 
-- @param handlerName: "mousePressEvent", "mouseReleaseEvent", etc. 
-- @param event: the event object. 
function SceneContext:event(event)
	if(not self:isEnabled()) then
		-- do nothing if not enabled. 
	else
		local event_type = event:GetType();
		local func = self[event:GetHandlerFuncName()];
		if(type(func) == "function") then
			func(self, event);
		end
	end
end

-- virtual: 
function SceneContext:mousePressEvent(mouse_event)
end

-- virtual: 
function SceneContext:mouseMoveEvent(mouse_event)
end

-- virtual: 
function SceneContext:mouseReleaseEvent(mouse_event)
end

-- virtual: 
function SceneContext:mouseWheelEvent(mouse_event)
end

-- virtual: actually means key stroke. 
function SceneContext:keyPressEvent(key_event)
end

-- virtual: currently NOT implemented. use keyPressEvent event instead. 
function SceneContext:keyReleaseEvent(key_event)
end

function SceneContext:AddManipulator(manip)
	if(not self.manipulators) then
		self.manipulators = commonlib.Array:new();
	end
	self.manipulators:add(manip);
end

-- automatically called when SceneContext is Unselected or destroyed. However, one may needs to call this manually
-- in places like self:UpdateMainipulators, just in case selection has changed, and we need to rebind data properties. 
function SceneContext:DeleteManipulators()
	if(self.manipulators) then
		for i, manip in pairs(self.manipulators) do
			manip:Destroy();
		end
		self.manipulators = nil;
	end
end

function SceneContext:HasManipulators()
	return self.manipulators~=nil and self.manipulators:size() > 0;
end

-- virtual function: implement this function to create a context with manipulators, and call it when selection changed. 
function SceneContext:UpdateManipulators()
	self:DeleteManipulators();
end