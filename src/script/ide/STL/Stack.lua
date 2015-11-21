--[[
Title: a similar implementation as STL (Standard Libaray) in NPL
Author(s): LiXizhi
Date: 2007/9/22 (stack)
Desc: Uses a table as stack, use <table>:push(value) and <table>:pop()
Lua 5.1 compatible
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/STL.lua");
---+++ create stack
stack = commonlib.Stack:Create()
-- push values on to the stack
stack:commonlib.push("a", "b")
-- pop values
commonlib.stack:pop(2)
-------------------------------------------------------
]]
local table_insert = table.insert;
local table_remove = table.remove;
local type, ipairs, pairs, unpack = type, ipairs, pairs, unpack;

------------------------------------------------
-- stack
------------------------------------------------
local Stack = commonlib.gettable("commonlib.Stack");

-- Create a Table with stack functions
function Stack:Create()

  -- stack table
  local t = {}
  -- entry table
  t._et = {}

  -- push a value on to the stack
  function t:push(a1,a2,a3,a4,a5)
    if a1 then
      local targs = {a1,a2,a3,a4,a5}
      -- add values
      for _,v in pairs(targs) do
        table_insert(self._et, v)
      end
    end
  end

  -- pop a value from the stack
  function t:pop(num)

    -- get num values from stack
    local num = num or 1

    -- return table
    local entries = {}

    -- get values into entries
    for i = 1, num do
      -- get last entry
      if #(self._et) ~= 0 then
        table_insert(entries, self._et[#(self._et)])
        -- remove last value
        table_remove(self._et)
      else
        break
      end
    end
    -- return unpacked entries
    return unpack(entries)
  end

  -- get entries
  function t:size()
    return #(self._et)
  end

  -- list values
  function t:list()
    for i,v in pairs(self._et) do
      print(i, v)
    end
  end
  return t
end

