--[[
Title: NPL page parser
Author: LiXizhi
Date: 2015/6/9
Desc: 
Everything outside of a pair of opening and closing tags is ignored by the page parser 
which allows npl page files to have mixed content. This allows NPL to be embedded in HTML documents, for example to create templates. 

<verbatim>
1.  <?npl echo 'if you want to serve NPL code in XHTML or XML documents, use these tags'; ?>

2.  <? echo 'this code is within short tags'; ?>
    Code within these tags <?= 'some text' ?> is a shortcut for this code <? echo 'some text' ?>

3.  <% echo 'You may optionally use ASP-style tags'; %>

</verbatim>
-----------------------------------------------
NPL.load("(gl)script/apps/WebServer/npl_page_parser.lua");
local npl_page_parser = commonlib.gettable("WebServer.npl_page_parser");
local parser = npl_page_parser:new(filename):parse();
if (parser) then
	parser:run(code_env)
end
-----------------------------------------------
]]
local npl_http = commonlib.gettable("WebServer.npl_http");
local npl_page_parser = commonlib.inherit(nil, commonlib.gettable("WebServer.npl_page_parser"));

function npl_page_parser:ctor()
end

function npl_page_parser:init(page_manager)
	self.page_manager = page_manager;
	return self;
end

function npl_page_parser:get_filename()
	return self.filename or "unknow_page_file";
end

function npl_page_parser:SetFilename(filename)
	self.filename = filename;
end


-- return nil if failed or the page object 
function npl_page_parser:parse(filename)
	self:set_error_msg(nil);
	self.filename = filename;
	local file = ParaIO.open(filename, "r");
	if(file) then
		LOG.std(nil, "info", "npl_page_parser", "parse file: %s", filename);
		local text = file:GetText();
		if(text) then
			self:parse_text(text);
		else
			LOG.std(nil, "warn", "npl_page_parser", "empty file: %s", filename);	
		end
		file:close();
		return self;
	end
end

function npl_page_parser:parse_text(text)
	local script = self:page_to_npl(text);
	self:compile_npl_script(script);
end

-- convert from mixed mode page text to npl script code text. 
-- return npl script as string.
function npl_page_parser:page_to_npl(text)
	local o = {};
	-- next i
	local ni;
	local i, j = 1, -1;
	local is_in_npl_mode = false;
	-- are we in something like this <?="text"?>
	local is_equal_mode = false;  
	while (true) do
		if(is_in_npl_mode) then
			ni,j = string.find(text, "[%%%?]>\r?\n?", i)
			if(not is_equal_mode) then
				o[#o+1] = string.sub(text, i, (ni or 0)-1);
			else
				is_equal_mode = false;
				o[#o+1] = "echo("
				o[#o+1] = string.sub(text, i, (ni or 0)-1);
				o[#o+1] = ");"
			end
				
			-- check for 0xa == '\n'
			if(j and string.byte(text, j) == 0xa) then
				-- so that the line number in script matches that of the merged script. Ease for reading runtime error.
				o[#o+1] = "\r\n";
			end
		else
			ni,j = string.find(text, "<[%%%?]n?p?l?=?", i)
			local html_text;
			if(ni and ni > 1) then
				is_equal_mode = (j == ni + 2);
				html_text = string.sub(text, i, ni-1);
			elseif(not ni) then
				html_text = string.sub(text, i, -1);
			end
			if(html_text) then
				o[#o+1] = "echo[[";
				-- TODO: escape unmatched [[ ]], since [[]] allow nesting, we will ignore for performance. 
				o[#o+1] = html_text; 
				o[#o+1] = "]];";
			end
		end

		if not ni then 
			break;
		else
			is_in_npl_mode = not is_in_npl_mode;
			i = j + 1;
		end
	end
	return table.concat(o);
end

function npl_page_parser:compile_npl_script(script)
	if(self.script ~= script and script) then
		self.script = script;
		self.code_func, self.errormsg = loadstring(script, self:get_filename());
	end
end

function npl_page_parser:has_error()
	return self.errormsg ~= nil;
end

function npl_page_parser:get_error_msg()
	return self.errormsg;
end

-- this will make the page output this error on all following requests
function npl_page_parser:set_error_msg(msg)
	if(msg) then
		LOG.std(nil, "info", "npl_page_parser", "page %s error: %s", self.filename, msg);
	elseif(self.errormsg) then
		LOG.std(nil, "info", "npl_page_parser", "page %s error cleared", self.filename);
	end
	self.errormsg = msg;
end

function npl_page_parser:send_page_error(msg, code_env)
	code_env = code_env or npl_http.code_env;
	code_env.response:send(string.format("fatal error occurs when running page %s, %s: ", code_env.request:url(), self.filename or ""))
	code_env.response:send(tostring(msg));
end

-- return the call depth
function npl_page_parser:enter_env(code_env)
	local call_depth = (code_env._calldepth_ or 0) + 1;
	code_env._calldepth_ = call_depth;
	if(call_depth == 1) then
		npl_http.code_env = code_env;
		code_env.is_exit_call = nil;
	end
	code_env.__FILE__ = self.filename;
	code_env.page = self;
	return call_depth;
end

-- return the call depth
function npl_page_parser:leave_env(code_env)
	local call_depth = (code_env._calldepth_ or 0) - 1;
	code_env._calldepth_ = call_depth;
	if(call_depth <= 0) then
		npl_http.code_env = nil;
	end
	return call_depth;
end


-- this function may be nest-called such as inside the code_env.include() function. 
-- @param code_env: the code enviroment. echo and print method should be overridden to send. 
-- @return the result of the function call. 
function npl_page_parser:run(code_env)
	if(self.code_func) then
		local last_filename = code_env.__FILE__;
		local last_page = code_env.page;
		self:enter_env(code_env);
		setfenv(self.code_func, code_env);
		local ok, result = pcall(self.code_func);
		local call_depth = self:leave_env(code_env);
		code_env.__FILE__ = last_filename;
		code_env.page = last_page;

		if(not ok) then
			if(not code_env.is_exit_call) then
				-- runtime error:
				self:send_page_error(result, code_env);
				LOG.std(nil, "error", "npl_page_parser", "runtime error: %s", tostring(result));
				-- self:set_error_msg(result);
			else
				if(call_depth==0) then
					if(code_env.exit_msg) then
						code_env.response:send(tostring(code_env.exit_msg));
					end
					code_env.is_exit_call = nil;
				else
					-- forward exit msg to up level run function. 
					code_env.exit(code_env.exit_msg);
				end
			end
		end		
		return result;
	end
end
