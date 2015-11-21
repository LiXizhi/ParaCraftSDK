--[[
Title: advanced log function
Author: LiXizhi
Date : 2008.3.5, Revised 2009.7.11 LiXizhi
Desc: Four log API are provided. 
   * commonlib.log for ad-hoc log. 
   * commonlib.applog for date formated application log. 
   * commonlib.servicelog for date formated multi-file log with append. 
   * commonlib.logging for 5 level based logging with custom listener(appender). 

A logging message also has a level associated with it. The levels defined in the system are, in order of decreasing
severity: FATAL, ERROR, WARN, INFO, DEBUG, TRACE. Levels are important because the level of a logger can be
set in the configuration file. Only a message with a level equal to or more severe than the level of the logger will pass
through the logger.

The logging system has been designed to impact General Interface performance as little as possible. The following is a
common idiom that is used when constructing the logging message is expensive. The code simply checks the logger to
see whether the logging message will pass the logger's level before sending the message.

local LOG = LOG; -- commonlib.logging.GetLogger("")
LOG.level = "ERROR";

if (LOG("INFO")) then
	LOG.info(string.format("string formatting is %s", "expensive. That is why we do a if before log."));
end
LOG.info("this is less expansive %s", "even without checking is isLoggable.");
LOG.debug("for non-time critical log simply %s", "write without check isLoggable");
LOG.error("some error is seen");
LOG.fatal({table_is_fine = "fatal error is seen"});
LOG.trace("tracing should be removed at release time: 11111111111111111111");
LOG.applog("write the applog with date time which is always printed. ");
LOG.ui("keyname", {value="show in UI on left top corner"})
LOG.show("keyname1", "LOG.show is same as LOG.ui")
LOG.std("thread_id","error","sub_system_name", "some formated message or data");

For more example, please see test/TestLog.lua.

use the lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/log.lua");
commonlib.log("hello %s \n", "paraengine")
commonlib.log({"anything"})
local fromPos = commonlib.log.GetLogPos()
log(fromPos.." babababa...\n");
local text = commonlib.log.GetLog(fromPos, nil)
log(tostring(text).." is retrieved\n")

commonlib.applog("hello paraengine"); --> ./log.txt --> 20090711 02:59:19|0|hello paraengine|script/shell_loop.lua:23: in function FunctionName|
commonlib.applog("hello %s", "paraengine") 

commonlib.servicelog("MyService", "hello paraengine"); --> ./MyService_20090711.log --> 2009-07-11 10:53:27|0|hello paraengine||
commonlib.servicelog("MyService", "hello %s", "paraengine");

-- set log properties before using the log
commonlib.servicelog.GetLogger("no_append"):SetLogFile("log/no_append.log")
commonlib.servicelog.GetLogger("no_append"):SetAppendMode(false);
commonlib.servicelog.GetLogger("no_append"):SetForceFlush(true);
commonlib.servicelog("no_append", "test");
-------------------------------------------------------
]]

if(not commonlib) then commonlib={}; end

local commonlib = commonlib;
local WriteToLogFile = ParaGlobal.WriteToLogFile;
local type, table, string, assert, tostring = type, table, string, assert, tostring
local string_gsub = string.gsub;
local string_sub = string.sub;
local string_format = string.format;
local format = format;
local ParaGlobal_timeGetTime = ParaGlobal.timeGetTime
local npl_thread_name = __rts__:GetName();
---------------------------------------------
-- log file class 
---------------------------------------------
if(not commonlib.log) then commonlib.log = {} end
local log_ = commonlib.log;

local nLastTime = 0;
local nLastDateTime = 0;
local date_str = ParaGlobal.GetDateFormat("yyyy-MM-dd");
local time_str = ParaGlobal.GetTimeFormat(nil);

-- get the standard time format string. 
-- return the date_str, time_str, and the tick count. 
local function GetLogTimeString()
	local nCurTime = ParaGlobal_timeGetTime();
	-- fixed time wrapping
	if((nCurTime - nLastTime) > 1000 or nCurTime < nLastTime) then
		nLastTime = nCurTime;
		if((nCurTime - nLastDateTime)>3600000 or nCurTime < nLastDateTime) then
			date_str = ParaGlobal.GetDateFormat("yyyy-MM-dd");
		end
		time_str = ParaGlobal.GetTimeFormat(nil);
	end
	return date_str, time_str, nCurTime
end

commonlib.log.GetLogTimeString = GetLogTimeString;

-- it support logging string longer than 1024 bytes by deviding input into multiple sections.
-- By default: log(string) longer than 1024 is cut. Use this function if u want to log something really long
-- @param str: the string to log. 
-- @param maxLength: if nil it is unlimited. 
function commonlib.log.log_long(str, maxLength)
	local nSize = #(str);
	-- should be smaller than the one defined in ParaEngine log size (1024 bytes)
	local nBlockSize = 1000;

	if( nSize < nBlockSize and (not maxLength or nSize <= maxLength)) then
		WriteToLogFile(str);
	else
		if(maxLength and nSize > maxLength) then
			nSize = maxLength;
		end
		
		local nFrom, nTo = 1,-1;
		while (nFrom<=nSize) do
			nTo = nFrom+nBlockSize-1;
			if(nTo > nSize) then
				nTo = nil;
			end
			WriteToLogFile(string_sub(str, nFrom, nTo));
			nFrom = nFrom + nBlockSize;
		end
	end
end

local log_long = commonlib.log.log_long;

-- @namespace: commonlib.log
-- logging with no limit to size and with formatting. 
-- support formatting: commonlib.log("hello %s \n", "paraengine")
commonlib.log = setmetatable(commonlib.log, {__call = function(self, input, ...)
	if(type(input) == "string") then
		local args = {...};
		if(#args == 0) then
			log_long(input)
		else
			log_long(string_format(input, ...));
		end	
	elseif(type(input) == "table") then	
		log_long(commonlib.serialize(input));
	else
		log_long(tostring(input));
	end
end});

-- get the current log file position. it is equavalent to the log file size in bytes. 
-- one can later get log text between two Log positions. 
function commonlib.log.GetLogPos()
	return ParaGlobal.GetLogPos()
end

-- get log text between two Log positions. 
-- @param fromPos: position in bytes. if nil, it defaults to 0
-- @param nCount: count in bytes. if nil, it defaults to end of log file. 
-- @return string returned. 
function commonlib.log.GetLog(fromPos, nCount)
	fromPos = fromPos or 0;
	nCount = nCount or -1;
	return ParaGlobal.GetLog(fromPos, nCount);
end

---------------------------------------------
-- application log
---------------------------------------------

if(not commonlib.applog) then commonlib.applog = {} end

-- it support logging string longer than 1024 bytes by deviding input into multiple sections.
-- By default: log(string) longer than 1024 is cut. Use this function if u want to log something really long
-- @param str: the string to log. 
-- @param maxLength: if nil it is unlimited. 
function commonlib.applog.log_long(str, maxLength, level, use_location)
	local date_str, time_str = GetLogTimeString();
	
	level = level or 0;
	WriteToLogFile(format("%s %s|%d|", date_str, time_str, level or 0));
	log_long(str, maxLength);
	if(level>=0) then
		WriteToLogFile("|"..commonlib.debug.locationinfo(3).."|\n");
	else	
		WriteToLogFile("|\n");
	end	
end
local app_log_long = commonlib.applog.log_long;

if(not commonlib.stdlog) then commonlib.stdlog = {} end
function commonlib.stdlog.log_long(thread_or_word,level,module_name,str)
	local date_str, time_str = GetLogTimeString();
	
	WriteToLogFile(format("%s %s|%s|%s|%s|", date_str, time_str, thread_or_word or npl_thread_name,level or "",module_name or ""));
	log_long(str, 10240);
	if(level == "error" or level == "warning") then
		WriteToLogFile("|"..commonlib.debug.locationinfo(3).."\n");
	else	
		WriteToLogFile("\n");
	end	
end
local std_log_long = commonlib.stdlog.log_long;

-- @namespace: commonlib.stdlog
-- logging in date formated string with file and line number
-- support formatting: commonlib.applog("hello %s \n", "paraengine")
commonlib.stdlog = setmetatable(commonlib.stdlog, {__call = function(self, thread_or_word,level,module_name,input, ...)
	if(type(input) == "string") then
		local args = {...};
		if(#args == 0) then
			std_log_long(thread_or_word,level,module_name,input)
		else
			std_log_long(thread_or_word,level,module_name,string_format(input, ...));
		end	
	elseif(type(input) == "table") then	
		std_log_long(thread_or_word,level,module_name,commonlib.serialize_compact(input));
	else
		std_log_long(thread_or_word,level,module_name,tostring(input));
	end
end});


-- @namespace: commonlib.applog
-- logging in date formated string with file and line number
-- support formatting: commonlib.applog("hello %s \n", "paraengine")
commonlib.applog = setmetatable(commonlib.applog, {__call = function(self, input, ...)
	if(type(input) == "string") then
		local args = {...};
		if(#args == 0) then
			app_log_long(input)
		else
			app_log_long(string_format(input, ...));
		end	
	elseif(type(input) == "table") then	
		app_log_long(commonlib.serialize_compact(input));
	else
		app_log_long(tostring(input));
	end
end});

---------------------------------------------
-- service log
---------------------------------------------

-- a mapping from logger name to logger pointer. 
local loggers_pool = {}

-- it support logging string longer than 1024 bytes
-- @param str: the string to log. 
-- @param maxLength: if nil it is unlimited. 
local function service_log_long(logger_name, str, maxLength)
	local logger = loggers_pool[logger_name or ""];
	if(not logger) then
		logger = ParaGlobal.GetLogger(logger_name or "");
		loggers_pool[logger_name or ""] = logger;
	end

	local nSize = #(str);
	if(maxLength) then
		if(nSize > maxLength) then
			nSize = maxLength;
		end
	end
	-- should be smaller than the one defined in ParaEngine log size (1024 bytes)
	local nBlockSize = 960;
	if(nSize>nBlockSize) then
		local nFrom, nTo = 1,-1;
		while (nFrom<=nSize) do
			nTo = nFrom+nBlockSize-1;
			if(nTo > nSize) then
				nTo = nil;
			end
			logger:log(0, string_sub(str, nFrom, nTo));
			nFrom = nFrom + nBlockSize;
		end
	else
		logger:log(0, str);
	end
end

-- @namespace: commonlib.servicelog
-- logging in date formated string with file and line number
-- support formatting: commonlib.servicelog("logger_name", "hello %s \n", "paraengine")
commonlib.servicelog = setmetatable({}, {__call = function(self, logger_name, input, ...)
	if(type(input) == "string") then
		local args = {...};
		if(#args == 0) then
			service_log_long(logger_name, input)
		else
			service_log_long(logger_name, string_format(input, ...));
		end	
	elseif(type(input) == "table") then	
		service_log_long(logger_name, commonlib.serialize(input));
	else
		service_log_long(logger_name, tostring(input));
	end
end});

commonlib.servicelog.log_long = service_log_long;

-- get a given logger. we usually do 
-- e.g. 
-- commonlib.servicelog.GetLogger("no_append"):SetAppendMode(false);
-- commonlib.servicelog.GetLogger("no_append"):SetForceFlush(true);
function commonlib.servicelog.GetLogger(logger_name)
	local logger = loggers_pool[logger_name or ""];
	if(not logger) then
		logger = ParaGlobal.GetLogger(logger_name or "");
	end
	return logger
end

---------------------------------------------
-- advanced logging similar to log4j.
---------------------------------------------

if(not commonlib.logging) then commonlib.logging = {} end
local logging = commonlib.logging;

-- The TRACE level designates temporary print log events. It makes itself stands out in the log file and should be removed completely from source code at release time. 
local TRACE = "TRACE"
-- The DEBUG Level designates fine-grained events that are most useful to debug an application
local DEBUG = "DEBUG"
-- The INFO level designates messages that highlight the progress of the application at coarse-grained level
local INFO = "INFO"
-- The WARN level designates potentially harmful situations
local WARN = "WARN"
-- The ERROR level designates error events that might still allow the application to continue running 
local ERROR = "ERROR"
-- The FATAL level designates very severe error events that will presumably lead the application to abort
local FATAL = "FATAL"

local LEVEL = {
	[TRACE] = 1,
	[DEBUG] = 2,
	["debug"] = 2,
	["Debug"] = 2,
	["user"] = 3,
	["system"] = 3,
	["info"] = 4,
	["warn"] = 4,
	["warning"] = 4,
	["error"] = 5,
	["fatal"] = 6,
	[INFO]  = 3,
	[WARN]  = 4,
	[ERROR] = 5,
	[FATAL] = 6,
}

local loggers = {};

-- create get a logger with a given name. 
-- @param name: name of the logger. if nil or "", it is the default global logger. 
function logging.GetLogger(name)
	local logger = loggers[name or ""];
	if(logger) then
		return logger;
	else
		logger = logging.new({name = name or ""});
		return logger;
	end
end

-------------------------------------------------------------------------------
-- Creates a new logger object
-- @param o: nil or empty table or table of {name="MyLogName"}
-- @return Table representing the new logger object.
-------------------------------------------------------------------------------
function logging.new(o)
	local logger = o or {};
	logger.level = DEBUG
	if(logger.name) then
		loggers[logger.name] = logger;
	end
	-- a function of type function(level, ...), where the argument can be string, table or string with format pattern.
	local appender;

	-- set log level
	logger.setLevel = function (self, level)
		assert(LEVEL[level], format("undefined level `%s'", tostring(level)))
		self.level = level
	end

	-- whether log is enabled for a given level. 
	logger.isLoggable = function (self, level)
		local nLevel = LEVEL[level];
		if (nLevel and nLevel < LEVEL[self.level]) then
			return false;
		else
			return true;
		end
	end
	-- meta table defaults to checking isLoggable.
	setmetatable(logger, {__call = logger.isLoggable});

	-- set output formatted log at the given level. 
	logger.log = function (self, level, ...)
		local nLevel = LEVEL[level];
		if (nLevel and nLevel < LEVEL[self.level]) then
			return
		end
		if(not appender) then
			WriteToLogFile(level..":");
			log_(...);
			WriteToLogFile("\n");
		else
			appender(level, ...);
		end
	end
	local log = logger.log;

	-- an optional appender function. If no appender is specified, the message will go to the default log.txt file.
	-- by using a custom appender, one can dump log to UI, file, or network, etc. 
	logger.setAppender = function (AppenderFunc)
		appender = AppenderFunc;
	end

	-- standard log with date_time, level, module_name and any output format. 
	logger.std = function (thread_or_word,level,module_name,input, ...) 
		local nLevel = LEVEL[level];
		if (nLevel and nLevel < LEVEL[logger.level]) then
			return;
		end
		if(type(input) == "string") then
			local args = {...};
			if(#args == 0) then
				std_log_long(thread_or_word,level,module_name,input)
			else
				local ok, result = pcall(string_format, input, ...);
				if ok then
					std_log_long(thread_or_word,level,module_name,string_format(input, ...));
				else
					std_log_long(thread_or_word,level,module_name, string.format("<runtime error> in LOG.std. input:%q with %s \n reason:%s \n callstack:%s", input, commonlib.serialize_compact({...}), tostring(result), commonlib.debugstack(2)));
				end
			end	
		elseif(type(input) == "table") then	
			std_log_long(thread_or_word,level,module_name,commonlib.serialize_compact(input));
		else
			std_log_long(thread_or_word,level,module_name,tostring(input));
		end
	end
	logger.debug = function (...) log(logger, DEBUG, ...) end
	logger.info  = function (...) log(logger, INFO,  ...) end
	logger.warn  = function (...) log(logger, WARN,  ...) end
	logger.error = function (...) log(logger, ERROR, ...) end
	logger.fatal = function (...) log(logger, FATAL, ...) end
	logger.trace = function (...) 
		local level = TRACE;
		local nLevel = LEVEL[level];
		if (nLevel and nLevel < LEVEL[logger.level]) then
			return
		end
		if(not appender) then
			WriteToLogFile(level..":");
			log_(...);
			WriteToLogFile("\n");
			-- here we simply make the log stands out by printing some slash, time, and filename
			local date_str, time_str = GetLogTimeString();
			WriteToLogFile(format("----------------------- time:%s | trace in file: %s|\n\n", time_str, commonlib.debug.locationinfo(2)));
		else
			appender(level, ...);
		end
	end
	-- convert to string 
	logger.tostring = function(input, ...)
		local result;
		if(type(input) == "string") then
			local args = {...};
			if(#args == 0) then
				result = input;
			else
				result = string_format(input, ...);
			end	
		elseif(type(input) == "table") then	
			result = commonlib.serialize_compact(input);
		else
			result = tostring(input);
		end
		return result;
	end

	-- write the applog with date time which is always printed. 
	logger.applog = function (...) 
		if(not appender) then
			commonlib.applog(...)
		else
			appender(level or 0, ...);
		end
	end
	-- log level is always the lowest TRACE
	-- show debug string using a UI control on the left top of the screen. call this function with multiple keys will display string in separate lines. 
	-- @param keyname: string key name, can not be nil
	-- @param value: any value to display, such as string, number or table
	logger.ui = function (keyname, value) 
		if (logger.level ~= TRACE) then
			return
		end
		commonlib.show(keyname, value);
	end
	logger.show = logger.ui;
	return logger
end

-- create a global logger with level "TRACE", one can usually set to "WARN" for release mode
LOG = commonlib.logging.GetLogger("");
LOG.level = "TRACE";

