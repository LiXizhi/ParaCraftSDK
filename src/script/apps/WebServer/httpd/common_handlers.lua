--[[
Title: some of the commonly used handlers
Author: ported by LiXizhi, most code is based on Xavante
Date: 2011-6-24
Desc: The most frequently used is the file handler. 
-----------------------------------------------
NPL.load("(gl)script/apps/WebServer/httpd/common_handlers.lua");
-- Note: only include this file after httpd.lua
-----------------------------------------------
]]
NPL.load("(gl)script/ide/socket/url.lua");
local url = commonlib.gettable("commonlib.socket.url")

if(not WebServer) then  WebServer = {} end

-----------------------------------------------------------------------------
-- virtual hosts handler
-----------------------------------------------------------------------------
function WebServer.vhostshandler(vhosts)
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

		local remote_ip=string.gsub (req.rawskt:getpeername (), ":%d*$", "")
		--LOG.std(nil, "debug", "WebServer allowip", allow);
		--LOG.std(nil, "debug", "WebServer remoteip", remote_ip);
		if (allow and type(allow)=="table") then
			isAllow = IsIPAllow(allow,remote_ip);
		end

		if (not isAllow) then		
			h = WebServer.httpd.err_403; 
			LOG.std(nil, "warn", "WebServer Deny", remote_ip);
		end
		return h (req, res)
	end
end

-----------------------------------------------------------------------------
-- NPL web server URL rules handler
-----------------------------------------------------------------------------

-- this is a coroutine-based iterator:
-- path_perputer takes a path and yields once for each handler key to try
--		first is the full path
--		next, anything with the same extension on the same directory
--		next, anything on the directory
--		strips the last subdirectory from the path, and repeats the last two patterns
--		for example, if the query was /first/second/file.ext , tries:
--			/first/second/file.ext
--			/first/second/*.ext
--			/first/second/*
--			/first/*.ext
--			/first/*
--			/*.ext
--			/*
--		and, if the query was for a directory like /first/second/last/ , it tries:
--			/first/second/last/
--			/first/second/
--			/first/
--			/
local function path_permuter (path)
	coroutine.yield (path)
	local _,_,ext = string.find (path, "%.([^./]*)$")
	local notdir = (string.sub (path, -1) ~= "/")
	
	while path ~= "" do
		path = string.gsub (path, "/[^/]*$", "")
		if notdir then
			if ext then
				coroutine.yield (path .."/*."..ext)
			end
			coroutine.yield (path .."/*")
		else
			coroutine.yield (path.."/")
		end
	end
end

-- given a path, returns an iterator to traverse all permutations
local function path_iterator (path)
	return coroutine.wrap (function () path_permuter (path) end)
end

-- parses the url, and gets the appropiate handler function
-- starts with the full path, and goes up to the root
-- until it finds a handler for the request method
local function match_url (req, conf)
	local path = req.relpath
	local h, set
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

function WebServer.ruleshandler (conf)
	if not conf or type (conf) ~= "table" then return nil end
	
	return function (req, res)
		match_url (req, conf)
		local h = req.handler or WebServer.httpd.err_404
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
		local h = req.handler or WebServer.httpd.err_404
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
    WebServer.httpd.redirect(res, path .. (query or ""))
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

function WebServer.patternhandler (conf)
  if not conf or type (conf) ~= "table" then return nil end
  
  return function (req, res)
	   local cap = match_url (req, conf) or {}
	   local h = req.handler or WebServer.httpd.err_404
	   return h (req, res, cap)
	 end
end


-----------------------------------------------------------------------------
-- WSAPI handler
-----------------------------------------------------------------------------

NPL.load("(gl)script/ide/IPCBinding/coxpcall.lua");
--pcall = copcall
--xpcall = coxpcall
NPL.load("(gl)script/apps/WebServer/httpd/wsapi_common.lua");
local common = commonlib.gettable("commonlib.wsapi.common");

-------------------------------------------------------------------------------
-- Implements WSAPI
-------------------------------------------------------------------------------

local function set_cgivars (req, diskpath, path_info_pat, script_name_pat, extra_vars)
  diskpath = diskpath or req.diskpath or ""
  req.cgivars = {
    SERVER_SOFTWARE   = req.serversoftware,
    SERVER_NAME       = req.parsed_url.host,
    GATEWAY_INTERFACE = "CGI/1.1",
    SERVER_PROTOCOL   = "HTTP/1.1",
    SERVER_PORT       = req.parsed_url.port,
    REQUEST_METHOD    = req.cmd_mth,
    DOCUMENT_ROOT     = diskpath,
    PATH_INFO         = string.match(req.parsed_url.path, path_info_pat) or "",
    PATH_TRANSLATED   = script_name_pat and (diskpath .. script_name_pat),
    SCRIPT_NAME       = script_name_pat,
    QUERY_STRING      = req.parsed_url.query or "",
    REMOTE_ADDR       = string.gsub (req.rawskt:getpeername (), ":%d*$", ""),
    CONTENT_TYPE      = req.headers ["content-type"],
    CONTENT_LENGTH    = req.headers ["content-length"],
  }
  if req.cgivars.PATH_INFO == "" then req.cgivars.PATH_INFO = "/" end
  for n,v in pairs(extra_vars or {}) do
    req.cgivars[n] = v
  end
  for n,v in pairs (req.headers) do
    req.cgivars ["HTTP_"..string.gsub (string.upper (n), "-", "_")] = v
  end
end

local function wsapihandler (req, res, wsapi_run, app_prefix, docroot, app_path, extra_vars)
  local path_info_pat = "^" .. (app_prefix or "") .. "(.*)"
  set_cgivars(req, docroot, path_info_pat, app_prefix, extra_vars)

  local get_cgi_var = function (var)
    return req.cgivars[var] or ""
  end

  local wsapi_env = common.wsapi_env {
    input       = req.socket,
    read_method = "receive",
    error       = io.stderr,
    env         = get_cgi_var
  }
  wsapi_env.APP_PATH = app_path

  local function set_status(status)
    if type(status) == "number" or status:match("^%d+$") then
      status = status .. " " .. common.status_codes[tonumber(status)]
    end
    res.statusline = "HTTP/1.1 " .. (status or "500 Internal Server Error")
  end

  local function send_headers(headers)
    for h, v in pairs(headers) do
      if h == "Status" or h == "Content-Type" then
        res.headers[h] = v
      elseif type(v) == "string" then
        res:add_header(h, v)
      elseif type(v) == "table" then
        for _, v in ipairs(v) do
          res:add_header(h, tostring(v))
        end
      else
        res:add_header(h, tostring(v))
      end
    end
    res:send_headers()
  end

  local ok, status, headers, res_iter = common.run_app(wsapi_run, wsapi_env)
  if ok then
    set_status(status or 500)
    send_headers(headers or {})
    common.send_content(res, res_iter, "send_data")
  else
    if wsapi_env.STATUS == 404 then
      res.statusline = "HTTP/1.1 404"
      send_headers({ ["Content-Type"] = "text/html", ["Content-Length"] = (status and #status) or 0 })
      res:send_data(status)
    else
      local content = common.error_html(status)
      res.statusline = "HTTP/1.1 500"
      send_headers({ ["Content-Type"] = "text/html", ["Content-Length"] = #content})
      res:send_data(content)
    end
  end
end

-- Makes a WSAPI handler for a single WSAPI application
function WebServer.makeHandler (app_func, app_prefix, docroot, app_path, extra_vars)
  return function (req, res)
    return wsapihandler(req, res, app_func, app_prefix, docroot, app_path, extra_vars)
  end
end

-- Makes a generic WSAPI handler, that launches WSAPI application scripts
-- See the wsapi script for the possible values of the "params" table
-- @param docroot: where filename is located.
-- @param params: additional params. usually nil.
function WebServer.makeGenericHandler(docroot, params, extra_vars)
	if(type(docroot) == "table") then
		docroot, params, extra_vars = docroot.docroot, docroot.params, docroot.extra_vars;
	end
	params = params or { isolated = true }
	return function (req, res)
		return wsapihandler(req, res, common.make_loader(params), nil, docroot, nil, extra_vars)
	end
end


-----------------------------------------------------------------------------
-- NPL CGILua handler
-----------------------------------------------------------------------------
local cgiluahandler = commonlib.gettable("WebServer.cgiluahandler")

local bootstrap = [[
  function print(...)
    remotedostring("print(...)", ...)
  end
    
  io.stdout = {
     write = function (...)
	       remotedostring("io.write(...)", ...)
	     end
   }

  io.stderr = {
    write = function (...)
	      remotedostring("io.stderr(...)", ...)
	    end
  }
]]

-- Returns the CGILua handler
function cgiluahandler.makeHandler (diskpath, params)
   params = setmetatable(params or {}, { __index = { modname = "wsapi.sapi",
      bootstrap = bootstrap } })
   local sapi_loader = commonlib.wsapi.common.make_loader(params)
   -- local sapi_loader = wsapi.common.make_isolated_launcher(params)
   return WebServer.makeHandler(sapi_loader, nil, diskpath)
end

