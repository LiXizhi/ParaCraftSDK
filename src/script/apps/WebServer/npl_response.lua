--[[
Title: npl HTTP response
Author: LiXizhi
Date: 2015/6/8
Desc: 
-----------------------------------------------
NPL.load("(gl)script/apps/WebServer/npl_response.lua");
local response = commonlib.gettable("WebServer.response");
response:send();
response:send_xml();
response:send_json();
response:set_header(h, v);
response:SetReturnCode("forbidden");  -- one of the status_strings keys
-----------------------------------------------
]]
NPL.load("(gl)script/apps/WebServer/npl_util.lua");
local util = commonlib.gettable("WebServer.util");
local tostring = tostring;
local type = type;
local date = os.date;

local response = commonlib.inherit(nil, commonlib.gettable("WebServer.response"));


local status_strings = {
	ok ="HTTP/1.1 200 OK",
	created ="HTTP/1.1 201 Created",
	accepted ="HTTP/1.1 202 Accepted",
	no_content = "HTTP/1.1 204 No Content",
	multiple_choices = "HTTP/1.1 300 Multiple Choices",
	moved_permanently = "HTTP/1.1 301 Moved Permanently",
	moved_temporarily = "HTTP/1.1 302 Moved Temporarily",
	not_modified = "HTTP/1.1 304 Not Modified",
	bad_request = "HTTP/1.1 400 Bad Request",
	unauthorized = "HTTP/1.1 401 Unauthorized",
	forbidden = "HTTP/1.1 403 Forbidden",
	not_found = "HTTP/1.1 404 Not Found",
	internal_server_error = "HTTP/1.1 500 Internal Server Error",
	not_implemented = "HTTP/1.1 501 Not Implemented",
	bad_gateway = "HTTP/1.1 502 Bad Gateway",
	service_unavailable = "HTTP/1.1 503 Service Unavailable",
};

-- default status line
response.statusline = status_strings.ok;
-- table of name, value pairs
response.headers = nil;
-- forcing text context
response.content = nil;

function response:ctor()
	self.headers = {};
end

-- response can be reused by calling this function. 
function response:init(req)
	self.req = req;
	-- reset send buffer
	self.buffer = nil;
	return self;
end

-- make a xml rpc response
-- @param xml: xml/html root node or text. 
-- @param return_code: nil if default to "ok"(200)
function response:send_xml(xml, return_code, headers)
	self:SetReturnCode(return_code);
	self.headers = headers or self.headers;

	if(type(xml) == "table") then
		self:send([[<?xml version="1.0" encoding="utf-8"?>]]);
		self:send(commonlib.Lua2XmlString(xml));
	else
		self.content = xml;
	end
end

-- make a json response
-- @param return_code: nil if default to "ok"(200)
function response:send_json(json, return_code, headers)
	if(type(json) == "table") then
		json = commonlib.Json.Encode(json)
	end
	self:SetReturnCode(return_code);
	self.headers = headers or self.headers;
	self.content = json;
end

function response:SetReturnCode(return_code)
	self.statusline = status_strings[return_code or "ok"] or status_strings["not_found"];
end

-- it will replace value
function response:set_header(h, v)
	if(not h) then
		return 
	end
	self.headers [h] = v;
end

-- there can be duplicated names 
function response:add_header (h, v)
	if(not h) then
		return 
	end
    if string.lower(h) == "status" then
        self.statusline = "HTTP/1.1 "..v
    else
        local prevval = self.headers [h]
        if (prevval  == nil) then
            self.headers[h] = v
        elseif type (prevval) == "table" then
            table.insert (prevval, v)
        else
            self.headers[h] = {prevval, v}
        end
    end
end


-- if one calls SetContent instead of send(), any previously buffered send text will be ignored. 
function response:SetContent(text)
	self.content = text;
end

-- cache string and send it until finish() is called.
-- it is optimized to call send() many times during a single request. 
-- @param text: string or a table of text lines. 
function response:send(text)
	if(type(text) == "string") then
		local content = self.content;
		if(not content) then
			content = {};
			self.content = content;
		end
		content[#content + 1] = text;
	elseif(type(text) == "table") then
		local content = self.content;
		if(not content) then
			content = text;
			self.content = content;
		else
			for i = 1, #text do
				content[#content + 1] = text[i];
			end
		end
	end
end

-- sends prebuilt content to the client
-- 		if possible, sets Content-Length: header field
-- uses:
--		self.content : content data to send
-- sets:
--		self.keep_alive : if possible to keep using the same connection
function response:send_response()
	if(not self.content and self.buffer) then
		self.content = table.concat(self.buffer);
	end
	
	if self.content then
		if not self.sent_headers then
			if (type (self.content) == "table" and not self.chunked) then
				self.content = table.concat (self.content)
			end
			if type (self.content) == "string" then
				self.headers["Content-Length"] = #(self.content)
			end
		end
	else
		if not self.sent_headers then
			self.statusline = "HTTP/1.1 204 No Content"
			self.headers["Content-Length"] = 0
		end
	end
	
    if self.chunked then
        self:add_header ("Transfer-Encoding", "chunked")
    end
    
	if self.chunked or ((self.headers ["Content-Length"]) and self.headers ["connection"] == "Keep-Alive") then
		self.headers ["Connection"] = "Keep-Alive"
		self.keep_alive = true
	else
		self.keep_alive = nil
	end
	
	if self.content then
		if type (self.content) == "table" then
			for _, v in ipairs (self.content) do 
				self:send_data (v) 
			end
		else
			self:send_data(self.content)
		end
	else
		self:send_headers()
	end
	
	if self.chunked then
		self.sendInternal("0\r\n\r\n")
	end
end

-- sends the response headers directly to client 
-- uses:
--		self.sent_headers : if true, headers are already sent, does nothing
--		self.statusline : response status, if nil, sends 200 OK
--		self.headers : table of header fields to send
function response:send_headers()
	if (self.sent_headers) then
		return
	end
	
	local out = {};
	out[#out+1] = self.statusline;
	out[#out+1] = "\r\n";
	if(self.headers) then
		for name, value in pairs(self.headers) do
			if(type(value) == "table") then
				-- mostly for Set-Cookie
				for i=1, #value do
					out[#out+1] = format("%s: %s\r\n", name, value[i]);
				end
			else
				out[#out+1] = format("%s: %s\r\n", name, value);
			end
		end
	end
	out[#out+1] = "\r\n";
	self:sendInternal(table.concat(out));

	self.sent_headers = true;
end

-- sends content directly to client. sends headers first, if not
-- @param data : content data to send
function response:send_data(data)
	if (not data or data == "") then
		return
	end

	if (not self.sent_headers) then
		self:send_headers(res);
	end
	
	if data then
		if self.chunked then
			self.sendInternal(string.format ("%X\r\n", #(data)));
			self.sendInternal(data);
			self.sendInternal("\r\n");
		else
			self:sendInternal(data);
		end
	end
end

local function optional (what, name)
	if name ~= nil and name ~= "" then
		return format("; %s=%s", what, name)
	else
		return ""
	end
end

local function make_cookie(name, value)
	local options = {}
	if type(value) == "table" then
		options = value
		value = value.value
	end
	local cookie = name .. "=" .. util.url_encode(value)
	if options.expires then
		local t = date("!%A, %d-%b-%Y %H:%M:%S GMT", options.expires)
		cookie = cookie .. optional("expires", t)
	end
	cookie = cookie .. optional("path", options.path)
	cookie = cookie .. optional("domain", options.domain)
	cookie = cookie .. optional("secure", options.secure)
	return cookie
end

function response:set_cookie(name, value)
	local cookie = self.headers["Set-Cookie"]
	if type(cookie) == "table" then
		table.insert(self.headers["Set-Cookie"], make_cookie(name, value))
	elseif type(cookie) == "string" then
		self.headers["Set-Cookie"] = { cookie, make_cookie(name, value) }
	else
		self.headers["Set-Cookie"] = make_cookie(name, value)
	end
end

function response:redirect(path)
	-- TODO:
end

function response:delete_cookie(name, path)
	self:set_cookie(name, { value =  "xxx", expires = 1, path = path })
end

-- drop this request, so that nothing is sent to client at the moment. 
-- we use this function to delegate a request from one thread to another in npl script handler
function response:discard()
	self.finished = true;
end

-- call this function to actually send cached response to client.
function response:finish()
	if(not self.finished) then
		self:send_response();
		self.finished = true;
	end
end

function response:GetAddress()
	-- if file name is "http",  the message body is raw http stream
	if(not self.addr) then
		self.addr = format("%s:http", self.req.nid);
	end
	return self.addr;
end

-- private: 
function response:sendInternal(text)
	-- echo(text);
	return NPL.activate(self:GetAddress(), text);
end
