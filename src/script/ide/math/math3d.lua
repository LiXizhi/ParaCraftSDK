--[[
Title: 3d math funcions
Author(s): LiXizhi
Date: 2008/12/20
Desc: a collection of standalone and frequently used 3d math functions, such as vector rotation, etc. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/math/math3d.lua");
print(mathlib.math3d.vec3Rotate(1,0,0,  0,1.57,0))
print(mathlib.math3d.vec3RotateByPoint(1000,0,0,  1001,0,0,  0,3.14,0))
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/Matrix4.lua");
local math3d = commonlib.gettable("mathlib.math3d");
local Matrix4 = commonlib.gettable("mathlib.Matrix4");

-- rotation a vector, around the X, then Y, then Z axis by the given radian.
-- e.g. print(mathlib.math3d.vec3Rotate(1,0,0,  0,1.57,0))
-- @param X, Y, Z: a point in 3D
-- @param a,b,c: radian around the X, Y, Z axis, such as 0, 1.57, 0
-- @return x,y,z: the rotated vector
function math3d.vec3Rotate(X, Y, Z, a, b, c)
	--[[
		Fact: v*M = v' => Rotation of a vector with a rotation matrix
		Roation on X axis
		| 1 		0		0		|		|	X	|		| 	X						|
		| 0		cos(a)	-sin(a)	|	*	|	Y	|	=	|	Y*cos(a) -Z*sin(a)		|
		| 0		sin(a)	cos(a)	|		|	Z	|		|	Y*sin(a) +Z*cos(a)		|

		Roation on Y axis
		| cos(b) 	0	sin(b)	|		|	X	|		| 	X*cos(b)+Z*sin(b)		|
		| 0			1	0		|	*	|	Y	|	=	|	Y						|
		| -sin(b)	0	cos(b)	|		|	Z	|		|	-X*sin(b)+Z*cos(b)		|

		Roation on Z axis
		| cos(c)	-sin(c)	0	|		|	X	|		| 	X*cos(c) -Y*sin(c)		|
		| sin(c)		cos(c)	0	|	*	|	Y	|	=	|	X*sin(c)+Y*cos(c)		|
		| 0			0		1	|		|	Z	|		|	Z						|
	
	--]]
	local x,y,z
	-- rotate around the X axis first
	if(a~=0) then
		x,y,z = X,Y,Z;
		Y = y*math.cos(a) - z*math.sin(a);
		Z = y*math.sin(a) + z*math.cos(a);
	end	
	-- And now around y
	if(b~=0)then
		x,y,z = X,Y,Z;
		X = x*math.cos(b) + z*math.sin(b);
		Z = -x*math.sin(b) + z*math.cos(b);
	end	
	-- Finally, around z
	if(c~=0) then
		x,y,z = X,Y,Z;
		X = x*math.cos(c) - y*math.sin(c);
		Y = x*math.sin(c) + y*math.cos(c);
	end	
	return X,Y,Z;
end

-- rotate input vector3 around a given point.
-- @param ox, oy, oz: around which point to rotate the input. 
-- @param X, Y, Z: the input point in 3D
-- @param a,b,c: radian around the X, Y, Z axis, such as 0, 1.57, 0
-- @return x,y,z: the rotated vector
function math3d.vec3RotateByPoint(ox, oy, oz, X, Y, Z, a, b, c)
	local x,y,z = X-ox, Y-oy, Z-oz;
	x,y,z = math3d.vec3Rotate(x, y, z, a, b, c)
	return x+ox,y+oy,z+oz
end

-- @param camx,camy,camz: camera eye position  if nil current camera is used
-- @param lookat_x,lookat_y,lookat_z: camera lookat position. if nil current camera lookat is used. 
-- return x,y,z: transform from camera space to world space, only for x,z.
function math3d.CameraToWorldSpace(dx,dy,dz, camx,camy,camz, lookat_x,lookat_y,lookat_z)
	if(not camx) then
		camx,camy,camz = ParaCamera.GetPosition();
	end
	if(not lookat_x) then 
		lookat_x,lookat_y,lookat_z = ParaCamera.GetLookAtPosition();
	end
	local cz = lookat_z - camz;
	local cy = lookat_y - camy;
	local cx = lookat_x - camx;
	local r = math.sqrt(cx*cx+cz*cz+cy*cy);
	local cr = math.sqrt(cx*cx+cz*cz);
	local ds = math.sqrt(dx*dx+dz*dz);
	local dr = math.sqrt(dx*dx+dz*dz+dy*dy);
	if(cr~=0 and ds~=0) then
		local sinC = -(cx/cr);
		local cosC = (cz/cr);
		local sinR = (dz/ds);
		local cosR = (dx/ds);
		dx = (cosR*cosC-sinR*sinC)*ds;
		dz = (sinR*cosC+cosR*sinC)*ds;
	end
	if(r~=0) then
		dy = dr * cy/r;
	end
	return dx,dy,dz;
end

-- multiply two matrix.  r = m1*m2
-- @param m1, m2: Matrix4
-- @param r: if nil, a new Matrix4 will be created and returned
-- @return: Matrix4
function math3d.MatrixMultiply(r, m1, m2)
	if(not r) then
		r = mathlib.Matrix4:new();
	end

	r[1] = m1[1] * m2[1] + m1[2] * m2[5] + m1[3] * m2[9] + m1[4] * m2[13];
	r[2] = m1[1] * m2[2] + m1[2] * m2[6] + m1[3] * m2[10] + m1[4] * m2[14];
	r[3] = m1[1] * m2[3] + m1[2] * m2[7] + m1[3] * m2[11] + m1[4] * m2[15];
	r[4] = m1[1] * m2[4] + m1[2] * m2[8] + m1[3] * m2[12] + m1[4] * m2[16];
										  
	r[5] = m1[5] * m2[1] + m1[6] * m2[5] + m1[7] * m2[9] + m1[8] * m2[13];
	r[6] = m1[5] * m2[2] + m1[6] * m2[6] + m1[7] * m2[10] + m1[8] * m2[14];
	r[7] = m1[5] * m2[3] + m1[6] * m2[7] + m1[7] * m2[11] + m1[8] * m2[15];
	r[8] = m1[5] * m2[4] + m1[6] * m2[8] + m1[7] * m2[12] + m1[8] * m2[16];
										  
	r[9] = m1[9] * m2[1] + m1[10] * m2[5] + m1[11] * m2[9] + m1[12] * m2[13];
	r[10] = m1[9] * m2[2] + m1[10] * m2[6] + m1[11] * m2[10] + m1[12] * m2[14];
	r[11] = m1[9] * m2[3] + m1[10] * m2[7] + m1[11] * m2[11] + m1[12] * m2[15];
	r[12] = m1[9] * m2[4] + m1[10] * m2[8] + m1[11] * m2[12] + m1[12] * m2[16];
										  
	r[13] = m1[13] * m2[1] + m1[14] * m2[5] + m1[15] * m2[9] + m1[16] * m2[13];
	r[14] = m1[13] * m2[2] + m1[14] * m2[6] + m1[15] * m2[10] + m1[16] * m2[14];
	r[15] = m1[13] * m2[3] + m1[14] * m2[7] + m1[15] * m2[11] + m1[16] * m2[15];
	r[16] = m1[13] * m2[4] + m1[14] * m2[8] + m1[15] * m2[12] + m1[16] * m2[16];
	return r;
end

-- column major:  r = m*v
-- @param r: output, can be nil, or v
-- @param m: Matrix4 or just array of 16 numbers.
-- @param v: vector3d or just array like {0, 1, 0}
-- @return r;
function math3d.MatrixMultiplyVector(r, m, v)
	if(not r) then
		r = mathlib.vector3d:new();
	end
	local x,y,z = v[1], v[2], v[3];
	r[1] = m[1] * x + m[2] * y + m[3] * z + m[4];
	r[2] = m[5] * x + m[6] * y + m[7] * z + m[8];
	r[3] = m[9] * x + m[10]* y + m[11] *z + m[12];	
	return r;
end

-- row major: r = v*m
-- @param r: output, can be nil, or v
-- @param v: vector3d or just array like {0, 1, 0}
-- @param m: Matrix4 or just array of 16 numbers.
-- @return r;
function math3d.VectorMultiplyMatrix(r, v, m)
	if(not r) then
		r = mathlib.vector3d:new();
	end
	local x,y,z = v[1], v[2], v[3];
	r[1] = x*m[1] + y*m[5] + z*m[9]  + m[13];
	r[2] = x*m[2] + y*m[6] + z*m[10] + m[14];
	r[3] = x*m[3] + y*m[7] + z*m[11] + m[15];
	return r;
end

-- vector 4 usually used used with projection matrix. 
-- @param v: vector3d or just array like {0, 1, 0}, however there can be a fourth element, which default to 1
-- @return r: {x,y,z,w}, which contains the fourth element. 
function math3d.Vector4MultiplyMatrix(r, v, m)
	if(not r) then
		r = mathlib.vector3d:new();
	end
	local x,y,z = v[1], v[2], v[3], v[4] or 1;
	r[1] = x*m[1] + y*m[5] + z*m[9]  + m[13];
	r[2] = x*m[2] + y*m[6] + z*m[10] + m[14];
	r[3] = x*m[3] + y*m[7] + z*m[11] + m[15];
	r[4] = x*m[3] + y*m[7] + z*m[11] + m[15];
	return r;
end