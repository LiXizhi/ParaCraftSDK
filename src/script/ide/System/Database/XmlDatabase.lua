--[[
Title: XML database
Author(s): LiXizhi, 
Date: 2015/6/15
Desc: XML based database server with a sql-like interface
Each database is a folder with table_XXX.xml files. 
The XML database is single-threaded and load every thing in a table into memory on first query of any table data.
and flushes changes on demand. 
It is suitable for storing read-only configuration files or simple settings for applications. 

sample table_XXX.xml file:
<verbatim>
	<xml_table table_index="key">
		<row key="1" value="data1"/>
	</xml_table>
</verbatim>

Table generally has one or more table_index. specify more index like this table_index="key,key2".

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Database/XmlDatabase.lua");
local Database = commonlib.gettable("System.Database.Xml.Database");
local db = Database:new_from_pool("temp/xmldatabase"):init("username", "password", "temp/xmldatabase");
db:query(db:new_query():update_row("test", {id="1", data="data1"}))
db:query(db:new_query():update_row("test", {id="2", data={name="table2"}}))
db:query(db:new_query():update_row("test", {id="3", data="data3"}))
db:query(db:new_query():update_row("test", {id="4", data="data4"}))
db:query(db:new_query():delete_row("test", {id="3"}))
echo(db:query(db:new_query():select_row("test", nil, {id="2"})))
assert(db:query(db:new_query():select_row("test", "data", {id="3"})) == nil)
assert(db:query(db:new_query():select_row("test", "data", {id="1"})) == "data1")
echo(db:query(db:new_query():select_rows("test")))
db:Flush();
------------------------------------------------------------
]]

local type = type;

-------------------------
-- Query
-------------------------
local Query = commonlib.inherit(nil, commonlib.gettable("System.Database.Xml.Query"));

function Query:ctor()
end

-- @param query: query string. 
function Query:init(query)
	self:parse_string(query);
	return self;
end

-- select a single row
-- @param select_fields: array of value fields to return, if nil, it return all fields. if string,  it query a single field.
-- @param where: condition to satify in name, value pairs. {name=value}; if nil, it may mean select all rows
function Query:select_row(table_name, select_fields, where)
	self.cmd = "SELECT";
	self.table_name = table_name;
	self.select_fields = select_fields;
	self.where = where;
	return self;
end

-- select all rows
function Query:select_rows(table_name)
	self.cmd = "SELECT";
	self.table_name = table_name;
	return self;
end

-- insert or update a given row
-- @param row: {key, value} pairs to update
-- @param where: condition to satify in name, value pairs. {name=value};
--	if nil, we will find default index in row parameter.
function Query:update_row(table_name, row, where)
	self.cmd = "UPDATE";
	self.table_name = table_name;
	self.update_row = self:normalize_row(row);
	if(not where) then
		where = {self.default_index, row[self.default_index]}
	end
	self.where = where;
	return self;
end

-- select a single row
-- @param select_fields: array of value fields to return, if nil, it return all fields. if string,  it query a single field.
-- @param where: condition to satify in name, value pairs. {name=value};
function Query:delete_row(table_name, where)
	self.cmd = "DELETE";
	self.table_name = table_name;
	self.where = where;
	return self;
end

-- convert row data to string inplace
-- @return row:
function Query:normalize_row(row)
	if(row) then
		for key, value in pairs(row) do
			if(type(value) == "table") then
				row[key] = commonlib.serialize_compact(value);
			end
		end
	end
	return row;
end

-- we only support a very basic set of sql command. 
-- @param query: 
--	 "SELECT * FROM table_name WHERE option_name=value"
--	 "INSERT INTO table_name (key1, key2, ...) VALUES (value1, value2, ...)"
--	 "UPDATE table_name SET key1 = value1, key2=value2, ..."
function Query:parse_string(query)
	-- TODO: not implemented
	-- ANTLR3? php-sql-parser?
end

-------------------------
-- Table 
-------------------------
local Table = commonlib.inherit(nil, commonlib.gettable("System.Database.Xml.Table"));

function Table:ctor()
	self.modified = nil;
	self.indices = {};
end

function Table:init(filename)
	self.filename = filename;
	self:Load();
	return self;
end

-- load from file to memory. 
function Table:Load()
	local xmlRoot = ParaXML.LuaXML_ParseFile(self.filename);
	if(type(xmlRoot)=="table" and #(xmlRoot)>0) then
		self.data = xmlRoot[1];
	else
		self.data = {name="xml_table", attr={table_index="id"}};
		self:SetModified();
	end
	self:BuildIndex();
end

function Table:GetAttribute(name)
	if(self.data.attr) then
		return self.data.attr[name];
	end
end

-- build index for fast query
function Table:BuildIndex()
	local indices = self:GetAttribute("table_index") or "id";
	for idx in string.gmatch(indices, "%w+") do
		self.indices[idx] = {};
		if(not self.default_index) then
			self.default_index = idx;
		end
	end

	for idx, idx_map in pairs(self.indices) do
		for _, row in ipairs(self.data) do
			row = row.attr;
			if(row) then
				local key = row[idx];
				if(key) then
					idx_map[key] = row;
				end
			end
		end
	end
end

function Table:GetIndexMap(name)
	return self.indices[name];
end

function Table:GetDefaultIndex()
	return self.default_index;
end

-- get row table containing all key, value pairs, where a given field name matches value. 
-- @param name: it is recommended that name is an indexed field, otherwise a linear search is performed. 
function Table:GetRow(name, value)
	local idx_map = self:GetIndexMap(name);
	if(idx_map) then
		-- index based search, this is fast
		if(value) then
			return idx_map[value];
		end
	else
		-- linear search
		for _, row in ipairs(self.data) do
			row = row.attr;
			if(row) then
				if(row[name] == value) then
					return row;	
				end
			end
		end
	end
end

-- return all rows in a list
function Table:GetRows()
	local rows =  {};
	for _, row in ipairs(self.data) do
		row = row.attr;
		if(row) then
			rows[#rows+1] = row;
		end
	end
	return rows;
end

-- if there is an existing row, we will update it. 
function Table:InsertRow(row)
	local index_value = row[self.default_index];
	if(index_value) then
		local old_row = self:GetRow(self.default_index, index_value);
		if(old_row) then
			commonlib.partialcopy(old_row, row);
		else
			self.data[#self.data+1] = {name="row", attr=row};
			self:AddRowToIndex(row);
		end
		self:SetModified();
	end
end

-- currently deletion does a linear search
-- @return true if removed. 
function Table:DeleteRow(name, value)
	if(name == self.default_index and value) then
		local old_row = self:GetRow(name, value);
		if(old_row) then
			self:RemoveRowFromIndex(old_row);
			-- linear search to remove the entry. 
			for idx, row in ipairs(self.data) do
				row = row.attr;
				if(row) then
					if(row[name] == value) then
						self.data[idx] = self.data[#self.data];
						self.data[#self.data] = nil;
					end
				end
			end
			self:SetModified();
			return true;
		end
	end
end

function Table:RemoveRowFromIndex(row)
	for idx, idx_map in pairs(self.indices) do
		local key = row[idx];
		if(key) then
			idx_map[key] = nil;
		end
	end
end

function Table:AddRowToIndex(row)
	for idx, idx_map in pairs(self.indices) do
		local key = row[idx];
		if(key) then
			idx_map[key] = row;
		end
	end
end

function Table:SetModified()
	self.modified = true;
end

-- save to file.
function Table:Save()
	self.modified = false;
	ParaIO.CreateDirectory(self.filename);
	local file = ParaIO.open(self.filename, "w");
	if(file:IsValid()) then
		file:WriteString(commonlib.Lua2XmlString(self.data, true));
		file:close();
	else
		LOG.std(nil, "warn", "XmlDatabase", "can not write to %s", self.filename);
	end
end

function Table:Flush()
	if(self.modified) then
		self:Save();
	end
end

-------------------------
-- Database
-------------------------

local Database = commonlib.inherit(nil, commonlib.gettable("System.Database.Xml.Database"));
function Database:ctor()
	self.tables = {};
	self.auto_flush = false;
	-- if true(default), we will deserialize string "{.*}" into a table object. 
	self.auto_serialize_object = true;
end

local s_pools = {};
function Database:new_from_pool(directory)
	directory = self:GetDirectoryPath(directory);
	if(s_pools[directory]) then
		return s_pools[directory];
	else
		return Database:new();
	end
end

function Database:GetDirectoryPath(directory)
	directory = directory or "temp/xmldatabase";
	if(not directory:match("/$")) then
		directory = directory.."/";
	end
	return directory;
end

-- @param directory: where to load/save database files. default to "temp/xmldatabase"
function Database:init(username, password, directory)
	if(self.inited) then
		return;
	end
	self.inited = true;
	
	directory = self:GetDirectoryPath(directory);
	self.directory = directory;
	
	self:Connect(username, password);
	-- add to pool
	s_pools[directory] = self;

	LOG.std(nil, "info", "XmlDatabase", "load xml database: %s", self.directory);	
	return self;
end

-- disabled by default. 
-- @param flushInterval: default to 10000ms
function Database:SetAutoFlush(bEnable, flushInterval)
	if(self.auto_flush ~= bEnable) then
		self.auto_flush = bEnable;
		if(bEnable) then
			self.timer = self.timer or commonlib.Timer:new({callbackFunc = function(timer)
				self:Flush();
			end})
			-- flush every 10 seconds
			self.timer:Change(1000, flushInterval or 10000);
		else
			if(self.timer) then
				self.timer:Change();
			end
		end
	end
end

function Database:Connect(username, password)
	-- load the users table. 
	self:GetTable("users", true);
end

function Database:Disconnect()

end

function Database:LoadTable(table_name)
	local filename = format("%stable_%s.xml", self.directory, table_name);
	local t = Table:new():init(filename);
	self.tables[table_name] = t;
	return t;
end

-- create the table if not exist
function Database:GetTable(table_name, bCreateIfNotExist)
	local t = self.tables[table_name];
	if(not t and bCreateIfNotExist) then
		t = self:LoadTable(table_name)
	end
	return t;
end

function Database:Flush()
	for _, t in pairs(self.tables) do
		t:Flush();
	end
end

-- TODO: not support string query yet
function Database:prepare(query)
	if(type(query) == "table") then
		return query;
	end
end

-- create a new query object. 
function Database:new_query()
	return Query:new();
end

-- if any value match "^%{.*%}$", we may deserialize as table object
function Database:may_deserialize_object(object)
	if(self.auto_serialize_object) then
		if(object and object:match("^%{.*%}$")) then
			object = NPL.LoadTableFromString(object) or object;
		end
	end
	return object;
end

-- if any value match "^%{.*%}$", we may deserialize as table object
function Database:may_deserialize_row(row)
	if(self.auto_serialize_object) then
		if(type(row) == "table") then
			for k, v in pairs(row) do
				if(type(v) == "string" and v:match("^%{.*%}$")) then
					row[k] = NPL.LoadTableFromString(v) or v;
				end
			end
		elseif(type(row) == "string") then
			row = self:may_deserialize_object(row);
		end
	end
	return row;
end

function Database:may_deserialize_rows(rows)
	if(self.auto_serialize_object) then
		for i, row in pairs(rows) do
			rows[i] = self:may_deserialize_row(row);
		end
	end
	return rows;
end

-- @param query: this should be the query object. 
function Database:query(query)
	if(not query) then
		return;
	end
	if(query.table_name) then
		local t = self:GetTable(query.table_name, true);
		if(t) then
			if(query.cmd == "SELECT") then
				local result, should_unpack, is_rows;
				if(query.where) then
					local name, value = next(query.where);
					if(name and value) then
						local row = t:GetRow(name, value);
						if(row) then
							if(not query.select_fields) then
								result = row;
							else
								if(type(query.select_fields) == "string") then
									result = row[query.select_fields];
								else
									local result = {};
									for _, fieldname in ipairs(query.select_fields) do
										result[#res+1] = row[fieldname];
									end
								end
							end
						end
					else
						result = t:GetRows();
						is_rows = true;
					end
				else
					result = t:GetRows();
					is_rows = true;
				end
				if(result~=nil) then
					if(is_rows) then
						result = self:may_deserialize_rows(result);
					else
						result = self:may_deserialize_row(result);
					end
					
					if(should_unpack) then
						return unpack(result);
					else
						return result;
					end
				end
			elseif(query.cmd == "UPDATE") then
				if(query.update_row) then
					t:InsertRow(query.update_row);
				end
			elseif(query.cmd == "DELETE") then
				local name, value = next(query.where);
				if(name and value) then
					t:DeleteRow(name, value);
				end
			end
		end
	end
end
