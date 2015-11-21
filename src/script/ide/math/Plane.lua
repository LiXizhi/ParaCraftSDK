--[[
Title: Defines a plane in 3D space.
Author(s): LiXizhi
Date: 2015/8/20, ported from C++ ParaEngine
Desc: 
@remarks
    A plane is defined in 3D space by the equation
    Ax + By + Cz + D = 0
@par
    This equates to a vector (the normal of the plane, whose x, y
    and z components equate to the coefficients A, B and C
    respectively), and a constant (D) which is the distance along
    the normal you have to go to move the plane back to the origin.
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/math/Plane.lua");
local Plane = commonlib.gettable("mathlib.Plane");
echo(v);
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/math3d.lua");
NPL.load("(gl)script/ide/math/vector.lua");
local math3d = commonlib.gettable("mathlib.math3d");
local vector3d = commonlib.gettable("mathlib.vector3d");
local type = type;
local Plane = commonlib.gettable("mathlib.Plane");
Plane.__index = Plane;

-- The "positive side" of the plane is the half space to which the
-- plane normal points. The "negative side" is the other half
-- space. The flag "no side" indicates the plane itself.
local Side = {
	NO_SIDE = 0,
	POSITIVE_SIDE = 1,
	NEGATIVE_SIDE = 2,
	BOTH_SIDE = 3,
};

-- create a new matrix
function Plane:new(o)
	o = o or {0,1,0,0};
	setmetatable(o, self);
	return o;
end

function Plane:clone()
	return Plane:new({self[1], self[2], self[3], self[4]});
end

function Plane:init(a,b,c,d)
	self[1], self[2], self[3], self[4] = a,b,c,d;
end

-- Redefine this plane based on a normal and a point.
function Plane:redefine(rkNormal, rkPoint)
	self[1], self[2], self[3] = rkNormal[1], rkNormal[2], rkNormal[3]
	self[4] = -vector3d.dot(rkNormal, rkPoint);
	return self;
end

function Plane:inverse()
	self[1], self[2], self[3], self[4] = -self[1], -self[2], -self[3], -self[4];
	return self;
end

function Plane:set(p)
	for i=1,4 do
		self[i] = p[i];
	end
	return self;
end

function Plane:equals(p)
	for i=1,4 do
		if(self[i] ~= p[i]) then
			return false
		end
	end
	return true;
end

function Plane:GetNormal()
	return vector3d:new(self[1], self[2], self[3]);
end

-- @return another plane transformed by a matrix4. 
function Plane:PlaneTransform(M)
	local plane = Plane:new();
	local a,b,c,d = self[1], self[2], self[3], self[4];
	plane[1] = M[1] * a + M[5] * b + M[9] * c  + M[13] * d;
	plane[2] = M[2] * a + M[6] * b + M[10] * c + M[14] * d;
	plane[3] = M[3] * a + M[7] * b + M[11] * c + M[15] * d;
	plane[4] = M[4] * a + M[8] * b + M[12] * c + M[16] * d;
	return plane;
end

-- @param v: a vector3d
function Plane:PlaneDotCoord(v)
	return vector3d.dot(self, v) + self[4];
end

-- @param v: can be a vector3d or the x component of vector.
-- @param y, z: if not nil, v, y, z is a vector's x,y,z
function Plane:PlaneDotNormal(v, y, z)
	return vector3d.dot(self, v, y, z);
end