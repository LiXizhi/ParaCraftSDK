--[[
Title: RotateManip Base 
Author(s): LiXizhi@yeah.net
Date: 2015/8/10
Desc: RotateManip is manipulator for 3D rotation
By default, it operates under yaw, pitch, roll mode.  

Virtual functions:
	mousePressEvent(event)
	mouseMoveEvent
	mouseReleaseEvent
	draw
	connectToDependNode(node);

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Scene/Manipulators/RotateManip.lua");
local RotateManip = commonlib.gettable("System.Scene.Manipulators.RotateManip");
local manip = RotateManip:new():init();
manip:SetPosition(x,y,z);
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/Scene/Manipulators/Manipulator.lua");
NPL.load("(gl)script/ide/math/Plane.lua");
NPL.load("(gl)script/ide/math/Quaternion.lua");
local Quaternion = commonlib.gettable("mathlib.Quaternion");
local Color = commonlib.gettable("System.Core.Color");
local Plane = commonlib.gettable("mathlib.Plane");
local vector3d = commonlib.gettable("mathlib.vector3d");
local ShapesDrawer = commonlib.gettable("System.Scene.Overlays.ShapesDrawer");
local RotateManip = commonlib.inherit(commonlib.gettable("System.Scene.Manipulators.Manipulator"), commonlib.gettable("System.Scene.Manipulators.RotateManip"));

RotateManip:Property({"Name", "RotateManip", auto=true});

RotateManip:Property({"FromAngle", nil, auto=true});
RotateManip:Property({"ToAngle", nil, auto=true});
RotateManip:Property({"PenWidth", 0.01});
RotateManip:Property({"radius", 1.2});
-- private: "x|y|z" current selected axis
RotateManip:Property({"selectedAxis", nil});
-- whether we are working in yaw pitch roll mode. 
RotateManip:Property({"YawPitchRollMode", true, "IsYawPitchRollMode", "SetYawPitchRollMode", auto=true});
RotateManip:Property({"YawEnabled", true, "IsYawEnabled", "SetYawEnabled", auto=true});
RotateManip:Property({"PitchEnabled", true, "IsPitchEnabled", "SetPitchEnabled", auto=true});
RotateManip:Property({"RollEnabled", true, "IsRollEnabled", "SetRollEnabled", auto=true});
-- whether to update values during dragging
RotateManip:Property({"RealTimeUpdate", true, "IsRealTimeUpdate", "SetRealTimeUpdate", auto=true});
-- whether to show last yaw/pitch/roll angles 
RotateManip:Property({"ShowLastAngles", false, "IsShowLastAngles", "SetShowLastAngles", auto=true});

function RotateManip:ctor()
	self.names = {};
	self:AddValue("position", {0,0,0});
	-- @note: need to be converted to mathlib.ToStandardAngle between -pi, pi
	self:AddValue("yaw", 0);
	self:AddValue("pitch", 0);
	self:AddValue("roll", 0);
	-- quaternion for bone rotation
	self.rot = Quaternion:new();
end

-- get rotation as quaternion
function RotateManip:GetRotation()
	self.rot:FromEulerAngles(self:GetField("yaw"), self:GetField("roll"), self:GetField("pitch"))
	return self.rot;
end

-- set initial value 
function RotateManip:SetYawPitchRoll(yaw, pitch, roll)
	if(yaw) then
		self:SetFieldInternal("yaw", mathlib.ToStandardAngle(yaw));
	end
	if(pitch) then
		self:SetFieldInternal("pitch", mathlib.ToStandardAngle(pitch));
	end
	if(roll) then
		self:SetFieldInternal("roll", mathlib.ToStandardAngle(roll));
	end
end

-- TODO: 
function RotateManip:SetRotation(quat)
	self.rot:set(quat);
end

function RotateManip:OnValueChange(name, value)
	RotateManip._super.OnValueChange(self);
	if(name == "position") then
		self:SetPosition(unpack(value));
	end
end

function RotateManip:init(parent)
	RotateManip._super.init(self, parent);
	return self;
end

local axis_dirs = {
	x = vector3d:new({1,0,0}),
	y = vector3d:new({0,1,0}),
	z = vector3d:new({0,0,1}),
}
local axis2_dirs = {
	x = axis_dirs.y,
	y = axis_dirs.z,
	z = axis_dirs.x,
}
-- @param axis: "x|y|z". default to current
-- @return vector3d
function RotateManip:GerRotAxisDir(axis)
	return axis_dirs[axis or self.selectedAxis];
end

function RotateManip:GerRotAxis2Dir(axis)
	return axis2_dirs[axis or self.selectedAxis];
end

-- is dragging
function RotateManip:IsDragging()
	return self.is_dragging;
end

-- virtual: 
function RotateManip:mousePressEvent(event)
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
		return;
	end
	local rotAxis = self:GerRotAxisDir();
	local rotAxis2 = self:GerRotAxis2Dir();
	self.last_mouse_x = event.x;
	self.last_mouse_y = event.y;

	
	-- calculate everything in view space. 
	local vecList = self:TransformVectorsInViewSpace({vector3d:new(0,0,0), rotAxis:clone(), rotAxis2:clone()});
	self.rotAxis = vecList[2] - vecList[1];
	self.rotAxis2 = vecList[3] - vecList[1];
	self.rotOrigin = vecList[1];
	-- define a virtual plane, perpendicular to the rotation axis. 
	self.virtualPlane = Plane:new():redefine(self.rotAxis, self.rotOrigin);
	self.last_yaw = self:GetField("yaw", 0);
	self.last_pitch = self:GetField("pitch", 0);
	self.last_roll = self:GetField("roll", 0);
	self.is_dragging = true;
end

-- virtual: 
function RotateManip:mouseMoveEvent(event)
	if(self.selectedAxis and self.rotAxis and self.rotOrigin) then
		event:accept();
		-- ray cast to virtual plane to obtain the mouse picking point. 
		local point = vector3d:new();
		local result, dist = self:MouseRayIntersectPlane(nil, nil, self.virtualPlane, point);
		if(result == 1) then
			point = point - self.rotOrigin;
			point:normalize();
			local cosAngle = self.rotAxis2:dot(point);
			local angle = math.acos(cosAngle);
			local sinAngle = self.rotAxis:dot(self.rotAxis2*point);
			if(sinAngle<0) then
				angle = - angle;
			end
			if(not self.FromAngle) then
				self.FromAngle = angle;
				self.ToAngle = angle;
				self:BeginModify();
			else
				self.ToAngle = angle;	
				if(self:IsRealTimeUpdate()) then
					self:GrabValues();
				end
			end
		end
	end
end

-- virtual: 
function RotateManip:mouseReleaseEvent(event)
	if(event:button() ~= "left") then
		return
	end
	event:accept();
	self:GrabValues();
	self.selectedAxis = nil;
	self.FromAngle = nil;
	self.ToAngle = nil;
	self.rotAxis = nil;
	self.last_yaw = nil;
	self.last_pitch = nil;
	self.last_roll = nil;
	self.is_dragging = nil;
	self:EndModify();
end

function RotateManip:GrabValues()
	self:BeginUpdate();
	self:GrabValuesImp();
	self:EndUpdate();
end

function RotateManip:GrabValuesImp()
	if(self.FromAngle and self.ToAngle) then
		local from, to = self.FromAngle, self.ToAngle;
		local delta = to - from;
		if(delta > math.pi) then
			delta = delta - math.pi*2;
		elseif(delta<-math.pi) then
			delta = delta + math.pi*2;
		end
		local yaw, pitch, roll;
		if(self.selectedAxis == "y") then
			yaw = self.last_yaw + delta;
		elseif(self.selectedAxis == "x") then
			pitch = self.last_pitch + delta;
		elseif(self.selectedAxis == "z") then
			roll = self.last_roll + delta;
		end
		self:SetNewYawPitchRoll(yaw, pitch, roll);
	end
end

function RotateManip:SetNewYawPitchRoll(yaw, pitch, roll)
	if(yaw) then
		self:SetField("yaw", mathlib.ToStandardAngle(yaw));
	end
	if(pitch) then
		self:SetField("pitch", mathlib.ToStandardAngle(pitch));
	end
	if(roll) then
		self:SetField("roll", mathlib.ToStandardAngle(roll));
	end
end

-- virtual: actually means key stroke. 
function RotateManip:keyPressEvent(event)
end

-- @param axis: "x", "y", "z"
-- @param name: current active name. if nil, it will load current active name
function RotateManip:IsAxisHighlighted(axis, name)
	if(self.selectedAxis) then
		return self.selectedAxis == axis;
	else
		name = name or self:GetActivePickingName();
		return (self.names[axis] == name);
	end
end

function RotateManip:HasPickingName(pickingName)
	return self.names.x == pickingName
		or self.names.y == pickingName
		or self.names.z == pickingName;
end


-- only show the half circle in front of the plane which is perpendicular to the camera view 
-- @param axis: "x|y|z"
-- @return fromAngle, toAngle
function RotateManip:caculateFrontCircleAngleRange(axis)
	local rotAxis = self:GerRotAxisDir(axis);
	local rotAxis2 = self:GerRotAxis2Dir(axis);
	local vecList = self:TransformVectorsInViewSpace({vector3d:new(0,0,0), rotAxis:clone(), rotAxis2:clone()});
	local rotAxisCamSpace = vecList[2] - vecList[1];
	local rotAxis2CamSpace = vecList[3] - vecList[1];
	if(math.abs(rotAxisCamSpace[3]) > 0.9) then
		-- show full circle if perpendicular to the camera view 
		return 0, math.pi*2;
	end
	-- edgeVector is either the fromAngle or toAngle
	local edgeVector = rotAxisCamSpace:clone();
	edgeVector[3] = 0;
	edgeVector:normalize();
	edgeVector[1], edgeVector[2] = -edgeVector[2], edgeVector[1];

	local angle = edgeVector:angle(rotAxis2CamSpace);
	local fromAngle = angle;
	if(angle > 0.01) then
		if(rotAxisCamSpace:dot(edgeVector*rotAxis2CamSpace) > 0) then
			fromAngle = -angle;
		end
	end
	return fromAngle + math.pi, fromAngle + math.pi*2;
end


function RotateManip:paintEvent(painter)
	self.pen.width = self.PenWidth;
	local cube_radius = self.PenWidth*2;
	painter:SetPen(self.pen);
	local isDrawingPickable = self:IsPickingPass();

	local x_name, y_name, z_name;
	if(isDrawingPickable) then
		x_name = self:GetNextPickingName();
		y_name = self:GetNextPickingName();
		z_name = self:GetNextPickingName();
	end

	local radius = self.radius;

	if(self:IsShowLastAngles() and not isDrawingPickable) then
		self:SetColorAndName(painter, Color.ChangeOpacity(self.lineColor, 128));
		-- draw last angles
		local last_yaw = self.last_yaw or self:GetField("yaw", 0);
		local last_pitch = self.last_pitch or self:GetField("pitch", 0);
		local last_roll = self.last_roll or self:GetField("roll", 0);
		if(last_yaw ~= 0 and self:IsYawEnabled()) then
			local from, to = 0, last_yaw;
			if(last_yaw < 0) then
				from, to = to, from;
			end
			ShapesDrawer.DrawCircle(painter, 0,0,0, radius, "y", true, nil, from, to);
		end
		if(last_pitch ~= 0 and self:IsPitchEnabled()) then
			local from, to = 0, last_pitch;
			if(last_pitch < 0) then
				from, to = to, from;
			end
			ShapesDrawer.DrawCircle(painter, 0,0,0, radius, "x", true, nil, from, to);
		end
		if(last_roll ~= 0 and self:IsRollEnabled()) then
			local from, to = 0, last_roll;
			if(last_roll < 0) then
				from, to = to, from;
			end
			ShapesDrawer.DrawCircle(painter, 0,0,0, radius, "z", true, nil, from, to);
		end
	end

	if(self:IsPitchEnabled()) then
		if(self:IsAxisHighlighted("x", name)) then 
			self:SetColorAndName(painter, self.selectedColor, x_name);
		else
			if(not self.selectedAxis) then
				self:SetColorAndName(painter, self.xColor, x_name);
			else
				self:SetColorAndName(painter, Color.ChangeOpacity(self.xColor, 32), x_name);
			end
		end
		local from, to = self:caculateFrontCircleAngleRange("x");
		ShapesDrawer.DrawCircle(painter, 0,0,0, radius, "x", false, nil, from, to);
	end
	if(self:IsYawEnabled()) then
		if(self:IsAxisHighlighted("y", name)) then 
			self:SetColorAndName(painter, self.selectedColor, y_name);
		else
			if(not self.selectedAxis) then
				self:SetColorAndName(painter, self.yColor, y_name);
			else
				self:SetColorAndName(painter, Color.ChangeOpacity(self.yColor, 32), y_name);
			end
		end
		local from, to = self:caculateFrontCircleAngleRange("y");
		ShapesDrawer.DrawCircle(painter, 0,0,0, radius, "y", false, nil, from, to);
	end
	if(self:IsRollEnabled()) then
		if(self:IsAxisHighlighted("z", name)) then 
			self:SetColorAndName(painter, self.selectedColor, z_name);
		else
			if(not self.selectedAxis) then
				self:SetColorAndName(painter, self.zColor, z_name);
			else
				self:SetColorAndName(painter, Color.ChangeOpacity(self.zColor, 32), y_name);
			end
		end
		local from, to = self:caculateFrontCircleAngleRange("z");
		ShapesDrawer.DrawCircle(painter, 0,0,0, radius, "z", false, nil, from, to);
	end

	if(self.FromAngle and self.ToAngle and self.selectedAxis and not isDrawingPickable) then
		painter:SetBrush(Color.ChangeOpacity(self.selectedColor, 196));
		local from, to = self.FromAngle, self.ToAngle;
		if(to < from) then
			to = to + 2*math.pi;
		end
		if((to-from) > math.pi) then
			to, from = from, to
		end
		ShapesDrawer.DrawCircle(painter, 0,0,0, radius, self.selectedAxis, true, nil, from, to);
		self:SetColorAndName(painter, self.lineColor);
		local cx, cy, cz = 0,0,0;
		ShapesDrawer.DrawCube(painter, cx, cy, cz, cube_radius);
		local axis = self.selectedAxis;
		for i=1,2 do
			local angle = if_else(i==1, from, to);
			local x, y = math.cos(angle)*radius, math.sin(angle)*radius;
			local x2,y2,z2;
			if(axis == "x") then
				x2,y2,z2 = cx, cy + x, cz + y;
			elseif(axis == "y") then
				x2,y2,z2 = cx + y, cy, cz + x;
			else -- "z"
				x2,y2,z2 = cx + x, cy + y, cz;
			end
			ShapesDrawer.DrawLine(painter, cx, cy, cz, x2,y2,z2);
			ShapesDrawer.DrawCube(painter, x2,y2,z2, cube_radius);
		end
	end

	if(isDrawingPickable) then
		self.names.x = x_name;
		self.names.y = y_name;
		self.names.z = z_name;
	end
end
