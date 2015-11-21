--[[
Title: MotionRender_Script
Author(s): Leio
Date: 2011/05/19
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/MotionEx/MotionRender_Script.lua");
local MotionRender_Script = commonlib.gettable("MotionEx.MotionRender_Script");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/MotionEx/MotionTypes.lua");
local MotionTypes = commonlib.gettable("MotionEx.MotionTypes");
NPL.load("(gl)script/ide/MotionEx/MotionXmlToTable.lua");
local MotionXmlToTable = commonlib.gettable("MotionEx.MotionXmlToTable");
local MotionRender_Script = commonlib.gettable("MotionEx.MotionRender_Script");
local ParaScene_GetMiniSceneGraph = ParaScene.GetMiniSceneGraph;
MotionRender_Script.instance_name = "MotionRender_Script.instance_name";
function MotionRender_Script.GetParamsByNode(mcmlNode,stage_params)
	local self = MotionRender_Script;
	if(mcmlNode)then
		local Text = MotionXmlToTable.GetString(mcmlNode,"Text");
		if(mcmlNode[1])then
			Text = mcmlNode[1];
		end
		local params = {
			Text = Text,
		};
		return params;
	end
end
function MotionRender_Script.DoUpdate(filename,instance_name,stage_params,run_time,pre_frame_node,frame_node,next_frame_node,state,motion_node,motion_line_node,delta)
	local self = MotionRender_Script;
	if(state == "jumpframe")then
		local props_param = MotionRender_Script.GetParamsByNode(frame_node,stage_params);
		self.Update(instance_name,props_param)
	end
end
function MotionRender_Script.Update(instance_name,props_param)
	local self = MotionRender_Script;
	if(not props_param)then return end
	local txt = props_param.Text or "";
	if(txt and txt ~= "" and type(txt) == "string")then
		NPL.DoString(txt);
	end
end
