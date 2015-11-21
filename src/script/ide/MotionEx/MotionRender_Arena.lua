--[[
Title: MotionRender_Arena
Author(s): Leio
Date: 2011/05/21
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/MotionEx/MotionRender_Arena.lua");
local MotionRender_Arena = commonlib.gettable("MotionEx.MotionRender_Arena");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/MotionEx/MotionRender_SpellCastViewer.lua");
local MotionRender_SpellCastViewer = commonlib.gettable("MotionEx.MotionRender_SpellCastViewer");
NPL.load("(gl)script/ide/MotionEx/MotionTypes.lua");
local MotionTypes = commonlib.gettable("MotionEx.MotionTypes");
NPL.load("(gl)script/ide/MotionEx/MotionXmlToTable.lua");
local MotionXmlToTable = commonlib.gettable("MotionEx.MotionXmlToTable");
local MotionRender_Arena = commonlib.gettable("MotionEx.MotionRender_Arena");
local ParaScene_GetMiniSceneGraph = ParaScene.GetMiniSceneGraph;
function MotionRender_Arena.GetParamsByNode(mcmlNode,stage_params)
	local self = MotionRender_Arena;
	if(mcmlNode)then
		local character_list = {};
		local node;
		for node in commonlib.XPath.eachNode(mcmlNode, "//Arena/Object") do
			local Index = MotionXmlToTable.GetNumber(node,"Index");
			local Scale = MotionXmlToTable.GetNumber(node,"Scale");
			local AssetFile = MotionXmlToTable.GetString(node,"AssetFile");
			local CCSInfoStr = MotionXmlToTable.GetString(node,"CCS");
			if(AssetFile and AssetFile ~= "")then
				character_list[Index]={
					AssetFile = AssetFile,
					CCSInfoStr = CCSInfoStr,
					Scale = Scale,
				};
			end
		end
		local stage_x,stage_y,stage_z = 0,0,0;
		if(stage_params)then
			stage_x = stage_params.x or 0;
			stage_y = stage_params.y or 0;
			stage_z = stage_params.z or 0;
		end
		local arena_node;
		for node in commonlib.XPath.eachNode(mcmlNode, "//Arena") do
			arena_node = node;
			break;
		end
		if(arena_node)then
			local params = {
				x = MotionXmlToTable.GetNumber(arena_node,"X") + stage_x,
				y = MotionXmlToTable.GetNumber(arena_node,"Y") + stage_y,
				z = MotionXmlToTable.GetNumber(arena_node,"Z") + stage_z,
				visible = MotionXmlToTable.GetBoolean(arena_node,"Visible"),
				character_list = character_list,
			};
			return params;
		end
	end
end
function MotionRender_Arena.DoUpdate(filename,instance_name,stage_params,run_time,pre_frame_node,frame_node,next_frame_node,state,motion_node,motion_line_node,delta)
	local self = MotionRender_Arena;
	if(state == "jumpframe")then
		 self.DestroyEntity(effect_name);
		local props_param = MotionRender_Arena.GetParamsByNode(frame_node,stage_params);
		self.CreateEntity(instance_name,props_param);
	end
end
function MotionRender_Arena.CreateEntity(effect_name,props_param)
	local self = MotionRender_Arena;
	if(not effect_name or not props_param)then return end
	local x,y,z = props_param.x,props_param.y,props_param.z;
	local visible = props_param.visible;
	local character_list = props_param.character_list;

	MotionRender_SpellCastViewer.RemoveTestArena();
	if(not visible)then
		return
	end
	MotionRender_SpellCastViewer.CreateArena(x, y, z,character_list);
	
end
function MotionRender_Arena.DestroyEntity(effect_name)
	local self = MotionRender_Arena;
	MotionRender_SpellCastViewer.RemoveTestArena();
end

