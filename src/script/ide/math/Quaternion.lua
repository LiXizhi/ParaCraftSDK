--[[
Title: Quaternion
Author(s): LiXizhi
Date: 2015/9/2, ported from C++ ParaEngine
Desc: Class encapsulating a standard quaternion {x,y,z,w}.

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/math/Quaternion.lua");
local Quaternion = commonlib.gettable("mathlib.Quaternion");
echo({Quaternion:new():FromEulerAngles(1.57, 1.1, 1.1):ToEulerAngles()});
local q1 = Quaternion:new():identity();
local q2 = Quaternion:new():identity();
local q = q1 * q2;
echo(q);
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/math3d.lua");
local vector3d = commonlib.gettable("mathlib.vector3d");
local math3d = commonlib.gettable("mathlib.math3d");
local type = type;
local Quaternion = commonlib.gettable("mathlib.Quaternion");
Quaternion.__index = Quaternion;

-- create a new matrix
function Quaternion:new(o)
	o = o or {0,0,0,1};
	setmetatable(o, self);
	return o;
end

function Quaternion:clone()
	return Quaternion:new({unpack(self)});
end

function Quaternion:set(q)
	self[1] = q[1]; self[2] = q[2]; self[3] = q[3]; self[4] = q[4];
	return self;
end

-- make this identity
function Quaternion:identity()
	return self:set(Quaternion.IDENTITY);
end

function Quaternion:equals(mat)
	return (self[1] == v[1] and self[2] == v[2] and self[3] == v[3] and self[4] == v[4]);
end

function Quaternion.__add(a,b)
	return Quaternion:new({a[1]+b[1], a[2]+b[2], a[3]+b[3], a[4]+b[4]})
end

function Quaternion.__sub(a,b)
	return Quaternion:new({a[1]-b[1], a[2]-b[2], a[3]-b[3], a[4]-b[4]})
end

-- @param b: can be vector3d or Quaternion
function Quaternion.__mul(a,b)
	return Quaternion:new({
		a[4] * b[1] + a[1] * b[4] + a[2] * b[3] - a[3] * b[2],
		a[4] * b[2] + a[2] * b[4] + a[3] * b[1] - a[1] * b[3],
		a[4] * b[3] + a[3] * b[4] + a[1] * b[2] - a[2] * b[1],
		a[4] * b[4] - a[1] * b[1] - a[2] * b[2] - a[3] * b[3]
	});
end

--This constructor creates a new quaternion that will rotate vector
-- a into vector b about their mutually perpendicular axis. (if one exists)
function Quaternion:FromVectorToVector(a, b)
	local factor = a:length() * b:length();

	if (math.abs(factor) > 0.000001) then
		-- Vectors have length > 0
		local dot = a:dot(b) / factor;
		local theta = math.acos(mathlib.clamp(dot, -1.0, 1.0));

		local pivotVector = a*b;
		if (dot < 0.0 and pivotVector:length() < 0.000001) then
			-- Vectors parallel and opposite direction, therefore a rotation
			-- of 180 degrees about any vector perpendicular to this vector
			-- will rotate vector a onto vector b.
			-- The following guarantees the dot-product will be 0.0.
			local dominantIndex = a:dominantAxis();
			pivotVector[dominantIndex] = -a[(dominantIndex) % 3+1];
			pivotVector[(dominantIndex) % 3 + 1] = a[dominantIndex];
			pivotVector[(dominantIndex + 1) % 3 + 1] = 0.0;
		end
		self:FromAngleAxis(theta, pivotVector);
	else
		self[1], self[2], self[3], self[4] = 0,0,0,1;
	end
	return self;
end

-- @param rkAxis: may not be normalized
function Quaternion:FromAngleAxis(rfAngle, rkAxis)
    -- The quaternion representing the rotation is
    --   q = cos(A/2)+sin(A/2)*(x*i+y*j+z*k)
	local sumOfSquares = rkAxis:length2();
	if(sumOfSquares <= 0.00001) then
		-- Axis too small.
		self[1], self[2], self[3], self[4] = 0,0,0,1;
	else
		local fHalfAngle = (rfAngle * 0.5);
		local fSin = math.sin(fHalfAngle);
		if(sumOfSquares ~= 1.0) then
			fSin = fSin / (sumOfSquares^0.5);
		end
		self[1] = fSin*rkAxis[1];
		self[2] = fSin*rkAxis[2];
		self[3] = fSin*rkAxis[3];
		self[4] = math.cos(fHalfAngle);
	end
	return self;
end

-- @return angle, axis: float, vector3d
function Quaternion:ToAngleAxis()
	local rfAngle;
	local rkAxis = vector3d:new();
    --The quaternion representing the rotation is
    --   q = cos(A/2)+sin(A/2)*(x*i+y*j+z*k)
	local x,y,z = self[1], self[2], self[3];
    local fSqrLength = x*x+y*y+z*z;
    if ( fSqrLength > 0.0 ) then
        rfAngle = math.acos(self[4])*2;
        local fInvLength = 1 / (fSqrLength ^ 0.5);
        rkAxis[1] = x*fInvLength;
        rkAxis[2] = y*fInvLength;
        rkAxis[3] = z*fInvLength;
    else
        -- angle is 0 (mod 2*pi), so any axis will do
        rfAngle = 0.0;
        rkAxis[1] = 1.0;
        rkAxis[2] = 0.0;
        rkAxis[3] = 0.0;
    end
	return rfAngle, rkAxis;
end

function Quaternion:tostring()
    return format("%f %f %f %f",self[1],self[2],self[3], self[4])
end

function Quaternion:tostringAngleAxis()
	local angle, axis = self:ToAngleAxis()
	return format("%f: %f %f %f",angle,axis[1],axis[2], axis[3])
end

-- transform to another coordinate system. 
function Quaternion:TransformAxisByMatrix(mat)
	local angle, axis = self:ToAngleAxis();
	axis:normalize();
	axis = axis*mat;
	return self:FromAngleAxis(angle, axis);
end

-- Conversion Euler to Quaternion
-- @param heading(yaw), attitude(roll), bank(pitch)
-- @returns: self
function Quaternion:FromEulerAngles(heading, attitude, bank) 
	-- same as following code
	--local q1 = Quaternion:new():FromAngleAxis(self:GetField("yaw"), vector3d.unit_y);
	--local q2 = Quaternion:new():FromAngleAxis(self:GetField("pitch"), vector3d.unit_x);
	--local q3 = Quaternion:new():FromAngleAxis(self:GetField("roll"), vector3d.unit_z);
	--self.rot:set(q1*q2*q3);

    -- Assuming the angles are in radians.    
    local c1 = math.cos(heading/2);    
    local s1 = math.sin(heading/2);    
    local c2 = math.cos(attitude/2);    
    local s2 = math.sin(attitude/2);    
    local c3 = math.cos(bank/2);    
    local s3 = math.sin(bank/2);
    local c1c2 = c1*c2;    
    local s1s2 = s1*s2;
    w =c1c2*c3 - s1s2*s3;
  	x =c1c2*s3 + s1s2*c3;
	y =s1*c2*c3 + c1*s2*s3;
	z =c1*s2*c3 - s1*c2*s3;
	self[1], self[2], self[3], self[4] =  x,y,z,w;
	return self;
end

-- @return heading, attitude, bank (yaw, roll, pitch)
function Quaternion:ToEulerAngles() 
	local heading, attitude, bank;
	local test = self[1]*self[2] + self[3]*self[4];
	if (test > 0.499) then -- singularity at north pole
		heading = 2 * math.atan2(self[1],self[4]);
		attitude = math.pi/2;
		bank = 0;
		return heading, attitude, bank
	end	
	if (test < -0.499) then -- singularity at south pole
		heading = -2 * math.atan2(self[1],self[4]);
		attitude = - math.pi/2;
		bank = 0;
		return heading, attitude, bank
	end
	local sqx = self[1]*self[1];    
	local sqy = self[2]*self[2];
	local sqz = self[3]*self[3];
    heading = math.atan2(2*self[2]*self[4]-2*self[1]*self[3] , 1 - 2*sqy - 2*sqz);
	attitude = math.asin(2*test);
	bank = math.atan2(2*self[1]*self[4]-2*self[2]*self[3] , 1 - 2*sqx - 2*sqz)
	return heading, attitude, bank
end

-- const static identity matrix. 
Quaternion.IDENTITY = Quaternion:new({0, 0, 0, 1});
