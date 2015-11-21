--[[
Title: ShapeRay
Author(s): LiXizhi
Date: 2015/8/20, ported from C++ ParaEngine
Desc: A ray is a half-line P(t) = mOrig + mDir * t, with 0 <= t <= +infinity
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/math/ShapeRay.lua");
local ShapeRay = commonlib.gettable("mathlib.ShapeRay");
local ray = ShapeRay:new():init({0,0,0}, {0,0,1})
echo(ray:Distance({0,0,2}));
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/math3d.lua");
NPL.load("(gl)script/ide/math/vector.lua");
local math3d = commonlib.gettable("mathlib.math3d");
local vector3d = commonlib.gettable("mathlib.vector3d");
local type = type;
local ShapeRay = commonlib.gettable("mathlib.ShapeRay");
ShapeRay.__index = ShapeRay;

-- create a new matrix
function ShapeRay:new(o)
	o = o or {};
	setmetatable(o, self);
	
	-- Ray origin
	o.mOrig = vector3d:new({0,0,0});
	-- Normalized direction
	o.mDir = vector3d:new({0,0,0});
	return o;
end

-- @param orig, dir: vector3d or tuple array 
function ShapeRay:init(orig, dir)
	self.mOrig:set(orig);
	self.mDir:set(dir);
	return self;
end

-- @param point: vector3d or tuple array
-- @return float, float
function ShapeRay:SquareDistance(point)
	local Diff = vector3d.__sub(point, self.mOrig);
	
	local fT = Diff:dot(self.mDir);

	if(fT<=0.0)  then
		fT = 0.0;
	else
		fT = fT / self.mDir:length2();
		Diff = Diff - self.mDir*fT;
	end

	return Diff:length2(), fT;
end

-- @param point: vector3d or tuple array
-- @return float
function ShapeRay:Distance(point)
	local dist, t = self:SquareDistance(point);
	return math.sqrt(dist), t;
end

-- @param point: if not nil, it will receive the intersection point
-- @return: int, distance: interaction type, and distance.
--  1:intersected
-- -1:The plane is parallel to the ray; 
-- -2:The plane is facing away from the ray so no intersection occurs.
-- -3:The intersection occurs behind the ray's origin.
function ShapeRay:IntersectPlane(plane, point)
	local vd, vo, PnDOTRo, t;

	vd = plane:PlaneDotNormal(self.mDir);
	if (vd == 0.0) then
		-- The plane is parallel to the ray. I've never seen this happen but someday it will . . .
		return -1;
	elseif (vd > 0.0) then
		-- The plane is facing away from the ray so no intersection occurs.
		return -2;
	end
	local PnDOTRo = plane:PlaneDotNormal(self.mOrig);
	vo = -1.0 * (PnDOTRo + plane[4]);
	t = vo / vd;

	if (t < 0.0) then
		-- The intersection occurs behind the ray's origin.
		return -3, t;
	end

	if(point) then
		point[1] = self.mOrig[1] + self.mDir[1] * t;
		point[2] = self.mOrig[2] + self.mDir[2] * t;
		point[3] = self.mOrig[3] + self.mDir[3] * t;
	end
	return 1, t;
end