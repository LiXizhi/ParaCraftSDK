--[[
Title: a similar implementation as STL (Standard Libaray) in NPL
Author(s): LiXizhi
Date: 2014.7.8
Desc:  array list, it is just a standard lua table with some helper functions to behave more 
like a stl OrderedArraySet. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/STL.lua");
---++ OrderedArraySet(ArrayList) example
local array = commonlib.OrderedArraySet:new();
array:add(1);
array:add(2);
echo(array:size())
array:removeByValue(1);
echo(array:size())
-------------------------------------------------------
]]
local table_insert = table.insert;
local table_remove = table.remove;
local type, ipairs, pairs, unpack = type, ipairs, pairs, unpack;

------------------------------------------------
-- OrderedArraySet: 
------------------------------------------------
local OrderedArraySet = commonlib.gettable("commonlib.OrderedArraySet");

function OrderedArraySet:new(o)
   	local object = o or {};
	setmetatable(object, self);
	self.__index = self;
	object.value_set = {};
	return object;
end

-- clone the array, please note it does not clone the value (value are referenced)
function OrderedArraySet:clone()
	local value_set = {};
	local o = {value_set = value_set};
	for k,v in pairs(self.value_set) do
		value_set[k] = v;	
	end
	for i = 1, #self do
		o[i] = self[i];	
	end
	setmetatable(o, OrderedArraySet);
	return o;
end

function OrderedArraySet:insert(pos, value)
	if (self.value_set[value] == nil) then
		table.insert(self, pos, value);
		self.value_set[value] = pos or #self;
		for i=pos+1, #self do
			self.value_set[i] = i;
		end
		return value;
	end
end

-- check if it contains a given value. 
function OrderedArraySet:contains(value)
	return self.value_set[value] ~= nil;
end

function OrderedArraySet:clear()
	if(#self > 0) then
		for i=#(self), 1, -1 do
			self[i] = nil;
		end
		self.value_set = {};
	end
	return self;
end

function OrderedArraySet:size()
	return #(self);
end

-- decrease the size of the array
function OrderedArraySet:resize(newSize)
	local value_set = self.value_set;
	for i=#self, newSize+1, -1 do
		value_set[self[i]] = nil;
		self[i] = nil;
	end
end

-- test if empty
function OrderedArraySet:empty()
	return (#self) == 0;
end

-- get the given index. 
function OrderedArraySet:get(nIndex)
	return self[nIndex];
end

-- this is slow
function OrderedArraySet:add(value)
	if (self.value_set[value] == nil) then
		self[(#self) + 1] = value;
		self.value_set[value] = #self;
	end
	return self;
end

-- alias
OrderedArraySet.push_back = OrderedArraySet.add;

-- add all items to the end of the array list. 
-- @param arrayList: another array table or OrderedArraySet. 
function OrderedArraySet:AddAll(arrayList)
	if(arrayList) then
		for i=1, #arrayList do
			self:push_back(arrayList[i]);
		end
	end
end

-- this is slow
-- return the index being removed.  or nil if not found. 
function OrderedArraySet:removeByValue(value)
	local index = self.value_set[value]
	if index then
		return self:remove(index);
	end
end

-- this is slow
function OrderedArraySet:remove(index)
	local v = self[index];
	local value_set = self.value_set;
	if(v~=nil) then
		value_set[v] = nil;
	end
	
	for k=index, #self do
		local nextValue = self[k+1];
		self[k] = nextValue;
		if(nextValue~=nil) then
			value_set[nextValue] = k;
		end
	end
end

function OrderedArraySet:first()
	return self[1];
end