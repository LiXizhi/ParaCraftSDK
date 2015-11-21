--[[
Title: sqlite3 interface
Author(s): luasql ported to NPL by LiXizhi. 
Date: 2013/6/26
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/mysql/sqlite3.lua");
local luasql = commonlib.luasql;

-------------------------------------------------------
]]
local luasql = commonlib.gettable("commonlib.luasql");

local sqlite3 = require("luasql.sqlite3")
luasql.sqlite3 = sqlite3.sqlite3;

LOG.std(nil,"debug", "luasql", "loaded sqlite3");

-- TODO