--[[
Title: vector2d and Point math
Author(s): LiXizhi
Date: 2015/4/21
Desc: We only provide limited and lightweighted interface of vectors in 2d. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/math/Point.lua");
local Point = commonlib.gettable("mathlib.Point");
local p1 = Point:new():init(0,0);
local p2 = Point:new_from_pool(9,0);
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/STL/RingBuffer.lua");
local temp_pool = commonlib.RingBuffer:new(); 
local type = type;
local Point = commonlib.gettable("mathlib.Point");
Point.__index = Point;

-- create a new point
-- @param x,y: if y is nil, x should be table or nil. 
function Point:new(x, y)
	local o;
	if(y) then
		o = {x, y};
	else
		o = x or {0,0};
	end
	setmetatable(o, self);
	return o;
end

function Point:init(x,y)
	self[1], self[2] = x or 0, y or 0;
	return self;
end

-- this is actually a ring buffer of 200, pay attention not to reach over this value in recursive calls. 
function Point:new_from_pool(x,y)
	if(temp_pool:size() >= 2000) then
		return temp_pool:next():init(x,y);
	else
		return temp_pool:add(Point:new():init(x,y));
	end
end

-- make a clone 
function Point:clone()
    return Point:new(self[1], self[2]);
end

function Point:clone_from_pool()
	return self:new_from_pool(self[1], self[2]);
end

function Point:x()
	return self[1];
end

function Point:y()
	return self[2];
end

-- get length
function Point:length()
	local len_sq = self:length2();
	if(len_sq>0) then
		return len_sq^0.5;
	else
		return 0;
	end
end

-- get length square
function Point:length2()
	return (self[1]^2 + self[2]^2);
end

function Point:normalize()
    local m = self:length()
    if m > 0.00001 then
        m = 1/m
        self[1] = self[1] * m
        self[2] = self[2] * m
        
    else
        self[1] = 0
        self[2] = 0
    end
    return self
end

function Point:set(x,y)
    if y == nil then
        self[1] = x[1]
        self[2] = x[2]
    else
        self[1] = x
        self[2] = y
    end
end

function Point:add(x,y)
    if y == nil then
        self[1] = self[1] + x[1]
        self[2] = self[2] + x[2]
    else
        self[1] = self[1] + x
        self[2] = self[2] + y
    end
end

function Point.__add(a,b)
	return Point:new(a[1]+b[1], a[2]+b[2])
end

function Point:interpolate(x,y,a)
    self[1] = self[1] + (x - self[1]) * a
    self[2] = self[2] + (y - self[2]) * a
    return self
end

function Point:sub(x,y)
    if y == nil then
        self[1] = self[1] - x[1]
        self[2] = self[2] - x[2]
    else
        self[1] = self[1] - x
        self[2] = self[2] - y
    end
end

function Point.__sub(a,b)
	return Point:new(a[1]-b[1], a[2]-b[2])
end

function Point:MulByFloat(a)
    self[1] = self[1] * a
    self[2] = self[2] * a
end

function Point.__mul(a,b)
	return Point:new(a[1] * b, a[2] * b)
end

-- @param x can be number or another vector 
function Point:dot(x,y)
    if not y then
        return self[1] * x[1] + self[2] * x[2]
    else
        return self[1] * x + self[2] * y
    end
end

function Point:get()
    return self[1],self[2],self[3]
end

-- distance square to a point
-- @param x can be number or another vector 
function Point:dist2(x,y)
    if not y then 
		return ((self[1]-x[1])^2 + (self[2]-x[2])^2);
	else
		return ((self[1]-x)^2 + (self[2]-y)^2);
	end
end

-- distance to a point
-- note param y can be nil. 
function Point:dist(x,y)
	local len_sq =  self:dist2(x,y,z);
    if(len_sq>0) then
		return len_sq^0.5;
	else
		return 0;
	end
end

function Point:tostring()
    return format("%f %f",self[1],self[2])
end

function Point:compare(v)
	return (self[1] == v[1] and self[2] == v[2]);
end

function Point:equals(v)
	return (self[1] == v[1] and self[2] == v[2]);
end


-- some static members.
Point.unit_x = Point:new(1,0);
Point.unit_y = Point:new(0,1);
Point.zero = Point:new(0, 0);