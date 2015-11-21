--[[
Title: npl server file api environment
Author: LiXizhi
Date: 2015/6/8
Desc: this class defines functions that can be used inside npl server page file
Following objects and functions can be used inside page script:
	request:   current request object: headers and cookies
	response:   current response object: send headers or set cookies, etc.
	echo(text):   output html
	__FILE__: current filename
	page: the current page (parser) object
	_GLOBAL: the _G itself

following are exposed via meta class:
	include(filename):  inplace include another script
	include_once(filename):  include only once, mostly for defining functions
	print(...):  output html with formated string.   
	nplinfo():   output npl information.
	exit(text), die():   end the request
	dirname(__FILE__):   get directory name
	site_url(path, scheme): 
	addheader(name, value):
	file_exists(filename):
	log(obj)
	sanitize(text)  escape xml '<' '>' 
	json_encode(value)   to json string
	xml_encode(value)    to xml string
	include_pagecode(code, filename):  inplace include page code. 
	get_file_text(filename) 

I may consider reimplement some handy functions from php reference below. 
However, the exposed request and response object already contains everything you need. 
References: 
	http://php.net/manual/en/function.header.php
	http://php.net/manual/en/reserved.variables.server.php
	http://php.net/manual/en/features.http-auth.php
-----------------------------------------------
NPL.load("(gl)script/apps/WebServer/npl_page_env.lua");
local npl_page_env = commonlib.gettable("WebServer.npl_page_env");
local env = npl_page_env:new(req, res);
-----------------------------------------------
]]
NPL.load("(gl)script/ide/System/Core/Filters.lua");
NPL.load("(gl)script/ide/Json.lua");
local npl_http = commonlib.gettable("WebServer.npl_http");
local npl_page_env = commonlib.gettable("WebServer.npl_page_env");
local util = commonlib.gettable("WebServer.util");

local tostring = tostring;

npl_page_env.__index = npl_page_env;

-- SECURITY: expose global _G to server env, this can be useful and dangourous.
setmetatable(npl_page_env, {__index = _G});


-- expose: request, response, echo and print to npl script. 
function npl_page_env:new(request, response)
	local o = {
		request = request,
		response = response,
		echo = function(text)
			if(text~=nil) then
				response:send(tostring(text));
			end
		end,
	};
	o._GLOBAL = o;
	setmetatable(o, self);
	return o;
end

-- handy function to output using current request context
-- @param text: string or number or nil or boolean. 
local function echo(text)
	local self = npl_http.code_env;
	self.echo(text);
end

-- same as self.echo(string.format(...))
function npl_page_env.print(...)
	local self = npl_http.code_env;
	self.echo(string.format(...));
end

-- similar to phpinfo()
-- output everything about the environment and the request including all request headers.
function npl_page_env.nplinfo()
	local self = npl_http.code_env;
	echo("<p>NPL web server v1.0</p>");
	echo(format("<p>site url: %s</p>", self.site_url() or ""))
	echo(format("<p>your ip: %s</p>", self.request:getpeername() or ""))
	echo("<p>");
	echo(commonlib.serialize(self.request.headers, true):gsub("\n", "<br/>"));
	echo("</p>");
end

-- similar to php.exit()
-- Output a message and terminate the current script
-- @param msg: output this message. usually nil. 
function npl_page_env.exit(msg)
	local self = npl_http.code_env;
	-- the caller use xpcall with custom error function, so caller will catch it gracefully and end the request
	self.is_exit_call = true;
	self.exit_msg = msg;
	error("exit_call");
end

-- alias for exit()
npl_page_env.die = npl_page_env.exit;

-- similar to php.dirname() however with the trailing /
-- get the directory name of the given file with the trailing /. 
-- @param filename: if nil, self.__FILE__ is used. 
function npl_page_env.dirname(filename)
	local self = npl_http.code_env;
	filename = filename or self.__FILE__;
	local dir = filename:gsub("[^/]+$", "");
	return dir;
end

-- @param filename: file path, relative or absolute. 
-- begin with './', relative to current file
-- begin with '/', relative to web root directory
-- no "/" in filename, relative to current file
-- otherwise, filename is absolute path. 
function npl_page_env.getfilepath(filename)
	local self = npl_http.code_env;
	local firstByte = filename:byte(1);
	if(firstByte == 46 and filename:byte(2) == 47) then 
		-- begin with './', relative to current file
		filename = self.dirname(self.__FILE__)..filename:sub(3, -1);
	elseif(firstByte == 47) then
		-- begin with '/', relative to web root directory
		filename = WebServer:webdir()..filename:sub(2, -1);
	elseif(not string.find(filename, "/")) then
		filename = self.dirname(self.__FILE__)..filename;
	else
		filename = filename:gsub("/[/]+", "/");
	end
	return filename;
end


-- Checks whether a file exists
function npl_page_env.file_exists(filename)
	return ParaIO.DoesFileExist(filename, true);
end

-- private: add file to be already included
function npl_page_env:add_include_file(filename)
	-- self.__includes mapping from filename to true
	local includes = self.__includes;
	if(not includes) then
		includes = {}
		self.__includes = includes;
	end
	if(not includes[filename]) then
		includes[filename] = true;
	end
end

-- private: return true if file is already included in the environment. 
function npl_page_env:has_include_file(filename)
	return (self.__includes and self.__includes[filename]);
end


-- similar to php.include: http://php.net/manual/en/function.include.php
-- The include statement includes and evaluates the specified file and return its result if any.
-- the included file share the same global environment as the caller. Unlike php, if you include another file 
-- inside a function, upvalues are NOT shared due to the lexical scoping nature of lua. 
-- Please note that exit() call will fallthrough all nested include and terminate the request.
-- e.g.
--		include(dirname(__FILE__).."test_include.page");
--		include("test_include.page");  -- identical to above
-- @param filename: if no parent directory is specified, we will assume it is from the containing file's parent directory. 
--      if filename begins with "/", it will append the web root directory. 
-- @return: result of the included function. 
function npl_page_env.include(filename)
	local self = npl_http.code_env;
	filename = self.getfilepath(filename);
	local page = self.page.page_manager:get(filename);
	if(page) then
		self:add_include_file(filename);
		if(not page:get_error_msg()) then
			return page:run(self);
		else
			LOG.std(nil, "error", "npl_env", "include() failed: error parse file %s: %s", filename, page:get_error_msg() or "");
			self.exit(page:get_error_msg());
		end
	else
		LOG.std(nil, "error", "npl_env", "include() failed for file %s", filename);
		self.exit(string.format("include() failed for file %s", filename));
	end
end

-- same as include(), expect that this function only takes effect on first call for a given env.
function npl_page_env.include_once(filename)
	local self = npl_http.code_env;
	filename = self.getfilepath(filename);
	if(not self:has_include_file(filename)) then
		return npl_page_env.include(filename);
	end
end

-- include a given page code. 
-- @param code: the actual code string to include. 
-- @param filename: nil to default to current file. only used for displaying error
function npl_page_env.include_pagecode(code, filename)
	local self = npl_http.code_env;
	filename = filename or (self.__FILE__.."#pagecode");
	local page = self.page.page_manager:get_by_code(code, filename);
	if(page) then
		self:add_include_file(filename);
		if(not page:get_error_msg()) then
			return page:run(self);
		else
			LOG.std(nil, "error", "npl_env", "include_pagecode() failed: error parse file %s: %s", filename, page:get_error_msg() or "");
			self.exit(page:get_error_msg());
		end
	end
end


-- return the site url like http://localhost:8080/
function npl_page_env.site_url(filename, scheme)
	return WebServer:site_url(filename, scheme);
end

-- add header, only possible when header is not sent yet. 
function npl_page_env.addheader(name, value)
	local self = npl_http.code_env;
	self.response:add_header(name, value);
end

-- set header (replace previously set values), only possible when header is not sent yet. 
function npl_page_env.setheader(name, value)
	local self = npl_http.code_env;
	self.response:set_header(name, value);
end

-- simple log any object, same as echo. 
function npl_page_env.log(...)
	commonlib.echo(...);
end

-- Sanitizes all HTML tags
function npl_page_env.sanitize(text)
	if(text) then
		return util.sanitize(text);
	end
end

-- Returns a string containing the JSON representation of value. 
function npl_page_env.json_encode(value)
	return commonlib.Json.Encode(value);
end

-- Returns a string containing the Xml representation of value. 
function npl_page_env.xml_encode(value)
	return commonlib.Lua2XmlString(value);
end

-- get file text
function npl_page_env.get_file_text(filename)
	local file = ParaIO.open(filename, "r");
	local text;
	if(file and file:IsValid()) then
		text = file:GetText();
		file:close();
	end
	return text;
end
