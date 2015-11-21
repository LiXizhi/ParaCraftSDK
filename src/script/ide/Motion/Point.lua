--[[
Title: Point
Author(s): Leio Zhang
Date: 2008/4/14
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Motion/Point.lua");
------------------------------------------------------------
--]]
local Point = { x = nil , y = nil };
function Point:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self;
	return o
end
commonlib.setfield("CommonCtrl.Motion.Point",Point);

function Point:clone()
	return CommonCtrl.Motion.Point:new {x=self.x,y=self.y};
end