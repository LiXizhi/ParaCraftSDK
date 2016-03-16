--[[
Title: Parsing Command
Author(s): LiXizhi, 
Date: 2015/8/16
Desc: command parser functions, parse from string and return value and remaining string. 
It is just a simple forward looking sequencial parser

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/Util/CmdParser.lua");
local CmdParser = commonlib.gettable("System.Util.CmdParser");

local bBoolean, cmd_text = CmdParser.ParseBool(cmd_text);
local data, cmd_text = CmdParser.ParseInt(cmd_text);
local data, cmd_text = CmdParser.ParseNumber(cmd_text); -- same as ParseInt
local data, cmd_text = CmdParser.ParseDeltaInt(cmd_text);
local list, cmd_text = CmdParser.ParseNumberList(cmd_text, nil, "|,%s")
local list, cmd_text = CmdParser.ParseStringList(cmd_text, )
local text, cmd_text = CmdParser.ParseText(cmd_text, "sometext")
local str, cmd_text = CmdParser.ParseString(cmd_text);
local str, cmd_text = CmdParser.ParseFormated(cmd_text, "_%S+");
local word, cmd_text = CmdParser.ParseWord(cmd_text);
local color, cmd_text = CmdParser.ParseColor(cmd_text, "#ff0000");
local options, cmd_text = CmdParser.ParseOptions(cmd_text);
local option, cmd_text = CmdParser.ParseOption(cmd_text);
------------------------------------------------------------
]]

local CmdParser = commonlib.gettable("System.Util.CmdParser");


-- return integer or float, cmd_text_remain
function CmdParser.ParseInt(cmd_text)
	local value, cmd_text_remain = cmd_text:match("^%s*(%-?[%d%.]+)%s*(.*)$");
	if(value) then
		value = tonumber(value);
		if(value) then
			return value, cmd_text_remain
		end
	end
	return nil, cmd_text;
end
-- alias
CmdParser.ParseNumber = CmdParser.ParseInt;

-- e.g. "~0.1"
-- return integer or float, cmd_text_remain
function CmdParser.ParseDeltaInt(cmd_text)
	local value, cmd_text_remain = cmd_text:match("^%s*~(%-?[%d%.]+)%s*(.*)$");
	if(value) then
		value = tonumber(value);
		if(value) then
			return value, cmd_text_remain
		end
	end
	return nil, cmd_text;
end

-- parse a given text
-- @param text:such as "home", must not contain regular expression letters. 
function CmdParser.ParseText(cmd_text, text)
	local cmd_text_remain = cmd_text:match("^%s*"..text.."%s*(.*)$");
	if(cmd_text_remain) then
		return text, cmd_text_remain;
	end
	return nil, cmd_text;
end

-- parse any string value without white space. 
function CmdParser.ParseString(cmd_text)
	local str, cmd_text_remain = cmd_text:match("^%s*([^%s=]+)%s*(.*)$");
	if(cmd_text_remain) then
		return str, cmd_text_remain;
	end
	return nil, cmd_text;
end

-- parse any word value without white space. 
function CmdParser.ParseWord(cmd_text)
	local str, cmd_text_remain = cmd_text:match("^%s*(%w+)%s*(.*)$");
	if(cmd_text_remain) then
		return str, cmd_text_remain;
	end
	return nil, cmd_text;
end

-- @param strFmt: regular expression such as "%S+", "%w+", etc. 
function CmdParser.ParseFormated(cmd_text, strFmt)
	strFmt = strFmt or "%S+"
	local str, cmd_text_remain = cmd_text:match("^%s*("..strFmt..")%s*(.*)$");
	if(cmd_text_remain) then
		return str, cmd_text_remain;
	end
	return nil, cmd_text;
end


-- parse option that begins with -, return the option name
function CmdParser.ParseOption(cmd_text)
	local value, cmd_text_remain = cmd_text:match("^%s*%-([%w_]+)%s*(.*)$");
	if(value) then
		return value, cmd_text_remain;
	end
	return nil, cmd_text;
end

-- return options: -[options]
function CmdParser.ParseOptions(cmd_text)
	local options = {};
	local option, cmd_text_remain = nil, cmd_text;
	while(cmd_text_remain) do
		option, cmd_text_remain = CmdParser.ParseOption(cmd_text_remain);
		if(option) then
			options[option] = true;
		else
			break;
		end
	end
	return options, cmd_text_remain;
end

-- 1|0 on|off true|false are all supported
function CmdParser.ParseBool(cmd_text)
	local value, cmd_text_remain = cmd_text:match("^([o01tf]%S*)%s*(.*)$");
	if(value) then
		return value=="on" or value=="1" or value=="true", cmd_text_remain;
	end
	return nil, cmd_text;
end

-- @param cmd_text: "1|2|3" will return {1,2,3}
--  "1|~|3" will return {1,false,3}
-- @param separator: default to "|," which is "|" or ",". one can also specify "|,%s"
-- return a table array of numbers
function CmdParser.ParseNumberList(cmd_text, list, separator)
	list = list or {};
	local value, cmd_text_remain;
	if(separator) then
		value, cmd_text_remain = cmd_text:match("^{?([%-]?[%d%.~]+)["..(separator or "|,").."]%s*(.*)}?$");
	else
		value, cmd_text_remain = cmd_text:match("^{?([%-]?[%d%.~]+)[|,]%s*(.*)}?$");
	end

	if(value) then
		if(value ~= "~") then
			list[#list+1] = tonumber(value);
		else
			list[#list+1] = false;
		end

		local _;
		_, cmd_text_remain = CmdParser.ParseNumberList(cmd_text_remain, list, separator);
		return list, cmd_text_remain;
	else
		value, cmd_text_remain = cmd_text:match("^(%-?[%d%.~]+)%s*(.*)$");
		if(value) then
			if(value ~= "~") then
				list[#list+1] = tonumber(value);
			else
				list[#list+1] = false;
			end
			return list, cmd_text_remain;
		else
			return nil, cmd_text;
		end
	end
end


-- @param cmd_text: "str1|2|str3" will return {"str1","2","str3"}
-- return a table of |or, sperated list
function CmdParser.ParseStringList(cmd_text, list)
	list = list or {};
	local value, cmd_text_remain = cmd_text:match("^(%S+)[|,]%s*(.*)$");
	if(value) then
		list[#list+1] = (value);
		local _;
		_, cmd_text_remain = CmdParser.ParseStringList(cmd_text_remain, list);
		return list, cmd_text_remain;
	else
		value, cmd_text_remain = cmd_text:match("^(%S+)%s*(.*)$");
		if(value) then
			list[#list+1] = (value);
			return list, cmd_text_remain;
		else
			return nil, cmd_text;
		end
	end
end

-- item's serverdata or tagData in xml format
-- currently, this must be the last parameter. 
-- @param cmd_text: "{table parameters}"
-- @return serverDataTable, cmd_remaining_text
function CmdParser.ParseServerData(cmd_text)
	local value = cmd_text:match("^%s*({.+})%s*$");
	if(value) then
		value = NPL.LoadTableFromString(value);
		if(value) then
			return value, "";
		end
	end
	return nil, cmd_text;
end

-- parse: #rgb like "#ffffff"
-- @return the string "#ffffff"
function CmdParser.ParseColor(cmd_text, default_value)
	local value, cmd_text_remain = cmd_text:match("^%s*(#[%w]+)%s*(.*)$");
	if(value) then
		return value, cmd_text_remain;
	end
	return default_value, cmd_text;
end

-- parse: NPL table string {attr={filename=""}}
-- @return table, remaining_text;
function CmdParser.ParseTable(cmd_text, default_value)
	local t, cmd_text_remain = cmd_text:match("^%s*(%{.+%})%s*(.*)$");
	if(t) then
		t = NPL.LoadTableFromString(t);
		return t, cmd_text_remain;
	end
	return default_value, cmd_text;
end