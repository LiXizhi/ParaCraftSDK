--[[
Title: Loading lua sqlite HAPI
Author(s): LiXizhi
Note: Lua Sqlite wrapper in ParaEngine is mainly based on the work of Michael Roth <mroth@nessie.de>.
	The code is free, please read the license in other files of sqlite folder, written by the original author. 
Date: 2006/4
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/sqlite/libluasqlite3-loader.lua");
api, ERR, TYPE, AUTH = load_libluasqlite3();
------------------------------------------------------------
]]

local api, ERR, TYPE, AUTH

api, ERR, TYPE, AUTH = luaopen_sqlite3()

function load_libluasqlite3()
  return  api, ERR, TYPE, AUTH
end

