--[[
Title: register npl runtime in environment path variable
Author(s): LiXizhi
Date: 2016/1/9
Desc: 
use the lib:
------------------------------------------------------------
-- from command line run
npls reg_env_path.lua
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/System/System.lua");

-- register to environment path variable
-- @param runtime_folder:
local function RegisterNPLRuntimeWin32(runtime_folder)
	LOG.std(nil, "info", "register", "NPL directory: %s", runtime_folder);
	local varPath = System.os("echo %path%");
	LOG.std(nil, "info", "register", "old env path: %s", varPath);
	
	runtime_folder = runtime_folder:gsub("/", "\\");
	if(varPath:match("[/\\]NPLRuntime")) then
		local oldPath = varPath:match("[^;]+NPLRuntime[^;]+");
		-- already installed
		LOG.std(nil, "info", "register", "NPL runtime already exist,ignore installation: %s", oldPath);
	else
		-- add to user environment variable. 
		local oldPath = System.os([[reg query HKCU\Environment /v PATH]]);
		oldPath = oldPath:match("PATH%s+REG_[%w_]*SZ%s+(.*)$"):gsub("%s+$", "");
        if(oldPath:match("[/\\]NPLRuntime")) then
            local oldPath = oldPath:match("[^;]+NPLRuntime[^;]+");
		    -- already installed
            LOG.std(nil, "info", "register", "NPL runtime already exist,ignore installation: %s", oldPath);
            return;
        end
		LOG.std(nil, "info", "register", "last HKCU\\Environment: %s", oldPath);
		local newPath = oldPath..";"..runtime_folder;
		if(#newPath >= 1024) then
			-- the /setx command only support 1024 chars, so ...
			LOG.std(nil, "info", "register", "path exceed 1024 characters, please manually add: %s to your environment path", newPath);
			return;
		end
		local result = System.os(format("setx PATH \"%s\"", newPath));
		LOG.std(nil, "info", "register", "NPL runtime is registered to %s\n%s", runtime_folder, result or "");
	end
end

RegisterNPLRuntimeWin32(ParaIO.GetCurDirectory(0).."win/bin");

exit(0);