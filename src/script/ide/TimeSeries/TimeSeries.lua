--[[
Title: Time Series
Author(s): LiXizhi
Date: 2007/11/10
Desc: Time series contains a group of relate variables. Each variable is an instance of AnimBlock, which is a serie of {time, value} pairs
Use Lib: 
-------------------------------------------------------
NPL.load("(gl)script/ide/TimeSeries/TimeSeries.lua");
local ctl = TimeSeries:new{name = "TimeSeries1",};
ctl:CreateVariable({name = "x", type="Linear"});
ctl:CreateVariable({name = "talk", type="Discrete"});

ctl:load({
	{name="x", tableType="AnimBlock", type="Linear", ranges={{1,2},{2,3}}, times={1000, 2000, 3000}, data={1,2,3} 	}
})
ctl["x"]:getValue(anim_id, cur_time);
-- One can later access these variables, simple by ctl.x or ctl.talk, etc. 
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/TimeSeries/AnimBlock.lua");

if(not TimeSeries) then TimeSeries = {}; end
if(not TimeSeries.AllObjects) then TimeSeries.AllObjects = {}; end
TimeSeries.AutoCounter = 1;

function TimeSeries:new(o)
	o = o or {};
	setmetatable(o, self);
	self.__index = self;
	
	o.tableType = "TimeSeries";
	
	return o;
end

-- load time series from a given file or table. It does not clear existing ones in the current time series, but will overwrite if name are the same as in the file. 
-- @param filename: the filename or table
function TimeSeries:Load(filename)
	local data
	if(type(filename) == "string") then
		data = commonlib.LoadTableFromFile(filename);
	elseif(type(filename) == "table") then
		data = filename;
	end
	if(not data) then
		log("error: failed loading time series file: "..filename.."\n");
		return;
	end
	
	local varName, v;
	for varName, v in pairs(data) do
		if(type(v) == "table" and v.tableType == "AnimBlock") then
			self:CreateVariable(v);
		end	
	end
	--log("Time series loaded from "..filename.."\n")
end

-- save time series to a given file. 
-- @param filename: the filename 
function TimeSeries:Save(filename)
	local file = ParaIO.open(filename, "w");
	if(file:IsValid()) then
		file:seek(0);
		file:SetEndOfFile();
		
		-- only  export animation blocks. 
		file:WriteString("{\r\n")
		local k,v
		for k,v in pairs(self) do
			if(type(v) == "table" and v.tableType == "AnimBlock") then
				file:WriteString("  [")
				commonlib.serializeToFile(file, k)
				file:WriteString("] = ")
				commonlib.serializeToFile(file, v)
				file:WriteString(",\r\n")
			end	
		end
		file:WriteString("}\r\n")
		
		file:close();
	end	
end

-- Applies to all variables: trim end, so that there are no time value that is smaller than time.
function TimeSeries:TrimEnd(time)
	local k,v
	for k,v in pairs(self) do
		if(type(v) == "table" and v.tableType == "AnimBlock") then
			v:TrimEnd(time);
		end	
	end
end

-- add a new variable to the time series. It there is an existing variable, the old one will be replaced. 
-- @param params: {name="", type="Linear"|"Discrete"}. It is actually passed to the new function of AnimBlock. More info see AnimBlock. 
function TimeSeries:CreateVariable(params)
	if(params.name == nil) then return end
	self[params.name] = AnimBlock:new(params);
end

-- @param varName: variable name
-- @param animID: range index
function TimeSeries:GetStartFrame(varName, animID)
	local timesID = self[varName].ranges[animID][1];
	return self[varName].times[timesID];
end

-- @param varName: variable name
-- @param animID: range index
function TimeSeries:GetEndFrame(varName, animID)
	local timesID = self[varName].ranges[animID][2];
	return self[varName].times[timesID];
end
