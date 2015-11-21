--[[
Title: vector2d and vector3d math
Author(s): LiXizhi
Date: 2010/10/19
Desc: We only provide limited and lightweighted interface of vectors in 3d. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/math/vector.lua");
local vector3d = commonlib.gettable("mathlib.vector3d");
local v1 = vector3d:new(0,0,1)
local v2 = vector3d:new({1,0,0})
local v1 = vector3d:new_from_pool(0,0,1)
local angle = v1:angle(v2)
local dist = v1:dist(v2)
LOG.info({angle, dist})
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/VectorPool.lua");
local VectorPool = commonlib.gettable("mathlib.VectorPool");
local type = type;
local vector3d = commonlib.gettable("mathlib.vector3d");
vector3d.__index = vector3d;

-- create a new vector
-- @param x, y, z: if x is nil, it is a {0,0,0} vector; if x is table, it is an array of x,y,z. if x is number, then y, z must also be number. 
function vector3d:new(x,y,z)
	local o;
	local type_ = type(x);
	if(type_ == "number") then
		o = {x,y,z};
	elseif(type_ == "table") then
		o = x;
	else
		o = {0,0,0};
	end
	setmetatable(o, self);
	return o;
end

function vector3d:new_from_pool(x,y,z)
	return VectorPool.GetSingleton():GetVector(x,y,z);	
end

-- make a clone 
function vector3d:clone()
    return vector3d:new(self[1], self[2], self[3]);
end

function vector3d:clone_from_pool()
	return VectorPool.GetSingleton():GetVector(self[1], self[2], self[3]);	
end

-- Returns the axis along which this vector is dominant 
-- @return number: 1 for x, 2 for y, 3 for z
function vector3d:dominantAxis()
	local xx = math.abs(self[1]);
	local yy = math.abs(self[2]);

	if (xx > yy) then
		if (xx > math.abs(self[3])) then
			return 1;
		else
			return 3;
		end
	else
		if (yy > math.abs(self[3])) then
			return 2;
		else
			return 3;
		end
	end
end

-- get length
function vector3d:length()
	local len_sq = self:length2();
	if(len_sq>0) then
		return len_sq^0.5;
	else
		return 0;
	end
end

-- get length square
function vector3d:length2()
	return (self[1]^2 + self[2]^2+self[3]^2);
end

function vector3d:normalize()
    local m = self:length()
    if m > 0.00001 then
        m = 1/m
        self[1] = self[1] * m
        self[2] = self[2] * m
        self[3] = self[3] * m
    else
        self[1] = 0
        self[2] = 0
        self[3] = 0
    end
    return self
end

function vector3d:set(x,y,z)
    if y == nil then
        self[1] = x[1]
        self[2] = x[2]
        self[3] = x[3]        
    else
        self[1] = x
        self[2] = y
        self[3] = z
    end
end

function vector3d:add(x,y,z)
    if y == nil then
        self[1] = self[1] + x[1]
        self[2] = self[2] + x[2]
        self[3] = self[3] + x[3]        
    else
        self[1] = self[1] + x
        self[2] = self[2] + y
        self[3] = self[3] + z
    end
end

function vector3d.__add(a,b)
	return vector3d:new(a[1]+b[1], a[2]+b[2], a[3]+b[3])
end

function vector3d:interpolate(x,y,z,a)
    if z == nil then
        self[1] = self[1] + (x[1] - self[1]) * y
        self[2] = self[2] + (x[2] - self[2]) * y
        self[3] = self[3] + (x[3] - self[3]) * y 
    else
        self[1] = self[1] + (x - self[1]) * a
        self[2] = self[2] + (y - self[2]) * a
        self[3] = self[3] + (z - self[3]) * a
    end
    return self
end

function vector3d:sub(x,y,z)
    if y == nil then
        self[1] = self[1] - x[1]
        self[2] = self[2] - x[2]
        self[3] = self[3] - x[3]        
    else
        self[1] = self[1] - x
        self[2] = self[2] - y
        self[3] = self[3] - z
    end
end

function vector3d.__sub(a,b)
	return vector3d:new(a[1]-b[1], a[2]-b[2], a[3]-b[3])
end

function vector3d:MulByFloat(a)
    self[1] = self[1] * a
    self[2] = self[2] * a
    self[3] = self[3] * a
	return self;
end

-- @param a: vector3d
function vector3d:MulByVector(a)
    self[1] = self[1] * a[1]
    self[2] = self[2] * a[2]
    self[3] = self[3] * a[3]
	return self;
end

-- @param a: vector3d
-- @return a new vector
function vector3d:MulVector(a)
	return vector3d:new(self[1] * a[1], self[2] * a[2], self[3] * a[3]);
end

-- cross product with a vector3d, or transform by a float or Matrix4
-- @param b: can be number, vector3d or Matrix4
function vector3d.__mul(a,b)
	if(type(b) == "table") then
		if(#b == 16) then
			local x,y,z = a[1], a[2], a[3];
			return vector3d:new(
				x*b[1] + y*b[5] + z*b[9] + b[13],
				x*b[2] + y*b[6] + z*b[10] + b[14],
				x*b[3] + y*b[7] + z*b[11] + b[15]
				);
		else
			return vector3d:new(a[2] * b[3] -a[3] * b[2],a[3] * b[1] - a[1] * b[3],a[1] * b[2] - a[2] * b[1])
		end
	elseif(type(b) == "number") then
		return vector3d:new(a[1] * b, a[2] * b, a[3] * b)
	end
end

-- @param x can be number or another vector 
function vector3d:dot(x,y,z)
    if not y then
        return self[1] * x[1] + self[2] * x[2] + self[3] * x[3]
    else
        return self[1] * x + self[2] * y + self[3] * z
    end
end

function vector3d:get()
    return self[1],self[2],self[3]
end

-- distance square to a point
-- @param x can be number or another vector 
function vector3d:dist2(x,y,z)
    if not y then 
		return ((self[1]-x[1])^2 + (self[2]-x[2])^2 + (self[3]-x[3])^2);
	else
		return ((self[1]-x)^2 + (self[2]-y)^2 + (self[3]-z)^2);
	end
end


-- distance to a point
-- note param y can be nil. 
function vector3d:dist(x,y,z)
	local len_sq =  self:dist2(x,y,z);
    if(len_sq>0) then
		return len_sq^0.5;
	else
		return 0;
	end
end

function vector3d:tostring()
    return format("%f %f %f",self[1],self[2],self[3])
end

function vector3d:compare(v)
	return (self[1] == v[1] and self[2] == v[2] and self[3] == v[3]);
end

function vector3d:equals(v)
	return (self[1] == v[1] and self[2] == v[2] and self[3] == v[3]);
end

function vector3d:rotateZYX(az,ay,ax)
    -- Z
    local x = self[1] * math.cos(az) - self[2] * math.sin(az)
    local y = self[1] * math.sin(az) + self[2] * math.cos(az)
    self[1],self[2] = x,y
    -- Y
    local z = self[3] * math.cos(ay) - self[1] * math.sin(ay)
    local x = self[3] * math.sin(ay) + self[1] * math.cos(ay)
    self[3],self[1] = z,x
    -- X
    local y = self[2] * math.cos(ax) - self[3] * math.sin(ax)
    local z = self[2] * math.sin(ax) + self[3] * math.cos(ax)
    self[2],self[3] = y,z
end

function vector3d:rotate(ax,ay,az)
    -- X
    local y = self[2] * math.cos(ax) - self[3] * math.sin(ax)
    local z = self[2] * math.sin(ax) + self[3] * math.cos(ax)
    self[2],self[3] = y,z
    -- Y
    local z = self[3] * math.cos(ay) - self[1] * math.sin(ay)
    local x = self[3] * math.sin(ay) + self[1] * math.cos(ay)
    self[3],self[1] = z,x
    -- Z
    local x = self[1] * math.cos(az) - self[2] * math.sin(az)
    local y = self[1] * math.sin(az) + self[2] * math.cos(az)
    self[1],self[2] = x,y
end

-- the angle between self and dest
-- @param dest
-- return a value between 0,3.14
function vector3d:angle(dest)
	local lenProduct = self:length() * dest:length();
	-- Divide by zero check
	if (lenProduct < 0.000001) then
		lenProduct = 0.000001;
	end
	local f = self:dot(dest) / lenProduct;
	f = mathlib.clamp(f, -1.0, 1.0);
	return math.acos(f);
end

-- the angle between self and dest wide range. usually used to calcute absolute facing
-- @param dest
-- return a value between -3.14,3.14
function vector3d:angleAbsolute(dest)
	local angle = self:angle(dest);
	if(dest[3]>0) then
		angle = -angle;
	end
	return angle;
end

-- Returns the vector that represents the rotation of this vector by the given quaternion.
function vector3d:rotateBy(q)
	-- nVidia SDK implementation: identical to following implementation. 
	--local qvec = vector3d:new(q[1], q[2], q[3]);
	--local uv = qvec * self;
	--local uuv = qvec * uv;
	--uv = uv * (2.0 * q[4]);
	--uuv = uuv * 2.0;
	--return self + uv + uuv;

	-- Simply carry out the quaternion multiplications: result = q.conjugate() * (*this) * q
	local x, y, z = self[1], self[2], self[3];
	local qx, qy, qz, qw = q[1], q[2], q[3], q[4];
	local rw = - qx * x - qy * y - qz * z;
	local rx = qw * x + qy * z - qz * y;
	local ry = qw * y + qz * x - qx * z;
	local rz = qw * z + qx * y - qy * x;
	return vector3d:new(- rw * qx +  rx * qw - ry * qz + rz * qy,
					- rw * qy +  ry * qw - rz * qx + rx * qz,
					- rw * qz +  rz * qw - rx * qy + ry * qx);
end

-- Returns TRUE if the vectors are parallel, that is, pointing in
-- the same or opposite directions, but not necessarily of the same magnitude.
-- @param tolerance: default to a small number
function vector3d:isParallel(otherVector, tolerance)
	local factor = self:length() * otherVector:length();
	local dotPrd = self:dot(otherVector) / factor;
	return (math.abs(math.abs(dotPrd) - 1.0) <= (tolerance or 0.000001));
end

-- some static members.
vector3d.unit_x = vector3d:new(1,0,0);
vector3d.unit_y = vector3d:new(0,1,0);
vector3d.unit_z = vector3d:new(0,0,1);
vector3d.zero = vector3d:new();