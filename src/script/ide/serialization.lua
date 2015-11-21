--[[
Title: serialization functions in commonlib
Author(s): LiXizhi
Date: 2006/11/25
Desc: serialization functions in commonlib
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/commonlib.lua");
-- include commonlib to use this lib
NPL.load("(gl)script/ide/serialization.lua");
-------------------------------------------------------
]]

if(not commonlib) then 	commonlib = {}; end
local commonlib = commonlib;

local tostring = tostring
local tonumber = tonumber
local type = type
local string_format = string.format;
local pairs = pairs
local ipairs = ipairs
local log = log;
-- output input to log safely in a single echo line. Only used in debugging or testing
-- Internally it uses commonlib.dump which handles recursive tables.
-- @param p1: anything to echo, table, nil, value, function, etc. 
-- @param handleRecursion: if true, table recursion is handled. it may cause stack overflow if set to nil with recursive table
function commonlib.echo(p1, handleRecursion)
	log("echo:")
	if(handleRecursion) then
		commonlib.log.log_long(commonlib.dump(p1,nil, not handleRecursion))
	else
		-- commonlib.log.log_long(commonlib.serialize(p1)); 
		commonlib.log.log_long(commonlib.serialize_compact(p1)); -- this will print in a single line(good for log search)
	end
	log("\n")
end
-- shortcut
echo = commonlib.echo;

--[[ serialize a table to the current file: function and user data are exported as nil value.  
@param o: table to serialize
]]
function commonlib.serializeToFile(file, o)
	local obj_type = type(o)
	if obj_type == "number" then
		file:WriteString(tostring(o))
	elseif obj_type == "string" then
		file:WriteString(string_format("%q", o))
	elseif obj_type == "boolean" then	
		if(o) then
			file:WriteString("true")
		else
			file:WriteString("false")
		end
	elseif obj_type == "table" then
		file:WriteString("{\r\n")
		
		local k,v
		for k,v in pairs(o) do
			file:WriteString("[")
			commonlib.serializeToFile(file, k)
			file:WriteString("]=")
			commonlib.serializeToFile(file, v)
			file:WriteString(",\r\n")
		end
		
		--local i;
		--for i,v in ipairs(o) do
			--file:WriteString( string_format("  [%d] = ",i) )
			--commonlib.serializeToFile(file, v)
			--file:WriteString(",\r\n")
		--end
	
		file:WriteString("}\r\n")
	elseif obj_type == "function" then
		file:WriteString("nil")
	elseif obj_type == "userdata" then
		file:WriteString("nil")
	else
		log("--cannot serialize a " .. obj_type.."\r\n")
	end
end

-- serialize to string.
-- e.g. print(commonlib.serialize(o))
-- @param o: the object to serialize
-- @param bBeautify: if true, it will generate with line breakings. if nil, it will use the C++ function to serialize. 
function commonlib.serialize(o, bBeautify)
	if(not bBeautify) then
		return NPL.SerializeToSCode("", o);
	else
		local obj_type = type(o)
		if obj_type == "number" then
			return (tostring(o))
		elseif obj_type == "nil" then
			return ("nil")
		elseif obj_type == "string" then
			return (string_format("%q", o))
		elseif obj_type == "boolean" then	
			if(o) then
				return "true"
			else
				return "false"
			end
		elseif obj_type == "function" then
			return (tostring(o))
		elseif obj_type == "userdata" then
			return ("nil")
		elseif obj_type == "table" then
			local str = "{\r\n"
			local k,v
			for k,v in pairs(o) do
				str = str..("[")..commonlib.serialize_compact3(k).."]="..commonlib.serialize(v, true)..",\r\n"
			end
			str = str.."}\r\n";
			return str
		else
			log("--cannot serialize a " .. obj_type.."\r\n")
		end
	end
end

-- this is the fatest serialization method using native API. 
function commonlib.serialize_compact(o) 
	return NPL.SerializeToSCode("", o);
end

-- same as commonlib.serialize, except that it is more compact by removing all \r\n and comments, etc. 
function commonlib.serialize_compact3(o)
	local obj_type = type(o)
	if obj_type == "number" then
		return (tostring(o))
	elseif obj_type == "nil" then
		return ("nil")
	elseif obj_type == "string" then
		return (string_format("%q", o))
	elseif obj_type == "boolean" then	
		if(o) then
			return "true"
		else
			return "false"
		end
	elseif obj_type == "table" then
		local str = "{"
		local k,v
		for k,v in pairs(o) do
			str = str..("[")..commonlib.serialize_compact(k).."]="..(commonlib.serialize_compact(v) or "nil")..","
		end
		str = str.."}";
		return str
	end
end


-- same as commonlib.serialize_compact, except that it is more compact by removing string key brackets, etc. 
-- e.x. {nid=19612,action="user_login",} instead of {["nid"]=19612,["action"]="user_login",}
local function serialize_compact2(o)
	local obj_type = type(o)
	if obj_type == "number" then
		return (tostring(o))
	elseif obj_type == "string" then
		return (string_format("%q", o))
	elseif obj_type == "boolean" then	
		if(o) then
			return "true"
		else
			return "false"
		end
	elseif obj_type == "table" then
		local str = "{"
		local k,v;
		local nIndex = 1;
		for k,v in pairs(o) do
			if(type(k) == "string") then
				str = str..k.."="..(serialize_compact2(v) or "nil")..",";
			elseif(nIndex == k) then
				str = str..(serialize_compact2(v) or "nil")..",";
				nIndex = nIndex + 1;
			else
				str = str.."["..tostring(k).."]="..(serialize_compact2(v) or "nil")..",";
			end
		end
		str = str.."}";
		return str
	elseif obj_type == "nil" then
		return ("nil")
	end
end
commonlib.serialize_compact2 = serialize_compact2;

-- this function will return a table created from file. 
-- function may return nil
-- e.g.
-- local t = commonlib.LoadTableFromFile("temp/t.txt")
-- if(t~=nil) then end
function commonlib.LoadTableFromFile(filename)
	--commonlib.tmptable = nil;
	--local file = ParaIO.open(filename, "r");
	--if(file:IsValid()) then
		--local body = file:GetText();
		--if(type(body)=="string") then
			--NPL.DoString("commonlib.tmptable = "..body);
		--end
		--file:close();
	--end	
	--return commonlib.tmptable;
	
	commonlib.tmptable = nil;
	local file = ParaIO.open(filename, "r");
	if(file:IsValid()) then
		local body = file:GetText();
		if(type(body)=="string") then
			commonlib.tmptable = NPL.LoadTableFromString(body)
			if(not commonlib.tmptable) then
				--log("error: commonlib.LoadTableFromFile() returns empty table. call stack is\n");
				--commonlib.log(commonlib.debugstack())
			end
		end
		file:close();
	end	
	return commonlib.tmptable;
end

-- @param body: should be a string of "{ any thing here }". if table or other data type, it is returned as it is. 
-- return the table. 
function commonlib.LoadTableFromString(body)
	if(type(body) == "string") then
		commonlib.tmptable = NPL.LoadTableFromString(body)
		if(not commonlib.tmptable) then
			--LOG.std(nil, "error", "serializer", "commonlib.LoadTableFromString() returns empty table. input %s. call stack is", tostring(body));
			--commonlib.log(commonlib.debugstack())
		end
		return commonlib.tmptable;
	else
		return body;
	end
end

-- this function will return a table created from file. 
-- @param bBeautified: true to enable indentation which is well organized and easy to read the table structure
-- function may return nil.e.g.
-- local t = {test=1};
-- commonlib.SaveTableToFile(t, "temp/t.txt");
function commonlib.SaveTableToFile(o, filename, bBeautified)
	local succeed;
	local file = ParaIO.open(filename, "w");
	if(file:IsValid()) then
		local str ; 
		if(bBeautified) then
			str = commonlib.serialize2(o,1);
		else
			str = commonlib.serialize(o);
		end
		file:WriteString(str);
		succeed = true;
	end	
	file:close();
	return succeed;
end

-- serialize to string
-- serialization will be well organized and easy to read the table structure
-- e.g. print(commonlib.serialize(o, 1))
function commonlib.serialize2(o, lvl)
	local obj_type = type(o)
	if obj_type == "number" then
		return (tostring(o))
	elseif obj_type == "string" then
		return (string_format("%q", o))
	elseif obj_type == "boolean" then	
		if(o) then
			return "true"
		else
			return "false"
		end
	elseif obj_type == "table" then
	
		local forwardStr = "";
		for i = 0, lvl do
			forwardStr = forwardStr.."  ";
		end
		local str = "{\r\n";
		local k,v
		for k,v in pairs(o) do
			nextlvl = lvl + 1;
			str = str..forwardStr..("  [")..commonlib.serialize2(k, nextlvl).."] = "..commonlib.serialize2(v, nextlvl)..",\r\n"
		end
		str = str..forwardStr.."}";
		return str
	elseif obj_type == "nil" then
		return ("nil")
	elseif obj_type == "function" then
		return (tostring(o))
	elseif obj_type == "userdata" then
		return ("nil")
	else
		log("-- cannot serialize a " .. obj_type.."\r\n")
	end
end

-- dump text or lines. it will automatically create directory for you. 
-- @param filename: which file to write to. it will replace whatever in the file. 
-- @param o: it can be text string or table array containing text lines, which are concartinated. It does NOT add line endings. 
-- commonlib.SaveTableToFile({"hello ", "world!"}, "temp/t.txt");
function commonlib.WriteTextToFile(o, filename)
	local succeed;
	ParaIO.CreateDirectory(filename);
	local file = ParaIO.open(filename, "w");
	if(file:IsValid()) then
		if(type(o) == "string") then
			file:WriteString(o);
		elseif(type(o) == "table") then
			local _, line 
			for _, line in ipairs(o) do
				if(type(line) == "string") then
					file:WriteString(line);
				end
			end
		end
		succeed = true;
	end	
	file:close();
	return succeed;
end
---------------------------------------
-- DataDumper.lua code is from: http://lua-users.org/wiki/DataDumper
-- added by LXZ on 2008.5.1
---------------------------------------

--[[
Copyright (c) 2007 Olivetti-Engineering SA

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
]]

local dumplua_closure = [[
local closures = {}
local function closure(t) 
  closures[#closures+1] = t
  t[1] = assert(loadstring(t[1]))
  return t[1]
end

for _,t in pairs(closures) do
  for i = 2,#t do 
    debug.setupvalue(t[1], i-1, t[i]) 
  end 
end
]]

local lua_reserved_keywords = {
  'and', 'break', 'do', 'else', 'elseif', 'end', 'false', 'for', 
  'function', 'if', 'in', 'local', 'nil', 'not', 'or', 'repeat', 
  'return', 'then', 'true', 'until', 'while' }

local function keys(t)
  local res = {}
  local oktypes = { stringstring = true, numbernumber = true }
  local function cmpfct(a,b)
    if oktypes[type(a)..type(b)] then
      return a < b
    else
      return type(a) < type(b)
    end
  end
  for k in pairs(t) do
    res[#res+1] = k
  end
  table.sort(res, cmpfct)
  return res
end

--local c_functions = {}
--for _,lib in pairs{'_G', 'string', 'table', 'math', 
    --'io', 'os', 'coroutine', 'package', 'debug'} do
  --local t = _G[lib] or {}
  --lib = lib .. "."
  --if lib == "_G." then lib = "" end
  --for k,v in pairs(t) do
    --if type(v) == 'function' and not pcall(string.dump, v) then
      --c_functions[v] = lib..k
    --end
  --end
--end

--[[ LiXizhi 2008.5.15: I modified to disable function and userdata dumping. 
DataDumper consists of a single Lua function, which could easily be put in a separate module or integrated into a bigger one. 
The function has four parameters, but only the first one is mandatory. It always returns a string value, which is valid Lua code. 
Simply executing this chunk will import back to a variable the complete structure of the original variable.
For simple structures, there is only one Lua instruction like a table constructor, but some more complex features will output a script with more instructions. 

All the following language features are supported: 

Simple Lua types: nil, boolean, number, string 
Tables are dumped recursively 
Table metatables are also dumped recursively 
Simple Lua functions (no upvalue) are dumped with loadstring 
Lua closures with upvalues are also supported, using the debug library! 
Known C functions are output using their original name 
Complex tables structures with internal references are supported 
@param value can be of any supported type 
@param varname: optional variable name. Depending on its form, the output will look like: 
	nil: "return value" 
	identifier: "varname = value" 
	other: "varname".."value" 
@param fastmode is a boolean value: 
	true: optimizes for speed. Metatables, closures, C functions and references are not supported. Returns a code chunk without any space or new line! 
	false: supports all advanced features and favors readable code with good indentation. 
@param indent: the number of additional indentation level. Default is 0. 
]]
function commonlib.dump(value, varname, fastmode, ident)
  local defined, dumplua = {}
  -- Local variables for speed optimization
  local string_format, type, string_dump, string_rep = 
        string.format, type, string.dump, string.rep
  local tostring, pairs, table_concat = 
        tostring, pairs, table.concat
  local keycache, strvalcache, out, closure_cnt = {}, {}, {}, 0
  setmetatable(strvalcache, {__index = function(t,value)
    local res = string_format('%q', value)
    t[value] = res
    return res
  end})
  local fcts = {
    string = function(value) return strvalcache[value] end,
    number = function(value) return value end,
    boolean = function(value) return tostring(value) end,
    ['nil'] = function(value) return 'nil' end,
    ['function'] = function(value) 
      --return string_format("loadstring(%q)", string_dump(value)) 
      return "function"
    end,
    userdata = function() return "userdata" end,
    thread = function() return "threads" end,
  }
  local function test_defined(value, path)
    if defined[value] then
      if path:match("^getmetatable.*%)$") then
        out[#out+1] = string_format("s%s, %s)\n", path:sub(2,-2), defined[value])
      else
        out[#out+1] = path .. " = " .. defined[value] .. "\n"
      end
      return true
    end
    defined[value] = path
  end
  local function make_key(t, key)
    local s
    if type(key) == 'string' and key:match('^[_%a][_%w]*$') then
      s = key .. "="
    else
      s = "[" .. dumplua(key, 0) .. "]="
    end
    t[key] = s
    return s
  end
  for _,k in ipairs(lua_reserved_keywords) do
    keycache[k] = '["'..k..'"] = '
  end
  if fastmode then 
    fcts.table = function (value)
      -- Table value
      local numidx = 1
      out[#out+1] = "{"
      for key,val in pairs(value) do
        if key == numidx then
          numidx = numidx + 1
        else
          out[#out+1] = keycache[key]
        end
        local str = dumplua(val)
        out[#out+1] = str..","
      end
      out[#out+1] = "}"
      return "" 
    end
  else 
    fcts.table = function (value, ident, path)
      if test_defined(value, path) then return "nil" end
      -- Table value
      local sep, str, numidx, totallen = " ", {}, 1, 0
      local meta, metastr = (debug or getfenv()).getmetatable(value)
      if meta then
        ident = ident + 1
        metastr = dumplua(meta, ident, "getmetatable("..path..")")
        totallen = totallen + #metastr + 16
      end
      for _,key in pairs(keys(value)) do
        local val = value[key]
        local s = ""
        local subpath = path
        if key == numidx then
          subpath = subpath .. "[" .. numidx .. "]"
          numidx = numidx + 1
        else
          s = keycache[key]
          if not s:match "^%[" then subpath = subpath .. "." end
          subpath = subpath .. s:gsub("%s*=%s*$","")
        end
        s = s .. dumplua(val, ident+1, subpath)
        str[#str+1] = s
        totallen = totallen + #s + 2
      end
      if totallen > 80 then
        sep = "\n" .. string_rep("  ", ident+1)
      end
      str = "{"..sep..table_concat(str, ","..sep).." "..sep:sub(1,-3).."}" 
      if meta then
        sep = sep:sub(1,-3)
        return "setmetatable("..sep..str..","..sep..metastr..sep:sub(1,-3)..")"
      end
      return str
    end
    --fcts['function'] = function (value, ident, path)
      --if test_defined(value, path) then return "nil" end
      --if c_functions[value] then
        --return c_functions[value]
      --elseif debug == nil or debug.getupvalue(value, 1) == nil then
        ----return string_format("loadstring(%q)", string_dump(value))
        --return "up_value";
      --end
      --closure_cnt = closure_cnt + 1
      --local res = {string.dump(value)}
      --for i = 1,math.huge do
        --local name, v = debug.getupvalue(value,i)
        --if name == nil then break end
        --res[i+1] = v
      --end
      --return "closure " .. dumplua(res, ident, "closures["..closure_cnt.."]")
    --end
  end
  function dumplua(value, ident, path)
    return fcts[type(value)](value, ident, path)
  end
  if varname == nil then
    varname = "return "
  elseif varname:match("^[%a_][%w_]*$") then
    varname = varname .. " = "
  end
  if fastmode then
    setmetatable(keycache, {__index = make_key })
    out[1] = varname
    table.insert(out,dumplua(value, 0))
    return table.concat(out)
  else
    setmetatable(keycache, {__index = make_key })
    local items = {}
    for i=1,10 do items[i] = '' end
    items[3] = dumplua(value, ident or 0, "t")
    if closure_cnt > 0 then
      items[1], items[6] = dumplua_closure:match("(.*\n)\n(.*)")
      out[#out+1] = ""
    end
    if #out > 0 then
      items[2], items[4] = "local t = ", "\n"
      items[5] = table.concat(out)
      items[7] = varname .. "t"
    else
      items[2] = varname
    end
    return table.concat(items)
  end
end

-- Used to escape "'s by toCSV
local function escapeCSV(s)
  if string.find(s, '[,"]') then
    s = '"' .. string.gsub(s, '"', '""') .. '"'
  end
  return s
end

-- Convert from CSV string to table
function commonlib.fromCSV(s)
  s = s .. ','        -- ending comma
  local t = {}        -- table to collect fields
  local fieldstart = 1
  repeat
    -- next field is quoted? (start with `"'?)
    if string.find(s, '^"', fieldstart) then
      local a, c
      local i  = fieldstart
      repeat
        -- find closing quote
        a, i, c = string.find(s, '"("?)', i+1)
      until c ~= '"'    -- quote not followed by quote?
      if not i then error('unmatched "') end
      local f = string.sub(s, fieldstart+1, i-1)
      table.insert(t, (string.gsub(f, '""', '"')))
      fieldstart = string.find(s, ',', i) + 1
    else                -- unquoted; find next comma
      local nexti = string.find(s, ',', fieldstart)
      table.insert(t, string.sub(s, fieldstart, nexti-1))
      fieldstart = nexti + 1
    end
  until fieldstart > string.len(s)
  return t
end

-- Convert from table to CSV string
function commonlib.toCSV(tt)
  local s = ""
  for _,p in pairs(tt) do
    s = s .. "," .. escapeCSV(p)
  end
  return string.sub(s, 2)      -- remove first comma
end

