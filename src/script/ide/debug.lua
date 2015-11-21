--[[
Title: debug funcions in commonlib
Author(s): LiXizhi
Date: 2006/11/25
Desc: debug related functions in commonlib
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/debug.lua");
commonlib.echo(commonlib.debugstack(2, 5, 1))
-------------------------------------------------------
]]
if(not commonlib) then commonlib={}; end
local commonlib = commonlib;
local log = log;
local tostring = tostring;
local ShowDebugStringKeys = {count=1};
local string_format = string.format

commonlib.debug = commonlib.debug or {};

-- dump webservice result to log file, it will dump str (if not nil) followed by the msg struct content.
-- @param str: nil or any name
function commonlib.DumpWSResult(str)
	if(str == nil) then str = "" end
	if(msg == nil) then
		log(str.." has WS callback: nil \r\n");
	else
		log(str.." has WS callback:"..commonlib.serialize(msg).."\r\n");
	end	
end

-- show debug string using a UI control on the left top of the screen. call this function with multiple keys will display string in separate lines. 
-- @param keyname: string key name, can not be nil
-- @param value: any value to display, such as string, number or table
function commonlib.ShowDebugString(keyname, value)
	local top=0;
	if(ShowDebugStringKeys[keyname]~=nil) then
		top = ShowDebugStringKeys[keyname];
	else
		top = 20*ShowDebugStringKeys.count;
		ShowDebugStringKeys[keyname] = top;
		ShowDebugStringKeys.count = ShowDebugStringKeys.count + 1;
	end
	local _this = ParaUI.GetUIObject("_debug_str_"..keyname);
	if(not _this:IsValid()) then
		_this=ParaUI.CreateUIObject("text","_debug_str_"..keyname, "_lt",0,0,1280,40);
		_this.zorder = 100;
		_this:AttachToRoot();	
	end
	_this.translationx = 10;
	_this.translationy = 100+top;
	_this.text=keyname..":"..commonlib.serialize_compact2(value);
end
-- short cut
commonlib.show = commonlib.ShowDebugString;

--[[
@param level Number - the stack depth at which to start the stack trace (default 1 - the function calling debugstack) 
@param count1 Number - the number of functions to output at the top of the stack (default 12) 
@param count2 Number - the number of functions to output at the bottom of the stack (default 10) 
@return String - a multi-line string showing what the current call stack looks like 
If there are more than count1+count2 calls in the stack, they are separated by a "..." line. 
e.g. local stack = commonlib.debugstack()
]]
function commonlib.debugstack(level, count1, count2)
	if not level then level = 1 end
	if not count1 then count1 = 12 end
	if not count2 then start = 10 end
	local res = "";
	level = level+1;
	local count = 1;
	while true do
		local info = debug.getinfo(level, "nSl")
		if not info then break end
		-- TODO: only print first count1 lines and last count2 lines. Print "..." for the rest
		if info.what == "C" then   
			-- a C function
			res = res.."C function\n"
		else   
			-- a Lua function
			if(info.name~=nil) then
				res = res..string_format("%s:%d: in function %s\n",
								info.source, info.currentline,tostring(info.name))
			else
				res = res..string_format("%s:%d:\n",info.source, info.currentline)
			end					
		end
		level = level + 1
		count = count + 1
    end
    return res;
end

-- get formated file, line number, function info
-- @param level Number - the stack depth at which to start the stack trace (default 1 - the function calling locationinfo) 
function commonlib.debug.locationinfo(level)
	if not level then level = 1 end
	local res = "";
	level = level+1;
	local info = debug.getinfo(level, "nSl")
	
	if not info then return res end
	
	if info.what == "C" then   
		-- a C function
		res = res.."C function:"
	else   
		-- a Lua function
		if(info.name~=nil) then
			res = res..string_format("%s:%d: in function %s",
							info.source, info.currentline,tostring(info.name))
		else
			res = res..string_format("%s:%d:",info.source, info.currentline)
		end					
	end
	return res;
end

-- e.g. commonlib.error(table,"error:%d", no) 
-- in most case, one can assign this function to be a member of a certain table.
function commonlib.warning(self, message, ...)
	commonlib.log(message, ...)
	log("\n")
end

local tmp = {};
-- e.g. commonlib.error(table,"error:%d", no) 
-- in most case, one can assign this function to be a member of a certain table.
function commonlib.error(self, message, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
	table.resize(tmp, 0);
	if a1 ~= nil then table.insert(tmp, a1)
	if a2 ~= nil then table.insert(tmp, a2)
	if a3 ~= nil then table.insert(tmp, a3)
	if a4 ~= nil then table.insert(tmp, a4)
	if a5 ~= nil then table.insert(tmp, a5)
	if a6 ~= nil then table.insert(tmp, a6)
	if a7 ~= nil then table.insert(tmp, a7)
	if a8 ~= nil then table.insert(tmp, a8)
	if a9 ~= nil then table.insert(tmp, a9)
	if a10 ~= nil then table.insert(tmp, a10)
	if a11 ~= nil then table.insert(tmp, a11)
	if a12 ~= nil then table.insert(tmp, a12)
	if a13 ~= nil then table.insert(tmp, a13)
	if a14 ~= nil then table.insert(tmp, a14)
	if a15 ~= nil then table.insert(tmp, a15)
	if a16 ~= nil then table.insert(tmp, a16)
	if a17 ~= nil then table.insert(tmp, a17)
	if a18 ~= nil then table.insert(tmp, a18)
	if a19 ~= nil then table.insert(tmp, a19)
	if a20 ~= nil then table.insert(tmp, a20)
	end end end end end end end end end end end end end end end end end end end end
	
	local stack = commonlib.debugstack(2)
	if not message then
		message = "error raised!"
	else
		for i,v in ipairs(tmp) do
			tmp[i] = tostring(v)
		end
		message = string_format(message, unpack(tmp))
	end
	if getmetatable(self) and getmetatable(self).__tostring then
		message = string_format("%s: %s", tostring(self), message)
	end
	log(string_format("%s\nCall stack:\n%s\n", message, stack))
	return
end

-- e.g. commonlib.assert(table, cond==1, "error:%d", no) 
-- in most case, one can assign this function to be a member of a certain table.
function commonlib.assert(self, condition, message, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
	if not condition then
		if not message then
			message = "assertion failed!"
		end
		error(self, message, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15, a16, a17, a18, a19, a20)
		return
	end
	return condition
end