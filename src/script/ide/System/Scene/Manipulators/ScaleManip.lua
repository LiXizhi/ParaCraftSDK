--[[
Title: ScaleManip Base 
Author(s): LiXizhi@yeah.net
Date: 2015/8/10
Desc: ScaleManip is manipulator for 3D rotation. 

Virtual functions:
	mousePressEvent(event)
	mouseMoveEvent
	mouseReleaseEvent
	draw
	connectToDependNode(node);

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Scene/Manipulators/ScaleManip.lua");
local ScaleManip = commonlib.gettable("System.Scene.Manipulators.ScaleManip");
local manip = ScaleManip:new():init();
manip:SetPosition(x+3,y,z);
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Scene/Manipulators/Manipulator.lua");
NPL.load("(gl)script/ide/math/Plane.lua");
local Color = commonlib.gettable("System.Core.Color");
local Plane = commonlib.gettable("mathlib.Plane");
local vector3d = commonlib.gettable("mathlib.vector3d");
local ShapesDrawer = commonlib.gettable("System.Scene.Overlays.ShapesDrawer");
local ScaleManip = commonlib.inherit(commonlib.gettable("System.Scene.Manipulators.Manipulator"), commonlib.gettable("System.Scene.Manipulators.ScaleManip"));

ScaleManip:Property({"Name", "ScaleManip", auto=true});
ScaleManip:Property({"radius", 1});
-- private: "x|y|z" current selected axis
ScaleManip:Property({"selectedAxis", nil});
-- uniform scaling
ScaleManip:Property({"UniformScaling", false, "IsUniformScaling", "SetUniformScaling", auto=true});
-- whether to update values during dragging
ScaleManip:Property({"RealTimeUpdate", true, "IsRealTimeUpdate", "SetRealTimeUpdate", auto=true});


function ScaleManip:ctor()
	self.names = {};
	self:AddValue("position", {0,0,0});
	self:AddValue("scaling", {1,1,1});
end

function ScaleManip:OnValueChange(name, value)
	ScaleManip._super.OnValueChange(self);
	if(name == "position") then
		self:SetPosition(unpack(value));
	end
end

function ScaleManip:init(parent)
	ScaleManip._super.init(self, parent);
	return self;
end

local axis_dirs = {
	x = vector3d:new({1,0,0}),
	y = vector3d:new({0,1,0}),
	z = vector3d:new({0,0,1}),
}
-- @param axis: "x|y|z". default to current
-- @return vector3d
function ScaleManip:GetMoveDirByAxis(axis)
	return axis_dirs[axis or self.selectedAxis];
end

-- virtual: 
function ScaleManip:mousePressEvent(event)
	if(event:button() ~= "left") then
		return
	end
	event:accept();
	local name = self:GetActivePickingName();
	if(name == self.names.x) then
		self.selectedAxis = "x"
	elseif(name == self.names.y) then
		self.selectedAxis = "y"
	elseif(name == self.names.z) then
		self.selectedAxis = "z"
	else
		self.selectedAxis = nil;
		self.drag_offset = nil;
		return;
	end
	local moveDir = self:GetMoveDirByAxis();
	self.last_mouse_x = event.x;
	self.last_mouse_y = event.y;
	self.drag_offset = {x=0,y=0,z=0};

	-- calculate everything in view space. 
	local vecList = self:TransformVectorsInViewSpace({vector3d:new(0,0,0), moveDir:clone()});
	self.moveDir = vecList[2] - vecList[1];
	self.moveOrigin = vecList[1];
	-- final a virtual plane, containing the selected axis. 
	local planeVec;
	if(math.abs(self.moveDir[2]) < 0.6) then
		planeVec = vector3d:new(0,1,0);
	else
		planeVec = vector3d:new(1,0,0);
	end
	self.virtualPlane = Plane:new():redefine(self.moveDir*planeVec, self.moveOrigin);
	self.last_scaling = self:GetField("scaling", {1,1,1});
	-- screenSpaceDir
	local vecList = self:TransformVectorsInScreenSpace({vector3d:new(0,0,0), moveDir:clone()});
	self.screenSpaceDir = vecList[2] - vecList[1];
	self.screenSpaceDir:normalize();
	self.is_dragging = true;
end

-- virtual: 
function ScaleManip:mouseMoveEvent(event)
	if(self.selectedAxis) then
		event:accept();
		-- get the mouse position for mouse ray casting. 
		local mouseMoveDir = vector3d:new(event.x - self.last_mouse_x, event.y-self.last_mouse_y, 0);
		local dist = mouseMoveDir:dot(self.screenSpaceDir);
		local mouse_x = self.last_mouse_x + self.screenSpaceDir[1] * dist;
		local mouse_y = self.last_mouse_y + self.screenSpaceDir[2] * dist;
		-- ray cast to virtual plane to obtain the mouse picking point. 
		local point = vector3d:new();
		local result, dist = self:MouseRayIntersectPlane(mouse_x, mouse_y, self.virtualPlane, point);
		if(result == 1) then
			if(not self.pressPoint) then
				self.pressPoint = point;
				self.pressDist = dist;
				self:BeginModify();
			else
				local dist = (point - self.pressPoint):dot(self.moveDir);
				self.drag_offset[self.selectedAxis] = dist;
				if(self:IsRealTimeUpdate()) then
					self:GrabValues();
				end
			end
		end
	end
end

-- virtual: 
function ScaleManip:mouseReleaseEvent(event)
	if(event:button() ~= "left") then
		return
	end
	event:accept();
	self:GrabValues();
	self.selectedAxis = nil;
	self.drag_offset = nil;
	self.pressPoint = nil;
	self.pressDist = nil;
	self.last_scaling = nil;
	self.is_dragging = true;
	self:EndModify();
end

function ScaleManip:GrabValues()
	if(self.drag_offset and self.last_scaling) then
		local radius = self.radius;
		local scaling = self.last_scaling;
		local new_x, new_y, new_z;
		if(self:IsUniformScaling()) then
			local scale = math.abs(1 + (self.drag_offset.x+ self.drag_offset.y+self.drag_offset.z)/radius);
			new_x, new_y, new_z = scale*scaling[1], scale*scaling[2], scale*scaling[3];
		else
			new_x, new_y, new_z = (1+self.drag_offset.x/radius)*scaling[1], (1+self.drag_offset.y/radius)*scaling[2], (1+self.drag_offset.z/radius)*scaling[3];
		end
		self:SetNewScaling(new_x, new_y, new_z);
	end
end

function ScaleManip:SetNewScaling(new_x, new_y, new_z)
	self:SetField("scaling", {new_x, new_y, new_z});
end

-- virtual: actually means key stroke. 
function ScaleManip:keyPressEvent(event)
end

-- @param axis: "x", "y", "z"
-- @param name: current active name. if nil, it will load current active name
function ScaleManip:IsAxisHighlighted(axis, name)
	if(self.selectedAxis) then
		return self.selectedAxis == axis;
	else
		name = name or self:GetActivePickingName();
		return (self.names[axis] == name);
	end
end

function ScaleManip:HasPickingName(pickingName)
	return self.names.x == pickingName
		or self.names.y == pickingName
		or self.names.z == pickingName;
end

-- is dragging
function ScaleManip:IsDragging()
	return self.is_dragging;
end

function ScaleManip:paintEvent(painter)
	self.pen.width = self.PenWidth;
	local cube_radius = self.PenWidth*4;
	painter:SetPen(self.pen);
	local isDrawingPickable = self:IsPickingPass();
	local radius = self.radius;

	if(self.drag_offset) then
		if(not isDrawingPickable) then
			self:SetColorAndName(painter, self.lineColor);
			-- draw dragging path
			ShapesDrawer.DrawCube(painter, 0,0,0, cube_radius);
			local moveDir = self:GetMoveDirByAxis();
			ShapesDrawer.DrawLine(painter, 0,0,0, moveDir[1]*radius, moveDir[2]*radius, moveDir[3]*radius);
			ShapesDrawer.DrawCube(painter, moveDir[1]*radius, moveDir[2]*radius, moveDir[3]*radius, cube_radius);
		end
	end
	
	local x_name, y_name, z_name;
	if(isDrawingPickable) then
		x_name = self:GetNextPickingName();
		y_name = self:GetNextPickingName();
		z_name = self:GetNextPickingName();
	end

	local name = self:GetActivePickingName();
	

	local offsetX, offsetY, offsetZ = 0,0,0;
	if(self:IsAxisHighlighted("x", name)) then 
		self:SetColorAndName(painter, self.selectedColor, x_name);
		if(self.drag_offset) then
			offsetX, offsetY, offsetZ = self.drag_offset.x, self.drag_offset.y, self.drag_offset.z;
		end
	else
		if(not self.selectedAxis) then
			self:SetColorAndName(painter, self.xColor, x_name);
		else
			self:SetColorAndName(painter, Color.ChangeOpacity(self.xColor, 32), x_name);
		end
	end
	ShapesDrawer.DrawLine(painter, 0,0,0, radius+offsetX,0+offsetY,0+offsetZ);
	ShapesDrawer.DrawCube(painter, radius+offsetX,0+offsetY,0+offsetZ, cube_radius);
	offsetX, offsetY, offsetZ = 0,0,0;
	if(self:IsAxisHighlighted("y", name)) then 
		self:SetColorAndName(painter, self.selectedColor, y_name);
		if(self.drag_offset) then
			offsetX, offsetY, offsetZ = self.drag_offset.x, self.drag_offset.y, self.drag_offset.z;
		end
	else
		if(not self.selectedAxis) then
			self:SetColorAndName(painter, self.yColor, y_name);
		else
			self:SetColorAndName(painter, Color.ChangeOpacity(self.yColor, 32), y_name);
		end
	end
	ShapesDrawer.DrawLine(painter, 0,0,0, 0+offsetX,radius+offsetY,0+offsetZ);
	ShapesDrawer.DrawCube(painter, 0+offsetX,radius+offsetY,0+offsetZ, cube_radius);
	offsetX, offsetY, offsetZ = 0,0,0;
	if(self:IsAxisHighlighted("z", name)) then 
		self:SetColorAndName(painter, self.selectedColor, z_name);
		if(self.drag_offset) then
			offsetX, offsetY, offsetZ = self.drag_offset.x, self.drag_offset.y, self.drag_offset.z;
		end
	else
		if(not self.selectedAxis) then
			self:SetColorAndName(painter, self.zColor, z_name);
		else
			self:SetColorAndName(painter, Color.ChangeOpacity(self.zColor, 32), y_name);
		end
	end
	ShapesDrawer.DrawLine(painter, 0,0,0, 0+offsetX,0+offsetY,radius+offsetZ);
	ShapesDrawer.DrawCube(painter, 0+offsetX,0+offsetY,radius+offsetZ, cube_radius);

	if(isDrawingPickable) then
		self.names.x = x_name;
		self.names.y = y_name;
		self.names.z = z_name;
	end
end
