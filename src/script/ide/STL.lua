--[[
Title: a similar implementation as STL (Standard Libaray) in NPL
Author(s): LiXizhi
Date: 2007/9/22 (stack), 2008/2/7(queue), 2009.10.8(List, LinkedList)
Desc: Uses a table as stack, use <table>:push(value) and <table>:pop()
Lua 5.1 compatible
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/STL.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/STL/Stack.lua");
NPL.load("(gl)script/ide/STL/Queue.lua");
NPL.load("(gl)script/ide/STL/List.lua");
NPL.load("(gl)script/ide/STL/LinkedList.lua");
NPL.load("(gl)script/ide/STL/Array.lua");
NPL.load("(gl)script/ide/STL/UnorderedArray.lua");
NPL.load("(gl)script/ide/STL/UnorderedArraySet.lua");
NPL.load("(gl)script/ide/STL/OrderedArraySet.lua");
NPL.load("(gl)script/ide/STL/RingBuffer.lua");
NPL.load("(gl)script/ide/STL/ArrayMap.lua");
