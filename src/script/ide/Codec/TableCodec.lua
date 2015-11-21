--[[
Title: Encoding/decoding(Compressing/Decompressing) table to and from string
Author: LiXizhi
Date: 2011/4/20
Desc: The string is usually more compact than the orginal table, useful for network transmission. 
Internally it will use index to replace frequently used values. It will also avoid using key names directly, 
such that long table key name will not affect the compressed table size.
-----------------------------------------------
NPL.load("(gl)script/ide/Codec/TableCodec.lua");
local TableCodec = commonlib.gettable("commonlib.TableCodec");
local my_codec = TableCodec:new();
my_codec:AddField("fieldname1", "default_value1", {"frequent_word1", "frequent_word2", "frequent_word3"});
my_codec:AddFields({
{name="fieldname2", default_value="default_value2", frequent_values={"frequent2_word1", "frequent2_word2", "frequent2_word3"}},
{name="fieldname3", default_value="default_value3", frequent_values={"frequent3_word1", "frequent3_word2", "frequent3_word3"}},
{name="fieldname4", default_value="default_value4", frequent_values={"frequent4_word1", "frequent4_word2", "frequent4_word3"}},
});

local sample_data = {
	foreign_fieldname = "foreign data",
	fieldname1 = "default_value1",
	fieldname2 = "frequent2_word1",
	fieldname3 = "frequent3_word2",
	fieldname4 = "unique words",
}
log(my_codec:Encode(sample_data).."\n"); -- {_v={"unique words",},_vi={4,},_fi={2,3,},foreign_fieldname="foreign data",_f={1,2,},}
commonlib.echo(my_codec:Decode(my_codec:Encode(sample_data))); -- echo:{foreign_fieldname="foreign data",fieldname3="frequent3_word2",fieldname1="default_value1",fieldname2="frequent2_word1",fieldname4="unique words",}
-----------------------------------------------
]]

local TableCodec = commonlib.gettable("commonlib.TableCodec");
local type = type;

function TableCodec:new(o)
	o = o or {}   -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self

	o.last_index = 1;
	-- mapping from field name to field desciption table
	o.fields = o.fields or {};
	-- mapping from field index to field description table
	o.fields_indice = o.fields_indice or {};
	return o
end

-- set all fields that may be in the table. 
-- @param name_or_table: name or a table of {name="field_name", default_value=nil, frequent_values={array of values},}
-- @param default_value: default value for missing field during decoding. 
-- @param frequent_values: array of frequently used values. these values will be replaced by their index during encoding. 
function TableCodec:AddField(name_or_table, default_value, frequent_values)
	local name, field;
	if(type(name_or_table) == "string") then
		name = name_or_table;
		field = {name=name, default_value=default_value, frequent_values=frequent_values};
	elseif(type(name_or_table) == "table") then
		name = name_or_table.name;
		field = name_or_table;
	end
	if(self:GetField(name)) then
		LOG.std(nil, "warn", "TableCodec", "field name %s already exist", name);
	else		
		-- install the field
		field.index = field.index or self.last_index;
		self.last_index = self.last_index +1;

		self.fields[name] = field;
		self.fields_indice[field.index] = field;

		if(field.frequent_values) then
			field.value_to_index = {};
			field.index_to_value = {};
			local index, value;
			for index, value in ipairs(field.frequent_values) do
				field.value_to_index[value] = index;
				field.index_to_value[index] = value;
			end
		end
	end
end

-- add fields in a group
-- @param fields: a table array of {name="field_name", default_value=nil, frequent_values={array of values},}
function TableCodec:AddFields(fields)
	local _, field
	for _, field in ipairs(fields) do
		self:AddField(field);
	end
end

-- get field description table by name. it may return nil
function TableCodec:GetField(name)	
	return self.fields[name];
end

-- get field description table by name. it may return nil
function TableCodec:GetFieldByIndex(index)	
	return self.fields_indice[index];
end

-- encode table to string
function TableCodec:Encode(obj)
	local out = self:EncodeToTable(obj);
	if (out) then
		return commonlib.serialize_compact(out);
	end
end

-- encode table to table
function TableCodec:EncodeToTable(obj)
	if(type(obj) == "table") then
		local out = {};
		local name, value
		for name, value in pairs(obj) do
			local field = self:GetField(name);
			if(field)then
				if(value == field.default_value) then
					
				elseif(field.frequent_values and field.value_to_index[value]) then
					-- write value and index to frequency table: _f and _fi
					out._f = out._f or {};
					out._f[#(out._f)+1] = field.value_to_index[value];
					out._fi = out._fi or {};
					out._fi[#(out._fi)+1] = field.index;
				else
					-- write value and index to value table: _v and _vi
					out._v = out._v or {};
					out._v[#(out._v)+1] = value;
					out._vi = out._vi or {};
					out._vi[#(out._vi)+1] = field.index;
				end
			else
				out[name] = value;
			end
		end
		return out;
	end
end

-- decode table from string
function TableCodec:Decode(str)
	return self:DecodeFromTable(NPL.LoadTableFromString(str), true);
end

-- decode table from another table. 
-- @param obj: the table object to decode. 
-- @param bInplace: if true, we will modify the original obj. currently only true is supported. 
function TableCodec:DecodeFromTable(obj, bInplace)
	if(type(obj) == "table") then
		if(obj._v and obj._vi) then
			local index, index_value
			for index, index_value in ipairs(obj._vi) do
				local field = self:GetFieldByIndex(index_value)	
				if (field) then
					obj[field.name] = obj._v[index];
				end
			end
			obj._v = nil;
			obj._vi = nil;
		end
		if(obj._f and obj._fi) then
			local index, index_value
			for index, index_value in ipairs(obj._fi) do
				local field = self:GetFieldByIndex(index_value)	
				if (field and field.index_to_value) then
					obj[field.name] = field.index_to_value[obj._f[index]];
				end
			end
			obj._f = nil;
			obj._fi = nil;
		end

		-- assign default value
		local _, field
		for _, field in pairs(self.fields) do
			if(field.default_value~=nil and obj[field.name] == nil) then
				obj[field.name] = field.default_value;
			end
		end
		return obj;
	end
end