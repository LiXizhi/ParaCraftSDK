--[[
Title: Deprecated use npl_http instead:  http server
Author: LiXizhi, based on Xavante HTTP handler
Date: 2011-6-24 
Desc: 
-----------------------------------------------
NPL.load("(gl)script/apps/WebServer/httpd/httpd.lua");
local httpd = commonlib.gettable("WebServer.httpd")
-----------------------------------------------
]]
local _VERSION = "NPLWebServer 1.0.0"

local tostring = tostring;
NPL.load("(gl)script/apps/WebServer/httpd/copas.lua");
NPL.load("(gl)script/ide/socket/socket.lua");
local copas = commonlib.gettable("commonlib.copas");
local socket = commonlib.gettable("commonlib.socket")

NPL.load("(gl)script/ide/socket/url.lua");
local url = commonlib.gettable("commonlib.socket.url")
NPL.load("(gl)script/apps/WebServer/httpd/common_handlers.lua");
NPL.load("(gl)script/apps/WebServer/httpd/file_handler.lua");
NPL.load("(gl)script/apps/WebServer/npl_script_handler.lua");

local httpd = commonlib.module("WebServer.httpd")

local _serversoftware = ""

local _serverports = {}

local string_gmatch = string.gmatch;

function strsplit (str)
	local words = {}
	
	for w in string.gmatch (str, "%S+") do
		table.insert (words, w)
	end
	
	return words
end


-- Manages one connection, maybe several requests
-- params:
--		skt : client socket

function connection (skt)
	copas.setErrorHandler (errorhandler)
	
	skt:setoption ("tcp-nodelay", true)
	local srv, port = skt:getsockname ()
	local req = {
		rawskt = skt,
		srv = srv,
		port = port,
		copasskt = copas.wrap (skt),
	}
	req.socket = req.copasskt
	req.serversoftware = _serversoftware
	
	while read_method (req) do
		local res
		read_headers (req)

		repeat
			req.params = nil
			parse_url (req)
			res = make_response (req)
		until handle_request (req, res) ~= "reparse"
		send_response (req, res)

		req.socket:flush ()
		if not res.keep_alive then
			break
		end
	end
end


function errorhandler (msg, co, skt)
    msg = tostring(msg)
	io.stderr:write("  NPLWebServer Error: "..msg.."\n", "  "..tostring(co).."\n", "  "..tostring(skt).."\n")
	skt:send ("HTTP/1.0 200 OK\r\n")
	skt:send (string.format ("Date: %s\r\n\r\n", os.date ("!%a, %d %b %Y %H:%M:%S GMT")))
	skt:send (string.format ([[
<html><head><title>NPLWebServer Error!</title></head>
<body>
<h1>NPLWebServer Error!</h1>
<p>%s</p>
</body></html>
]], string.gsub (msg, "\n", "<br/>\n")))
end

-- gets and parses the request line
-- params:
--		req: request object
-- returns:
--		true if ok
--		false if connection closed
-- sets:
--		req.cmd_mth: http method
--		req.cmd_url: url requested (as sent by the client)
--		req.cmd_version: http version (usually 'HTTP/1.1')
function read_method (req)
	local err
	req.cmdline, err = req.socket:receive ()
	
	if not req.cmdline then return nil end
	req.cmd_mth, req.cmd_url, req.cmd_version = unpack (strsplit (req.cmdline))
	req.cmd_mth = string.upper (req.cmd_mth or 'GET')
	req.cmd_url = req.cmd_url or '/'
	
	return true
end

-- gets and parses the request header fields
-- params:
--		req: request object
-- sets:
--		req.headers: table of header fields, as name => value
function read_headers (req)
	local headers = {}
	local prevval, prevname
	
	while 1 do
		local l,err = req.socket:receive ()
		if (not l or l == "") then
			req.headers = headers
			return
		end
		local _,_, name, value = string.find (l, "^([^: ]+)%s*:%s*(.+)")
		name = string.lower (name or '')
		if name then
			prevval = headers [name]
			if prevval then
				value = prevval .. "," .. value
			end
			headers [name] = value
			prevname = name
		elseif prevname then
			headers [prevname] = headers [prevname] .. l
		end
	end
end

function parse_url (req)
	local def_url = string.format ("http://%s%s", req.headers.host or "", req.cmd_url or "")
	
	req.parsed_url = url.parse (def_url or '')
	req.parsed_url.port = req.parsed_url.port or req.port
	req.built_url = url.build (req.parsed_url)
	
	req.relpath = url.unescape (req.parsed_url.path)
end


-- sets the default response headers
function default_headers (req)
	return  {
		Date = os.date ("!%a, %d %b %Y %H:%M:%S GMT"),
		Server = _serversoftware,
	}
end

function add_res_header (res, h, v)
    if string.lower(h) == "status" then
        res.statusline = "HTTP/1.1 "..v
    else
        local prevval = res.headers [h]
        if (prevval  == nil) then
            res.headers[h] = v
        elseif type (prevval) == "table" then
            table.insert (prevval, v)
        else
            res.headers[h] = {prevval, v}
        end
    end
end


-- sends the response headers
-- params:
--		res: response object
-- uses:
--		res.sent_headers : if true, headers are already sent, does nothing
--		res.statusline : response status, if nil, sends 200 OK
--		res.headers : table of header fields to send
local function send_res_headers (res)
	if (res.sent_headers) then
		return
	end
	
	if WebServer.cookies then
		WebServer.cookies.set_res_cookies (res)
	end
    
	res.statusline = res.statusline or "HTTP/1.1 200 OK"
	
	res.socket:send (res.statusline.."\r\n")
	for name, value in pairs (res.headers) do
                if type(value) == "table" then
                  for _, value in ipairs(value) do
                    res.socket:send (string.format ("%s: %s\r\n", name, value))
                  end
                else
                  res.socket:send (string.format ("%s: %s\r\n", name, value))
                end
	end
	res.socket:send ("\r\n")
	
	res.sent_headers = true;
end

-- sends content directly to client
--		sends headers first, if necesary
-- params:
--		res ; response object
--		data : content data to send
local function send_res_data (res, data)

	if not data or data == "" then
		return
	end

	if not res.sent_headers then
		send_res_headers (res)
	end
	
	if data then
		if res.chunked then
			res.socket:send (string.format ("%X\r\n", string.len (data)))
			res.socket:send (data)
			res.socket:send ("\r\n")
		else
			res.socket:send (data)
		end
	end
end

function make_response (req)
	local res = {
		req = req,
		socket = req.socket,
		headers = default_headers (req),
		add_header = add_res_header,
		send_headers = send_res_headers,
		send_data = send_res_data,
	}
	
	return res
end

-- sends prebuilt content to the client
-- 		if possible, sets Content-Length: header field
-- params:
--		req : request object
--		res : response object
-- uses:
--		res.content : content data to send
-- sets:
--		res.keep_alive : if possible to keep using the same connection
function send_response (req, res)

	if res.content then
		if not res.sent_headers then
			if (type (res.content) == "table" and not res.chunked) then
				res.content = table.concat (res.content)
			end
			if type (res.content) == "string" then
				res.headers["Content-Length"] = string.len (res.content)
			end
		end
	else
		if not res.sent_headers then
			res.statusline = "HTTP/1.1 204 No Content"
			res.headers["Content-Length"] = 0
		end
	end
	
    if res.chunked then
        res:add_header ("Transfer-Encoding", "chunked")
    end
    
	if res.chunked or ((res.headers ["Content-Length"]) and req.headers ["connection"] == "Keep-Alive")
	then
		res.headers ["Connection"] = "Keep-Alive"
		res.keep_alive = true
	else
		res.keep_alive = nil
	end
	
	if res.content then
		if type (res.content) == "table" then
			for _,v in ipairs (res.content) do res:send_data (v) end
		else
			res:send_data (res.content)
		end
	else
		res:send_headers ()
	end
	
	if res.chunked then
		res.socket:send ("0\r\n\r\n")
	end
end

function getparams (req)
	if not req.parsed_url.query then return nil end
	if req.params then return req.params end
	
	local params = {}
	req.params = params
	
	for parm in string.gmatch (req.parsed_url.query, "([^&]+)") do
		k,v = string.match (parm, "(.*)=(.*)")
		k = url.unescape (k)
		v = url.unescape (v)
		if k ~= nil then
			if params[k] == nil then
				params[k] = v
			elseif type (params[k]) == "table" then
				table.insert (params[k], v)
			else
				params[k] = {params[k], v}
			end
		end
	end
	
	return params
end

function err_404 (req, res)
	res.statusline = "HTTP/1.1 404 Not Found"
	res.headers ["Content-Type"] = "text/html"
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

function err_403 (req, res)
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

function err_405 (req, res)
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

function redirect (res, d)
	res.headers ["Location"] = d
	res.statusline = "HTTP/1.1 302 Found"
	res.content = "redirect"
end

function register (host, port, serversoftware)
	local _server, error = socket.bind(host, port);
	if(not _server) then
		LOG.std(nil, "error", "httpd", "socket.bind failed with host:port=%s %s because %s", tostring(host), tostring(port), tostring(error));
		return;
	end
	_serversoftware = serversoftware
	local _ip, _port = _server:getsockname()
	_serverports[_port] = true
	copas.addserver(_server, connection)
end

function get_ports()
  local ports = {}
  for k, _ in pairs(_serverports) do
    table.insert(ports, tostring(k))
  end
  return ports
end

-------------------------------
-- server loop
-------------------------------
local copas = commonlib.gettable("commonlib.copas");

local _startmessage = function (ports)
	LOG.std(nil, "system", "WebServer", "NPLWebServer started on port(s) %s", table.concat(ports, ", "))
end

function LoadConfig(config)
	-- normalizes the configuration
    config.server = config.server or {host = "*", port = 80}
    local vhosts_table = {}

	NPL.load("(gl)script/apps/WebServer/rules.lua");
	local Rules = commonlib.gettable("WebServer.Rules");

    if config.defaultHost then
        vhosts_table[""] = {rule = WebServer.patternhandler(Rules:new():init(config.defaultHost.rules)), allow = config.defaultHost.allow};
    end

    if type(config.virtualhosts) == "table" then
        for hostname, host in pairs(config.virtualhosts) do
			vhosts_table[hostname] = {rule= WebServer.patternhandler(Rules:new():init(host.rules)),allow = config.virtualhosts[hostname].allow};
        end
    end

    WebServer.httpd.handle_request = WebServer.vhostshandler(vhosts_table)
    WebServer.httpd.register(config.server.host, config.server.port, _VERSION)
end
-- public:
-- @param bIsAsync: default to true
function start(config, bIsAsync)
	LOG.std(nil, "system", "WebServer", "NPL Web Server is started. ");

	LoadConfig(config);

	if(bIsAsync~=false) then
		startAsync();
	else
		start(function()
			LOG.std(nil, "system", "WebServer", "tick");
			return;
		end, 10);
	end
end

-- to start the server, you need to call WebServer:start([checkfunction[, timeout]]) 
-- passing an optional checking function and connection timeout value. 
-- @param isFinished: The checking function, if present, will be called periodically to check if Server should continue to run. 
-- This function can be also used for maintenance tasks or as a callback to your application. 
-- @param timeout: in seconds. such as 10 seconds. 
function startSync(isFinished, timeout)
	while true do
		if isFinished and isFinished() then break end
		copas.step(timeout)
    end
	LOG.std(nil, "system", "WebServer", "NPL Web Server exited gracefully");
end

function startAsync()
	-- use a timer to periodically pool it. 
	NPL.load("(gl)script/ide/timer.lua");
	local mytimer = commonlib.Timer:new({callbackFunc = function(timer)
		if(WebServer.is_exiting) then
			timer:Change();
		else
			-- step forward with 0 timeout, since we use a timer to poll it
			copas.step(0)
		end
	end})
	-- the timer runs as fast as possible.
	mytimer:Change(0, WebServer.config.polling_interval or 10);
	LOG.std(nil, "system", "WebServer", "NPL Web Server is started with polling interval %d ms", WebServer.config.polling_interval or 10);
end