--[[
Title: MovieRender_Script
Author(s): Leio
Date: 2012/05/10
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/Director/MovieRender_Script.lua");
local MovieRender_Script = commonlib.gettable("Director.MovieRender_Script");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/MotionEx/MotionTypes.lua");
local MotionTypes = commonlib.gettable("MotionEx.MotionTypes");
NPL.load("(gl)script/ide/Director/Movie.lua");
local Movie = commonlib.gettable("Director.Movie");
NPL.load("(gl)script/apps/Aries/Combat/CombatCameraView.lua");
local CombatCameraView = commonlib.gettable("MotionEx.CombatCameraView");
local MovieRender_Script = commonlib.gettable("Director.MovieRender_Script");
function MovieRender_Script.Update(movieclip,frames,root_frame,motion_index,line_index,frame,next_frame,frame_index,next_frame_index,need_created)
	local frame_node = frames[frame_index];
	local next_frame_node = frames[next_frame_index];
	if(frame_node)then
		local Text = Movie.GetString(frame_node,"Text");
		local time = Movie.GetNumber(frame_node,"Time");

		if(frame_node[1])then
			Text = frame_node[1];
		end
		if(need_created)then
			if(Text and Text ~= "" and type(Text) == "string")then
				local func = commonlib.getfield(Text);
				if(func)then
					func(root_frame,time);
				end
				--NPL.DoString(Text);
			end
		end
	end
end
