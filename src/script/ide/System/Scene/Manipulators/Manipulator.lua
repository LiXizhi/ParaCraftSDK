--[[
Title: Manipulator Base 
Author(s): LiXizhi@yeah.net
Date: 2015/8/10
Desc: Manipulator is the base class used for creating user-defined manipulators.
A manipulator can be connected to a depend node instead of updating a node attribute directly
call AddValue() in constructor if one wants to define a custom manipulator property(plug) 
that can be easily binded with depedent node's plug. 

Virtual functions:
	mousePressEvent(event)
	mouseMoveEvent
	mouseReleaseEvent
	draw
	

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Scene/Manipulators/Manipulator.lua");
local Manipulator = commonlib.gettable("System.Scene.Manipulators.Manipulator");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Scene/Overlays/Overlay.lua");
NPL.load("(gl)script/ide/System/Scene/Overlays/ShapesDrawer.lua");
NPL.load("(gl)script/ide/System/Scene/Cameras/Cameras.lua");
NPL.load("(gl)script/ide/System/Windows/Screen.lua");
NPL.load("(gl)script/ide/System/Core/AttributeObject.lua");
NPL.load("(gl)script/ide/STL.lua");
local Screen = commonlib.gettable("System.Windows.Screen");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");
local math3d = commonlib.gettable("mathlib.math3d");
local Cameras = commonlib.gettable("System.Scene.Cameras");
local ShapesDrawer = commonlib.gettable("System.Scene.Overlays.ShapesDrawer");

local Manipulator = commonlib.inherit(commonlib.gettable("System.Scene.Overlays.Overlay"), commonlib.gettable("System.Scene.Manipulators.Manipulator"));

Manipulator:Property("Name", "Manipulator");
Manipulator:Property({"PenWidth", 0.02});
Manipulator:Property({"mainColor", "#000000"});
Manipulator:Property({"dimmedColor", "#000000"});
Manipulator:Property({"selectedColor", "#ffff00"});
Manipulator:Property({"hoverColor", "#ffff00"});
Manipulator:Property({"labelColor", "#000000"});
Manipulator:Property({"labelBackgroundColor", "#ffffff"});
Manipulator:Property({"lineColor", "#808080"});
Manipulator:Property({"gridColor", "#000000"});
Manipulator:Property({"xColor", "#ff0000"});
Manipulator:Property({"yColor", "#0000ff"});
Manipulator:Property({"zColor", "#00ff00"});
Manipulator:Property({"textScale", 0.01});

Manipulator:Signal("valueChanged", function() end);
-- connect this to depedent node to support undo/redo operation. 
Manipulator:Signal("modifyBegun");
Manipulator:Signal("modifyEnded");

Manipulator.valueFields = commonlib.ArrayMap:new();

function Manipulator:ctor()
	self.pen = {width=self.PenWidth, color="#ff0000"}
	self.valueFields = commonlib.ArrayMap:new();
end

function Manipulator:init(parent)
	return Manipulator._super.init(self, parent);
end

function Manipulator:Destroy()
	-- just in case we forget to call end modify
	self:EndModify();
	Manipulator._super.Destroy(self);
end


function Manipulator:BeginModify()
	if(not self.m_bIsBeginModify) then
		self.m_bIsBeginModify = true;
		self:modifyBegun();
	end
end

function Manipulator:EndModify()
	if(self.m_bIsBeginModify) then
		self.m_bIsBeginModify = nil;
		self:modifyEnded();
	end
end


-- virtual function callback, called whenever the values is modified. Both SetField and SetFieldInternal will call this
function Manipulator:OnValueChange(name, value)
end

function Manipulator:GetPen()
	return self.pen;
end

-- virtual: 
function Manipulator:mousePressEvent(mouse_event)
end

-- virtual: 
function Manipulator:mouseMoveEvent(mouse_event)
end

-- virtual: 
function Manipulator:mouseReleaseEvent(mouse_event)
end

-- virtual: actually means key stroke. 
function Manipulator:keyPressEvent(key_event)
end

-- transform a list of local space vectors to view space. mostly used for calculating mouse positions. 
-- @param vecList: input|output: a list of vector3d like {{0,1,0}}, which will be transformed
function Manipulator:TransformVectorsInViewSpace(vecList)
	local worldMat = self:CalculateWorldMatrix(nil, true);
	local viewMat = Cameras:GetCurrent():GetViewMatrix();
	local worldViewMat = worldMat*viewMat;
	for _, vec in ipairs(vecList) do
		math3d.VectorMultiplyMatrix(vec, vec, worldViewMat);
	end
	return vecList;
end

function Manipulator:TransformVectorInViewSpace(vec)
	local worldMat = self:CalculateWorldMatrix(nil, true);
	local viewMat = Cameras:GetCurrent():GetViewMatrix();
	local worldViewMat = worldMat*viewMat;
	math3d.VectorMultiplyMatrix(vec, vec, worldViewMat);
	return vec;
end

-- transform 3d vectors to screen space (projection space / w). 
-- only v[1], v[2] should be used in returned value
function Manipulator:TransformVectorsInScreenSpace(vecList)
	local worldMat = self:CalculateWorldMatrix(nil, true);
	local viewMat = Cameras:GetCurrent():GetViewMatrix();
	local projMat = Cameras:GetCurrent():GetProjMatrix();
	local finalMat = worldMat*viewMat*projMat;
	local screenWidth = Screen:GetWidth();
	local screenHeight = Screen:GetHeight();
	for _, vec in ipairs(vecList) do
		math3d.Vector4MultiplyMatrix(vec, vec, finalMat);
		vec:MulByFloat(1/vec[4]);
		vec[1] = ((vec[1]+1)*0.5) * screenWidth;
		vec[2] = ((1-vec[2])*0.5) * screenHeight;
		vec[3] = 0;
		vec[4] = nil;
	end
	return vecList;
end


-- @param mouse_x, mouse_y : if nil, it is the current mouse position. 
-- @param plane: ShapePlane in view space. 
-- @param point: if not nil, it will receive the intersection point in view space
-- @return: int, distance: interaction type, and distance.
--  1:intersected
-- -1:The plane is parallel to the ray; 
-- -3:The intersection occurs behind the ray's origin.
function Manipulator:MouseRayIntersectPlane(mouse_x, mouse_y, plane, point)
	local mouseRay = Cameras:GetCurrent():GetMouseRay(mouse_x, mouse_y);
	local result, t = mouseRay:IntersectPlane(plane, point);
	if(result == -2) then
		local result2, t2 = mouseRay:IntersectPlane(plane:clone():inverse(), point);
		if( result2 == 1 ) then
			return result2, t2
		end
	end
	return result, t;
end

-- when a group of changes takes place, such as during recording, 
-- we can put change inside BeginUpdate() and EndUpdate() pairs, so that 
-- only one keyChanged() event will be emitted. 
function Manipulator:BeginUpdate()
	if(not self.isBeginUpdate) then
		self.isBeginUpdate = 0;
		self.isValueChanged = false;
	else
		self.isBeginUpdate = self.isBeginUpdate + 1;
	end
end

function Manipulator:EndUpdate()
	if(self.isBeginUpdate) then
		if(self.isBeginUpdate <= 0) then
			self.isBeginUpdate = false;
			if(self.isValueChanged) then
				self.isValueChanged = false;
				self:SetModified();
			end
		else
			self.isBeginUpdate = self.isBeginUpdate - 1;
		end
	end
end

function Manipulator:SetModified()
	if(self.isBeginUpdate) then
		self.isValueChanged = true;
	else
		self:valueChanged();
	end
end

-------------------------------------
-- reimplement Attribute Fields interface:
--  1. support dyanamically AddValue, 
--  2. automatically emit valueChanged signal
--  3. support getting previous value in addition to current value.
-------------------------------------

-- @return attribute plug
function Manipulator:AddValue(name, defaultValue)
	local fieldType;
	local valueType = type(defaultValue);
	if(valueType == "table") then
		local nSize = #defaultValue;
		if(nSize == 3) then
			fieldType = "vector3";
		elseif(nSize == 2) then
			fieldType = "vector2";
		elseif(nSize == 4) then
			fieldType = "vector4";
		elseif(nSize == 16) then
			fieldType = "Matrix4";
		else
			fieldType = "";
		end
	elseif(valueType == "bool") then
		fieldType = "bool";
	elseif(valueType == "string") then
		fieldType = "string";
	else
		fieldType = "double";
	end
	self.valueFields:add(name, {name=name, value=defaultValue, preValue=defaultValue, type=fieldType})
	
	return self:findPlug(name);
end

function Manipulator:GetFieldNum()
	return self.valueFields:size();
end

function Manipulator:GetFieldName(valueIndex)
	local field = self.valueFields:at(valueIndex);
	if(field) then
		return field.name;
	end
end

function Manipulator:GetFieldIndex(sFieldname)
	return self.valueFields:getIndex(sFieldname) or -1;
end

function Manipulator:GetFieldType(nIndex)
	local field = self.valueFields:at(valueIndex);
	if(field) then
		return field.type;
	end
end

function Manipulator:SetField(name, value)
	local field = self.valueFields:get(name);
	if(field) then
		if(not commonlib.partialcompare(value, field.value)) then
			field.preValue = field.value;
			field.value = value;
			self:OnValueChange(name, value);
			self:SetModified();
		end
	end
end

-- without sending the valueChanged signal like SetField. 
-- usually used for updating manipulator values from plugs
function Manipulator:SetFieldInternal(name, value)
	local field = self.valueFields:get(name);
	if(field) then
		if(not commonlib.partialcompare(value, field.value)) then
			field.preValue = field.value;
			field.value = value;
			self:OnValueChange(name, value);
		end
	end
end

function Manipulator:GetField(name, defaultValue)
	local field = self.valueFields:get(name);
	if(field) then
		return field.value;
	else
		return defaultValue;
	end
end

-- similar to SetField
function Manipulator:SetValue(name, value)
	self:SetField(name, value);
end

-- return the value similar to GetField
function Manipulator:GetValue(name, defaultValue, bPreviousValue)
	if(not bPreviousValue) then
		return self:GetField(name, defaultValue);
	else
		local field = self.valueFields:get(name);
		return field.preValue;
	end
end