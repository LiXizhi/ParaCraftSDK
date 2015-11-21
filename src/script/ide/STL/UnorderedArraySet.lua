--[[
Title: a similar implementation as STL (Standard Libaray) in NPL
Author(s): LiXizhi
Date: 2014.7.10
Desc:  array list, this similar to UnorderedArray, except that we can find/fetch by value very fast, 
because it maintains an internal set for array values. the cost is one additional set table. 
PLEASE NOTE: all values in the array set are unique. use UnorderedArray if not unique. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/STL.lua");
---++ UnorderedArraySet(ArrayList) example
local array = commonlib.UnorderedArraySet:new();
array:add("1");
array:add(2);

local i = 1;
while i<=#array do
	if(array[i] == "1") then
		array:remove(i);
	else
		i = i + 1;
	end
end

echo(array:size())
array:removeByValue("1");
array:remove(1);
echo(array:size())

-------------------------------------------------------
]]
local table_insert = table.insert;
local table_remove = table.remove;
local type, ipairs, pairs, unpack = type, ipairs, pairs, unpack;

------------------------------------------------
-- UnorderedArraySet: 
------------------------------------------------
local UnorderedArraySet = commonlib.gettable("commonlib.UnorderedArraySet");

function UnorderedArraySet:new(o)
   	local object = o or {};
	setmetatable(object, self);
	self.__index = self;
	object.value_set = {};
	return object;
end

function UnorderedArraySet:clear()
	if(#self > 0) then
		for i=#(self), 1, -1 do
			self[i] = nil;
		end
		self.value_set = {};
	end
	return self;
end

function UnorderedArraySet:size()
	return #(self);
end

-- clone the array, please note it does not clone the value (value are referenced)
function UnorderedArraySet:clone()
	local value_set = {};
	local o = {value_set = value_set};
	for k,v in pairs(self.value_set) do
		value_set[k] = v;	
	end
	for i = 1, #self do
		o[i] = self[i];	
	end
	setmetatable(o, UnorderedArraySet);
	return o;
end

-- decrease the size of the array
function UnorderedArraySet:resize(newSize)
	local value_set = self.value_set;
	for i=#self, newSize+1, -1 do
		value_set[self[i]] = nil;
		self[i] = nil;
	end
end

-- test if empty
function UnorderedArraySet:empty()
	return (#self) == 0;
end

-- get the given index. 
function UnorderedArraySet:get(nIndex)
	return self[nIndex];
end

-- add all items to the end of the array list. 
-- @param arrayList: another array table or UnorderedArraySet. 
function UnorderedArraySet:AddAll(arrayList)
	if(arrayList) then
		for i=1, #arrayList do
			self:push_back(arrayList[i]);
		end
	end
end

-- check if it contains a given value. 
function UnorderedArraySet:contains(value)
	return self.value_set[value] ~= nil;
end

-- value must be unqiue
function UnorderedArraySet:add(value)
	if (self.value_set[value] == nil) then
		self[#self+1] = value;
		self.value_set[value] = #self;
		return value
	end
end
-- alias
UnorderedArraySet.push_back = UnorderedArraySet.add;

-- return the index being removed.  or nil if not found. 
function UnorderedArraySet:removeByValue(value)
	local index = self.value_set[value]
	if index then
		local size = #self
		if index ~= size then
			local last_value = self[size]
			self[index], self.value_set[last_value] = last_value, index
		end
		self.value_set[value] = nil
		self[size] = nil
		return index;
	end
end

function UnorderedArraySet:remove(index)
	return self:removeByValue(self[index]);
end

function UnorderedArraySet:first()
	return self[1];
end