--[[
Title: ManipContainer
Author(s): LiXizhi@yeah.net
Date: 2015/8/10
Desc: ManipContainer is the base class for user-defined container manipulators. 
A container manipulator has one converter which is the interface between the container's children manipulators and the node plugs they affect. 

Virtual functions:
	createChildren()
	connectToDependNode(node)

	mousePressEvent(event)
	mouseMoveEvent
	mouseReleaseEvent
	paintEvent

References: 
	MPxManipContainer in Maya
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Scene/Manipulators/ManipContainer.lua");
local ManipContainer = commonlib.gettable("System.Scene.Manipulators.ManipContainer");
local manipCont = ManipContainer:new():init();
manipCont:SetPosition(x,y,z);
manipCont.rotateManip = manipCont:AddRotateManip();
manipCont.scaleManip = manipCont:AddScaleManip();
manipCont.translateManip = manipCont:AddTranslateManip();
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Scene/Manipulators/Manipulator.lua");
local ShapesDrawer = commonlib.gettable("System.Scene.Overlays.ShapesDrawer");
local ManipContainer = commonlib.inherit(commonlib.gettable("System.Scene.Manipulators.Manipulator"), commonlib.gettable("System.Scene.Manipulators.ManipContainer"));

ManipContainer:Property({"Name", "ManipContainer", auto=true});
ManipContainer:Property({"ShowPos", false, "IsShowPos","SetShowPos", auto=true});

ManipContainer:Signal("beforeDestroyed");

function ManipContainer:ctor()
	self.plugToManipCallbacks = {};
	self.manipToPlugCallbacks = {};
end

function ManipContainer:init(parent)
	ManipContainer._super.init(self, parent);
	self:createChildren();
	return self;
end

function ManipContainer:Destroy()
	self:beforeDestroyed();
	ManipContainer._super.Destroy(self);
end

-- virtual: add all child manipulators here.
function ManipContainer:createChildren()
end

-- create and add a rotate manipulator to the container. 
-- return the manipulator just added. 
function ManipContainer:AddRotateManip()
	NPL.load("(gl)script/ide/System/Scene/Manipulators/RotateManip.lua");
	local RotateManip = commonlib.gettable("System.Scene.Manipulators.RotateManip");
	return RotateManip:new():init(self);
end

-- create and add a scale manipulator to the container. 
-- return the manipulator just added. 
function ManipContainer:AddScaleManip()
	NPL.load("(gl)script/ide/System/Scene/Manipulators/ScaleManip.lua");
	local ScaleManip = commonlib.gettable("System.Scene.Manipulators.ScaleManip");
	return ScaleManip:new():init(self);
end

-- create and add a translate manipulator to the container. 
-- return the manipulator just added. 
function ManipContainer:AddTranslateManip()
	NPL.load("(gl)script/ide/System/Scene/Manipulators/TranslateManip.lua");
	local TranslateManip = commonlib.gettable("System.Scene.Manipulators.TranslateManip");
	return TranslateManip:new():init(self);
end

-- virtual: 
function ManipContainer:mousePressEvent(mouse_event)
end

-- virtual: 
function ManipContainer:mouseMoveEvent(mouse_event)
end

-- virtual: 
function ManipContainer:mouseReleaseEvent(mouse_event)
end

-- virtual: actually means key stroke. 
function ManipContainer:keyPressEvent(key_event)
end

-- virtual function: connect plugs between manipulators and dependend node
-- make sure to call finishAddingManips() when everything is done.
-- @param node: usually a ToolBase or AttributeObject, sometimes it can be a command object that support undo/redo.
function ManipContainer:connectToDependNode(node)
	self:finishAddingManips();
	-- add the dependency node as well if not added before
	if(not self.plug_objs[node]) then
		self.plug_objs[node] = true;
		node:Connect("valueChanged", self, self.OnPlugValueChanged);
	end
	-- add all manip nodes  
	if(self.children) then
		local children = self.children;
		local child = children:first();
		while (child) do
			if(not self.manip_objs[child]) then
				self.manip_objs[obj] = child;
				child:Connect("valueChanged", self, self.OnManipValueChanged);
			end
			child = children:next(child);
		end
	end

	-- causing all manips value to be initialized from plugs. 
	self:OnPlugValueChanged();
end

-- helper function:
-- it ensures that position and bounding rect are set according to given object. 
-- it is a one-time settings, one needs to manually connect attributes if dynamic changes occurs. 
function ManipContainer:ShowWithObject(obj)
	if(obj) then
		if(obj.GetPosition) then
			self:SetPosition(obj:GetPosition());
		end
		if(obj.GetBoundRadius) then
			self:SetBoundRadius(obj:GetBoundRadius());
		else
			local radius = self:GetField("radius", 0);
			if(radius~=0) then
				self:SetBoundRadius(radius);
			end
		end
	end
end

-- This method should be called from the user-defined manipulator plug-in near the end of 
-- the connectToDependNode method so that the converter in the manipulator can be initialized. 
-- This function is called in the Base ManipContainer class's connectToDependNode, so if one calls
-- base class's connectToDependNode at the last line in connectToDependNode, there is no need to invoke this method explicitly. 
function ManipContainer:finishAddingManips()
	self.plug_objs = self.plug_objs or {};
	for plug, _ in pairs(self.manipToPlugCallbacks) do
		local obj = plug:GetObject();
		if(obj and obj.Connect) then
			if(not self.plug_objs[obj]) then
				self.plug_objs[obj] = true;
				obj:Connect("valueChanged", self, self.OnPlugValueChanged);
			end
		end
	end

	self.manip_objs = self.manip_objs or {};
	for plug, _ in pairs(self.plugToManipCallbacks) do
		local obj = plug:GetObject();
		if(obj and obj.Connect) then
			if(not self.manip_objs[obj]) then
				self.manip_objs[obj] = true;
				obj:Connect("valueChanged", self, self.OnManipValueChanged);
			end
		end
	end
end

-- private: whenever any of the dependent node's value is changed, update manipulator
function ManipContainer:OnPlugValueChanged()
	for plug, callbackFunc in pairs(self.plugToManipCallbacks) do
		local value = callbackFunc(self, plug);
		if(value~=nil) then
			plug:SetValueInternal(value);
		end
	end
end

-- private: whenever any of the manipulator value is changed, update plugs
function ManipContainer:OnManipValueChanged()
	for plug, callbackFunc in pairs(self.manipToPlugCallbacks) do
		local value = callbackFunc(self, plug);
		if(value~=nil) then
			plug:SetValue(value);
		end
	end
end

function ManipContainer:GetConverterManipValue(manipIndex)
	return manipIndex:GetValue();
end

function ManipContainer:GetConverterPlugValue(plug)
	return plug:GetValue();
end

-- add a call back to calculate a given manipulater value based on any of plugs
function ManipContainer:addPlugToManipConversionCallback(manipIndex, callbackFunc)
	self.plugToManipCallbacks[manipIndex] = callbackFunc;
end

-- add a call back to calculate a given plug value based on any of manipulator values
function ManipContainer:addManipToPlugConversionCallback(plug, callbackFunc)
	self.manipToPlugCallbacks[plug] = callbackFunc;
end

-- helper function to establish a direction one to one connection. 
-- @param connectionType: nil for two-way connection, "PlugToManip" or "ManipToPlug" for one way connection
function ManipContainer:connectPlugToManip(plug, manipPlug, connectionType)
	if(plug and manipPlug) then
		if(not connectionType or connectionType == "ManipToPlug") then
			self:addManipToPlugConversionCallback(plug, function(self, plug)
				return manipPlug:GetValue();
			end);
		end
		self:addPlugToManipConversionCallback(manipPlug, function(self, manipPlug)
			return plug:GetValue();
		end);
		return true;
	end
end

function ManipContainer:paintEvent(painter)
	ManipContainer._super.paintEvent(self, painter);
	if(self:IsShowPos() and not self:IsPickingPass()) then
		local lineScale = self:GetLineScale(painter);
		self.pen.width = self.PenWidth * lineScale;
		painter:SetPen(self.pen);
		local length = 0.2;
		self:SetColorAndName(painter, self.xColor);
		ShapesDrawer.DrawLine(painter, 0,0,0, length,0,0);
		self:SetColorAndName(painter, self.yColor);
		ShapesDrawer.DrawLine(painter, 0,0,0, 0,length,0);
		self:SetColorAndName(painter, self.zColor);
		ShapesDrawer.DrawLine(painter, 0,0,0, 0,0,length);
	end
end