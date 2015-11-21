--[[
Title: an extension library to all ParaEngine namespaces
Author(s): LiXizhi
Date: 2006/11/12
Desc: 
Use Lib: 
-------------------------------------------------------
NPL.load("(gl)script/ide/ParaEngineExtension.lua");
-------------------------------------------------------
]]
NPL.load("(gl)script/ide/NPLExtension.lua");
NPL.load("(gl)script/ide/GUIEngine/TouchManager.lua");
local TouchManager = commonlib.gettable("commonlib.GUIEngine.TouchManager");
				
local select = select;

-- it first searches the global object, if not found, it will search the OPC list.
-- always check if the object is valid() upon receive.
function ParaScene.GetCharacter(charName)
	local obj = ParaScene.GetObject(charName);
	if(obj:IsValid() == false) then
		obj = ParaScene.GetObject("<OPC>"..charName);
	end
	return obj;
end

local sceneState;

-- scene State 
ParaEngine.SceneStateRenderState = 	{
	RenderState_Standard = 0,
	RenderState_3D = 1,
	RenderState_Shadowmap = 2,
	RenderState_Headon = 3,
	RenderState_Overlay_ZPass = 4,
	RenderState_Overlay = 5,
	RenderState_Overlay_Picking = 6, 
	RenderState_Debug = 7,
	RenderState_GUI = 8,
};

-- return the cached scene state attribute 
function ParaScene.GetSceneState()
	if(not sceneState or not sceneState:IsValid()) then
		sceneState = ParaScene.GetAttributeObject():GetChild("SceneState");
	end
	return sceneState;
end

-- optimize C++ API function by caching the table
local ParaCamera_GetAttributeObject = ParaCamera.GetAttributeObject;
local camera_attr_;
function ParaCamera.GetAttributeObject()
	if(not camera_attr_ or not camera_attr_:IsValid()) then
		log("camera attribute object refreshed \n");
		camera_attr_ = ParaCamera_GetAttributeObject();
	end
	return camera_attr_;
end

-- optimize C++ API function by caching the table
local ParaScene_GetAttributeObject = ParaScene.GetAttributeObject;
local scene_attr_;
function ParaScene.GetAttributeObject(name)
	if(not name) then
		if(not scene_attr_ or not scene_attr_:IsValid()) then
			scene_attr_ = ParaScene_GetAttributeObject();
		end
		return scene_attr_;
	else
		return ParaScene_GetAttributeObject(name);
	end
end

-- optimize C++ API function by caching the table
local ParaEngine_GetAttributeObject = ParaEngine.GetAttributeObject;
local paraengine_attr_;
function ParaEngine.GetAttributeObject()
	if(not paraengine_attr_ or not paraengine_attr_:IsValid()) then
		paraengine_attr_ = ParaEngine_GetAttributeObject();
	end
	return paraengine_attr_;
end


-- capture the current scene state to be restored later on. 
-- e.g. 
--  local state = ParaScene.CaptureSceneState()
--	-- change scene state and render ...
--	ParaScene.RestoreSceneState(state);
--
-- options: a table or nil. if nil, it will capture everything. 
-- @return: return the captured scene state 
function ParaScene.CaptureSceneState(options)
	local att;
	local state = {};
	-- save player
	state.player = ParaScene.GetPlayer();
	
	-- save scene
	state.OceanEnabled = ParaScene.IsGlobalWaterEnabled();
	att = ParaScene.GetAttributeObject();
	state.EnableFog = att:GetField("EnableFog", false);
	state.FogEnd = att:GetField("FogEnd", 120);
	state.FogStart = att:GetField("FogStart", 40);
	
	-- save camera settings
	att = ParaCamera.GetAttributeObject();
	state.CameraFarPlane = att:GetField("FarPlane", 120);
	state.CameraNearPlane = att:GetField("NearPlane", 0.5);
	state.FieldOfView = att:GetField("FieldOfView", 1.0472);
	state.AspectRatio = att:GetField("AspectRatio", 1);
	
	state.CameraObjectDistance = att:GetField("CameraObjectDistance", 5);
	state.CameraLiftupAngle = att:GetField("CameraLiftupAngle", 0.4);
	state.CameraRotY = att:GetField("CameraRotY", 0);
	state.is_perspective_view = att:GetField("IsPerspectiveView", true);

	-- UI
	state.UIVisible = ParaUI.GetUIObject("root").visible;
	state.EnableMiniSceneGraph = ParaScene.IsMiniSceneGraphEnabled();
	return state;
end

-- restore scene state
function ParaScene.RestoreSceneState(state)
	if(not state) then return end
	local att;
	--player
	if(state.player) then
		state.player:ToCharacter():SetFocus();
		if(state.CameraObjectDistance and state.CameraLiftupAngle and state.CameraRotY) then
			ParaCamera.ThirdPerson(0, state.CameraObjectDistance, state.CameraLiftupAngle, state.CameraRotY);
		end	
	end
	-- scene
	att = ParaScene.GetAttributeObject(); 
	if(state.OceanEnabled~=nil) then
		ParaScene.SetGlobalWater(state.OceanEnabled, ParaScene.GetGlobalWaterLevel())
	end	
	if(state.FogStart) then
		att:SetField("FogStart", state.FogStart);
	end	
	if(state.FogEnd) then
		att:SetField("FogEnd", state.FogEnd);
	end	
	if(state.EnableFog) then
		att:SetField("EnableFog", state.EnableFog);
	end	
	
	-- camera
	att = ParaCamera.GetAttributeObject();
	if(state.FarPlane) then	
		att:SetField("FarPlane", state.FarPlane);
	end	
	if(state.NearPlane) then	
		att:SetField("NearPlane", state.NearPlane);
	end
	if(state.FieldOfView) then		
		att:SetField("FieldOfView", state.FieldOfView);
	end	
	if(state.AspectRatio) then		
		att:SetField("AspectRatio", state.AspectRatio);
	end	

	if(state.is_perspective_view ~= nil) then
		att:SetField("IsPerspectiveView", state.is_perspective_view);
	end
	
	-- UI
	if(state.UIVisible~=nil) then
		ParaUI.GetUIObject("root").visible = state.UIVisible;
	end
	if(state.EnableMiniSceneGraph~=nil) then
		ParaScene.EnableMiniSceneGraph(state.EnableMiniSceneGraph);
	end	
end

-- set the look at position of the camera. It uses an invisible avatar as the camera look at position. 
-- after calling this function, please call ParaCamera.SetEyePos(facing, height, angle) to change the camera eye position. 
function ParaCamera.SetLookAtPos(x, y, z)
	local player = ParaCamera.GetDummyObject();
	player:SetPosition(x, y - 0.35, z);
	player:ToCharacter():SetFocus();
end

function ParaCamera.GetLookAtPos()
	return unpack(ParaCamera.GetAttributeObject():GetField("Lookat position", {0,0,0}));
end
-- it returns polar coordinate system.
-- @return camobjDist, LifeupAngle, CameraRotY
function ParaCamera.GetEyePos()
	local att = ParaCamera.GetAttributeObject();
	return att:GetField("CameraObjectDistance", 0), att:GetField("CameraLiftupAngle", 0), att:GetField("CameraRotY", 0);
end

-- create/get the dummy camera object for the camera look position. 
function ParaCamera.GetDummyObject()
	local player = ParaScene.GetObject("invisible camera");
	if(player:IsValid() == false) then
		player = ParaScene.CreateCharacter ("invisible camera", "", "", true, 0, 0, 0);
		--player:GetAttributeObject():SetField("SentientField", 0);--senses nobody
		player:GetAttributeObject():SetField("SentientField", 65535);--senses everybody
		--player:SetAlwaysSentient(true);--senses everybody
		player:SetDensity(0); -- make it flow in the air
		player:SetPhysicsHeight(0);
		player:SetPhysicsRadius(0);
		player:SetField("SkipRender", true);
		player:SetField("SkipPicking", true);
		ParaScene.Attach(player);
		player:SetPosition(0, 0, 0);
	end
	return player;
end

-- set the camera eye position by camera object distance, life up angle and rotation around the y axis. One must call ParaCamera.SetLookAtPos() before calling this function. 
-- e.g.ParaCamera.SetEyePos(5, 1.3, 0.4);
function ParaCamera.SetEyePos(camobjDist, LifeupAngle, CameraRotY)
	local att = ParaCamera.GetAttributeObject();
	att:SetField("CameraObjectDistance", camobjDist);
	att:SetField("CameraLiftupAngle", LifeupAngle);
	att:SetField("CameraRotY", CameraRotY);
end

-- switch to orthographic camera view, where the near and far objects are of the same size. 
-- @param orthoWidth: the width of the orthographic view volumn.
-- @param orthoHeight: the height of the orthographic view volumn.
function ParaCamera.SwitchOrthoView(orthoWidth, orthoHeight)
	local att = ParaCamera.GetAttributeObject();
	att:SetField("OrthoWidth", orthoWidth or 100);
	att:SetField("OrthoHeight", orthoHeight or 100);
	att:SetField("IsPerspectiveView", false);
end

-- only for documentation and api compatible. these two functions are implemented in c++. 
if(not ParaCamera.SetKeyMap and not ParaCamera.GetKeyMap) then
	--we can alter key map at runtime
	-- e.g. ParaCamera.SetKeyMap(0, DIK_SCANCODE.DIK_A);
	--		ParaCamera.SetKeyMap(1, DIK_SCANCODE.DIK_D);
	-- @param key: CharacterAndCameraKeys . [0-10]
	-- @param scancode:  DIK_SCANCODE.DIK_A, DIK_D,DIK_W,DIK_S,DIK_Q,DIK_E,DIK_SPACE,0,0,DIK_INSERT,DIK_DELETE*/
	function ParaCamera.SetKeyMap(name, value)	end
	-- e.g. ParaCamera.SetKeyMap(0) == DIK_SCANCODE.DIK_A
	function ParaCamera.GetKeyMap(name)		return 0	end
end


-- switch to perspective view
function ParaCamera.SwitchPerspectiveView()
	local att = ParaCamera.GetAttributeObject();
	att:SetField("IsPerspectiveView", true);
end

NPL.load("(gl)script/kids/3DMapSystemApp/localserver/factory.lua");
ParaAsset.RemoteTexture_cache_policy = Map3DSystem.localserver.CachePolicy:new("access plus 1 hour");
--[[ 
An internal ResourceStore (local server) called "_default_" is used to serve http textures. 
An internal time is also used so that we can sequence downloader threads. 
]]
function ParaAsset.GetRemoteTexture(url)
	local ls = Map3DSystem.localserver.CreateStore();
	if(not ls) then
		log("error: failed creating local server resource store \n")
		return
	end
	ls:GetFile(ParaAsset.RemoteTexture_cache_policy, url, ParaAsset.GetRemoteTexture_callback);
end

function ParaAsset.GetRemoteTexture_callback(entry)
	if(entry and entry.entry and entry.entry.url and entry.payload and entry.payload.cached_filepath) then
		local asset = ParaAsset.LoadTexture("", entry.entry.url, 1);
		--if(asset:IsValid()) then -- TODO: shall we: and asset:GetFileName() ~= entry.payload.cached_filepath ?
			asset:Refresh(entry.payload.cached_filepath);
		--end
	end
end

-- clear all cached textures. 
function ParaAsset.ClearTextureCache()
	local ls = Map3DSystem.localserver.CreateStore();
	if(not ls) then
		log("error: failed creating local server resource store\n")
		return
	end
	ls:DeleteAll();
end

--[[
This function is only used internally. It is called automatically when the ParaEngine Core detects that a texture is a remote texture. 
@note: One shall never call this function explicitly. In scripting interface, we can call ParaAsset.LoadRemoteTexture() instead
Load a texture from remote file. It first checks if the file is available from the local texture cache,
if yes, it will immediately use the local copy, before refreshing from the network. In either case, a thread is 
used to synchronize with the remote server. The only exception is that the filename contains a CRC32 parameter, 
where the remote sync is skipped if CRC match.
]]
function ParaAsset.SyncRemoteTexture(FileUrl)
	local _, _, uri= string.find(FileUrl, "(.*)%?CRC32=%d+");
	if(uri==nil) then uri = FileUrl end
	local _, _, domain, subfile = string.find(uri, "http://([^/]-)/(.*)$");
	if(not domain or not subfile) then return end
	subfile = string.gsub(subfile, "[%?/=&]", "_");
	local DestFolder = "temp/textures/"..domain.."/"
	ParaIO.CreateDirectory(DestFolder);
	DestFolder = DestFolder..subfile;
	
	NPL.SyncFile(uri, DestFolder, string.format("ParaAsset.SyncRemoteTexture_callback(%q, %q);", FileUrl, DestFolder), FileUrl)
end

function ParaAsset.SyncRemoteTexture_callback(FileUrl, DestFolder)
	if(msg~=nil and msg.DownloadState=="complete") then
		local asset = ParaAsset.LoadTexture("", FileUrl, 1);
		if(asset:IsValid() and asset:GetFileName()~=DestFolder) then
			asset:Refresh(DestFolder);
		end
	end
end

--[[ Load a remote texture explicitly. This function differs from the original ParaAsset.LoadTexture() that
it allows you to specify a loadingtexture to display while the texture is being downloaded. 
@param filename: http texture
	note3: crc32 code can be appended to file name, so that the same file does not need to be downloaded multiple times if local and server version match. such as "http://www.paraengine.com/images/index_12.png?CRC32=0".
@param loadingtexture: while filename is being downloaded, this texture will be used. 
@return: texture is returned.
]]
function ParaAsset.LoadRemoteTexture(filename, loadingtexture)
	local asset = ParaAsset.LoadTexture("", filename, 1);
	if(asset:IsValid()) then
		if(loadingtexture~=nil and asset:GetFileName()=="")then
			asset:Refresh(loadingtexture);
		end	
	end
	return asset;
end

if(ParaUI and ParaUI.ParaUIObject) then
	-- internal pool for storing callback
	local scriptPools = {};

	-- all supported events
	local supportEvents = {
		["onclick"] = true,
		["ondoubleclick"] = true,
		["onframemove"] = true,
		["ondraw"] = true,
		["onchange"] = true,
		["onkeydown"] = true,
		["onkeyup"] = true,
		["ondragbegin"] = true,
		["ondragend"] = true,
		["ondragmove"] = true,
		["onmousedown"] = true,
		["onmouseup"] = true,
		["onmousemove"] = true,
		["onmousewheel"] = true,
		["onmousehover"] = true,
		["onmouseenter"] = true,
		["onmouseleave"] = true,
		["onselect"] = true,
		["onmodify"] = true,
		["onsize"] = true,
		["ondestroy"] = true,
		["ontouch"] = true,
		["oninputmethod"] = true,
		["onactivate"] = true,
	}

	local touchEvents = {
		["ontouchbegin"] = true,
		["ontouchmove"] = true,
		["ontouchend"] = true,
		["ontouchcancel"] = true,
		-- represent all above touch events, ontouch is handled via C++ now
		-- ["ontouch"] = true,
	}

	local function OnGUITouchEventCallback(id, event)
		local eventname = event.type;
		local pool = scriptPools[id]
		if(pool) then
			local callInfo = pool[eventname];
			if(callInfo) then
				if(type(callInfo.func) == "function") then
					local obj = ParaUI.GetUIObject(id)
					-- TODO: shall we only send message if message falls within the control? 
					-- local x, y, width, height = obj:GetAbsPosition();
					-- if(event.x > x and event.y > y and ...) then 

					if(obj and obj:IsValid()) then
						if(callInfo.args) then
							callInfo.func(obj, event, unpack(callInfo.args, 1, callInfo.args.n));
						else
							callInfo.func(obj, event);
						end
						return;
					end
				end
			end
		end
		-- automatically remove touch listener if UI object no longer exist. 
		TouchManager.GetEventSystem():RemoveEventListener(eventname, OnTouchEventCallback, id);
	end

	-- this function makes ParaUIObject to be able to accept function callback.
	-- hence one can do this _parent:SetScript("onclick", MyFunction); in addition to _parent.onclick=";MyFunction();"
	-- Please note that: the caller is advised not to use the original "ondestroy" event (using SetScript is fine), 
	-- since internally, we will use the ondestroy event to clear the message pool. Failed doing so, we will cause unused message pool objects not cleared. 
	-- However, this might not be a big problem for static UI, but will be a problem if objects are frequently created and destroyed (looks like memory leak).
	-- @param EventName: string of "onclick" , "onframemove", etc. it should be an support event name of ParaUIObject. 
	-- @param pCallBackFunc: function of type function(obj, ...) end
	-- @param ...: additional parameters passed to pCallBackFunc.
	function ParaUI.ParaUIObject:SetScript(EventName, pCallBackFunc, ...)
		local id = self.id
		if(id) then
			local pool = scriptPools[id] or {};
			local bIsTouchEvent;
			if(not supportEvents[EventName]) then
				if(touchEvents[EventName]) then
					bIsTouchEvent = true;
				else
					commonlib.log("warning: EventName %s is not supported for %s\n", EventName, self.name);
					return
				end
				
			end

			-- Tricky: fixed for varargs syntax in lua5.1 and luajit2. There can be nils in the varargs, we will keep the argument count in args.n. 
			local args;
			local args_count = select('#', ...);
			if(args_count > 0) then
				args = {...};
				args.n = args_count;
			end
			 
			pool[EventName] = {func = pCallBackFunc, args = args}
			scriptPools[id] = pool;
			
			if(not bIsTouchEvent) then
				self[EventName] = string.format(";__onuievent__(%d, %q);", id, EventName)
			else
				-- register for touch event. 
				TouchManager.GetEventSystem():AddEventListener(EventName, OnGUITouchEventCallback, id, id);
			end

			if(EventName ~= "ondestroy" and self.ondestroy == "") then
				-- create the ondestroy handler
				self.ondestroy = string.format(";__onuievent__(%d, %q);", id, "ondestroy")
				-- LOG.std("", "debug", "UI", "ui object %d script handler added", id);
			end
		end	
	end
	
	-- Example: this allows us to add or override an existing luabind property
	--[[ParaUI.ParaUIObject.text1 = property(
		function(self)  -- get attribute
			return "asd" 
		end, 
		function(self, value) -- set attribute
		end);]]

	-- this is a global function to invoke script.
	function __onuievent__(id, eventname)
		
		if(eventname == "ondestroy") then
			local pool = scriptPools[id];
			if(pool) then
				-- now clear the ui event pool to prevent memory leak. 
				scriptPools[id] = nil;
				-- LOG.std("", "debug", "UI", "ui object %d script handler cleared", id);
				local callInfo = pool[eventname];
				if(callInfo) then
					if(type(callInfo.func) == "function") then
						if(callInfo.args) then
							callInfo.func(obj, unpack(callInfo.args, 1, callInfo.args.n));
						else
							callInfo.func(obj);
						end
					end
				end
			end
		else
			local obj = ParaUI.GetUIObject(id)
			if(obj and obj:IsValid()) then
				local pool = scriptPools[id]
				if(pool) then
					local callInfo = pool[eventname];
					if(callInfo) then
						if(type(callInfo.func) == "function") then
							if(callInfo.args) then
								callInfo.func(obj, unpack(callInfo.args, 1, callInfo.args.n));
							else
								callInfo.func(obj);
							end
						end
					end
				end
			end
		end
	end
end	

---------------------------------------
-- install SetScript function for ParaObject 
---------------------------------------
local supported3DEvent = {
	["On_Paint"] = true,
	["On_EnterSentientArea"] = true,
	["On_LeaveSentientArea"] = true,
	["On_Click"] = true,
	["On_Event"] = true,
	["On_Perception"] = true,
	["On_FrameMove"] = true,
	["On_Net_Send"] = true,
	["On_Net_Receive"] = true,
}

-- internal pool for storing callback
local script3DPools = {};

function onevent_(id, eventname)
	local pool = script3DPools[id]
	if(pool) then
		local callInfo = pool[eventname];
		if(callInfo) then
			if(type(callInfo.func) == "function") then
				if(callInfo.args) then
					callInfo.func(unpack(callInfo.args, 1, callInfo.args.n));
				else
					callInfo.func();
				end
			end
		end
	end
end

-- @param class_meta: for ParaScene.ParaObject mostly. or any class having SetField(event_name, string_callback) method. 
local function InstallSetScript(class_meta, supportEvents)
	class_meta["SetScript"] = function(self, EventName, pCallBackFunc, ...)
		local id = self.id
		if(id) then
			local pool = script3DPools[id] or {};
			
			-- Tricky: fixed for varargs syntax in lua5.1 and luajit2. There can be nils in the varargs, we will keep the argument count in args.n. 
			local args;
			local args_count = select('#', ...);
			if(args_count > 0) then
				args = {...};
				args.n = args_count;
			end
			 
			pool[EventName] = {func = pCallBackFunc, args = args}
			script3DPools[id] = pool;
			-- set callback to C++ side
			self:SetField(EventName, string.format(";onevent_(%d, %q);", id, EventName));
		end	
	end;
end

if(ParaScene and ParaScene.ParaObject) then
	InstallSetScript(ParaScene.ParaObject, supported3DEvent);
end

if(ParaScene and ParaScene.ParaMiniSceneGraph) then
	InstallSetScript(ParaScene.ParaMiniSceneGraph, supported3DEvent);
end

-- fixing open http page if the user computer does not have iexplore or http file binding. 
if(ParaGlobal.ShellExecute) then
	local ShellExecute_old = ParaGlobal.ShellExecute;
	ParaGlobal.ShellExecute = function(Operation, sFile, sParameters, sDirectory, nShowCmd)
		if(Operation == "open") then
			if(sFile == "iexplore.exe" and sParameters:match("^http")) then
				if(not ShellExecute_old(Operation, sFile, sParameters, sDirectory, nShowCmd) ) then
					-- try opening http directly if iexplore failed
					return ShellExecute_old(Operation, sParameters, "", sDirectory, nShowCmd);
				end
				return true;
			elseif(sFile:match("^http") and sParameters=="") then
				if(not ShellExecute_old(Operation, sFile, sParameters, sDirectory, nShowCmd) ) then
					-- try opening iexplore if open http directly failed
					return ShellExecute_old(Operation, "iexplore.exe", sFile, sDirectory, nShowCmd);
				end
				return true;
			end
		end
		return ShellExecute_old(Operation, sFile, sParameters, sDirectory, nShowCmd);
	end
end
-- obsoleted API functions
-- mapping from table name to boolean, string or function. 
local obsoleted_functions = {
	["ParaAudio.PlayBGMusic"] = true, 
	["ParaAudio.StopBGMusic"] = "This can be a message.", 
	["ParaAudio.PlayStatic3DSound"] = function(sName, filepath, x, y, z)
		log("warning: ParaAudio.PlayStatic3DSound is not supported\n")
	end, 
	["ParaAudio.StopCategory"] = true, 
	["ParaAudio.LoadInMemoryWaveBank"] = true, 
	["ParaAudio.LoadStreamWaveBank"] = true, 
	["ParaAudio.LoadSoundBank"] = true, 
	["ParaAudio.StopRecording"] = true, 
	["ParaAudio.GetRecordingDeviceEnum"] = true, 
	["ParaAudio.SetRecordingOutput"] = true, 
	["ParaAudio.BeginRecording"] = true, 
	["ParaAudio.SetBGMusicVolume"] = true, 
	["ParaAudio.SetDialogVolume"] = true, 
	["ParaAudio.SetAmbientSoundVolume"] = true, 
	["ParaAudio.SetUISoundVolume"] = true, 
	["ParaAudio.Set3DSoundVolume"] = true, 
	["ParaAudio.SetInteractiveSoundVolume"] = true, 
	["ParaAudio.PlayUISound"] = true, 
	["ParaAudio.GetBGMusicVolume"] = true, 
	["ParaAudio.EnableAudioBank"] = true, 
}

local function CreateDummy_functions()
	local func_name, sMsg
	for func_name, sMsg in pairs(obsoleted_functions) do
		if(type(sMsg) == "boolean") then
			commonlib.setfield(func_name,  function()
				commonlib.log("warning: function %s is obsoleted.\n", func_name);
			end)
		elseif(type(sMsg) == "string") then
			commonlib.setfield(func_name,  function()
				commonlib.log("warning: function %s is obsoleted. %s\n", func_name, sMsg);
			end)
		elseif(type(sMsg) == "function") then
			commonlib.setfield(func_name,  sMsg);
		end
	end
end

-- for mobile platform
if(ParaEngine.GetAttributeObject():GetField("IsMobilePlatform", false)) then
	-- load related api
	NPL.load("(gl)script/mobile/API/LocalBridgePBAPI.lua");
	if(MobileDevice) then
		log("mobile platform API loaded from LocalBridgePBAPI\n");
		-- for mobile device, replace ShellExecute to open url externally. 
		local old_ParaGlobal_ShellExecute = ParaGlobal.ShellExecute;
		ParaGlobal.ShellExecute = function(lpOperation, lpFile, lpParameters, lpDirectory, nShowCmd)
			if(lpOperation == "open" and lpFile and lpFile:match("http://")) then
				if(MobileDevice.openURL) then
					MobileDevice.openURL({url = lpFile});
				else
					_guihelper.MessageBox(lpFile);
				end
			else
				old_ParaGlobal_ShellExecute(lpOperation, lpFile, lpParameters, lpDirectory, nShowCmd);
			end
		end
	end
end

-- add some helper function on ParaAttributeObject to make it compatible with System.Core.AttributeObject
if(ParaAttributeObject) then
	NPL.load("(gl)script/ide/System/Core/Attribute.lua");
	local Attribute = commonlib.gettable("System.Core.Attribute");
	ParaAttributeObject.findPlug = function(self, name)
		if(self:GetFieldIndex(name)) then
			return Attribute:new():init(self, name);
		end
	end
	-- same as SetField, except that some implementation may not send signals like valueChanged even data is modified. 
	-- it will automatically fallback to SetField if not such implementation is provided by the attribute object.  
	ParaAttributeObject.SetFieldInternal = function(self, name, value)
		self:SetField(name, value);
	end
end

-- create dummy functions for obsoleted functions. 
CreateDummy_functions();


