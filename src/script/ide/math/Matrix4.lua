--[[
Title: 4x4 homogeneous matrix
Author(s): LiXizhi
Date: 2015/8/19, ported from C++ ParaEngine
Desc: Class encapsulating a standard 4x4 homogeneous matrix.
@remarks
    ParaEngine uses row vectors when applying matrix multiplications,
    This means a vector is represented as a single row, 4-column
    matrix. This has the effect that the transformations implemented
    by the matrices happens left-to-right e.g. if vector V is to be
    transformed by M1 then M2 then M3, the calculation would be
    V * M1 * M2 * M3 . The order that matrices are concatenated is
    vital since matrix multiplication is not commutative, i.e. you
    can get a different result if you concatenate in the wrong order.
	But it is fine to use this class in a column-major math, the math are the same.
@par
    ParaEngine deals with the differences between D3D and OpenGL etc.
    internally when operating through different render systems. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/math/Matrix4.lua");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");
local m1 = Matrix4:new():identity();
local m2 = m1:clone():makeTrans(3, 3, 3);
local v = mathlib.vector3d:new(1,2,3);
v = v * (m1 * m2);
echo(v);
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/math3d.lua");
NPL.load("(gl)script/ide/math/vector.lua");
local math3d = commonlib.gettable("mathlib.math3d");
local type = type;
local Matrix4 = commonlib.gettable("mathlib.Matrix4");
Matrix4.__index = Matrix4;

-- create a new matrix
function Matrix4:new(o)
	o = o or {};
	setmetatable(o, self);
	return o;
end

function Matrix4:clone()
	return Matrix4:new({unpack(self)});
end

function Matrix4:set(mat)
	for i=1,16 do
		self[i] = mat[i];
	end
	return self;
end

-- make this identity
function Matrix4:identity()
	return self:set(Matrix4.IDENTITY);
end

function Matrix4:equals(mat)
	for i=1,16 do
		if(self[i] ~= mat[i]) then
			return false
		end
	end
	return true;
end

function Matrix4.__add(a,b)
	local mat = {};
	for i=1,16 do
		mat[i] = a[i] + b[i];
	end
	return Matrix4:new(mat);
end

function Matrix4.__sub(a,b)
	local mat = {};
	for i=1,16 do
		mat[i] = a[i] - b[i];
	end
	return Matrix4:new(mat);
end

-- @param b: can be vector3d or Matrix4
function Matrix4.__mul(a,b)
	local nSizeB = #b;
	if(#b == 16) then
		return math3d.MatrixMultiply(nil, a, b);
	elseif(#b == 3) then
		return math3d.MatrixMultiplyVector(nil, a, b)
	end
end

-- Builds a translation matrix
function Matrix4:makeTrans(tx, ty, tz)
	self:set(Matrix4.IDENTITY);
	self[13] = tx;  self[14] = ty;  self[15] = tz;
	return self;
end

function Matrix4:offsetTrans(tx, ty, tz)
	self[13] = self[13]+tx;  self[14] = self[14]+ty;  self[15] = self[15]+tz;
	return self;
end

function Matrix4:setScale(sx, sy, sz)
	self[1] = sx or 1;  	self[6] = sy or 1;  self[11] = sz or 1;
end

function Matrix4:setTrans(tx, ty, tz)
	self[13] = tx or 0;  self[14] = ty or 0;  self[15] = tz or 0;
end

-- return the inverse of this matrix
function Matrix4:inverse()
	local m00, m01, m02, m03 = self[1], self[2], self[3], self[4];
    local m10, m11, m12, m13 = self[5], self[6], self[7], self[8];
    local m20, m21, m22, m23 = self[9], self[10],self[11],self[12];
    local m30, m31, m32, m33 = self[13],self[14],self[15],self[16];

    local v0 = m20 * m31 - m21 * m30;
    local v1 = m20 * m32 - m22 * m30;
    local v2 = m20 * m33 - m23 * m30;
    local v3 = m21 * m32 - m22 * m31;
    local v4 = m21 * m33 - m23 * m31;
    local v5 = m22 * m33 - m23 * m32;

    local t00 = (v5 * m11 - v4 * m12 + v3 * m13);
    local t10 = - (v5 * m10 - v2 * m12 + v1 * m13);
    local t20 = (v4 * m10 - v2 * m11 + v0 * m13);
    local t30 = - (v3 * m10 - v1 * m11 + v0 * m12);

    local invDet = 1 / (t00 * m00 + t10 * m01 + t20 * m02 + t30 * m03);

    local d00 = t00 * invDet;
    local d10 = t10 * invDet;
    local d20 = t20 * invDet;
    local d30 = t30 * invDet;

    local d01 = - (v5 * m01 - v4 * m02 + v3 * m03) * invDet;
    local d11 = (v5 * m00 - v2 * m02 + v1 * m03) * invDet;
    local d21 = - (v4 * m00 - v2 * m01 + v0 * m03) * invDet;
    local d31 = (v3 * m00 - v1 * m01 + v0 * m02) * invDet;

    v0 = m10 * m31 - m11 * m30;
    v1 = m10 * m32 - m12 * m30;
    v2 = m10 * m33 - m13 * m30;
    v3 = m11 * m32 - m12 * m31;
    v4 = m11 * m33 - m13 * m31;
    v5 = m12 * m33 - m13 * m32;

    local d02 = (v5 * m01 - v4 * m02 + v3 * m03) * invDet;
    local d12 = - (v5 * m00 - v2 * m02 + v1 * m03) * invDet;
    local d22 = (v4 * m00 - v2 * m01 + v0 * m03) * invDet;
    local d32 = - (v3 * m00 - v1 * m01 + v0 * m02) * invDet;

    v0 = m21 * m10 - m20 * m11;
    v1 = m22 * m10 - m20 * m12;
    v2 = m23 * m10 - m20 * m13;
    v3 = m22 * m11 - m21 * m12;
    v4 = m23 * m11 - m21 * m13;
    v5 = m23 * m12 - m22 * m13;

    local d03 = - (v5 * m01 - v4 * m02 + v3 * m03) * invDet;
    local d13 = (v5 * m00 - v2 * m02 + v1 * m03) * invDet;
    local d23 = - (v4 * m00 - v2 * m01 + v0 * m03) * invDet;
    local d33 = (v3 * m00 - v1 * m01 + v0 * m02) * invDet;

    return Matrix4:new({
        d00, d01, d02, d03,
        d10, d11, d12, d13,
        d20, d21, d22, d23,
        d30, d31, d32, d33});
end

-- const static identity matrix. 
Matrix4.IDENTITY = Matrix4:new({1, 0, 0, 0,        0, 1, 0, 0,        0, 0, 1, 0,        0, 0, 0, 1 });
