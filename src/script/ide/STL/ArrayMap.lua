--[[
Title: Array map
Author(s): LiXizhi
Date: 2015.6.13
Desc: it is both an array and a key-value map. key must be unique. 
The difference is that we can sort element(key-value pair) in any order we like and access them 

Mainly used for priority queue. 

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/STL.lua");
local array = commonlib.ArrayMap:new();
array[1] = "1";
array[10] = "10";
array[3] = "3";
assert(array[10] == "10");
assert(array:at(2) == "10");
-- auto create multi-dimentional array. 
local v = array:createget(5);
v[1] = "51"
v[2] = "52"
assert(array[5][1] == "51");
array[5] = nil;
array:add("4"); -- add with default index
array:ksort(); -- sort by key

for key, value in array:pairs() do
	echo({key, value})
end
-------------------------------------------------------
]]
local type, ipairs, pairs, unpack = type, ipairs, pairs, unpack;
local next = next;
local rawget = rawget;

local ArrayMap = commonlib.gettable("commonlib.ArrayMap");

local commonlib = commonlib;

function ArrayMap:new(o)
   	o = o or {};
	o.key_map = {};
	o.key_index_map = {};
	o.key_array = {};
	setmetatable(o, self);
	return o;
end

-- do not modify the returned array
function ArrayMap:get_array()
	return self.key_array;
end

-- do not modify the returned map
function ArrayMap:get_map()
	return self.key_map;
end

-- check if it contains a given key 
function ArrayMap:contains(key)
	return (self.key_map[key] ~= nil) 
end

function ArrayMap:clear()
	commonlib.cleartable(self.key_map);
	table.resize(self.key_array, 0);
	commonlib.cleartable(self.key_index_map);
	self.free_index = 0;
	return self;
end

function ArrayMap:size()
	return #(self.key_array);
end

-- test if empty
function ArrayMap:empty()
	return (#(self.key_array)) == 0;
end

-- return value by key 
function ArrayMap:get(key)
	return self.key_map[key];
end

-- return value by key 
function ArrayMap:createget(key)
	local v = self.key_map[key];
	if(not v) then
		v = ArrayMap:new();
		self[key]= v;
	end
	return v;
end

-- return value by index
function ArrayMap:at(index)
	local key = self.key_array[index];
	if(key~=nil) then
		return self.key_map[key];
	end
end

function ArrayMap:first()
	return self:at(1);
end

function ArrayMap:last()
	local size = self:size();
	if(size) then
		return self:at(self:size());
	end
end

-- it will replace old key value pair
-- @param key: if no key is provided, the key is the last index. 
-- @param value: if value is nil, value is key, and key is (self:size()+1)
-- e.g.  
--		self:add(nil, value) is same as self:add(value) or self:add(self:size()+1, value)
function ArrayMap:add(key, value)
	if(not key) then
		key = self:size() + 1;
	end
	if(value==nil) then
		value = key;
		key = self:size() + 1;
	end
	if(value~=nil and key) then
		if(not self.key_map[key]) then
			local idx = #self.key_array+1;
			self.key_array[idx] = key;
			self.key_index_map[key] = idx;
		end
		self.key_map[key] = value;
	end
end

-- get index of the given key
function ArrayMap:getIndex(key)
	return self.key_index_map[key];
end

function ArrayMap:remove(key)
	if(self.key_index_map[key]) then
		self.key_map[key] = nil;
		local idx = self.key_index_map[key];
		self.key_index_map[key] = nil;
		if(idx == #(self.key_array)) then
			self.key_array[idx] = nil;
		else
			self.key_array[idx] = self.key_array[#self.key_array];
			self.key_array[#self.key_array] = nil;
		end
	end
end

-- @return key, value pair that is poped. 
function ArrayMap:pop()
	local key = self.key_array[#self.key_array];
	if(key~=nil) then
		local value = self.key_map[key];
		self:remove(key);
		return key, value;
	end
end

-- if the key already exist it will return nil. Use add() if you want to push or replace existing value. 
-- @param value: if value is nil, value is key, and key is (self:size()+1)
-- return true if element is added to the last
function ArrayMap:push(key, value)
	if(value==nil) then
		value = key;
		key = self:size() + 1;
	end
	if(value~=nil) then
		if(not self.key_map[key]) then
			local idx = #self.key_array+1;
			self.key_array[idx] = key;
			self.key_index_map[key] = idx;
			self.key_map[key] = value;
			return true;
		end
	end
end

-- sort by key
-- @param compare_func: same as table.sort()'s compare function. function(a, b) end.
function ArrayMap:ksort(compare_func)
	table.sort(self.key_array, compare_func);

	for idx, key in ipairs(self.key_array) do
		self.key_index_map[key] = idx;
	end
end


-- return iteractor of key, value pairs in current array order
function ArrayMap:pairs()
	local idx = 1;
	local key_map = self.key_map;
	local key_array = self.key_array;
	return function()
		local key = key_array[idx];
		if(key) then
			idx = idx + 1;
			return key, key_map[key];
		end
	end
end

function ArrayMap.__index(t, key)
	local func = rawget(t, key) or ArrayMap[key];
	if(func) then
		return func;
	else
		return rawget(t, "key_map")[key];
	end
end

function ArrayMap.__newindex(t, key, value)
	if(value ~= nil) then
		return ArrayMap.add(t, key, value);
	else
		return ArrayMap.remove(t, key);
	end
end