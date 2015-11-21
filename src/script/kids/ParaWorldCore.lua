--[[
Title: ParaWorld Platform Include
Author(s):  LiXizhi
Date: 2007/8/22
Desc: A single include file that contains the ParaWorld platform architecture. 
If you want to utilize the rich features of ParaWorld platform to create your ParaEngine application. 
Include this file in your main loop file.
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/kids/ParaWorldCore.lua");
System.SystemInfo.SetField("name", "Aries")
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/IDE.lua");
NPL.load("(gl)script/ide/Debugger/IPCDebugger.lua");

-- when ParaEngine starts, call following function only once to load all packages/startup/*.zip
-- Remove this line, if do not need to load any packages.
commonlib.package.Startup();

--
-- ParaWorld platform includes
--
NPL.load("(gl)script/kids/3DMapSystem_Data.lua");
NPL.load("(gl)script/kids/3DMapSystemUI/loadworld.lua");
NPL.load("(gl)script/ide/WindowFrame.lua");
NPL.load("(gl)script/kids/3DMapSystemAnimation/AnimationManager.lua");

--
-- ParaWorld platform commandline setting processing
--
-- let command line params to override some loaded or default settings. 
Map3DSystem.User.Name = ParaEngine.GetAppCommandLineByParam("username", Map3DSystem.User.Name);
Map3DSystem.User.Password = ParaEngine.GetAppCommandLineByParam("password", Map3DSystem.User.Password);

Map3DSystem.User.ChatDomain = ParaEngine.GetAppCommandLineByParam("chatdomain", nil);
Map3DSystem.User.Domain = ParaEngine.GetAppCommandLineByParam("domain", nil);
paraworld.ChangeDomain({domain=Map3DSystem.User.Domain, chatdomain=Map3DSystem.User.ChatDomain})
Map3DSystem.options.ForceGateway = ParaEngine.GetAppCommandLineByParam("gateway", nil);

local IsServerMode = ParaEngine.GetAppCommandLineByParam("servermode", "false");
local IsQuestServerMode = ParaEngine.GetAppCommandLineByParam("questservermode", "false");
if(IsServerMode == "true") then
	main_state = "JGSL_servermode";
	ParaGlobal.SetGameLoop("(gl)script/kids/3DMapSystemNetwork/JGSL_servermode_loop.lua");
elseif(IsQuestServerMode == "true") then
	main_state = "Quest_servermode";
	ParaGlobal.SetGameLoop("(gl)script/kids/3DMapSystemQuest/Quest_Server_Loop.lua");
else	
	IsServerMode = nil;
end

Map3DSystem.User.IP = ParaEngine.GetAppCommandLineByParam("IP", "0");
Map3DSystem.User.Port = tonumber(ParaEngine.GetAppCommandLineByParam("port", "60001"));

-- update application title
ParaEngine.SetWindowText(string.format("www.paraengine.com -- powered by ParaEngine"));

-- whether we are in a web browser plugin. 
Map3DSystem.options.IsWebBrowser = ((ParaEngine.GetAttributeObject():GetField("CoreUsage", 1) % 2) == 0);
-- whether we are in the mobile platform
Map3DSystem.options.IsMobilePlatform = ParaEngine.GetAttributeObject():GetField("IsMobilePlatform", false);
-- do not allow resizing windows when running standalone mode. Allow resizing in web browser
ParaEngine.GetAttributeObject():SetField("IgnoreWindowSizeChange", not Map3DSystem.options.IsWebBrowser);

--
-- ParaWorld platform common functions: init, reset, LoadWorld, CreateWorld
--

-- initialize the platform. This function is called at the beginning or after reset() to provide a clean restart of the platform
-- @param params: {useDefaultTheme, use Map3DSystem default theme
--		}
-- @return : return nil if failed or server mode. if succeed, return 0. e.g. main_state = Map3DSystem.init()
function Map3DSystem.init(params)
	
	if(IsServerMode) then
		return
	end
	
	if(params and params.useDefaultTheme) then
		-- load theme
		Map3DSystem.LoadDefaultMap3DSystemTheme();
	end
			
	-- set IP address of game server
	--ParaNetwork.SetNerveCenterAddress(string.format("%s:%d", Map3DSystem.User.IP, Map3DSystem.User.Port));
	--ParaNetwork.SetNerveReceptorAddress(string.format("%s:%d", Map3DSystem.User.IP, Map3DSystem.User.Port-1));
	
	-- startup all applications
	NPL.load("(gl)script/kids/3DMapSystemApp/AppManager.lua");
	Map3DSystem.App.AppManager.Startup();
	
	-- rebind event handlers
	Map3DSystem.ReBindEventHandlers();
		
	-- disable network unpon restart
	ParaNetwork.EnableNetwork(false, "","");
	--ParaAudio.EnableAudioBank("Kids");
	
	-- TODO: Play back ground music?
	return 0;
end
				
-- reset the scene
-- @param bPerserveUI: if true, UI and timers are not cleared. default to nil
function Map3DSystem.reset(bPerserveUI)
	if(not bPerserveUI) then
		-- kill all timers.
		NPL.KillTimer(-1);
		-- kill all virtual timers. 
		if(commonlib.TimerManager) then
			commonlib.TimerManager.Clear();
		end	
	end	
	ParaScene.Reset();
	if(not bPerserveUI) then
		ParaUI.ResetUI();
		
		if(UIAnimManager and UIAnimManager.Init) then
			UIAnimManager.Init();
		end	
	end	
	ParaAsset.GarbageCollect();
	ParaGlobal.SetGameStatus("disable");
	if(_AI~=nil and _AI.temp_memory~=nil) then
		_AI.temp_memory = {}
	end
	Map3DSystem.ResetState();
	
	-- TODO: reset recorder and movie box. 
	
	collectgarbage();
	log("scene has been reset\n");

	if(IPCDebugger) then
		IPCDebugger.Start();
	end	

	-- clear all entity cache . This is defined in NPL.load("(gl)script/ide/IPCBinding/EntityHelper.lua");
	local clear_cache_func = commonlib.getfield("IPCBinding.EntityHelper.ClearAllCachedObject");
	if(type(clear_cache_func) == "function") then
		clear_cache_func();
	end
end

-- close current world
function Map3DSystem.CloseWorld(isPerserveUI)
end

-- providing system information. 
SystemInfo = commonlib.gettable("Map3DSystem.SystemInfo");
SystemInfo.info = {};
function SystemInfo.GetField(name)
	return SystemInfo.info[name];
end
function SystemInfo.SetField(name, value)
	SystemInfo.info[name] = value;
end

-- loadworld and start the default UI.
-- @param input: it can be worldpath string, such as "worlds/3DMapStartup", or a table of 
-- {worldpath, bExclusiveMode, bRunOnloadScript, OnProgress}
--		bExclusiveMode: use exclusive desktop mode. menu and taskbar will not be created. 
--		OnProgress: nil or a function of function(percent) end, where percent is between [0,100]
-- @param bHideProgressUI: if true, progress UI is hidden. default to nil
-- return true if loaded successfully. otherwise it may be false or an error message. 
function Map3DSystem.LoadWorld(input, isPerserveUI,bHideProgressUI)
	--NPL.load("(gl)script/kids/3DMapSystemUI/ApplicationManager.lua");
	
	local worldpath;
	local bExclusiveMode, bRunOnloadScript = false, true
	if(type(input) == "string") then
		worldpath = input;
	elseif(type(input) == "table") then
		worldpath = input.worldpath;
		if(input.bExclusiveMode~=nil) then
			bExclusiveMode = input.bExclusiveMode
		end	
		if(input.bRunOnloadScript~=nil) then
			bRunOnloadScript = input.bRunOnloadScript
		end
	end
	
	-- read the application list
	--local appList = Map3DSystem.ApplicationManager.ReadApplicationList(worldpath);
	
	-- download applications on demand according to the application list
	-- TODO: basicly paraworld should provide two distinct download process:
	--		 1. in-game downloading: this will download the applications in back stage
	--		 2. in-loading downloading: this will download the applications during the loading process
	-- Here we assume the applications are already in user's client
	--Map3DSystem.ApplicationManager.DownloadApplicationList(appList);
	
	-- load applications
	-- call each onload function for each applications
	--Map3DSystem.ApplicationManager.LoadApplicationList(appList);
	
	-- TODO LiXizhi 2008.1.5: check for application dependency for this world. 
	
	local currentWorldPath = ParaWorld.GetWorldDirectory();
	
	if(currentWorldPath ~= "_emptyworld/") then
		-- not previous world is loaded when function Map3DSystem.LoadWorld() is invoked
		if(Map3DSystem.App.AppManager.OnWorldClosing()) then
			return "当前世界的关闭, 需要确认";
		end
		
		-- reset the scene TODO: 2010.2.10. delete this line, since Map3DSystem.UI.LoadWorld.LoadWorldImmediate will call it anyway
		-- Map3DSystem.reset(isPerserveUI);
		
		if(not Map3DSystem.App.AppManager.OnWorldClosed()) then
			log("error: sending APP_WORLD_CLOSED message to all applications\n");
			return;
		end
	end
	
	local res = Map3DSystem.UI.LoadWorld.LoadWorldImmediate(worldpath, isPerserveUI, bHideProgressUI, function (percent)
		if(input.OnProgress) then
			input.OnProgress(percent*0.8);
		end
	end);

	if(res == true) then
		Map3DSystem.Animation.InitAnimationManager();

		NPL.load("(gl)script/kids/3DMapSystemUI/Desktop/AppDesktop.lua");
		Map3DSystem.UI.AppDesktop.OnInit()
		
		-- Locale IDE to fetch the head arrow asset
		Map3DSystem.HeadArrowAsset = ParaAsset.LoadParaX("", CommonCtrl.Locale("IDE")("asset_headarrow"));

		-- rebind event handlers
		Map3DSystem.ReBindEventHandlers();
		
		-- send APP_WORLD_LOAD msg for each installed application, whenever a new world is loaded
		Map3DSystem.App.AppManager.OnWorldLoad();
		
		-- load menu and app task bar.
		Map3DSystem.UI.AppDesktop.LoadDesktop(bExclusiveMode);
		
		-- TODO: security alert, this is not in sandbox.  call the onload script for the given world
		if(bRunOnloadScript) then
			local sOnLoadScript = string.gsub(Map3DSystem.World.sConfigFile, "[^/\\]+$", "onload.lua");
			if(ParaIO.DoesFileExist(sOnLoadScript, true))then
				NPL.load("(gl)"..sOnLoadScript, true);
			end
		end	
		if(input.OnProgress) then
			input.OnProgress(100);
		end
	end
	return res;	
end

-- create a new world at path
--@param newworldpath such as "worlds/LiXizhi"
--@param BaseWorldPath: from which world the new world is derived. It can be nil if the empty world should be used. 
--@param bUseBaseWorldNPC: if this is true, base world NPC are inherited.
--@param bCloneBaseWorldScene: if this is true, base world files are cloned to the new world path. otherwise it will reuse the files from the base world. 
--@param bMinClone: we will only copy minimum files necessary to the new world path. if nil, it will copy all files under base world directory to the new world directory. 
--@return the error message is returned as a string. otherwise true is returned.
function Map3DSystem.CreateWorld(NewWorldpath, BaseWorldPath, bUseBaseWorldNPC, bCloneBaseWorldScene, bMinClone, bOverWrite)
	NewWorldpath = string.gsub(NewWorldpath, "[/\\]+$", "")
	if(BaseWorldPath) then
		BaseWorldPath = string.gsub(BaseWorldPath, "[/\\]+$", "")
	end	
	
	local world = Map3DSystem.world:new()
	world.name = NewWorldpath;
	world:SetDefaultFileMapping(NewWorldpath);
	
	-- ensure that the directory exists.
	ParaIO.CreateDirectory(NewWorldpath.."/log.txt");
	if(ParaIO.DoesFileExist(world.sConfigFile, true) == true and not bOverWrite) then
		return L"世界已经存在了, 如想重新创建, 请手工删除文件夹./"..commonlib.Encoding.DefaultToUtf8(NewWorldpath);
	else
		if(world:SetBaseWorldName(BaseWorldPath) ==  true) then
			local sConfigFileName = ParaWorld.NewWorld(NewWorldpath, world.sBaseWorldCfgFile);
			if(sConfigFileName ~= "") then
				world.sConfigFile = sConfigFileName;
				-- copy the base world's attribute file to the newly created world.
				-- so that environment and initial character position are preserved. 
				if(world.sBaseWorldAttFile) then
					if(not ParaIO.CopyFile(world.sBaseWorldAttFile, world.sAttributeDbFile, true)) then
						commonlib.log("warning: failed copying file sBaseWorldAttFile when creating world\n")
					end
				end
				
				if(bUseBaseWorldNPC and world.sBaseWorldNPCFile) then
					if(not ParaIO.CopyFile(world.sBaseWorldNPCFile, world.sNpcDbFile, true)) then
						commonlib.log("warning: failed copying file sBaseWorldNPCFile when creating world\n")
					end
				end
				
				if(bCloneBaseWorldScene and BaseWorldPath) then
					
					if(not bMinClone) then
						-- copy all other files under the directory. 
						local output = {};
						commonlib.SearchFiles(output, ParaIO.GetCurDirectory(0)..BaseWorldPath.."/", "*.*", 10, 10000, true)
						local _, file;
						for _, file in ipairs(output) do
							-- ignore any db, backup and worldconfig files.
							if(not string.match(file, "%.db$") and not string.match(file, "worldconfig%.txt$") and not string.match(file, "%.bak$")) then
								if(string.match(file, "[/\\][^.]+$")) then
									-- this is directory
									ParaIO.CreateDirectory(BaseWorldPath.."/"..file.."/log.txt");
								else
									ParaIO.CopyFile(BaseWorldPath.."/"..file, NewWorldpath.."/"..file, true);
								end	
							end
						end
					else
						-- copy only used files, this way we can support clone a world from assets manifest files. 
						local base_world = Map3DSystem.World:new();
						local worldpath = BaseWorldPath;
						base_world:SetDefaultFileMapping(worldpath);
						local new_name = NewWorldpath:match("([^/\\]+)$");
								
						local config_file = ParaIO.OpenAssetFile(base_world.sConfigFile);
						if(config_file:IsValid()) then
							-- find all referenced files
							local text = config_file:GetText();
							local files = {};
							local w;
							for w in string.gfind(text, "[^\r\n]+") do
								w = string.match(w, "[^/]+config%.txt$");
								if(w) then
									local config_file_name = worldpath.."/config/"..w;
									--files["/config/"..w] = "/config/"..w:gsub("^.*(_%d+_%d+%.)", new_game.."%1");
									files["/config/"..w] = true;
						
									local file = ParaIO.OpenAssetFile(config_file_name);
									if(file:IsValid()) then
										local tile_text = file:GetText();
										for w in string.gfind(tile_text, "[^\r\n]+") do
											local content = string.match(w, "[^/]+%.onload%.lua$");
											if(content) then
												files["/script/"..content] = true;
												files["/config/"..string.gsub(content, "onload%.lua$", "mask")] = true;
											end
											local content = string.match(w, "[^/]+%.raw$");
											if(content) then
												files["/elev/"..content] = true;
											end
										end
										file:close();
									else
										commonlib.log("warning: config file %s is not found\n", config_file_name);
									end
								end	
							end
							config_file:close();
							
							-- we will assume there is a preview image, and we will copy that too. Since it is harmless even there is no such file. 
							files["/preview.jpg"] = true;
							files["/LocalNPC.xml"] = true;
							files["/Player.xml"] = true;
							files["/tag.xml"] = true;
							files["/entity.xml"] = true;

							local filename, to_filename;
							for filename, to_filename in pairs(files) do
								
								-- commonlib.echo({worldpath..filename, NewWorldpath..filename});
								if(to_filename == true) then
									ParaIO.CopyFile(worldpath..filename, NewWorldpath..filename, true);
								else
									ParaIO.CopyFile(worldpath..filename, NewWorldpath..to_filename, true);
								end
							end

							-- check for any block world
							local output = {};
							commonlib.SearchFiles(output, ParaIO.GetCurDirectory(0)..BaseWorldPath.."/blockWorld.lastsave/", "*.*", 0, 1000, true)
							if(#output > 0) then
								ParaIO.CreateDirectory(NewWorldpath.."/blockWorld.lastsave/");
								local _, file;
								for _, file in ipairs(output) do
									local file_ending =  file:match("_(%d+_%d+%.raw)$")
									if(file_ending) then
										ParaIO.CopyFile(BaseWorldPath.."/blockWorld.lastsave/"..file, NewWorldpath.."/blockWorld.lastsave/"..file_ending, true);
									else
										ParaIO.CopyFile(BaseWorldPath.."/blockWorld.lastsave/"..file, NewWorldpath.."/blockWorld.lastsave/"..file, true);
									end
								end
							end
						else
							commonlib.echo({"file not found", config_file})	
						end
					end	
				end
				
				--TODO: keep other info from the user.
				return true;
			else 
				return "世界创建失败了。";
			end
		else
			return "被派生的世界不存在。";
		end
	end
end