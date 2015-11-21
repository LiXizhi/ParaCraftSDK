--[[
Title: MotionXmlToTable
Author(s): Leio
Date: 2011/05/16
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/MotionEx/MotionXmlToTable.lua");
local MotionXmlToTable = commonlib.gettable("MotionEx.MotionXmlToTable");
local filepath = "config/Aries/StaticMovies/Motion.xml";
local stage_params = {
	x = 250, y = 0, z = 250,
}
MotionXmlToTable.Play(filepath,1,stage_params)

NPL.load("(gl)script/ide/MotionEx/MotionXmlToTable.lua");
local MotionXmlToTable = commonlib.gettable("MotionEx.MotionXmlToTable");
local filepath = "config/Aries/StaticMovies/HaqiTown_FireCavern_FireRockyOgre_2.xml";
MotionXmlToTable.PlayCombatMotion(filepath,callbackFunc)

------------------------------------------------------------
--]]
NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
NPL.load("(gl)script/ide/MotionEx/StaticMoviePreloaderPage.lua");
local StaticMoviePreloaderPage = commonlib.gettable("MotionEx.StaticMoviePreloaderPage");
NPL.load("(gl)script/ide/MotionEx/MotionRender_SpellCastViewer.lua");
local MotionRender_SpellCastViewer = commonlib.gettable("MotionEx.MotionRender_SpellCastViewer");
NPL.load("(gl)script/apps/Aries/Combat/CombatCameraView.lua");
local CombatCameraView = commonlib.gettable("MotionEx.CombatCameraView");
NPL.load("(gl)script/ide/ExternalInterface.lua");
NPL.load("(gl)script/ide/MotionEx/MotionRender_Spell.lua");
local MotionRender_Spell = commonlib.gettable("MotionEx.MotionRender_Spell");
NPL.load("(gl)script/ide/MotionEx/MotionRender_Arena.lua");
local MotionRender_Arena = commonlib.gettable("MotionEx.MotionRender_Arena");
NPL.load("(gl)script/ide/MotionEx/MotionRender_Image.lua");
local MotionRender_Image = commonlib.gettable("MotionEx.MotionRender_Image");
NPL.load("(gl)script/ide/MotionEx/MotionRender_Mcml.lua");
local MotionRender_Mcml = commonlib.gettable("MotionEx.MotionRender_Mcml");
NPL.load("(gl)script/ide/MotionEx/MotionRender_Audio.lua");
local MotionRender_Audio = commonlib.gettable("MotionEx.MotionRender_Audio");
NPL.load("(gl)script/ide/MotionEx/MotionRender_Camera.lua");
local MotionRender_Camera = commonlib.gettable("MotionEx.MotionRender_Camera");
NPL.load("(gl)script/ide/MotionEx/MotionRender_Text.lua");
local MotionRender_Text = commonlib.gettable("MotionEx.MotionRender_Text");
NPL.load("(gl)script/ide/MotionEx/MotionRender_Model.lua");
local MotionRender_Model = commonlib.gettable("MotionEx.MotionRender_Model");
NPL.load("(gl)script/ide/MotionEx/MotionRender_Script.lua");
local MotionRender_Script = commonlib.gettable("MotionEx.MotionRender_Script");
NPL.load("(gl)script/ide/timer.lua");
NPL.load("(gl)script/apps/Aries/Scene/main.lua");
local Scene = commonlib.gettable("MyCompany.Aries.Scene");
NPL.load("(gl)script/ide/Director/Movie.lua");
local Movie = commonlib.gettable("Director.Movie");

local MotionXmlToTable = commonlib.gettable("MotionEx.MotionXmlToTable");
MotionXmlToTable.motionMap = {};
MotionXmlToTable.assetMap = {};
MotionXmlToTable.audioMap = {};
MotionXmlToTable.mcmlContainerMap = {};
MotionXmlToTable.motion_duration_map = {};
MotionXmlToTable.Const_Interval = 10;
MotionXmlToTable.mini_scene_motion_name = "mini_scene_motion_name_MotionXmlToTable";
local ParaScene_GetMiniSceneGraph = ParaScene.GetMiniSceneGraph;
MotionXmlToTable.maps = {
	["Model"] = MotionRender_Model,
	["Character"] = MotionRender_Model,
	["Text"] = MotionRender_Text,
	["Camera"] = MotionRender_Camera,
	["Audio"] = MotionRender_Audio,
	["Mcml"] = MotionRender_Mcml,
	["Image"] = MotionRender_Image,
	["Arena"] = MotionRender_Arena,
	["Spell"] = MotionRender_Spell,
	["Script"] = MotionRender_Script,
}
--播放电影的时候隐藏世界中的怪物
MotionXmlToTable.hide_mobs = {
	["config/Aries/StaticMovies/Global_AncientEgyptIsland_TreasureHouse_Show.teen.xml"] = true,
}
-- NOTE by andy: NEVER INVOKE LIKE THIS !!!
----hook player
--MotionXmlToTable.player = ParaScene.GetPlayer();

--hook player
if(ParaScene and ParaScene.GetPlayer) then
	MotionXmlToTable.player = ParaScene.GetPlayer();
end

function MotionXmlToTable.FindFocus_isDebug()
	local self = MotionXmlToTable;
	if(self.player and self.player:IsValid())then
		self.player:ToCharacter():SetFocus();
	end
end
function MotionXmlToTable.GetAvatarParams()
	local self = MotionXmlToTable;
	local player = ParaScene.GetPlayer();
	local X,Y,Z = player:GetPosition();
	X = string.format("%.2f",X);
	Y = string.format("%.2f",Y);
	Z = string.format("%.2f",Z);
	local p = {
		X = X,
		Y = Y,
		Z = Z,
	}
	ExternalInterface.Call("motion_avatar_params",p);
end
function MotionXmlToTable.GetCameraParams()
	local self = MotionXmlToTable;
	local X,Y,Z = ParaCamera.GetLookAtPos(); 
	local att = ParaCamera.GetAttributeObject();
	local CameraObjectDistance = att:GetField("CameraObjectDistance", 5);
	local CameraLiftupAngle = att:GetField("CameraLiftupAngle", 0.4);
	local CameraRotY = att:GetField("CameraRotY", 0);
	X = string.format("%.2f",X);
	Y = string.format("%.2f",Y);
	Z = string.format("%.2f",Z);
	CameraObjectDistance = string.format("%.2f",CameraObjectDistance);
	CameraLiftupAngle = string.format("%.2f",CameraLiftupAngle);
	CameraRotY = string.format("%.2f",CameraRotY);
	local p = {
		X = X,
		Y = Y,
		Z = Z,
		CameraObjectDistance = CameraObjectDistance,
		CameraLiftupAngle = CameraLiftupAngle,
		CameraRotY = CameraRotY,
	}
	ExternalInterface.Call("motion_camera_params",p);
end
function MotionXmlToTable.Clear_AllAssets()
	local self = MotionXmlToTable;
	local effectGraph = ParaScene_GetMiniSceneGraph(self.mini_scene_motion_name);
	local k,v;
	for k,v  in pairs(self.assetMap) do
		effectGraph:DestroyObject(v);
	end
	self.assetMap = {};
	local k,v;
	for k,v  in pairs(self.audioMap) do
		local audio_src = AudioEngine.CreateGet(v)
		if(audio_src)then
			audio_src.file = AssetFile;
			audio_src:stop();
			audio_src:release();
		end
	end
	self.audioMap = {};
	local k,v;
	for k,v  in pairs(self.mcmlContainerMap) do
		ParaUI.Destroy(v);
	end
	self.mcmlContainerMap = {};
	MotionRender_Text.DoEnd();
	MotionRender_SpellCastViewer.RemoveTestArena();
end
function MotionXmlToTable.Clear()
	local self = MotionXmlToTable;
	self.Clear_AllAssets();
	if(self.timer)then
		self.timer.callbackFunc = nil;
		self.timer:Change();
	end
	CombatCameraView.enabled = true;
	MotionRender_SpellCastViewer.StopSpellCasting();
	CombatCameraView.PlayIn_MotionXmlToTable(false);
	CombatCameraView.DoStop();
end
function MotionXmlToTable.GetCurPlayNode(motion_line_node,run_time,delta)
	local self = MotionXmlToTable;
	if(motion_line_node and run_time)then
		local state="update";
		local frame_node;
		delta = delta or 0;
		local last_frame_node;
		local jump_frame_map = motion_line_node.jump_frame_map;
		for frame_node in commonlib.XPath.eachNode(motion_line_node, "//Frame") do
			local time = self.GetNumber(frame_node,"Time");
			local next_time = time;
			local pre_frame_node = frame_node.pre_frame_node;
			local next_frame_node = frame_node.next_frame_node;
			if(pre_frame_node)then
				pre_time = self.GetNumber(pre_frame_node,"Time");
			end
			if(next_frame_node)then
				next_time = self.GetNumber(next_frame_node,"Time");
			end
			if(jump_frame_map)then
				if(run_time >= time and run_time < next_time)then
						local has_state = jump_frame_map[time];
						if(has_state == "none")then
							jump_frame_map[time] = "jumped";
							state="jumpframe";
						end
					return pre_frame_node,frame_node,next_frame_node,state;
				else
					local has_state = jump_frame_map[run_time];
					if(has_state == "jumped")then
						jump_frame_map[time] = "none";
					end
				end
			end
			last_frame_node = frame_node;
		end
		if(last_frame_node)then
			local time = self.GetNumber(last_frame_node,"Time");
			if( math.abs(run_time - time) <= delta )then
				local has_state = jump_frame_map[time];
				if(has_state == "none")then
					jump_frame_map[time] = "jumped";
					state="jumpframe";
				end
				return last_frame_node.pre_frame_node,last_frame_node,nil,state;
			end
		end
	end	
end
function MotionXmlToTable.GotoTime(filename,stage_params,motion_node,run_time,delta)
	local self = MotionXmlToTable;
	delta = delta or 0;
	if(motion_node and run_time)then
		local Duration = self.GetNumber(motion_node,"Duration");
		if(run_time >= Duration)then
			run_time = Duration;
			delta = 0;
		elseif(run_time < 0)then
			run_time = 0;
			delta = 0;
		end
		local motion_line_node;
		local level = 0;
		for motion_line_node in commonlib.XPath.eachNode(motion_node, "//MotionLine") do
			level = level + 1;
			local TargetType = motion_line_node.attr.TargetType or "";
			local pre_frame_node,frame_node,next_frame_node,state = self.GetCurPlayNode(motion_line_node,run_time,delta);
			if(frame_node)then
				local func = MotionXmlToTable.maps[TargetType];
				local clone_stage_params = {
					x = stage_params.x,
					y = stage_params.y,
					z = stage_params.z,
				}
				if(func and func.DoUpdate)then
					local instance_name = string.format("%s_%d",filename,level);
					if(TargetType == "Model")then
						clone_stage_params.ismodel = true;
					end
					local pre_time = self.GetNumber(pre_frame_node,"Time");
					local time = self.GetNumber(frame_node,"Time");
					local next_time = self.GetNumber(next_frame_node,"Time");
					func.DoUpdate(filename,instance_name,clone_stage_params,run_time,pre_frame_node,frame_node,next_frame_node,state,motion_node,motion_line_node,delta);
				end
			end
		end
	end
end
function MotionXmlToTable.OnInit()
	-- some code driven audio files for backward compatible
	AudioEngine.Init();
	-- set max concurrent sounds
	AudioEngine.SetGarbageCollectThreshold(10)
	-- load wave description resources
	AudioEngine.LoadSoundWaveBank("config/Aries/Audio/AriesRegionBGMusics.bank.xml");
end
--编辑工具使用
function MotionXmlToTable.Play_ByString_isDebug(filename,str,play_scene_index,stage_params)
	local self = MotionXmlToTable;
	local player = ParaScene.GetPlayer();
	self.Play_ByString(filename,str,play_scene_index,stage_params,function()
		player:ToCharacter():SetFocus();
	end,function(msg)
		ExternalInterface.Call("motion_time_update",{
			index = msg.play_scene_index,
			run_time = msg.run_time,
		});
	end)
end
--编辑工具使用
function MotionXmlToTable.Play_isDebug(filename,play_scene_index,stage_params)
	local self = MotionXmlToTable;
	local player = ParaScene.GetPlayer();
	self.Play(filename,play_scene_index,stage_params,function()
		player:ToCharacter():SetFocus();
	end,function(msg)
		ExternalInterface.Call("motion_time_update",{
			index = msg.play_scene_index,
			run_time = msg.run_time,
		});
	end)
end

--[[
	播放一个电影文件
	local stage_params = {x = x,y = y,z = z, play_single_index = play_single_index,start_time = start_time};
--]]
function MotionXmlToTable.Play(filename,play_scene_index,stage_params,callbackFunc,updateFunc)
	local self = MotionXmlToTable;
	commonlib.echo("=====MotionXmlToTable.Play");
	commonlib.echo(filename);
	commonlib.echo(play_scene_index);
	commonlib.echo(stage_params);
	if(not filename)then
		if(callbackFunc)then
			callbackFunc();
		end
		return
	end
	--加载要播放的文件
	local mcmlNode = self.Load(filename);
	if(not mcmlNode)then
		if(callbackFunc)then
			callbackFunc();
		end
		return
	end
	self.Play_ByMcmlNode(filename,mcmlNode,play_scene_index,stage_params,callbackFunc,updateFunc);
end
--内在方法
function MotionXmlToTable.Play_ByString(filename,str,play_scene_index,stage_params,callbackFunc,updateFunc)
	local self = MotionXmlToTable;
	commonlib.echo("=====MotionXmlToTable.Play_ByString");
	commonlib.echo(filename);
	commonlib.echo(str);
	commonlib.echo(play_scene_index);
	commonlib.echo(stage_params);
	local mcmlNode = ParaXML.LuaXML_ParseString(str);
	self.Play_ByMcmlNode(filename,mcmlNode,play_scene_index,stage_params,callbackFunc,updateFunc);
end
--内在方法
function MotionXmlToTable.Play_ByMcmlNode(filename,mcmlNode,play_scene_index,stage_params,callbackFunc,updateFunc)
	local self = MotionXmlToTable;
	commonlib.echo("=====MotionXmlToTable.Play_ByMcmlNode");
	commonlib.echo(filename);
	commonlib.echo(play_scene_index);
	commonlib.echo(stage_params);
	if(not mcmlNode)then return end
	local timer = self.timer;
	if(not timer)then
		timer = commonlib.Timer:new();
		self.timer = timer;
	end
	self.OnInit();
	self.Clear();
	play_scene_index = play_scene_index or 1;
	if(not stage_params)then
		stage_params = {
			x = 0,
			y = 0,
			z = 0,
		}
	end
	--起始播放时间
	local start_time = stage_params.start_time or 0;
	if(mcmlNode)then
		local motion_node;
		for motion_node in commonlib.XPath.eachNode(mcmlNode, "//Motions/Motion") do
			local line_node;
			for line_node in commonlib.XPath.eachNode(mcmlNode, "//MotionLine") do
				local frame_node;
				local pre_frame_node;
				local next_frame_node;
				local nodes = commonlib.XPath.selectNodes(line_node, "//Frame");
				local len = #nodes;
				local k;
				local jump_frame_map = {};
				for k = 1,len do
					frame_node = nodes[k];
					frame_node.pre_frame_node = nodes[k-1];
					frame_node.next_frame_node = nodes[k+1];
					local time = self.GetNumber(frame_node,"Time") or 0;
					jump_frame_map[time] = "none";
				end
				--关键帧是否触发
				line_node.jump_frame_map = jump_frame_map;
			end
		end

		local scene_count = self.GetSceneCount(mcmlNode) or 0;
		local motion_node = self.GetMotionByIndex(mcmlNode,play_scene_index)
		local Duration = 0;
		local run_time = start_time;
		Duration = self.GetNumber(motion_node,"Duration");
		timer.callbackFunc = function(timer)
			--标记MotionXmlToTable正在运行
			CombatCameraView.PlayIn_MotionXmlToTable(true);
			local delta = timer:GetDelta(200);
			--local delta = timer.delta;
			if(run_time > Duration)then
				self.GotoTime(filename,stage_params,motion_node,Duration,delta);

				play_scene_index = play_scene_index + 1;
				--是否只播放一个场景
				local play_single_index = stage_params.play_single_index;
				if(play_scene_index > scene_count or play_single_index)then
					self.Clear();
					if(callbackFunc)then
						callbackFunc();
					end
				else
					self.Clear_AllAssets();
					motion_node = self.GetMotionByIndex(mcmlNode,play_scene_index)
					Duration = self.GetNumber(motion_node,"Duration");
					run_time = 0;
					self.GotoTime(filename,stage_params,motion_node,run_time,delta);
				end
			else
				self.GotoTime(filename,stage_params,motion_node,run_time,delta);
			end
			run_time = run_time + delta;
			if(updateFunc)then
				updateFunc({
					play_scene_index = play_scene_index,
					run_time = run_time,
				});
			end
			local esc_pressed = ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_ESCAPE) or ParaUI.IsKeyPressed(DIK_SCANCODE.DIK_SPACE);
			if(esc_pressed and run_time > 1000)then
				self.Clear();
				if(callbackFunc)then
					callbackFunc();
				end
			end	
		end
		timer:Change(0, self.Const_Interval);
	else
		if(callbackFunc)then
			callbackFunc();
		end
	end
end
--编辑工具使用
function MotionXmlToTable.GotoTimeByManual_ByString(filename,str,play_scene_index,stage_params,run_time)
	local self = MotionXmlToTable;
	commonlib.echo("=====MotionXmlToTable.GotoTimeByManual_ByString");
	commonlib.echo(filename);
	commonlib.echo(play_scene_index);
	commonlib.echo(stage_params);
	commonlib.echo(run_time);

	local mcmlNode = ParaXML.LuaXML_ParseString(str);
	self.GotoTimeByManual_ByMcmlNode(filename,mcmlNode,play_scene_index,stage_params,run_time);
end
--编辑工具使用
--NOTE:self.GotoTime被触发了两次，第一次触发关键帧 第二次触发 区间变化
function MotionXmlToTable.GotoTimeByManual_ByMcmlNode(filename,mcmlNode,play_scene_index,stage_params,run_time)
	local self = MotionXmlToTable;
	play_scene_index = play_scene_index or 1;
	run_time = run_time or 0;
	self.OnInit();
	if(mcmlNode)then
		local motion_node;
		for motion_node in commonlib.XPath.eachNode(mcmlNode, "//Motions/Motion") do
			local line_node;
			for line_node in commonlib.XPath.eachNode(mcmlNode, "//MotionLine") do
				local frame_node;
				local pre_frame_node;
				local next_frame_node;
				local nodes = commonlib.XPath.selectNodes(line_node, "//Frame");
				local len = #nodes;
				local k;
				local jump_frame_map = {};
				for k = 1,len do
					frame_node = nodes[k];
					frame_node.pre_frame_node = nodes[k-1];
					frame_node.next_frame_node = nodes[k+1];
					local time = self.GetNumber(frame_node,"Time") or 0;
					jump_frame_map[time] = "none";
				end
				--关键帧是否触发
				line_node.jump_frame_map = jump_frame_map;
			end
		end

		local motion_node = self.GetMotionByIndex(mcmlNode,play_scene_index)
		self.GotoTime(filename,stage_params,motion_node,run_time);
		self.GotoTime(filename,stage_params,motion_node,run_time);
	end
end
function MotionXmlToTable.GetBoolean(mcmlNode,p)
	local self = MotionXmlToTable;
	local v = self.GetPropertyValue(mcmlNode,p)
	local b;
	if(v == "False" or v == "false")then
		b = false;
	else
		b = true;
	end
	return b;
end
function MotionXmlToTable.GetBoolean2(mcmlNode,p)
	local self = MotionXmlToTable;
	local v = self.GetPropertyValue(mcmlNode,p)
	local b;
	if(v == "True" or v == "true")then
		b = true;
	else
		b = false;
	end
	return b;
end
function MotionXmlToTable.GetString(mcmlNode,p)
	local self = MotionXmlToTable;
	local v = self.GetPropertyValue(mcmlNode,p)
	return v;
end
function MotionXmlToTable.GetNumber(mcmlNode,p)
	local self = MotionXmlToTable;
	local v = self.GetPropertyValue(mcmlNode,p)
	v = tonumber(v);
	return v;
end
function MotionXmlToTable.GetMotionByIndex(mcmlNode,index)
	local self = MotionXmlToTable;
	index = index or 1;
	if(mcmlNode)then
		local n = 0;
		local node;
		for node in commonlib.XPath.eachNode(mcmlNode, "//Motions/Motion") do
			n = n + 1;
			if(index == n)then
				return node;
			end
		end
	end
end
function MotionXmlToTable.GetMotionLineCount(mcmlNode)
	local self = MotionXmlToTable;
	if(mcmlNode)then
		local n = 0;
		local node;
		for node in commonlib.XPath.eachNode(mcmlNode, "//MotionLine") do
			n = n + 1;
		end
		return n;
	end
	return 0;
end
function MotionXmlToTable.GetSceneCount(mcmlNode)
	local self = MotionXmlToTable;
	if(mcmlNode)then
		local n = 0;
		local node;
		for node in commonlib.XPath.eachNode(mcmlNode, "//Motions/Motion") do
			n = n + 1;
		end
		return n;
	end
	return 0;
end
function MotionXmlToTable.GetPropertyValue(mcmlNode,p)
	local self = MotionXmlToTable;
	if(mcmlNode and p)then
		if(mcmlNode.attr)then
			local v = mcmlNode.attr[p];
			return v;
		end
	end
end
function MotionXmlToTable.SetPropertyValue(mcmlNode,p,v)
	local self = MotionXmlToTable;
	if(mcmlNode and p and v)then
		if(mcmlNode.attr)then
			mcmlNode.attr[p] = v;
		end
	end
end
--获取电影播放总时间长度
function MotionXmlToTable.GetMovieDuration(filename)
	local self = MotionXmlToTable;
	if(not filename)then 
		return 0;
	end
	local duration = self.motion_duration_map[filename];
	if(not duration)then
		duration = 0;
		self.motion_duration_map[filename] = duration;
		local xmlRoot = self.Load(filename);
		if(xmlRoot)then
			local node;
			for node in commonlib.XPath.eachNode(xmlRoot, "//Motions/Motion") do
				duration = tonumber(node.attr.Duration) or 0;
				self.motion_duration_map[filename] = duration;
				break;
			end
		end	
	end
	return duration;
end
function MotionXmlToTable.Load(filename,bForceLoad)
	local self = MotionXmlToTable;
	if(not filename)then return end
	filename = string.lower(filename);
	if(self.motionMap[filename] and not bForceLoad)then
		return self.motionMap[filename];
	end
	local xmlRoot = ParaXML.LuaXML_ParseFile(filename);
	self.motionMap[filename] = xmlRoot;
	
	return xmlRoot;
end
------------------------------------------------------------
NPL.load("(gl)script/apps/Aries/Combat/CombatSceneMotionHelper.lua");
local CombatSceneMotionHelper = commonlib.gettable("MotionEx.CombatSceneMotionHelper");

-- @param state: true to freeze camera.
local function SetPlayerFreeze(state)
	local player = ParaScene.GetPlayer();
	local playerChar = player:ToCharacter();
	if(state == true)then
		playerChar:Stop();
		-- commented by LiXizhi 2011.9.22 (Enter Key should be received in object manager)
		-- ParaScene.GetAttributeObject():SetField("BlockInput", true); 
		System.KeyBoard.SetKeyPassFilter(System.KeyBoard.enter_key_filter);
		System.Mouse.SetMousePassFilter(System.Mouse.disable_filter);
		ParaCamera.GetAttributeObject():SetField("BlockInput", true);
	else
		System.KeyBoard.SetKeyPassFilter(nil);
		System.Mouse.SetMousePassFilter(nil);
		ParaScene.GetAttributeObject():SetField("BlockInput", false);
		ParaCamera.GetAttributeObject():SetField("BlockInput", false);
	end
end
local function SetFocus()
	local Pet = commonlib.gettable("MyCompany.Aries.Pet");
	if(Pet and Pet.GetRealPlayer)then
		local player = Pet.GetRealPlayer();
		if(player and player:IsValid())then
			player:ToCharacter():SetFocus();
		end
	end
	
end
NPL.load("(gl)script/ide/TooltipHelper.lua");
local BroadcastHelper = commonlib.gettable("CommonCtrl.BroadcastHelper");
local function ShowUI(bShow)
	NPL.load("(gl)script/apps/Aries/Desktop/AriesDesktop.lua");
	if(bShow)then
		MyCompany.Aries.Desktop.ShowAllAreas();
	else
		MyCompany.Aries.Desktop.HideAllAreas();
	end
	BroadcastHelper.Show(bShow);
end
--是否是老版本的副本进入动画文件
function MotionXmlToTable.IsOld_LoginWorldMotionFile(filepath)
	local self = MotionXmlToTable;
	if(not filepath)then return end
	if(self.old_motion_files[filepath])then
		return true;
	end
end
--是否是老版本的 战斗结束动画id
function MotionXmlToTable.IsOld_CombatMotionID(id)
	local self = MotionXmlToTable;
	if(not id)then return end
	if(self.old_motion_ids[id])then
		return true;
	end
end
MotionXmlToTable.old_motion_files = {
	["config/Aries/WorldData/HaqiTown_FireCavern.Motion.xml"] = true,
	["config/Aries/WorldData/FlamingPhoenixIsland_TheGreatTree.Motion.xml"] = true,
	["config/Aries/WorldData/HaqiTown_FireCavern_110527_1.Motion.xml"] = true,
	["config/Aries/WorldData/HaqiTown_FireCavern_110527_2.Motion.xml"] = true,
}
MotionXmlToTable.old_motion_ids = {
	["TheGreatTree_ShadowOfPhoenix"] = true,
	["TheGreatTree_GoldenPhoenix"] = true,
	["AncientEgyptIsland_DoomLord"] = true,
	["FlamingPhoenixIsland_DoomLord"]= true,
	["HaqiTown_FireCavern_FireRockyOgre"] = true,
	["HaqiTown_FireCavern_FireRockyOgre_1"] = true,
	["HaqiTown_FireCavern_FireRockyOgre_2"] = true,

}
--指定的电影 有播放次数限制
MotionXmlToTable.special_movie_cnt = {
	["config/Aries/StaticMovies/FlamingPhoenixIsland_teen.SceneMotion.xml"] = 1,
	["config/Aries/StaticMovies/FrostRoarIsland_teen.SceneMotion.xml"] = 1,
	["config/Aries/StaticMovies/AncientEgyptIsland_teen.SceneMotion.xml"] = 1,
	["config/Aries/StaticMovies/DarkForestIsland_teen.SceneMotion.xml"] = 1,
	["config/Aries/StaticMovies/CloudFortressIsland_teen.SceneMotion.xml"] = 1,
}
--播放动画
--@param filepath:播放电影文件路径
--@param callbackFunc:电影结束回调函数
--@param args:额外参数
--[[
	args(optional) = {
		inner_combat = true,--是否在战斗中播放的动画
		inner_combat_callback = nil,--触发技能
	}
--]]
function MotionXmlToTable.PlayCombatMotion(filepath,callbackFunc,args)
	local self = MotionXmlToTable;
	args = args or {};

	-- NOTE 2012/12/12: don't use DoesAssetFileExist which don't search pkg
	if(not ParaIO.DoesFileExist(filepath, true)) then
		LOG.std(nil, "error", "MotionXmlToTable.PlayCombatMotion", "failed loading persistent file %s", filepath);
		if(callbackFunc)then
			callbackFunc();
		end
		return;
	end
	if(CommonClientService.IsKidsVersion() or CommonClientService.IsTeenVersion())then
		if(MotionXmlToTable.IsOld_CombatMotionID(filepath) or not MotionXmlToTable.CanPlayMovie(filepath))then
			if(callbackFunc)then
				callbackFunc();
			end
			return;
		end
	end
	local inner_combat = args.inner_combat;
	local inner_combat_callback = args.inner_combat_callback;
	--跳过预载屏幕
	if(inner_combat)then
		MotionXmlToTable.PlayCombatMotion_Internal2(filepath,callbackFunc,args)
	else
		StaticMoviePreloaderPage.Load(filepath,percent,function()
			MotionXmlToTable.PlayCombatMotion_Internal2(filepath,callbackFunc,args);
		end);
	end
end
--时间轴触发函数
--@param root_time:时间轴运行时间
--@param time:关键帧触发时间
function MotionXmlToTable.InnerDispatchSpell(root_time,time)
	if(MotionXmlToTable.inner_combat_callback)then
		MotionXmlToTable.inner_combat_callback();
	end
end
--检测动画文件中是否包含 播放技能的效果
function MotionXmlToTable.IncludeSpellMotion(mcmlNode)
	if(not mcmlNode)then
		return
	end
	local line;
	for line in commonlib.XPath.eachNode(mcmlNode, "//Motions/Motion/MotionLine") do
		local TargetType = line.attr.TargetType;
		if(TargetType and TargetType == "Spell")then
			return true;
		end
	end
end
function MotionXmlToTable.PlayCombatMotion_Internal2(filepath,callbackFunc,args)
	local self = MotionXmlToTable;
	args = args or {};
	MotionXmlToTable.inner_combat_callback = nil;
	if(not filepath)then
		if(callbackFunc)then
			callbackFunc();
		end
		return
	end
	Movie.ClearGraph();
	local inner_combat = args.inner_combat;
	local inner_combat_callback = args.inner_combat_callback;
	MotionXmlToTable.inner_combat_callback = inner_combat_callback;
	local player_name = "MotionXmlToTable.movie_player";
	local movie_player = Movie.CreateOrGetPlayer(player_name);
	
	local include_spell_motion;
	if(CommonClientService.IsKidsVersion() or CommonClientService.IsTeenVersion())then
		--记录播放次数+1
		local max_cnt = MotionXmlToTable.GetLimitCnt(filepath);
		if(max_cnt)then
			local cnt = MotionXmlToTable.LoadLimitCnt_FromLocalDB(filepath);
			if(cnt < max_cnt)then
				cnt = cnt + 1;
				MotionXmlToTable.SaveLimitCnt_FromLocalDB(filepath,cnt);
			end
		end
		--有技能播放的文件 隐藏 跳过 按钮
		include_spell_motion = MotionXmlToTable.IncludeSpellMotion(MotionXmlToTable.Load(filepath));
	end
	SetPlayerFreeze(true)
	ShowUI(false);
	Scene.StopRegionBGMusic();
	
	local name = "motioin_close_btn_name";
	ParaUI.Destroy(name);
	local _this = ParaUI.CreateUIObject("button",name,"_rb",-85,-110,80,25);
	_this.text="跳过动画";
	_this.zorder = 5000;
	_this:AttachToRoot();

	if(inner_combat or include_spell_motion)then
		_this.visible = false;
	end
	local ObjectManager = commonlib.gettable("MyCompany.Aries.Combat.ObjectManager");
	if(self.hide_mobs[filepath])then
		ObjectManager.SetIsHideIdleMobs(true);
	end
	local function end_function()
		MotionXmlToTable.inner_combat_callback = nil;
		ParaUI.Destroy(name);
		if(not inner_combat)then
			SetFocus();
			SetPlayerFreeze(false);
			ShowUI(true);
		end
		ObjectManager.SetIsHideIdleMobs(false);
		local bChecked = System.options.EnableBackgroundMusic;
		if(bChecked)then
			Scene.ResumeRegionBGMusic();
		end
		if(callbackFunc)then
			callbackFunc();
		end
	end
	movie_player:ClearAllEvents();
	movie_player:AddEventListener("movie_end",function(holder,event)
		end_function();
	end)
	_this:SetScript("onclick", function()
		movie_player:Clear();
		end_function();
	end);
	movie_player:DoPlay_File(filepath,true);
end
function MotionXmlToTable.PlayCombatMotion_Internal(filepath,callbackFunc,args)
	local self = MotionXmlToTable;
	args = args or {};
	if(not filepath)then
		if(callbackFunc)then
			callbackFunc();
		end
		return
	end
	if(CommonClientService.IsKidsVersion() or CommonClientService.IsTeenVersion())then
		--记录播放次数+1
		local max_cnt = MotionXmlToTable.GetLimitCnt(filepath);
		if(max_cnt)then
			local cnt = MotionXmlToTable.LoadLimitCnt_FromLocalDB(filepath);
			if(cnt < max_cnt)then
				cnt = cnt + 1;
				MotionXmlToTable.SaveLimitCnt_FromLocalDB(filepath,cnt);
			end
		end
	end
	SetPlayerFreeze(true)
	ShowUI(false);
	Scene.StopRegionBGMusic();
	
	local name = "motioin_close_btn_name";
	ParaUI.Destroy(name);
	local _this = ParaUI.CreateUIObject("button",name,"_rb",-85,-110,80,25);
	_this.text="跳过动画";
	_this.zorder = 5000;
	_this:AttachToRoot();

	local ObjectManager = commonlib.gettable("MyCompany.Aries.Combat.ObjectManager");
	if(self.hide_mobs[filepath])then
		ObjectManager.SetIsHideIdleMobs(true);
	end
	local function end_function()
		ParaUI.Destroy(name);
		SetFocus();
		SetPlayerFreeze(false);
		ShowUI(true);
		ObjectManager.SetIsHideIdleMobs(false);
		local bChecked = System.options.EnableBackgroundMusic;
		if(bChecked)then
			Scene.ResumeRegionBGMusic();
		end
		if(callbackFunc)then
			callbackFunc();
		end
	end
	
	_this:SetScript("onclick", function()
		self.Clear();
		end_function();
	end);

	self.Play(filepath,1,nil,function()
		end_function();
	end)
end
--特殊电影有播放次数限制
function MotionXmlToTable.CanPlayMovie(filepath)
	if(not filepath)then return end
	local max_cnt = MotionXmlToTable.GetLimitCnt(filepath);
	if(not max_cnt)then
		return true;
	end
	local cnt = MotionXmlToTable.LoadLimitCnt_FromLocalDB(filepath);
	if(cnt >= max_cnt)then
		return false;
	end
	return true;
end
--获取播放次数 如果没有限制返回nil
function MotionXmlToTable.GetLimitCnt(filepath)
	if(not filepath)then return end
	filepath = string.lower(filepath);
	local k,v;
	for k,v in pairs(MotionXmlToTable.special_movie_cnt) do
		local path = string.lower(k);
		if(filepath == path)then
			return v;
		end
	end
end
function MotionXmlToTable.LoadLimitCnt_FromLocalDB(filepath)
	local max_cnt = MotionXmlToTable.GetLimitCnt(filepath);
	if(not max_cnt)then
		return;
	end
	filepath = string.lower(filepath);
	local key = string.format("MovieLimit_%s",filepath);
	return MyCompany.Aries.Player.LoadLocalData(key, 0);
end
function MotionXmlToTable.SaveLimitCnt_FromLocalDB(filepath,cnt)
	local max_cnt = MotionXmlToTable.GetLimitCnt(filepath);
	if(not max_cnt)then
		return;
	end
	cnt = cnt or 0;
	filepath = string.lower(filepath);
	local key = string.format("MovieLimit_%s",filepath);
	MyCompany.Aries.Player.SaveLocalData(key, cnt)
end

