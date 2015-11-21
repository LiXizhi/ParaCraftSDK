--[[
Title: npl HTTP server
Author: LiXizhi
Date: 2015/6/8
Desc: 
-----------------------------------------------
NPL.load("(gl)script/apps/WebServer/npl_http.lua");
local npl_http = commonlib.gettable("WebServer.npl_http");
-----------------------------------------------
]]
NPL.load("(gl)script/apps/WebServer/npl_request.lua");
NPL.load("(gl)script/apps/WebServer/npl_common_handlers.lua");
local common_handlers = commonlib.gettable("WebServer.common_handlers");
local request = commonlib.gettable("WebServer.request");

local npl_http = commonlib.gettable("WebServer.npl_http");

-- keep statistics
local stats = {
	request_received = 0,
}

function npl_http.LoadBuildinHandlers()
	NPL.load("(gl)script/apps/WebServer/npl_common_handlers.lua");
	NPL.load("(gl)script/apps/WebServer/npl_file_handler.lua");
	NPL.load("(gl)script/apps/WebServer/npl_script_handler.lua");
	NPL.load("(gl)script/apps/WebServer/npl_page_handler.lua");
	-- TODO: add your buildin handlers here. 
end

-- set request handler according to configuration
function npl_http.LoadConfig(config)
	npl_http.LoadBuildinHandlers();

	-- normalizes the configuration
    config.server = config.server or {}
    local vhosts_table = {}

	NPL.load("(gl)script/apps/WebServer/rules.lua");
	local Rules = commonlib.gettable("WebServer.Rules");

	if config.defaultHost then
        vhosts_table[""] = {rule = common_handlers.patternhandler(Rules:new():init(config.defaultHost.rules)), allow = config.defaultHost.allow};
    end

    if type(config.virtualhosts) == "table" then
        for hostname, host in pairs(config.virtualhosts) do
			vhosts_table[hostname] = {rule= common_handlers.patternhandler(Rules:new():init(host.rules)),allow = config.virtualhosts[hostname].allow};
        end
    end

	npl_http.SetRequestHandler(common_handlers.vhostshandler(vhosts_table));
end

-- start server with config
--  do not call this directly, use WebServer.Start() to start your server. 
function npl_http.start(config)
	npl_http.LoadConfig(config);
	LOG.std(nil, "system", "WebServer", "NPL Web Server is started. ");
	NPL.AddPublicFile("script/apps/WebServer/npl_http.lua", -10);
	NPL.StartNetServer(tostring(config.server.ip or ""), tostring(config.server.port or 8080));
end

-- replace the default request handler
-- @param handler: function(req, response) end, 
function npl_http.SetRequestHandler(handler)
	npl_http.request_handler = handler;
end

function npl_http.handleRequest(req)
	stats.request_received = stats.request_received + 1;

	if(npl_http.request_handler) then
		local result = npl_http.request_handler(req, req.response);

		while(result == "reparse") do
			req.params = nil;
			req:parse_url();
			
			result = npl_http.request_handler(req, req.response);
		end

		req.response:finish();
	else
		-- no handler set? send test message. 
		req.response:send_xml(format("<html><body>hello world. req: %d. input is %s</body></html>", stats.request_received, req:tostring()));
	end
end

local function activate()
	local req = request:new():init(msg);
	npl_http.handleRequest(req);
end
NPL.this(activate)