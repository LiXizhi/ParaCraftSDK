--[[
Title: Main loop
Author(s): LiXizhi
Company: ParaEnging Co.
Date: 2014/3/21
Desc: This mostly run on console of linux or windows. 
use the lib:
------------------------------------------------------------
NPL.activate("source/SimpleWebServer/main.lua");
Or run application with command line: bootstrapper="source/SimpleWebServer/main.lua"
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");

main_state = nil;

-- 读取从网上动态下载资源的服务器URL
local function set_asset_server()
	local xmlRoot = ParaXML.LuaXML_ParseFile("config/GameClient.config.xml");
	if( xmlRoot ) then
		local node = commonlib.XPath.selectNodes(xmlRoot, "/GameClient/asset_server_addresses/address")[1];
		-- 设置资源服务器URL
		ParaAsset.SetAssetServerUrl(node.attr.host);
	end	
end

-- 在Windows下显示管理UI, Linux下不显示
local function InitUIConsole()
	if(ParaUI and ParaUI.CreateUIObject) then
		set_asset_server();
		
		-- 注册常用HTML渲染控件
		NPL.load("(gl)script/apps/Aries/mcml/mcml_aries.lua");
		MyCompany.Aries.mcml_controls.register_all();
	
		-- load game server console
		NPL.load("(gl)script/ide/Debugger/MCMLConsole.lua");
		local init_page_url = "source/SimpleWebServer/server_console.html";
		commonlib.mcml_console.show(true, init_page_url);
	end
end

--启动Server: 支持NPL TCP/IP协议，以及HTTP协议
local function StartWebServer()
	local host = "127.0.0.1";
	local port = "8099";
	-- 当有HTTP请求时，下面的脚本会收到消息. 
	NPL.AddPublicFile("source/SimpleWebServer/http_server.lua", -10);
	NPL.StartNetServer(host, port);
	LOG.std(nil, "system", "WebServer", "NPL Server started on ip:port %s %s", host, port);
end

local function activate()
	-- commonlib.echo("heart beat: 30 times per sec");
	if(main_state==0) then
		-- this is the main pay loop
		
	elseif(main_state==nil) then
		main_state=0;
		StartWebServer();
		InitUIConsole();
	end
end
NPL.this(activate);