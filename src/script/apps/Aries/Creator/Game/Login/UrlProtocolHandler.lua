--[[
Title: URL protocol handler
Author(s): LiXizhi
Date: 2016/1/19
Desc: singleton class

---++ paracraft://cmd/loadworld/[url_filename]
paracraft://cmd/loadworld/https://github.com/LiXizhi/HourOfCode/archive/master.zip

Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Creator/Game/Login/UrlProtocolHandler.lua");
local UrlProtocolHandler = commonlib.gettable("MyCompany.Aries.Creator.Game.UrlProtocolHandler");
UrlProtocolHandler:ParseCommand()
if(not UrlProtocolHandler:HasUrlProtocol("paracraft")) then
	UrlProtocolHandler:RegisterUrlProtocol();
end
-------------------------------------------------------
]]
local UrlProtocolHandler = commonlib.gettable("MyCompany.Aries.Creator.Game.UrlProtocolHandler");

--@param cmdline: if nil we will read from current cmd line
function UrlProtocolHandler:ParseCommand(cmdline)
	local cmdline = cmdline or ParaEngine.GetAppCommandLine();
	local urlProtocol = string.match(cmdline or "", "paracraft://(.*)$");
	if(urlProtocol) then
		NPL.load("(gl)script/ide/Encoding.lua");
		urlProtocol = commonlib.Encoding.url_decode(urlProtocol);
		LOG.std(nil, "info", "UrlProtocolHandler", "protocol paracraft://%s", urlProtocol);
		-- paracraft://cmd/loadworld/[url_filename]
		local world_url = urlProtocol:match("^cmd/loadworld[%s/]+([%S]*)");
		if(world_url and world_url:match("^http(s)://")) then
			System.options.cmdline_world = world_url;
		end
	end
end

-- this will spawn a new process that request for admin right
-- @param protocol_name: TODO: default to "paracraft"
function UrlProtocolHandler:RegisterUrlProtocol(protocol_name)
	local res = System.os([[reg query "HKCR\paracraft\shell\open\command"]])
	if(res and res:match("URL Protocol")) then
		echo("paracraft url protocol is already installed. We will overwrite it anyway");
	end

	local res = System.os.runAsAdmin([[
reg add "HKCR\paracraft" /ve /d "URL:paracraft" /f
reg add "HKCR\paracraft" /v "URL Protocol" /d ""  /f
reg add "HKCR\paracraft\shell\open\command" /ve /d "\"%CD%\ParaEngineClient.exe\" mc=\"true\" %%1" /f
]]);
end

-- return true if url protocol is installed
-- @param protocol_name: default to "paracraft://"
function UrlProtocolHandler:HasUrlProtocol(protocol_name)
	protocol_name = protocol_name or "paracraft";
	protocol_name = protocol_name:gsub("[://]+","");

	local has_protocol = ParaGlobal.ReadRegStr("HKCR", protocol_name, "URL Protocol");
	if(has_protocol == "") then
		do 
			return true
		end
		-- following code is further check, which is not needed. 
		has_protocol = ParaGlobal.ReadRegStr("HKCR", protocol_name, "");
		if(has_protocol == "URL:"..protocol_name) then
			local cmd = ParaGlobal.ReadRegStr("HKCR", protocol_name.."/shell/open/command", "");
			if(cmd) then
				cmd = string.lower(cmd:gsub("/", "\\"));
			end
		end
	end
end

function UrlProtocolHandler:CheckInstallUrlProtocol()
	if(System.options.mc and System.os.GetPlatform() == "win32") then
		if(self:HasUrlProtocol()) then
			return true;
		else
			_guihelper.MessageBox(L"安装URL Protocol, 可用浏览器打开3D世界, 是否现在安装？(可能需要管理员权限)", function(res)
				if(res and res == _guihelper.DialogResult.Yes) then
					self:RegisterUrlProtocol();
				end
			end, _guihelper.MessageBoxButtons.YesNo);
		end	
	end
end