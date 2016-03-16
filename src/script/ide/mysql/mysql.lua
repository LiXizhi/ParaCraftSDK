--[[
Title: My SQL interface
Author(s): luasql ported to NPL by LiXizhi. 
Date: 2013/1/31
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/mysql/mysql.lua");
local luasql = commonlib.luasql;


NPL.load("(gl)script/ide/mysql/mysql.lua");
local MySql = commonlib.gettable ("System.Database.MySql");
local mysql_db = MySql:new():init(db_user, db_password, db_name, db_host, db_port);
-------------------------------------------------------
]]

local luasql = commonlib.gettable("commonlib.luasql");

local mysql = require("luasql.mysql");
luasql._MYSQLVERSION = mysql._MYSQLVERSION;
luasql.mysql = mysql.mysql;

LOG.std(nil,"debug", "MySQL", "version:%s loaded", commonlib.luasql._MYSQLVERSION);


local MySql = commonlib.inherit (nil, commonlib.gettable ("System.Database.MySql"));
MySql.env = nil;
MySql.con = nil;
function MySql:ctor ()
end

function MySql:init (db_user, db_password, db_name, db_host, db_port)
	local env, con;
	-- create environment object
	env = assert (luasql.mysql ())
	-- connect to data source
	-- env:connect(databasename[,username[,password[,hostname[,port]]]])
	con = assert (env:connect (db_name, db_user, db_password, db_host or "localhost", db_port or 3306))
	self.env = evn;
	self.con = con;

	return self;
end
function MySql:close ()
	self.con:close ();
	self.env:close();
end

function MySql:query(query)
	LOG.std (nil, "debug", "query", "%s", query);
	if(not query)then
		return
	end
	local cur = assert (self.con:execute (query))
	return cur;
end
function MySql:get_var (query, x, y)
	if(not query)then
		return
	end
	x = x or 1;
	y = y or 1;
	local rows = self:get_results (query, nil);
	if(rows and rows[y])then
		local cols = rows[y];
		return cols[x];
	end
end
function MySql:get_row (query, index)
	local results = self:get_results (query,"a");
	if(results)then
		index = index or 1;
		return results[index];
	end
end
function MySql:get_col (query, index)
	local results = self:get_results (query, nil);
	if(results)then
		index = index or 1;
		local arr = {};
		local k, v;
		for k, v in ipairs (results) do
			table.insert(arr,v[index]);
		end
		return arr;
	end
end
-- @param output_type:nil or "a".if "a" the rows will be indexed by field names
function MySql:get_results (query, output_type)
	local cur = self:query(query);
	if(cur)then
		local row = cur:fetch ( {}, output_type)
		local results = {};
		while row do
			table.insert (results, commonlib.clone (row));
			row = cur:fetch (row, output_type)
		end
		cur:close ();
		return results;
	end
end

