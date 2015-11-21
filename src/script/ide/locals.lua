--[[
Title: Local defines (Do not include this file, just copy whatever you need to your code)
Author(s): LiXizhi, more info: http://lua-users.org/wiki/OptimisationTips and http://www.lua.org/gems/sample.pdf(must read)
Date: 2010-5-27
Desc: Local(nested as well) variables are very fast as they reside in virtual machine registers, 
and are accessed directly by index. Global variables on the other hand, reside in a lua table and as such are accessed by a hash lookup.

Making global variables local
Local variables are very quick, since they are accessed by index. If possible, make global variables local (weird, eh?). Seriously, it works great and indexed access is always going to be faster than a hash lookup. If a variable, say GameState, needs global scope for access from C, make a secondary variable that looks like 'local GSLocal = GameState' and use GSLocal within the module. This technique can also be used for functions that are called repetitively, too. eg.

    x = { a=1,b=2 }
    function foo()
      local y=x
      print( x.a )
      print( y.b )  -- faster than the print above since y is a local table
    end

Variables(locals) in Lua is static (lexically) scoped, which means that 
we and the compiler always know the index of a local variable by only examing the source code. 
So local variables are always accessed by index(pointers) instead of looking up a hash table. 
This is TRUE for any nested functions (closures). 

local x;
local function foo()
	x = x + 1
	return x;
end

where, variable x is referenced by index (pointers) in its upvalues, so it is really fast without get global table and hash look up. 
The most efficient lua program will be without using ANY global values. One can ensure this by reading and GREP G[etGlobal] of the result of 

script\bin\luac5.1.exe  -p -l filename.lua
This will parse only and list BYTE code. 

use the lib:
------------------------------------------------------------
copy and paste whatever you need, but make sure the right side is a valid object. 
*only need to update per frame code, or code that is executed very often.*
-------------------------------------------------------
]]

-- quick replace, without changing the code
local _G = _G
local getmetatable = getmetatable
local setmetatable = setmetatable
local getfenv = getfenv
local setfenv = setfenv
local pairs = pairs
local ipairs = ipairs
local tostring = tostring
local tonumber = tonumber
local error = error
local type = type

-- standard libs
local math_abs = math.abs;
local math_floor = math.floor;
local math_ceil = math.ceil;

local table_getn = table.getn
local table_insert = table.insert

local string_find = string.find;
local string_gfind = string.gfind;
local string_lower = string.lower;
local string_match = string.match;
local string_gsub = string.gsub;
local string_format = string.format;

-- common libs
local commonlib = commonlib;
local echo = commonlib.echo;
local log = commonlib.log;
local applog = commonlib.applog;


-- API related
local NPL = NPL;
local ParaScene = ParaScene;
local ParaUI = ParaUI;

local ParaGlobal_timeGetTime = ParaGlobal.timeGetTime

local NPL_activate = NPL.activate;
local ParaUI_GetUIObject = commonlib.getfield("ParaUI.GetUIObject");
-- local ParaObject_IsValid = commonlib.getfield("ParaScene.ParaObject.IsValid");
local ParaScene_GetObject = commonlib.getfield("ParaScene.GetObject");
local ParaScene_GetCharacter = commonlib.getfield("ParaScene.GetCharacter");

-- App related
local Aries = commonlib.getfield("MyCompany.Aries");
