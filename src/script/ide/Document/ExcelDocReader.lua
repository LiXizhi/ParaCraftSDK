--[[
Title: Reading XML based excel 2007 file
Author(s): LiXizhi
Date: 2012/7/11
Desc: currently only single worksheet is supported
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Document/ExcelDocReader.lua");
local ExcelDocReader = commonlib.gettable("commonlib.io.ExcelDocReader");
local reader = ExcelDocReader:new();

-- schema is optional, which can change the row's keyname to the defined value. 
reader:SetSchema({
	[1] = {name="column_name1"},
	[2] = {name="column_name2", type="number"},
	[3] = {name="column_name3", validate_func=function(value)  return value=="true"; end },
})
-- read from the second row
if(reader:LoadFile("temp/some_xml_excel_file.xml", 2)) then 
	local rows = reader:GetRows();
	echo(rows);
end

------------------------------------------------------------
]]
local ExcelDocReader = commonlib.gettable("commonlib.io.ExcelDocReader");

function ExcelDocReader:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o	
end

-- set the scheme used when parsing the excel file
-- @param schema: if nil, it means no schema is used. it can also be a table mapping from row index to schema table. { [1]={name="my_keyname", type="number"}, {}}
function ExcelDocReader:SetSchema(schema)
	self.scheme = schema;
end

-- @param column_index: starting from 1
-- @return nil if there is no schema defined. otherwise it is a table {type="number", validate_func=function(value) end, }
-- the validate_func function() should return value, name. name can be nil. if name is specified, it will replace the schema.name. So that the value itself can define the schema name. 
function ExcelDocReader:GetSchemaByColumn(column_index)
	self.scheme = self.scheme or {};
	return self.scheme[column_index]
end

-- @param filename: xml based excel document.
-- @param nStartRow: default to 2. where the row 1 is skipped (usually some comments on the first row). 
-- @return true if there is data
function ExcelDocReader:LoadFile(filename, nStartRow)
	if(not filename) then
		return filename;
	end
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	if(xmlRoot) then
		LOG.std(nil, "debug", "ExcelDocReader", "load file:%s", filename);
		nStartRow = nStartRow or 1;
		local rows = {};
		local index = 1;
		local nodes;
		for nodes in commonlib.XPath.eachNode(xmlRoot, "/Workbook/Worksheet/Table/Row") do
			if(index >= nStartRow)then
				local cell_nodes;
				local row = {};
				self.rows = rows;
				local col_index = 1;
				for cell_nodes in commonlib.XPath.eachNode(nodes, "/Cell") do
					local cell_data = cell_nodes[1];
					if(cell_nodes.attr) then
						local col_force_index = cell_nodes.attr["ss:Index"];
						if(col_force_index) then
							col_index = tonumber(col_force_index) or col_index;
						end
					end

					if(cell_data and cell_data.name == "Data") then
						local value = cell_data[1];
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
					end
					col_index = col_index + 1;
				end
				rows[#rows+1]  = row;
			end
			index = index + 1;
		end
		return true;
	end
end

-- get all rows. 
function ExcelDocReader:GetRows()
	return self.rows;
end