--[[
Title: math lib funcions
Author(s): LiXizhi
Date: 2007/10/18
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/mathlib.lua");

local q1 = mathlib.QuatFromAxisAngle(0,1,0,3.14)
local q2 = mathlib.QuatFromAxisAngle(0,1,0,-3.14)
commonlib.echo(mathlib.QuaternionMultiply(q1,q2))
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/bit.lua");
local mathlib = commonlib.gettable("mathlib");
local rshift = mathlib.bit.rshift;
local lshift = mathlib.bit.lshift;
local bor = mathlib.bit.bor;
local math_floor = math.floor;

-- Conversion Quaternion to Euler
-- @param q1: {x,y,z,w}
-- @returns: heading, attitude, bank
-- @note: code converted from http://www.euclideanspace.com/maths/geometry/rotations/conversions/quaternionToEuler/index.htm
function mathlib.QuatToEuler(q1) 
	local heading, attitude, bank;
	local test = q1.x*q1.y + q1.z*q1.w;
	if (test > 0.499) then -- singularity at north pole
		heading = 2 * math.atan2(q1.x,q1.w);
		attitude = math.pi/2;
		bank = 0;
		return heading, attitude, bank
	end	
	if (test < -0.499) then -- singularity at south pole
		heading = -2 * math.atan2(q1.x,q1.w);
		attitude = - math.pi/2;
		bank = 0;
		return heading, attitude, bank
	end
	local sqx = q1.x*q1.x;    
	local sqy = q1.y*q1.y;
	local sqz = q1.z*q1.z;
    heading = math.atan2(2*q1.y*q1.w-2*q1.x*q1.z , 1 - 2*sqy - 2*sqz);
	attitude = math.asin(2*test);
	bank = math.atan2(2*q1.x*q1.w-2*q1.y*q1.z , 1 - 2*sqx - 2*sqz)
	return heading, attitude, bank
end	

-- Conversion Euler to Quaternion
-- @param heading(yaw), attitude(roll), bank(pitch)
-- @returns: x,y,z,w
function mathlib.EulerToQuat(heading, attitude, bank) 
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
	return x,y,z,w;
end

-- assumes axis is already normalised
-- @param x,y,z: is a normalized axis vector 
-- @param angle: is the angle to rotate
function mathlib.QuatFromAxisAngle(x,y,z, angle) 
	local s = math.sin(angle/2);
	local q = {
		x = x * s,
		y = y * s,
		z = z * s,
		w = math.cos(angle/2),
	};
	return q;
end

-- Since a unit quaternion represents an orientation in 3D space, the multiplication of two unit quaternions will result in 
-- another unit quaternion that represents the combined rotation. Amazing, but it's true.
-- see: http://www.cprogramming.com/tutorial/3d/quaternions.html
-- @param q1,q2: q1 and q2 are two quaternion{x,y,z,w}
function mathlib.QuaternionMultiply(q1,q2)
	local q = {};
	q.w = (q1.w*q2.w - q1.x*q2.x - q1.y*q2.y - q1.z*q2.z)
	q.x = (q1.w*q2.x + q1.x*q2.w + q1.y*q2.z - q1.z*q2.y)
	q.y = (q1.w*q2.y - q1.x*q2.z + q1.y*q2.w + q1.z*q2.x)
	q.z = (q1.w*q2.z + q1.x*q2.y - q1.y*q2.x + q1.z*q2.w)
	return q;
end

-- the angle is reduced to an angle between -180 and +180 by mod, and a 360 check
function mathlib.WrapAngleTo180(angle)
    angle = angle % 360;
    if (angle >= 180) then
        angle = angle - 360;
    elseif (angle < -180) then
        angle = angle + 360;
    end
    return angle;
end

-- make sure that the angle is in the range (-Pi,Pi]
function mathlib.ToStandardAngle(fAngle)
	if(fAngle>0) then
		fAngle = fAngle - 6.28318*(math_floor(fAngle/6.28318));
		if(fAngle>3.14159) then
			fAngle = fAngle - 6.28318;
		end
	else
		fAngle = fAngle + 6.28318*(math_floor(-fAngle/6.28318));
		if(fAngle<-3.14159) then
			fAngle = fAngle + 6.28318;
		end
	end
	return fAngle;
end

-- change src from src to dest, by a maximum of fMaxStep. If dest has been reached, return true; otherwise return false.
--@return result_value, bEqual: 
function  mathlib.SmoothMoveFloat(src, dest, fMaxStep)
	if(math.abs(src-dest)<=fMaxStep) then
		--src = dest;
		return dest, true;
	elseif(src>dest) then
		src = src - fMaxStep;
	elseif(src<dest) then
		src = src + fMaxStep;
	end
	return src, false;
end

-- change src from src to dest, by a maximum of fMaxStep. If dest has been reached, return true; otherwise return false.
--@return result_value, bEqual: 
function mathlib.SmoothMoveAngle(src, dest, fMaxStep)
	local fDif = mathlib.ToStandardAngle(src-dest);
	if(math.abs(fDif)<=fMaxStep) then
		-- src = dest;
		return dest, true;
	elseif(fDif>0) then
		src = src - fMaxStep;
	else --  if(fDif<0)
		src = src + fMaxStep;
	end
	return src, false;
end

-- such that t=0, return a. t=1, return b
function mathlib.lerp(a, b, t)
	return a + t * (b - a);
end

-- get string hash, return int (maybe negative)
function mathlib.GetHash(value)
	if(type(value) == "string") then
		local hash = 0;
		for i=1, #(value) do
			local byte = string.byte(value, i);
			hash = lshift(hash, 8) + hash + byte;
		end
		return hash;
	else
		return 0;
	end
end

-- Returns the value of the first parameter, clamped to be within the lower and upper limits given by the second and third parameters
function mathlib.clamp(value, from, to)
    if(value < from) then
		return from;
	elseif(value > to) then
		return to;
	else
		return value;
	end
end

-- @param x: must be int, make sure to call math.floor(x) before this.
function mathlib.NextPowerOf2(x)
	x = x - 1;
	x = bor(x, rshift(x,1));
	x = bor(x, rshift(x,2));
	x = bor(x, rshift(x,4));
	x = bor(x, rshift(x,8));
	x = bor(x, rshift(x,16));
	return x + 1;
end