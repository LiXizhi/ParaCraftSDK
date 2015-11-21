--[[
Title: example of npl_script_handler
Author: LiXizhi
Date: 2015/6/9
Desc: Unlike standard NPL activation, this file is protected by webserver configuration. 
It is possible to configure this file to run in multiple NPL threads to reduce server load. 
-----------------------------------------------
NPL.load("(gl)script/apps/WebServer/test/helloworld.lua");
-----------------------------------------------
]]

local function run(req, res)
	-- test cookie
	local num = tonumber(req:get_cookie("counter") or 0);
	res:set_cookie("counter", num + 1);
	
	res:send(format("<html><body>hello world! %d</body></html>", num));

	res:finish();
end

local function activate()
	local req = WebServer.request:new():init(msg);
	run(req, req.response);
end
NPL.this(activate);