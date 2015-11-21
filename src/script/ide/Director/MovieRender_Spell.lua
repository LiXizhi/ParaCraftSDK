--[[
Title: MovieRender_Spell
Author(s): Leio
Date: 2012/05/10
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/Director/MovieRender_Spell.lua");
local MovieRender_Spell = commonlib.gettable("Director.MovieRender_Spell");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/MotionEx/MotionRender_SpellCastViewer.lua");
local MotionRender_SpellCastViewer = commonlib.gettable("MotionEx.MotionRender_SpellCastViewer");
NPL.load("(gl)script/ide/MotionEx/MotionTypes.lua");
local MotionTypes = commonlib.gettable("MotionEx.MotionTypes");
NPL.load("(gl)script/ide/Director/Movie.lua");
local Movie = commonlib.gettable("Director.Movie");
NPL.load("(gl)script/apps/Aries/Combat/CombatCameraView.lua");
local CombatCameraView = commonlib.gettable("MotionEx.CombatCameraView");
local MovieRender_Spell = commonlib.gettable("Director.MovieRender_Spell");
function MovieRender_Spell.Update(movieclip,frames,root_frame,motion_index,line_index,frame,next_frame,frame_index,next_frame_index,need_created)
	local self = MovieRender_Spell;
	local obj_name = movieclip:GetInstanceName(motion_index,line_index);
	local frame_node = frames[frame_index];
	local next_frame_node = frames[next_frame_index];
	if(frame_node)then
		if(need_created)then
			local params = {
				from = Movie.GetNumber(frame_node,"From"),
				to = Movie.GetNumber(frame_node,"To"),
				assetfile = Movie.GetString(frame_node,"AssetFile"),
			};
			local CameraEnabled = true;
			if(Movie.motion_list)then
				local motion = Movie.motion_list[motion_index];
				local MotionLines = motion["MotionLines"];
				local motion_line_node = MotionLines[line_index];
				if(motion_line_node)then
					CameraEnabled = Movie.GetBoolean(motion_line_node,"CameraEnabled");
				end
			end
			self.CreateEntity(obj_name,params,CameraEnabled);
		end
	end
end
function MovieRender_Spell.CreateEntity(obj_name,props_param,CameraEnabled)
	local self = MovieRender_Spell;
	if(not obj_name or not props_param)then return end
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
