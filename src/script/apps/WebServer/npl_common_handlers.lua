--[[
Title: common handlers
Author: LiXizhi
Date: 2015/6/8
Desc: 
-----------------------------------------------
NPL.load("(gl)script/apps/WebServer/npl_common_handlers.lua");
local common_handlers = commonlib.gettable("WebServer.common_handlers");
-----------------------------------------------
]]
NPL.load("(gl)script/ide/socket/url.lua");
local url = commonlib.gettable("commonlib.socket.url")
local common_handlers = commonlib.gettable("WebServer.common_handlers");

local tostring = tostring;

function common_handlers.err_404 (req, res)
	res.statusline = "HTTP/1.1 404 Not Found"
	res.headers["Content-Type"] = "text/html"
	res.content = string.format ([[
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>404 Not Found</TITLE>
</HEAD><BODY>
<H1>Not Found</H1>
The requested URL %s was not found on this server.<P>
</BODY></HTML>]], req.built_url);
	return res
end

function common_handlers.err_403 (req, res)
	res.statusline = "HTTP/1.1 403 Forbidden"
	res.headers ["Content-Type"] = "text/html"
	res.content = string.format ([[
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>403 Forbidden</TITLE>
</HEAD><BODY>
<H1>Forbidden</H1>
You are not allowed to access the requested URL %s .<P>
</BODY></HTML>]], req.built_url);
	return res
end

function common_handlers.err_405 (req, res)
	res.statusline = "HTTP/1.1 405 Method Not Allowed"
	res.content = string.format ([[
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<HTML><HEAD>
<TITLE>405 Method Not Allowed</TITLE>
</HEAD><BODY>
<H1>Not Found</H1>
The Method %s is not allowed for URL %s on this server.<P>
</BODY></HTML>]], req.cmd_mth, req.built_url);
	return res
end

-----------------------------------------------------------------------------
-- URL patterns handler
-----------------------------------------------------------------------------
local function path_iterator (path)
	return path_p, path
end

local function match_url (req, conf)
  local path = req.relpath
  for _, rule in ipairs(conf) do
    for _, pat in ipairs(rule.pattern) do
      local cap = { string.match(path, pat) }
      if #cap > 0 then 
		req.handler = rule.handler
		return cap 
      end
    end
  end
end

function common_handlers.patternhandler(conf)
	if not conf or type (conf) ~= "table" then return nil end

	return function (req, res)
		local cap = match_url (req, conf) or {}
		local h = req.handler or common_handlers.err_404;
		return h (req, res, cap)
	end
end

-----------------------------------------------------------------------------
-- virtual hosts handler
-----------------------------------------------------------------------------
function common_handlers.vhostshandler(vhosts)
	return function (req, res)
		local h;
		local allow;

		if (vhosts[req.headers.host]) then
			allow = vhosts[req.headers.host].allow;
			h = vhosts[req.headers.host].rule
		elseif (vhosts[""]) then
			allow = vhosts[""].allow
			h = vhosts[""].rule
		end

		local isAllow = true;
		
		local function IsIPAllow(allowip, judgeip)
			local ip;
			local judgeip = tostring(judgeip)
			for _,ip in pairs(allowip) do
				--LOG.std(nil, "debug", "WebServer ip",string.format("ip:%s, judgeip:%s", ip, judgeip));
				if (ip==judgeip) then
					return true;
				end
			end
			return false;
		end

		local remote_ip=string.gsub (req:getpeername(), ":%d*$", "")
		--LOG.std(nil, "debug", "WebServer allowip", allow);
		--LOG.std(nil, "debug", "WebServer remoteip", remote_ip);
		if (allow and type(allow)=="table") then
			isAllow = IsIPAllow(allow,remote_ip);
		end

		if (not isAllow) then		
			h = common_handlers.err_403; 
			LOG.std(nil, "warn", "WebServer Deny", remote_ip);
		end
		return h (req, res)
	end
end

-----------------------------------------------------------------------------
-- URL paths handler
-----------------------------------------------------------------------------

local function path_p (s, p)
	if not p then return s end
	if p=="" then return nil end
	return string.gsub (p, "[^/]*/?$", "")
end 

local function path_iterator (path)
	return path_p, path
end

local function match_url (req, conf)
	local path = req.relpath
	local h = nil
	for p in path_iterator (path) do
		h = conf [p]
		if h then
			req.match = p
			break
		end
	end
	
	if req.match then
		local _,_,pfx = string.find (req.match, "^(.*/)[^/]-$")
		assert (string.sub (path, 1, string.len (pfx)) == pfx)
		req.relpath = string.sub (path, string.len (pfx)+1)
	end
	req.handler = h
end

function WebServer.urlhandler (conf)
	if not conf or type (conf) ~= "table" then return nil end
	
	return function (req, res)
		match_url (req, conf)
		local h = req.handler or WebServer.common_handlers.err_404
		return h (req, res)
	end
end

-------------------------------------------------------------------------------
-- redirect handler
-------------------------------------------------------------------------------
-- params = { dest, action }
-- dest can be of three kinds:
--	absolute: begins with protocol string or '/', the entire path is replaced with dest
--	concat: begins with ':', dest is appended to the path
--	relative: dest is appended to the dirname of the path
-- if used with patternhandler, dest can use the captures with %1, %2 etc.
-- action can be "redirect" or "rewrite", default is "rewrite", except when
--      dest starts with a protocol string
local function redirect (req, res, dest, action, cap)
	dest = string.gsub(dest, "%%(%d)", function (capn) return cap[tonumber(capn)] or "" end)
	dest = string.gsub(dest, "%%%%", "%")
  
	local path = req.parsed_url.path
	local pfx = string.sub (dest, 1,1)
  
	if pfx == "/" then
		path = dest
	elseif pfx == ":" then
		path = path .. string.sub (dest, 2)
	elseif dest:find("^[%w]+://") then
		path = dest
		action = "redirect"
	else
		path = string.gsub (path, "/[^/]*$", "") .. "/" .. dest
	end

	local path, query = path:match("^([^?]+)(%??.*)$")  
	req.parsed_url.path = path
	req.built_url = url.build (req.parsed_url) .. (query or "")
	req.cmd_url = string.gsub (req.built_url, "^[^:]+://[^/]+", "")
  
	if action == "redirect" then
		res:redirect(path .. (query or ""));
		return res    
	elseif type(action) == "function" then
		return action(req, res, cap)
	else
		return "reparse"
	end
end

if(not WebServer.redirecthandler) then WebServer.redirecthandler={} end

function WebServer.redirecthandler.makeHandler (params)
	return function (req, res, cap)
		return redirect (req, res, params[1], params[2], cap)
	end
end

-----------------------------------------------------------------------------
-- WSAPI handler
-----------------------------------------------------------------------------

-- it will automatically add .lua extension. 
-- @param cmd_url: like "/helloworld.lua"
-- @return nil if not found. 
function common_handlers.GetValidNPLFileName(docroot, cmd_url)
	local filename;
	if(cmd_url:match("%.lua")) then
		filename = docroot..cmd_url;
	else
		filename = docroot..cmd_url..".lua";
	end
	filename = filename:gsub("/[/]+", "/");
	if(ParaIO.DoesFileExist(filename, true)) then
		return filename;
	end
end

-- it will automatically add .lua extension. 
-- @param cmd_url: like "/helloworld.lua"
-- @return nil if not found. 
function common_handlers.GetValidFileName(docroot, cmd_url)
	local filename = docroot..cmd_url;
	filename = filename:gsub("/[/]+", "/");
	if(ParaIO.DoesFileExist(filename, true)) then
		return filename;
	else
		-- WebServer:GetVirtualDirectory();
	end
end

local function wsapihandler(req, res, params, docroot, extra_vars)
	local filename = common_handlers.GetValidNPLFileName(docroot, req.cmd_url);
	if(filename) then
		-- TODO: support multiple threads, and routing to remote computer. 
		req:send(filename);
	else
		common_handlers.err_404(req, res);
	end
end

-- Makes a generic WSAPI handler, that launches WSAPI application scripts
-- @param docroot: where filename is located.
-- @param params: additional params. usually nil.
function WebServer.makeGenericHandler(docroot, params, extra_vars)
	if(type(docroot) == "table") then
		docroot, params, extra_vars = docroot.docroot, docroot.params, docroot.extra_vars;
	end
	params = params or { isolated = true }
	return function (req, res)
		return wsapihandler(req, res, params, docroot, extra_vars);
	end
end