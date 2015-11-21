--[[
Title: MovieRender_SpellCamera
Author(s): Leio
Date: 2012/05/10
Desc: 
NOTE:
 Ù–‘º∆À„”√
Internal_X
Internal_Y
Internal_Z
Internal_CameraObjectDistance
Internal_CameraLiftupAngle
Internal_CameraRotY
------------------------------------------------------------
NPL.load("(gl)script/ide/Director/MovieRender_SpellCamera.lua");
local MovieRender_SpellCamera = commonlib.gettable("Director.MovieRender_SpellCamera");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Director/SpellCameraHelper.lua");
local SpellCameraHelper = commonlib.gettable("Director.SpellCameraHelper");
NPL.load("(gl)script/ide/MotionEx/MotionTypes.lua");
local MotionTypes = commonlib.gettable("MotionEx.MotionTypes");
NPL.load("(gl)script/ide/Director/Movie.lua");
local Movie = commonlib.gettable("Director.Movie");
NPL.load("(gl)script/apps/Aries/Combat/CombatCameraView.lua");
local CombatCameraView = commonlib.gettable("MotionEx.CombatCameraView");
local MovieRender_SpellCamera = commonlib.gettable("Director.MovieRender_SpellCamera");
function MovieRender_SpellCamera.Update(movieclip,frames,root_frame,motion_index,line_index,frame,next_frame,frame_index,next_frame_index,need_created)
	local frame_node = frames[frame_index];
	local next_frame_node = frames[next_frame_index];
	if(frame_node)then
		local X = Movie.GetNumber(frame_node,"Internal_X");
		local Y = Movie.GetNumber(frame_node,"Internal_Y");
		local Z = Movie.GetNumber(frame_node,"Internal_Z");
		local CameraObjectDistance = Movie.GetNumber(frame_node,"Internal_CameraObjectDistance");
		local CameraLiftupAngle = Movie.GetNumber(frame_node,"Internal_CameraLiftupAngle");
		local CameraRotY = Movie.GetNumber(frame_node,"Internal_CameraRotY");
		local SpellCameraDisabled = Movie.GetNumber(frame_node,"SpellCameraDisabled") or 0;
		
		local props_param = {
			X = X,Y = Y,Z = Z,
			CameraObjectDistance = CameraObjectDistance,
			CameraLiftupAngle = CameraLiftupAngle,
			CameraRotY = CameraRotY,
			SpellCameraDisabled = SpellCameraDisabled,
		};
		if(need_created)then
			MovieRender_SpellCamera.UpdateParams(props_param);
			--local RefID = Movie.GetString(frame_node,"RefID");
			--SpellCameraHelper.ShowFrameNode_InEditor(RefID,
				--Movie.GetNumber(frame_node,"X"),
				--Movie.GetNumber(frame_node,"Y"),
				--Movie.GetNumber(frame_node,"Z"),
				--Movie.GetNumber(frame_node,"CameraRotY")
			--);
		end
		if(next_frame_node)then
			local FrameType = Movie.GetString(next_frame_node,"FrameType");
			local motion_handler = MotionTypes[FrameType];
			if(motion_handler and frame_node ~= next_frame_node)then
				local _X = Movie.GetNumber(next_frame_node,"Internal_X");
				local _Y = Movie.GetNumber(next_frame_node,"Internal_Y");
				local _Z = Movie.GetNumber(next_frame_node,"Internal_Z");
				local _CameraObjectDistance = Movie.GetNumber(next_frame_node,"Internal_CameraObjectDistance");
				local _CameraLiftupAngle = Movie.GetNumber(next_frame_node,"Internal_CameraLiftupAngle");
				local _CameraRotY = Movie.GetNumber(next_frame_node,"Internal_CameraRotY");

				local time = root_frame - frame;
				local duration = next_frame - frame;

				X = Movie.GetMotionValue(motion_handler,time,duration,X,_X);
				Y = Movie.GetMotionValue(motion_handler,time,duration,Y,_Y);
				Z = Movie.GetMotionValue(motion_handler,time,duration,Z,_Z);
				CameraObjectDistance = Movie.GetMotionValue(motion_handler,time,duration,CameraObjectDistance,_CameraObjectDistance);
				CameraLiftupAngle = Movie.GetMotionValue(motion_handler,time,duration,CameraLiftupAngle,_CameraLiftupAngle);
				CameraRotY = Movie.GetMotionValue(motion_handler,time,duration,CameraRotY,_CameraRotY);
				props_param = {
					X = X,Y = Y,Z = Z,
					CameraObjectDistance = CameraObjectDistance,
					CameraLiftupAngle = CameraLiftupAngle,
					CameraRotY = CameraRotY,
					SpellCameraDisabled = SpellCameraDisabled,
				};
				MovieRender_SpellCamera.UpdateParams(props_param);
			end
		end
	end
end
function MovieRender_SpellCamera.UpdateParams(props_param)
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
		att:SetField("CameraRotY", CameraRotY + 1.57);
	end
end