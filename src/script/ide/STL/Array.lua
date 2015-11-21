--[[
Title: a similar implementation as STL (Standard Libaray) in NPL
Author(s): LiXizhi
Date: 2014.7.8
Desc:  array list, it is just a standard lua table with some helper functions to behave more 
like a stl vector. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/STL.lua");
---++ vector(ArrayList) example
local array = commonlib.vector:new();
local array = commonlib.Array:new();
array:add(1);
array:add(2);
echo(array:size())
array:clear();
echo(array:size())
-------------------------------------------------------
]]
local table_getn = table.getn;
local table_insert = table.insert;
local table_remove = table.remove;
local type, ipairs, pairs, unpack = type, ipairs, pairs, unpack;

------------------------------------------------
-- vector/Array: 
------------------------------------------------
local vector = commonlib.gettable("commonlib.vector");
commonlib.Array = vector;
vector.__index = vector;

function vector:new(o)
   	local object = o or {};
	setmetatable(object, self);
	return object;
end

-- clone the array, please note it does not clone the value (value are referenced)
function vector:clone()
	local o = {};
	for i = 1, #self do
		o[i] = self[i];	
	end
	setmetatable(o, vector);
	return o;
end

function vector:insert(pos, elem, n)
	if not n then
		table.insert(self, pos, elem);
	else
		for i = pos, pos + n do
			table.insert(self, i, elem);
		end
	end
end

-- check if it contains a given value. 
function vector:contains(value)
	for i=1, #self do
		if(self[i] == value) then
			return true;
		end
	end
end

function vector:clear()
	for i=#(self), 1, -1 do
		self[i] = nil;
	end
	return self;
end

function vector:size()
	return #(self);
end

-- decrease the size of the array
function vector:resize(newSize)
	local i
	for i=#self, newSize+1, -1 do
		self[i] = nil;
	end
end

-- test if empty
function vector:empty()
	return (#self) == 0;
end

-- get the given index. 
function vector:get(nIndex)
	return self[nIndex];
end

function vector:push_back(elem)
	self[(#self) + 1] = elem;
	return self;
end

-- alias
vector.add = vector.push_back;
vector.append = vector.push_back;

function vector:push_front(elem)
	table.insert(self, 1, elem);
end

-- alias
vector.prepend = vector.push_front;

-- add all items to the end of the array list. 
-- @param arrayList: another array table or vector. 
function vector:AddAll(arrayList)
	if(arrayList) then
		for i=1, #arrayList do
			self:push_back(arrayList[i]);
		end
	end
end

-- this could be slow. use UnorderedArray for faster ones. 
function vector:remove(index)
	for k=index, #self do
		self[k] = self[k+1];
	end
end

-- this is not fast.  Use UnorderedArraySet for faster ones. 
function vector:removeByValue(value)
	for i=1, #self do
		if(self[i] == value) then
			self:remove(i)
			return true;
		end
	end
end

function vector:removeAll(value)
	while (self:removeByValue(value)) do
	end
end

function vector:first()
	return self[1];
end

function vector:last()
	return self[#self];
end