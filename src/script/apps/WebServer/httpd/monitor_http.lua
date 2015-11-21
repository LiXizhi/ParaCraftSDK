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
local npl_http = commonlib.gettable("commonlib.npl_http");
-----------------------------------------------
]]
NPL.load("(gl)script/ide/Json.lua");
NPL.load("(gl)script/ide/LuaXML.lua");

local tostring = tostring;
local type = type;

local npl_http = commonlib.gettable("commonlib.npl_http");

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

function npl_http.cmd_response(nid, url)

	local function send_broadcast(msg)
		local _msg = commonlib.Encoding.url_decode(msg);
		local toserver_msg_template={};
		toserver_msg_template.type = "fs_chat";
		toserver_msg_template.user_nid = 0;
		local send_msg = string.format("{_v={\"%s\",10,},_vi={10,1,},}",_msg);
		toserver_msg_template.msg = {chat_data = send_msg};
		local LobbyServer_script="(rest)script/apps/GameServer/LobbyService/GSL_LobbyServerProxy.lua";

		if (NPL.activate(LobbyServer_script, toserver_msg_template) ~=0) then
			LOG.std(nil, "warning", "lobbyserverproxy", "unable to send request to "..LobbyServer_script);
		else
			LOG.std(nil, "system", "lobbyserverproxy", "Success to send request to "..LobbyServer_script);
		end
	end

	local function send_cmd(msg)
		local toserver_msg_template={};
		toserver_msg_template.type = msg.type;
		toserver_msg_template.user_nid = msg.nid;
		toserver_msg_template.msg = msg.msg;
		local LobbyServer_script="(rest)script/apps/GameServer/LobbyService/GSL_LobbyServerProxy.lua";

		if (NPL.activate(LobbyServer_script, toserver_msg_template) ~=0) then
			LOG.std(nil, "warning", "lobbyserverproxy", "unable to send request to "..LobbyServer_script);
		else
			LOG.std(nil, "system", "lobbyserverproxy", "Success to send request to "..LobbyServer_script);
		end
	end

	if(type(url) == "string" and nid) then
		local _msg = string.match(url,"msg=(.+)");
		local _cmd,_passwd = string.match(url,"cmd=(%a+)&passwd=([a-zA-Z0-9_]+)");
		if (_passwd) then
			if ( string.lower(_passwd) == "paraengine_gm" ) then
				if ( string.lower(_cmd) == "broadcast" ) then
					send_broadcast(_msg);
				else
					local _type,_nid = string.match(url,"type=(%a+)&nid=([0-9]+)");
					local __msg = {nid=_nid, type=_type, msg=_msg}
					send_cmd(__msg);
				end
			else
				LOG.std(nil, "warning", "npl_http", "wrong GM passwd for http_cmd");
			end
		else
			LOG.std(nil, "warning", "npl_http", "no GM passwd for http_cmd");	
			LOG.std(nil, "warning", "npl_http", url);		
		end
	end
end

local function activate()
	stats.request_received = stats.request_received + 1;
	local msg=msg;
	local nid = msg.tid or msg.nid;
	if(npl_http.dump_stream) then
		log("HTTP:"); echo(msg);
	end
	--	npl_http.make_response(nid, format("<html><body>hello world. req: %d. input is %s</body></html>", stats.request_received, commonlib.serialize_compact(msg)));

	local remote_ip = NPL.GetIP(msg.nid or msg.tid);

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

	local method="";
	if (msg.method) then
		method = string.lower(msg.method);
	end
	local url=""
	if (method=="get") then
		url = msg.url;
	elseif (method=="post") then
		url = msg.body;
	end
	if (GameServer.http_allowip) then
		local isAllow = IsIPAllow(GameServer.http_allowip,remote_ip);		
		if (isAllow) then
			commonlib.echo(url);	
			npl_http.cmd_response(nid,url);
			npl_http.make_response(nid, format("<html><body>hello world. req: %d. </body></html>", stats.request_received));

		else
			LOG.std(nil, "warning", "npl_http",string.format("ip:%s isnot allowed to visit npl_http!", remote_ip));
		end
	else
		npl_http.cmd_response(nid,url);
		npl_http.make_response(nid, format("<html><body>hello world. req: %d. </body></html>", stats.request_received));
	end
end
NPL.this(activate)
