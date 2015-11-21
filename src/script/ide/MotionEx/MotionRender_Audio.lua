--[[
Title: MotionRender_Audio
Author(s): Leio
Date: 2011/05/19
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/MotionEx/MotionRender_Audio.lua");
local MotionRender_Audio = commonlib.gettable("MotionEx.MotionRender_Audio");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/MotionEx/MotionTypes.lua");
local MotionTypes = commonlib.gettable("MotionEx.MotionTypes");
NPL.load("(gl)script/ide/MotionEx/MotionXmlToTable.lua");
local MotionXmlToTable = commonlib.gettable("MotionEx.MotionXmlToTable");
local MotionRender_Audio = commonlib.gettable("MotionEx.MotionRender_Audio");
local ParaScene_GetMiniSceneGraph = ParaScene.GetMiniSceneGraph;
MotionRender_Audio.instance_name = "MotionRender_Audio.instance_name";

local params_template = {};

function MotionRender_Audio.GetParamsByNode(mcmlNode,stage_params)
	local self = MotionRender_Audio;
	if(mcmlNode)then
		local AssetFile = MotionXmlToTable.GetString(mcmlNode,"AssetFile");
		local Loop = MotionXmlToTable.GetBoolean2(mcmlNode,"Loop");
		local params = {
			AssetFile = AssetFile,
			Loop = Loop,
		};
		return params;
	end
end
function MotionRender_Audio.DoUpdate(filename,instance_name,stage_params,run_time,pre_frame_node,frame_node,next_frame_node,state)
	local self = MotionRender_Audio;
	if(state == "jumpframe")then
		local old_props_param = {};
		if(pre_frame_node)then
			old_props_param = MotionRender_Audio.GetParamsByNode(pre_frame_node,stage_params);
			self.Update(instance_name,old_props_param,"stop")
		end
		local props_param = MotionRender_Audio.GetParamsByNode(frame_node,stage_params);
		self.Update(instance_name,props_param,"play")
	end
end
function MotionRender_Audio.Update(instance_name,props_param,play_state)
	local self = MotionRender_Audio;
	if(not props_param)then return end
	local AssetFile = props_param.AssetFile or "";
	local Loop = props_param.Loop;
	local audio_src = AudioEngine.CreateGet(AssetFile)
	audio_src.file = AssetFile;
	MotionXmlToTable.audioMap[AssetFile] = AssetFile;
	if(play_state == "play")then
		audio_src.loop = Loop;
		audio_src:play();
	else
		audio_src:stop();
		audio_src:release();
	end
end