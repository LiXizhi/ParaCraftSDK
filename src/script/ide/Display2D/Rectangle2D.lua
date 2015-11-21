--[[
Title: Rectangle2D
Author(s): Leio
Date: 2009/7/28
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Display2D/Rectangle2D.lua");
------------------------------------------------------------
]]
local Rectangle2D ={
	x = 0,
	y = 0,
	width = 0,
	height = 0,
}  
commonlib.setfield("CommonCtrl.Display2D.Rectangle2D",Rectangle2D);
function Rectangle2D:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	return o
end
--set x,y,width,height
function Rectangle2D:SetLTWH(x,y,width,height)
	self.x = x;
	self.y = y;
	self.width = width;
	self.height = height;
end
--return x,y,width,height
function Rectangle2D:GetLTWH()
	return self.x,self.y,self.width,self.height
end
--setleft,top,right,bottom
function Rectangle2D:SetLTRB(x,y,right,bottom)
	self.x = x;
	self.y = y;
	self.width = right - x;
	self.height = bottom - y;
end
--return left,top,right,bottom
function Rectangle2D:GetLTRB()
	return self:GetLeft(),self:GetTop(),self:GetRight(),self:GetBottom()
end
function Rectangle2D:GetLeft()
	return self.x;
end
function Rectangle2D:GetTop()
	return self.y;
end
function Rectangle2D:GetRight()
	return self.x + self.width;
end
function Rectangle2D:GetBottom()
	return self.y + self.height;
end
--return a boolean value
function Rectangle2D:ContainsPoint(point)
	if(not point)then return end
	local left,top = point.x,point.y;
	local self_left,self_top,self_right,self_bottom = self:GetLTRB();
	if( left >= self_left and 
		top >= self_top and
		left <= self_right and
		top <= self_bottom )then
		return true;	
	end
end
--return a boolean value
function Rectangle2D:Contains(rect)
	if(not rect)then return end
	local left,top,right,bottom = rect:GetLTRB();
	local self_left,self_top,self_right,self_bottom = self:GetLTRB();
	if( left >= self_left and 
		top >= self_top and
		right <= self_right and
		bottom <= self_bottom )then
		return true;	
	end
end
--return a boolean value
function Rectangle2D:Intersects(rect)
	if(not rect)then return false end				
	local s_left,s_top,s_right,s_bottom = self:GetLTRB();
	local left,top,right,bottom = rect:GetLTRB();
	if(math.abs(s_left + s_right - left - right) < (self.width + rect.width))then
		if(math.abs(s_top + s_bottom - top - bottom) < (self.height + rect.height))then
			return true;
		end	
	end
	return false;
end
--static funciton
function Rectangle2D.Union(rect1,rect2)
	if(not rect1 or not rect2)then return end
	local min_x = math.min(rect1:GetLeft(),rect2:GetLeft());
	local min_y = math.min(rect1:GetTop(),rect2:GetTop());
	local max_right = math.max(rect1:GetRight(),rect2:GetRight());
	local max_bottom = math.max(rect1:GetBottom(),rect2:GetBottom());
	local r = Rectangle2D.Empty();
	r:SetLTRB(min_x,min_y,max_right,max_bottom)
	return r;
end
--static funciton
function Rectangle2D.Empty()
	return CommonCtrl.Display2D.Rectangle2D:new();
end
--return a point
function Rectangle2D:GetCenter()
	local x = self.x + self.width/2;
	local y = self.y + self.height/2;
	return {x = x, y = y};
end
function Rectangle2D:Inflate(dx,dy)
	dx = dx or 0;
	dy = dy or 0;
	self.x = self.x - dx;
	self.width = self.width + 2 * dx;
	
	self.y = self.y - dy;
	self.height = self.height + 2 * dy;
end
function Rectangle2D:ToTable()
	return {self.x,self.y,self.width,self.height,
			"||",self:GetLeft(),self:GetTop(),self:GetRight(),self:GetBottom()};
end
