--[[
Title: MotionRender_Spell
Author(s): Leio
Date: 2011/05/21
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/MotionEx/MotionRender_Spell.lua");
local MotionRender_Spell = commonlib.gettable("MotionEx.MotionRender_Spell");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/MotionEx/MotionRender_SpellCastViewer.lua");
local MotionRender_SpellCastViewer = commonlib.gettable("MotionEx.MotionRender_SpellCastViewer");
NPL.load("(gl)script/ide/MotionEx/MotionTypes.lua");
local MotionTypes = commonlib.gettable("MotionEx.MotionTypes");
NPL.load("(gl)script/ide/MotionEx/MotionXmlToTable.lua");
local MotionXmlToTable = commonlib.gettable("MotionEx.MotionXmlToTable");
local MotionRender_Spell = commonlib.gettable("MotionEx.MotionRender_Spell");
local ParaScene_GetMiniSceneGraph = ParaScene.GetMiniSceneGraph;
function MotionRender_Spell.GetParamsByNode(mcmlNode,stage_params)
	local self = MotionRender_Spell;
	if(mcmlNode)then
		local params = {
			from = MotionXmlToTable.GetNumber(mcmlNode,"From"),
			to = MotionXmlToTable.GetNumber(mcmlNode,"To"),
			assetfile = MotionXmlToTable.GetString(mcmlNode,"AssetFile"),
		};
		return params;
	end
end

function MotionRender_Spell.DoUpdate(filename,instance_name,stage_params,run_time,pre_frame_node,frame_node,next_frame_node,state,motion_node,motion_line_node,delta)
	local self = MotionRender_Spell;
	if(state == "jumpframe")then
		local props_param = MotionRender_Spell.GetParamsByNode(frame_node,stage_params);
		local CameraEnabled = true;
		if(motion_line_node)then
			CameraEnabled = MotionXmlToTable.GetBoolean(motion_line_node,"CameraEnabled");
		end
		self.CreateEntity(instance_name,props_param,CameraEnabled);
	end
end
function MotionRender_Spell.CreateEntity(effect_name,props_param,CameraEnabled)
	local self = MotionRender_Spell;
	if(not effect_name or not props_param)then return end
	local asset_file =  props_param.assetfile;
	local caster_id = props_param.from;
	local target_id = props_param.to;
	if(asset_file and asset_file ~= "" and caster_id and target_id)then
		NPL.load("(gl)script/apps/Aries/Combat/CombatCameraView.lua");
		local CombatCameraView = commonlib.gettable("MotionEx.CombatCameraView");
		CombatCameraView.enabled = CameraEnabled;
		MotionRender_SpellCastViewer.TestSpellFromFile(asset_file, caster_id, target_id)
	end
end
