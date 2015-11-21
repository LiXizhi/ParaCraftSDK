--[[
Title: My SQL interface
Author(s): luasql ported to NPL by LiXizhi. 
Date: 2013/1/31
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/mysql/mysql.lua");
local luasql = commonlib.luasql;

-------------------------------------------------------
]]

local luasql = commonlib.gettable("commonlib.luasql");

local mysql = require("luasql.mysql");
luasql._MYSQLVERSION = mysql._MYSQLVERSION;
luasql.mysql = mysql.mysql;

LOG.std(nil,"debug", "MySQL", "version:%s loaded", commonlib.luasql._MYSQLVERSION);

-- TODO