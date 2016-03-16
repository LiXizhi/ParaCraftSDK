--[[
Title: web server loop file
Author(s):  LiXizhi, 
Date: 2011.6.24
Desc: 
command line params:
e.g. bootstrapper="script/apps/WebServer/shell_loop_webserver.lua"
e.g. bootstrapper="script/apps/WebServer/shell_loop_webserver.lua" config="script/apps/WebServer/test/Sample.WebServer.config.xml"
| config | can be omitted which defaults to config/WebServer.config.xml |

use the lib:
------------------------------------------------------------
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/apps/WebServer/WebServer.lua");

main_state = nil;

-- init UI console
local function InitUIConsole()
	if(ParaUI and ParaUI.CreateUIObject and not ParaEngine.GetAttributeObject():GetField("IsServerMode", false)) then
		-- load game server console
		NPL.load("(gl)script/ide/Debugger/MCMLConsole.lua");
		local init_page_url = nil;
		commonlib.mcml_console.show(true, init_page_url);
	end
end

local function activate()
	-- commonlib.echo("heart beat: 30 times per sec");
	if(main_state==0) then
		-- this is the main pay loop
		
	elseif(main_state==nil) then
		main_state=0;
		
		LOG.std(nil, "system", "WebServer", "Web Server started")

		InitUIConsole();

		-- start the server
		local config_file = ParaEngine.GetAppCommandLineByParam("config", "");
		if(config_file == "") then
			config_file = nil;
		end
		WebServer:StartDeprecatedHttpd(config_file);
	end
end
NPL.this(activate);