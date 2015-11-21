--[[
Title: MovieRender_Audio
Author(s): Leio
Date: 2012/05/10
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/Director/MovieRender_Audio.lua");
local MovieRender_Audio = commonlib.gettable("Director.MovieRender_Audio");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/AudioEngine/AudioEngine.lua");
local AudioEngine = commonlib.gettable("AudioEngine");
NPL.load("(gl)script/ide/Director/Movie.lua");
local Movie = commonlib.gettable("Director.Movie");
local MovieRender_Audio = commonlib.gettable("Director.MovieRender_Audio");
function MovieRender_Audio.IsSameStr(s1,s2)
	if(s1 and s2 and string.lower(s1) == string.lower(s2))then
		return true;
	end
end
function MovieRender_Audio.Update(movieclip,frames,root_frame,motion_index,line_index,frame,next_frame,frame_index,next_frame_index,need_created)
	local frame_node = frames[frame_index];
	local next_frame_node = frames[next_frame_index];
	if(frame_node)then
		local loop = Movie.GetBoolean(frame_node,"Loop");
		local AssetFile = Movie.GetString(frame_node,"AssetFile");
		if(need_created and AssetFile)then
			NPL.load("(gl)script/apps/Aries/Service/CommonClientService.lua");
			local CommonClientService = commonlib.gettable("MyCompany.Aries.Service.CommonClientService");
			NPL.load("(gl)script/apps/Aries/Player/main.lua");
			local Player = commonlib.gettable("MyCompany.Aries.Player");
			local gender = Player.GetGender()
			--Ìæ»»ÐÔ±ð
			if(CommonClientService.IsTeenVersion() and gender and gender == "male")then
				if(MovieRender_Audio.IsSameStr(AssetFile,"Audio/Haqi/CombatTutorialTeen/Arrival_Player_Female.ogg"))then
					AssetFile = "Audio/Haqi/CombatTutorialTeen/Arrival_Player_Male.ogg";
				end
			end
			movieclip.audio_pool[AssetFile] = true;
			local audio_src = AudioEngine.CreateGet(AssetFile);
			audio_src.file = AssetFile;
			audio_src.loop = loop;
			audio_src:play();
		end
	end
end
function MovieRender_Audio.DestroyEntity(movieclip,motion_index,line_index)
	local audio_pool = movieclip.audio_pool;
	if(audio_pool)then
		local k,v;
		for k,v in pairs(audio_pool) do
			local audio_src = AudioEngine.CreateGet(k);
			audio_src:stop();
			audio_src:release();
			audio_pool[k] = nil;
		end
	end
end
