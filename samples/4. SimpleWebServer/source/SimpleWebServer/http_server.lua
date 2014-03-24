--[[
Title: npl HTTP handler example
Author: LiXizhi
Date: 2013/2/24
Desc: the raw NPL HTTP message handler (example). 
This is an example file is activated whenever a http request/response is received. 
This file also provide a basic 
	npl_http.make_response and npl_http.make_json_response method for your use. 

In NPLPublicFiles.xml, add 
<!--HTTP id=-10 is a special system id for all http request/response -->
<file id="-10" path="script/apps/WebServer/npl_http.lua" />

The path is the file to be activated. In above example, this npl_http.lua is used. 
One can specify other files can invoke npl_http.make_response() like in this file example. 

-----------------------------------------------
NPL.load("(gl)script/apps/WebServer/npl_http.lua");
local npl_http = commonlib.gettable("MyCompany.Samples.npl_http");
-----------------------------------------------
]]
NPL.load("(gl)script/ide/Json.lua");
NPL.load("(gl)script/ide/LuaXML.lua");

local tostring = tostring;
local type = type;

local npl_http = commonlib.gettable("MyCompany.Samples.npl_http");

-- whether to dump all incoming stream;
npl_http.dump_stream = false;

-- keep statistics
local stats = {
	request_received = 0,
}

local default_msg = "HTTP/1.1 200 OK\r\nContent-Length: 31\r\nContent-Type: text/html\r\n\r\n<html><body>hello</body></html>";

local status_strings = {
	ok ="HTTP/1.1 200 OK\r\n",
	created ="HTTP/1.1 201 Created\r\n",
	accepted ="HTTP/1.1 202 Accepted\r\n",
	no_content = "HTTP/1.1 204 No Content\r\n",
	multiple_choices = "HTTP/1.1 300 Multiple Choices\r\n",
	moved_permanently = "HTTP/1.1 301 Moved Permanently\r\n",
	moved_temporarily = "HTTP/1.1 302 Moved Temporarily\r\n",
	not_modified = "HTTP/1.1 304 Not Modified\r\n",
	bad_request = "HTTP/1.1 400 Bad Request\r\n",
	unauthorized = "HTTP/1.1 401 Unauthorized\r\n",
	forbidden = "HTTP/1.1 403 Forbidden\r\n",
	not_found = "HTTP/1.1 404 Not Found\r\n",
	internal_server_error = "HTTP/1.1 500 Internal Server Error\r\n",
	not_implemented = "HTTP/1.1 501 Not Implemented\r\n",
	bad_gateway = "HTTP/1.1 502 Bad Gateway\r\n",
	service_unavailable = "HTTP/1.1 503 Service Unavailable\r\n",
};
npl_http.status_strings = status_strings;

-- make an HTML response
-- @param return_code: nil if default to "ok"(200)
function npl_http.make_html_response(nid, html, return_code, headers)
	if(type(html) == "table") then
		html = commonlib.Lua2XmlString(html);
	end
	npl_http.make_response(nid, html, return_code, headers);
end

-- make a json response
-- @param return_code: nil if default to "ok"(200)
function npl_http.make_json_response(nid, json, return_code, headers)
	if(type(html) == "table") then
		json = commonlib.Json.Encode(json)
	end
	npl_http.make_response(nid, json, return_code, headers);
end

-- make a string response
-- @param return_code: nil if default to "ok"(200)
-- @param body: must be string
-- @return true if send. 
function npl_http.make_response(nid, body, return_code, headers)
	if(type(body) == "string" and nid) then
		local out = {};
		out[#out+1] = status_strings[return_code or "ok"] or return_code["not_found"];
		if(body~="") then
			out[#out+1] = format("Content-Length: %d\r\n", #body);
		end
		if(headers) then
			local name, value;
			for name, value in pairs(headers) do
				if(name ~= "Content-Length") then
					out[#out+1] = format("%s: %s\r\n", name, value);
				end
			end
		end
		out[#out+1] = "\r\n";
		out[#out+1] = body;

		-- if file name is "http",  the message body is raw http stream
		return NPL.activate(format("%s:http", nid), table.concat(out));
	end
end


local function activate()
	stats.request_received = stats.request_received + 1;
	local msg=msg;
	local nid = msg.tid or msg.nid;
	if(npl_http.dump_stream) then
		log("HTTP:"); echo(msg);
	end
	npl_http.make_response(nid, format("<html><body>hello world. req: %d. input is %s</body></html>", stats.request_received, commonlib.serialize_compact(msg)));
end
NPL.this(activate)