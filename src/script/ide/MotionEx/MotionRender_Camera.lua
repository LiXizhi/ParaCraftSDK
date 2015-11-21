--[[
Title: MotionRender_Camera
Author(s): Leio
Date: 2011/05/19
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/MotionEx/MotionRender_Camera.lua");
local MotionRender_Camera = commonlib.gettable("MotionEx.MotionRender_Camera");
------------------------------------------------------------
--]]
NPL.load("(gl)script/apps/Aries/Combat/CombatCameraView.lua");
local CombatCameraView = commonlib.gettable("MotionEx.CombatCameraView");
NPL.load("(gl)script/ide/MotionEx/MotionTypes.lua");
local MotionTypes = commonlib.gettable("MotionEx.MotionTypes");
NPL.load("(gl)script/ide/MotionEx/MotionXmlToTable.lua");
local MotionXmlToTable = commonlib.gettable("MotionEx.MotionXmlToTable");
local MotionRender_Camera = commonlib.gettable("MotionEx.MotionRender_Camera");
function MotionRender_Camera.GetParamsByNode(mcmlNode,stage_params)
	local self = MotionRender_Camera;
	if(mcmlNode)then
		local params = {
			X = MotionXmlToTable.GetNumber(mcmlNode,"X"),
			Y = MotionXmlToTable.GetNumber(mcmlNode,"Y"),
			Z = MotionXmlToTable.GetNumber(mcmlNode,"Z"),
			CameraObjectDistance = MotionXmlToTable.GetNumber(mcmlNode,"CameraObjectDistance"),
			CameraLiftupAngle = MotionXmlToTable.GetNumber(mcmlNode,"CameraLiftupAngle"),
			CameraRotY = MotionXmlToTable.GetNumber(mcmlNode,"CameraRotY"),
			SpellCameraDisabled = MotionXmlToTable.GetNumber(mcmlNode,"SpellCameraDisabled") or 0,
		};
		return params;
	end
end
function MotionRender_Camera.GetRunTimeParams(motion_handler,run_time,cur_play_node,next_play_node,stage_params)
	local self = MotionRender_Camera;
	if(motion_handler and cur_play_node and next_play_node)then
		
		local start_time = MotionXmlToTable.GetNumber(cur_play_node,"Time");
		local end_time = MotionXmlToTable.GetNumber(next_play_node,"Time");
		local duration = end_time - start_time;
		local time = run_time - start_time;

		local function get_value_number(p)
			local from = MotionXmlToTable.GetNumber(cur_play_node,p);
			local to = MotionXmlToTable.GetNumber(next_play_node,p);
			local begin = from;
			local change = to - from;
			local value = motion_handler( time , begin , change , duration );	
			return value;
		end
		local params = {
			X = get_value_number("X"),
			Y = get_value_number("Y"),
			Z = get_value_number("Z"),
			CameraObjectDistance = get_value_number("CameraObjectDistance"),
			CameraLiftupAngle = get_value_number("CameraLiftupAngle"),
			CameraRotY = get_value_number("CameraRotY"),
		};
		return params;
	end
end
function MotionRender_Camera.DoUpdate(filename,instance_name,stage_params,run_time,pre_frame_node,frame_node,next_frame_node,state)
	local self = MotionRender_Camera;
	if(state == "jumpframe")then
		local props_param = self.GetParamsByNode(frame_node,stage_params);
		self.Update(instance_name,props_param)
	elseif(state == "update")then
		if(frame_node and next_frame_node)then
			local cur_time = MotionXmlToTable.GetNumber(frame_node,"Time");
			local frame_type = MotionXmlToTable.GetString(next_frame_node,"FrameType");
			local motion_handler = MotionTypes[frame_type];
			if(motion_handler)then
				local props_param = self.GetRunTimeParams(motion_handler,run_time,frame_node,next_frame_node,stage_params);
				self.Update(instance_name,props_param)
			end

		elseif(frame_node and not next_frame_node)then
			--last frame
			local props_param = self.GetParamsByNode(frame_node,stage_params);
			self.Update(instance_name,props_param);
		end
	end
end

function MotionRender_Camera.Update(effect_name,props_param)
	local self = MotionRender_Camera;
	if(not props_param)then
		return
	end
	local x,y,z = ParaCamera.GetLookAtPos()
	ParaCamera.SetLookAtPos(props_param.X or x, props_param.Y or y, props_param.Z or z);
	local att = ParaCamera.GetAttributeObject();

	local CameraObjectDistance = props_param.CameraObjectDistance;
	local CameraLiftupAngle = props_param.CameraLiftupAngle;
	local CameraRotY = props_param.CameraRotY;
	local SpellCameraDisabled = props_param.SpellCameraDisabled;
	if(SpellCameraDisabled and SpellCameraDisabled == 1)then
		CombatCameraView.enabled = false;
		CombatCameraView.StopCurMotion();
	end
	if(CameraObjectDistance)then
		att:SetField("CameraObjectDistance", CameraObjectDistance);
	end
	if(CameraLiftupAngle)then
		att:SetField("CameraLiftupAngle", CameraLiftupAngle);
	end
	if(CameraRotY)then
		att:SetField("CameraRotY", CameraRotY);
	end
end
