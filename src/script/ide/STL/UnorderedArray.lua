--[[
Title: a similar implementation as STL (Standard Libaray) in NPL
Author(s): LiXizhi
Date: 2014.7.10
Desc:  array list, this similar to vector array, except that insert/remove is faster because the order is not maintained. 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/STL.lua");
---++ UnorderedArray(ArrayList) example
local array = commonlib.UnorderedArray:new();
array:add(1);
array:add(2);
local i = 1;
while i<=#array do
	if(array[i] == 1) then
		array:remove(i);
	else
		i = i + 1;
	end
end
echo(array:size())
array:remove(1);
echo(array:size())
-------------------------------------------------------
]]
local table_insert = table.insert;
local table_remove = table.remove;
local type, ipairs, pairs, unpack = type, ipairs, pairs, unpack;

------------------------------------------------
-- UnorderedArray: 
------------------------------------------------
local UnorderedArray = commonlib.gettable("commonlib.UnorderedArray");

function UnorderedArray:new(o)
   	local object = o or {};
	setmetatable(object, self);
	self.__index = self;
	return object;
end

function UnorderedArray:insert(pos, elem, n)
	if not n then
		table.insert(self, pos, elem);
	else
		for i = pos, pos + n do
			table.insert(self, i, elem);
		end
	end
end

-- check if it contains a given value. this can be slow. 
-- use UnorderedArraySet for a faster version. 
function UnorderedArray:contains(value)
	for i=1, #self do
		if(self[i] == value) then
			return true;
		end
	end
end

-- clone the array, please note it does not clone the value (value are referenced)
function UnorderedArray:clone()
	local o = {};
	for i = 1, #self do
		o[i] = self[i];	
	end
	setmetatable(o, UnorderedArray);
	return o;
end

function UnorderedArray:clear()
	for i=#(self), 1, -1 do
		self[i] = nil;
	end
	return self;
end

function UnorderedArray:size()
	return #(self);
end

-- decrease the size of the array
function UnorderedArray:resize(newSize)
	local i
	for i=#self, newSize+1, -1 do
		self[i] = nil;
	end
end

-- test if empty
function UnorderedArray:empty()
	return (#self) == 0;
end

-- get the given index. 
function UnorderedArray:get(nIndex)
	return self[nIndex];
end

function UnorderedArray:push_back(elem)
	self[(#self) + 1] = elem;
	return self;
end

-- remove and return the last object. 
function UnorderedArray:pop_back()
	local nCount = #self;
	local elem = self[nCount];
	self[nCount] = nil;
	return elem;
end


function UnorderedArray:remove(index)
	local size = #self
	if index == size then
		self[size] = nil
	elseif (index > 0) and (index < size) then
		self[index], self[size] = self[size], nil
	end
end

-- this is not fast.  Use UnorderedArraySet for faster ones. 
function UnorderedArray:removeByValue(value)
	for i=1, #self do
		if(self[i] == value) then
			self:remove(i)
			return true;
		end
	end
end

-- remove howmany number of item at given index. and add item1,item2, item3 to the given index. 
-- @param index: the position where to remove or insert items. 
-- @param howmany:  how many items to remove at index. if nil, means 1. 
-- @param item1, item2, item3: nil or new items to insert at the given index. 
function UnorderedArray:splice(index, howmany, item1, item2, item3)
	if(not howmany or howmany == 1) then
		self:remove(index);
	else
		for i=1, howmany do
			self:remove(index);
		end
	end
	if(item1) then
		self:insert(index, item1);
		if(item2) then
			self:insert(index, item2);
			if(item3) then
				self:insert(index, item3);
			end
		end
	end
end

function UnorderedArray:first()
	return self[1];
end

-- alias
UnorderedArray.add = UnorderedArray.push_back;

-- add all items to the end of the array list. 
-- @param arrayList: another array table or UnorderedArray. 
function UnorderedArray:AddAll(arrayList)
	if(arrayList) then
		for i=1, #arrayList do
			self:push_back(arrayList[i]);
		end
	end
end
