--[[
Title: Inter Process Communication for external app
Author(s): LiXizhi
Date: 2010/5/24
Desc: 
Use Lib:
-------------------------------------------------------
NPL.load("(gl)script/ide/app_ipc.lua");
commonlib.app_ipc.AddPublicFile("filename.lua", 1);
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
NPL.load("(gl)script/ide/IPC.lua");

local debug_stream = true;

local app_ipc = commonlib.gettable("commonlib.app_ipc");

-- get the ipc queue name from command line
local apphost_name = ParaEngine.GetAppCommandLineByParam("apphost", "");
if(apphost_name == "") then
	apphost_name = nil;
end
app_ipc.apphost_name = apphost_name;

-- for trusted files
local trusted_files;

-- add a public file, so that NPLJabberClient:AddPublicFile(filename, id)
-- this function is similar to NPL.AddPublicFile()
-- @param filename: any string of file name. case sensitive. 
-- @param id: id of the file. 
function app_ipc.AddPublicFile(filename, id)
	if(not trusted_files) then
		NPL.load("(gl)script/ide/stringmap.lua");
		trusted_files = commonlib.stringmap:new()
	end
	trusted_files:add(filename, id);
end

-- whether the file is trusted. 
function app_ipc.IsFileTrusted(filename)
	if(trusted_files) then
		return (trusted_files:GetID(filename)~=nil)
	else
		-- security alert: one should call AddPublicFile() instead of trust all files. 
		return true;
	end
end

-- send an activation message to host app via IPC
-- @return true if succeed. 
function app_ipc.ActivateHostApp(filename, code, param1, param2)
	if(apphost_name) then
		local ipc_writer = IPC.CreateGetQueue(apphost_name, 2)
		if(ipc_writer) then
			return ipc_writer:try_send({type = 9, filename = filename, code = code, param1 = param1, param2 = param2,})
		end
	end	
end


local function activate()
	if(debug_stream) then
		log("app_ipc.lua received:");
		commonlib.echo(msg);
	end	

	local code;
	if(msg.code) then
		 code = string.match(msg.code, "^msg=({.*})?;$");
		 if(code) then
			code = NPL.LoadTableFromString(code);
		end	
	end
			
	if(msg.param1 == 0) then
		-- send to the given file. 
		if(type(code) == "table") then
			code.type = msg.type;
			code.from = msg.from;
			-- security warning: only allow activation of trusted files from another process. 
			if(app_ipc.IsFileTrusted(msg.filename)) then
				NPL.activate(msg.filename, code);
			else
				commonlib.log("error: access denied when activating files via IPC.");
				commonlib.echo(msg);
			end	
		end
		
	elseif(msg.param1 == 1) then
		-- echo back to remote process
		local ipc_writer = IPC.CreateGetQueue(msg.from, 2)
		if(ipc_writer) then
			log("echoing app_ipc msg back.\n")
			ipc_writer:try_send({type = msg.type, param1 = msg.param1, param2 = msg.param2, filename = msg.filename, code = msg.code})
		end
		
		-- Or one can do following call. 
		--if(app_ipc.ActivateHostApp(msg.filename, msg.code, msg.param1, msg.param2)) then
			--log("echoing app_ipc msg back.\n")
		--end
	end	
	
end
NPL.this(activate);