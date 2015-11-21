--[[
Title: a similar implementation as STL (Standard Libaray) in NPL
Author(s): LiXizhi
Date: 2009.10.8(List, LinkedList)
Desc: unlike commonlib.Link, it uses seperate tables for data keeping, therefore data item can be any type. 
Lua 5.1 compatible
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/STL.lua");
---+++ LinkedList example
local list = commonlib.LinkedList:new();
list:add({"item1"})
list:add({"item2"})
list:add({"item3"})
local item = list:first();
list:remove(item.next);
item = list:first();
while (item) do
	commonlib.echo(item[1])
	item = list:next(item)
end
echo(list:Clone():size())
-------------------------------------------------------
]]
local table_getn = table.getn;
local table_insert = table.insert;
local table_remove = table.remove;
local type, ipairs, pairs, unpack = type, ipairs, pairs, unpack;

------------------------------------------------
-- linked list: 
------------------------------------------------
local LinkedList = commonlib.gettable("commonlib.LinkedList");

function LinkedList:new()
    local head = {prev = nil, next = nil, data = nil}
	local object = {list = head, tail = nil}
	setmetatable(object, {__index = self})
	return object
end

function LinkedList:next()
	local l = self.list
	return 	function ()
				l = l.next
				return l and l.data or nil
			end
end

function LinkedList:prev()
    local l = self.tail or self.list
    local data
    return 	function ()
                data = l and l.data or nil
				l = l and l.prev or nil
				return data
			end
end

function LinkedList:add(...)
	local nCount = select("#",...);
	for i = 1,  nCount do
        if self.tail == nil then
            self.tail = {prev = self.list, next = nil, data = select(i,...) }
            self.list.next = self.tail
        else
            self.tail.next = {prev = self.tail, next = nil, data = select(i,...) }
            self.tail = self.tail.next
        end

	end
	return self.tail
end

function LinkedList:addToHead(...)
	local nCount = select("#",...);
    for i = 1, nCount do
        if self.tail == nil then
            self.tail = {prev = self.list, next = nil, data = select(i,...) }
            self.list.next = self.tail     	    
		else
		    local head = self.list
    	    local h  = {prev = nil, next = head.next, data = select(i,...) }
    		head.next = h
    		h.next.prev = h
		end
	end
end

function LinkedList:remove(item)
    local head = self.list
	while head ~= nil and head.data ~= item do
		head = head.next
	end

	if head == nil then return end
	if head.prev ~= nil then 
        head.prev.next = head.next 
    end
	if head.next ~= nil then 
        head.next.prev = head.prev
    elseif head == self.tail then
        self.tail = head.prev  
    end
end

function LinkedList:size()
    local head = self.list
    local count = 0
	while head.next do
		head = head.next
        count = count + 1
	end
    return count
end

function LinkedList:delete()
	self.list = nil
	return nil
end

--[[
function LinkedList:test()
	--test the list
	
	local list = self:new()
	local removeMe1 = "remove me"
	local removeMe2 = "abc"
	-- add some items to the list
	list:add("abc", 23,{},function() end)
	list:add(removeMe1)
	list:add("this", "is","the","end")
	list:add("final element")

	--list:add("abc", 23,{},function() end)

    for v in list:next() do
		print(v)
	end 
	--print them out

	print("size of list before removing: " .. list:size())
	print("removing element: " .. removeMe1 .. ", " .. removeMe2)
	list:remove(removeMe1)
	list:remove(removeMe2)
	print("size of list after removing: " .. list:size())

	
	-- now delete the list
	list:delete()
end
]]
