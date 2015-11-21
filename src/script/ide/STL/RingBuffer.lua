--[[
Title: ring buffer
Author(s): LiXizhi
Date: 2015/4/21
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/STL/RingBuffer.lua");
local ring = commonlib.RingBuffer:new(); 
ring:add(10);
ring:add(20);
echo({ring, ring:next(), ring:next(), ring:next()});
-------------------------------------------------------
]]
local table_insert = table.insert;
local table_remove = table.remove;
local type, ipairs, pairs, unpack = type, ipairs, pairs, unpack;

local RingBuffer = commonlib.gettable("commonlib.RingBuffer");
RingBuffer.__index = RingBuffer;

function RingBuffer:new(o)
	o = o or {};
	o.current = 1;
	return setmetatable(o, RingBuffer);
end

function RingBuffer:add(item)
	if item then 
		self[#self+1] = item;
		return item;
	end
end

function RingBuffer:remove(k)
	if(k) then
		-- wrap position
		local pos = (self.current + k) % #self;

		-- remove item
		local item = table.remove(self, pos)

		-- possibly adjust current pointer
		if pos < self.current then self.current = self.current - 1 end
		if self.current > #self then self.current = 1 end

		-- return item
		return item
	else
		return table.remove(self, self.current)
	end
end

function RingBuffer:get()
	return self[self.current]
end

function RingBuffer:size()
	return #self
end

function RingBuffer:next()
	self.current = (self.current % #self) + 1
	return self:get()
end

function RingBuffer:prev()
	self.current = self.current - 1
	if self.current < 1 then
		self.current = #self
	end
	return self:get()
end