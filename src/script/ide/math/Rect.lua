--[[
Title: Rect math
Author(s): LiXizhi
Date: 2015/4/21
Desc: ported from ParaEngine C++ code
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/math/Rect.lua");
local Rect = commonlib.gettable("mathlib.Rect");
local r1 = Rect:new():init(0, 0, 100, 20);
echo({r1:contains(100, 0) == true, r1:contains(101, 0) == false})
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/math/Point.lua");
NPL.load("(gl)script/ide/STL/RingBuffer.lua");
local temp_pool = commonlib.RingBuffer:new(); 
local Point = commonlib.gettable("mathlib.Point");
local Rect = commonlib.createtable("mathlib.Rect", {
	xp = 0, yp=0, w=0, h=0,
});
Rect.__index = Rect;

-- create a new rect
function Rect:new(o)
	o = o or {};
	return setmetatable(o, Rect);
end

function Rect:new_from_pool(x,y,width, height)
	if(temp_pool:size() >= 2000) then
		return temp_pool:next():init(x,y, width, height);
	else
		return temp_pool:add(Rect:new():init(x,y, width, height));
	end
end

-- make a clone 
function Rect:clone()
    return Rect:new():assign(self);
end

function Rect:clone_from_pool()
	return self:new_from_pool(self.xp, self.yp, self.w, self.h);
end

function Rect:init(x, y, w, h)
	self.xp, self.yp, self.w, self.h = x, y, w, h;
	return self;
end

function Rect:assign(fromRc)
	self.xp, self.yp, self.w, self.h = fromRc.xp, fromRc.yp, fromRc.w, fromRc.h;
	return self;
end

function Rect:isNull()
	return self.w == 0 and self.h == 0;
end

function Rect:isEmpty()
	return self.w <= 0 and self.h <= 0;
end

function Rect:isValid()
	return self.w >= 0 and self.h >= 0;
end

function Rect:left()
	return self.xp;
end

function Rect:top()
	return self.yp;
end

function Rect:right()
	return self.xp + self.w;
end

function Rect:bottom()
	return self.yp + self.h;
end

function Rect:x()
	return self.xp;
end
function Rect:y()
	return self.yp;
end

function Rect:setX(x)
	self.xp = x or self.xp;
end

function Rect:setY(y)
	self.yp = y or self.yp;
end

function Rect:setRight(pos)
	self.w = pos - self.xp;
end

function Rect:setBottom(pos)
	self.h = pos - self.yp;
end

function Rect:setRect(x, y, w, h)
	self.xp, self.yp, self.w, self.h = x, y, w, h;
end

function Rect:getRect()
	return self.xp, self.yp, self.w, self.h;
end

function Rect:width()
	return self.w;
end

function Rect:height()
	return self.h;
end

function Rect:topLeft() 
	return self.xp, self.yp;
end

function Rect:bottomRight() 
	return self.xp + self.w, self.yp + self.h;
end

function Rect:topRight() 
	return self.xp + self.w, self.yp;
end

function Rect:bottomLeft() 
	return self.xp, self.yp + self.h;
end

function Rect:setSize(w, h)
	self.w, self.h = w, h;
end

-- @param x,y: {0,0} or 0,0
-- Returns true if the given point is inside or on the edge of the rectangle; otherwise returns false.
function Rect:contains(x, y)
	if(not y) then
		y = x[2];
		x = x[1];
	end
	local l = self.xp;
	local r = l;
	if (self.w < 0) then
		l = l + self.w;
	else
		r = r + self.w;
	end

	-- null rect
	if (l == r)  then
		return false;
	end

	if (x < l or x > r) then
		return false;
	end

	local t = self.yp;
	local b = t;
	if (self.h < 0) then
		t = t + self.h;
	else
		b = b + self.h;
	end
	if (t == b) then -- null rect
		return false;
	end

	if (y < t or y > b) then
		return false;
	end

	return true;
end
