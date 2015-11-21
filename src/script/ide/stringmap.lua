--[[
Title: bidirectional string map
Author(s):  LiXizhi
Date: 2008/12/28
Desc: 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/stringmap.lua");
local myStringMap = commonlib.stringmap:new()
myStringMap:add("A", 1);
myStringMap:add("B", 2);
myStringMap:add("C");
myStringMap:add("D");
print(myStringMap:GetString(3))  --> "C"
print(myStringMap:GetID("D"))    --> 4

local myStringMap = commonlib.stringmap:new({
	"A",
	"B",
	"C",
	"D",
})
print(myStringMap(3))  --> "C"
print(myStringMap("D"))    --> 4
------------------------------------------------------------
]]

if(not commonlib.stringmap) then commonlib.stringmap={} end
local stringmap = commonlib.stringmap;

-- a new string map
-- @param o: o can be a table array of strings, where the reverse string to id map will be automatically generated. 
function stringmap:new (id2str)
	local o = {};
	o.id2str = id2str or {}   -- create object if user does not provide one
	o.str2id = {};
	setmetatable(o, self)
	self.__index = self
	o:Rebuild();
	return o
end

-- auto return mapping according to input type
-- @param input: a string
-- @return output 
function stringmap:__call(input)
	if(type(input) == "number") then
		return self.id2str[input];
	elseif(type(input) == "string") then
		return self.str2id[input];
	end	
end

-- add/(or remove) a new str, id entry to the string map
-- str, id can not be nil at the same time. 
-- @param str: if can be nil to delete string at id. 
-- @param id: if nil, it is auto assigned the next available id. 
function stringmap:add(str, id)
	id = id or (#(self.id2str) + 1);
	if(str) then
		self.str2id[str] = id;
	end
	self.id2str[id] = str;
end

-- regenerate str2id table according to id2str
function stringmap:Rebuild()
	local id, str
	for id, str in ipairs(self.id2str) do
		self.str2id[str] = id;
	end
end

-- get string by id
function stringmap:GetString(input)
	return self.id2str[input];
end

-- get id by string
function stringmap:GetID(input)
	return self.str2id[input];
end

-- if input is already string, it will be returned. if not, it will be converted if possible. 
function stringmap:ConvertToString(input)
	if(type(input) == "number") then
		return self.id2str[input];
	else
		return input;
	end
end

-- if input is already ID, it will be returned. if not, it will be converted if possible. 
function stringmap:ConvertToID(input)
	if(type(input) == "string") then
		return self.str2id[input];
	else
		return input;
	end
end
