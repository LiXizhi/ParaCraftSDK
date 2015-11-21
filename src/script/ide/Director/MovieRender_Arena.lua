--[[
Title: MovieRender_Arena
Author(s): Leio
Date: 2012/05/10
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/Director/MovieRender_Arena.lua");
local MovieRender_Arena = commonlib.gettable("Director.MovieRender_Arena");
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
local MovieRender_Arena = commonlib.gettable("Director.MovieRender_Arena");
function MovieRender_Arena.Update(movieclip,frames,root_frame,motion_index,line_index,frame,next_frame,frame_index,next_frame_index,need_created)
	local uid = movieclip.uid or "";
	local obj_name = string.format("Movie_Arena_%s_%d_%d",uid,motion_index,line_index);
	local frame_node = frames[frame_index];
	local next_frame_node = frames[next_frame_index];
	if(frame_node)then
		if(need_created)then
			local character_list = {};
			local node;
			for node in commonlib.XPath.eachNode(frame_node, "//Arena/Object") do
				local Index = Movie.GetNumber(node,"Index");
				local Scale = Movie.GetNumber(node,"Scale");
				local AssetFile = Movie.GetString(node,"AssetFile");
				local CCSInfoStr = Movie.GetString(node,"CCS");
				if(AssetFile and AssetFile ~= "")then
					character_list[Index]={
						AssetFile = AssetFile,
						CCSInfoStr = CCSInfoStr,
						Scale = Scale,
					};
				end
			end
			local arena_node;
			for node in commonlib.XPath.eachNode(frame_node, "//Arena") do
				arena_node = node;
				break;
			end
			if(arena_node)then
				local params = {
					x = Movie.GetNumber(arena_node,"X"),
					y = Movie.GetNumber(arena_node,"Y"),
					z = Movie.GetNumber(arena_node,"Z"),
					visible = Movie.GetBoolean(arena_node,"Visible"),
					character_list = character_list,
				};
				MovieRender_Arena.CreateEntity(obj_name,params)
			end
		end
	end
end
function MovieRender_Arena.CreateEntity(obj_name,props_param)
	local self = MovieRender_Arena;
	if(not obj_name or not props_param)then return end
	local x,y,z = props_param.x,props_param.y,props_param.z;
	local visible = props_param.visible;
	local character_list = props_param.character_list;

	MotionRender_SpellCastViewer.RemoveTestArena();
	if(not visible)then
		return
	end
	MotionRender_SpellCastViewer.CreateArena(x, y, z,character_list);
	
end
function MovieRender_Arena.DestroyEntity()
	local self = MovieRender_Arena;
	MotionRender_SpellCastViewer.RemoveTestArena();
end
