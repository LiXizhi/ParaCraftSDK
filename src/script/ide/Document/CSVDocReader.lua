--[[
Title: Reading CSV based text file
Author(s): LiXizhi
Date: 2012/11/29
Desc: currently only single worksheet is supported
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Document/CSVDocReader.lua");
local CSVDocReader = commonlib.gettable("commonlib.io.CSVDocReader");
local reader = CSVDocReader:new();

-- schema is optional, which can change the row's keyname to the defined value. 
reader:SetSchema({
	[1] = {name="column_name1"},
	[2] = {name="column_name2", type="number"},
	[3] = {name="column_name3", validate_func=function(value)  return value=="true"; end },
})
-- read from the second row
if(reader:LoadFile("temp/some_csv_excel_file.csv", 1)) then 
	local rows = reader:GetRows();
	echo(rows);
end

------------------------------------------------------------
]]
local CSVDocReader = commonlib.gettable("commonlib.io.CSVDocReader");

function CSVDocReader:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o	
end

-- set the scheme used when parsing the excel file
-- @param schema: if nil, it means no schema is used. it can also be a table mapping from row index to schema table. { [1]={name="my_keyname", type="number"}, {}}
function CSVDocReader:SetSchema(schema)
	self.scheme = schema;
end

-- @param column_index: starting from 1
-- @return nil if there is no schema defined. otherwise it is a table {type="number", validate_func=function(value) end, }
-- the validate_func function() should return value, name. name can be nil. if name is specified, it will replace the schema.name. So that the value itself can define the schema name. 
function CSVDocReader:GetSchemaByColumn(column_index)
	self.scheme = self.scheme or {};
	return self.scheme[column_index]
end

-- @param filename: xml based excel document.
-- @param nStartRow: default to 1 (first row). one may specify 2 where the row 1 is skipped (usually some comments on the first row). 
-- @return true if there is data
function CSVDocReader:LoadFile(filename, nStartRow)
	nStartRow = nStartRow or 1;
	if(not filename) then
		return filename;
	end
	local file = ParaIO.open(filename, "r");
	if(file:IsValid()) then
		LOG.std(nil, "debug", "CSVDocReader", "load file:%s", filename);

		local rows = {};
		self.rows = rows;
		local index = 1;
		
		local line = file:readline();
		while(line) do
			local row = {};
			rows[#rows+1]  = row;
			local section;
			local col_index = 1;
			local value;
			local nLength = #line
			if(line:sub(nLength,nLength) ~= ",") then
				line = line..","
			end
			for value in string.gmatch(line, "([^,]*),") do
				local schema = self:GetSchemaByColumn(col_index);
				if(not schema)then
					-- if there is no schema, simply use the col_index as key
					row[col_index] = value;
				else
					local name;
					if(schema.validate_func) then
						value, name = schema.validate_func(value);
					elseif(schema.type == "number") then
						value = tonumber(value);
					end
					row[name or schema.name or col_index] = value;
				end
				col_index = col_index + 1;
			end
			
			-- read next line
			line = file:readline();
		end
		file:close();
		return true;
	else
		LOG.std(nil, "warn", "CSVDocReader", "failed to load file:%s", filename);
	end
end

-- get all rows. 
function CSVDocReader:GetRows()
	return self.rows;
end