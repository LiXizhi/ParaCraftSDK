--[[
Title: operating system parent file
Author(s): LiXizhi
Date: 2016/1/9
Desc: all os module files are included here. 
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/System/os/os.lua");
echo(System.os.GetPlatform()=="win32");
echo(System.os.args("bootstrapper", ""));
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/os/run.lua");
NPL.load("(gl)script/ide/System/os/GetUrl.lua");

local os = commonlib.gettable("System.os");

-- @return "win32", "linux", "android", "ios", "mac"
function os.GetPlatform()
	if(not os.platform) then
		local platform = ParaEngine.GetAttributeObject():GetField("Platform", 0);
		if(platform == 3) then
			return "win32";
		elseif(platform == 1) then
			return "ios";
		elseif(platform == 2) then
			return "android";
		elseif(platform == 14) then
			return "winrt";
		elseif(platform == 5) then
			return "linux";
		elseif(platform == 13) then
			return "wp8";
		elseif(platform == 0) then
			return "unknown";
		end
	end
	return os.platform;
end

-- get command line argument
-- @param name: argument name
-- @param default_value: default value
function os.args(name, default_value)
	return ParaEngine.GetAppCommandLineByParam(name, default_value);
end
