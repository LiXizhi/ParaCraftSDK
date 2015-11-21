--[[
Title: a similar implementation as STL (Standard Libaray) in NPL
Author(s): LiXizhi
Date: 2008/2/7
Desc: 
Lua 5.1 compatible
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/STL.lua");
---+++ queue example
local q = commonlib.Queue:new(); 
q:pushleft("A"); 
log(q:popright())
-------------------------------------------------------
]]
local table_insert = table.insert;
local table_remove = table.remove;
local type, ipairs, pairs, unpack = type, ipairs, pairs, unpack;

------------------------------------------------
-- queue: from official LUA site
------------------------------------------------
local Queue = commonlib.gettable("commonlib.Queue");

Queue.__index = Queue;

function Queue:new()
	local object = {first = 0, last = -1};
	setmetatable(object, Queue)
	return object;
end

function Queue:pushleft(value)
  local first = self.first - 1
  self.first = first
  self[first] = value
end

function Queue:pushright(value)
  local last = self.last + 1
  self.last = last
  self[last] = value
end
--  
Queue.push_back = Queue.pushright;
Queue.push = Queue.pushright;

function Queue:popleft()
  local first = self.first
  if first > self.last then 
	log("Queue is empty\n") 
	return
  end
  local value = self[first]
  self[first] = nil        -- to allow garbage collection
  self.first = first + 1
  return value
end
-- alias
Queue.pop = Queue.popleft;

function Queue:popright()
  local last = self.last
  if self.first > last then 
    log("Queue is empty\n") 
    return
  end
  local value = self[last]
  self[last] = nil         -- to allow garbage collection
  self.last = last - 1
  return value
end

function Queue:empty()
	return self.first > self.last;
end

function Queue:size()
	if(self.first <= self.last) then
		return self.last - self.first + 1;
	else
		return 0;
	end
end

-- get the top/left item. or nil if no item.
function Queue:front()
	if self.first <= self.last then 
		return self[self.first];
	end
end