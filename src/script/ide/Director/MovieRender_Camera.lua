--[[
Title: MovieRender_Camera
Author(s): Leio
Date: 2012/05/10
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/Director/MovieRender_Camera.lua");
local MovieRender_Camera = commonlib.gettable("Director.MovieRender_Camera");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/MotionEx/MotionTypes.lua");
local MotionTypes = commonlib.gettable("MotionEx.MotionTypes");
NPL.load("(gl)script/ide/Director/Movie.lua");
local Movie = commonlib.gettable("Director.Movie");
NPL.load("(gl)script/apps/Aries/Combat/CombatCameraView.lua");
local CombatCameraView = commonlib.gettable("MotionEx.CombatCameraView");
local MovieRender_Camera = commonlib.gettable("Director.MovieRender_Camera");
function MovieRender_Camera.Update(movieclip,frames,root_frame,motion_index,line_index,frame,next_frame,frame_index,next_frame_index,need_created)
	local frame_node = frames[frame_index];
	local next_frame_node = frames[next_frame_index];
	if(frame_node)then
		local X = Movie.GetNumber(frame_node,"X");
		local Y = Movie.GetNumber(frame_node,"Y");
		local Z = Movie.GetNumber(frame_node,"Z");
		local CameraObjectDistance = Movie.GetNumber(frame_node,"CameraObjectDistance");
		local CameraLiftupAngle = Movie.GetNumber(frame_node,"CameraLiftupAngle");
		local CameraRotY = Movie.GetNumber(frame_node,"CameraRotY");
		local SpellCameraDisabled = Movie.GetNumber(frame_node,"SpellCameraDisabled") or 0;
		
		local props_param = {
			X = X,Y = Y,Z = Z,
			CameraObjectDistance = CameraObjectDistance,
			CameraLiftupAngle = CameraLiftupAngle,
			CameraRotY = CameraRotY,
			SpellCameraDisabled = SpellCameraDisabled,
		};
		if(need_created)then
			MovieRender_Camera.UpdateParams(props_param);
		end
		if(next_frame_node)then
			local FrameType = Movie.GetString(next_frame_node,"FrameType");
			local motion_handler = MotionTypes[FrameType];
			if(motion_handler and frame_node ~= next_frame_node)then
				local _X = Movie.GetNumber(next_frame_node,"X");
				local _Y = Movie.GetNumber(next_frame_node,"Y");
				local _Z = Movie.GetNumber(next_frame_node,"Z");
				local _CameraObjectDistance = Movie.GetNumber(next_frame_node,"CameraObjectDistance");
				local _CameraLiftupAngle = Movie.GetNumber(next_frame_node,"CameraLiftupAngle");
				local _CameraRotY = Movie.GetNumber(next_frame_node,"CameraRotY");

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
				MovieRender_Camera.UpdateParams(props_param);
			end
		end
	end
end
function MovieRender_Camera.UpdateParams(props_param)
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
	--在编辑模式下更新
	Movie.GetCameraParamsByEdit();
end