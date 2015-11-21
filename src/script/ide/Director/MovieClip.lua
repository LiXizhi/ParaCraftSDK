--[[
Title: MovieClip
Author(s): Leio
Date: 2012/05/10
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/Director/MovieClip.lua");
local MovieClip = commonlib.gettable("Director.MovieClip");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/EventDispatcher.lua");
NPL.load("(gl)script/ide/ExternalInterface.lua");
NPL.load("(gl)script/ide/Director/MovieRender_Mcml.lua");
local MovieRender_Mcml = commonlib.gettable("Director.MovieRender_Mcml");
NPL.load("(gl)script/ide/Director/MovieRender_Script.lua");
local MovieRender_Script = commonlib.gettable("Director.MovieRender_Script");
NPL.load("(gl)script/ide/Director/MovieRender_Audio.lua");
local MovieRender_Audio = commonlib.gettable("Director.MovieRender_Audio");
NPL.load("(gl)script/ide/Director/MovieRender_Spell.lua");
local MovieRender_Spell = commonlib.gettable("Director.MovieRender_Spell");
NPL.load("(gl)script/ide/Director/MovieRender_Arena.lua");
local MovieRender_Arena = commonlib.gettable("Director.MovieRender_Arena");
NPL.load("(gl)script/ide/Director/MovieRender_Text.lua");
local MovieRender_Text = commonlib.gettable("Director.MovieRender_Text");
NPL.load("(gl)script/ide/Director/MovieRender_Image.lua");
local MovieRender_Image = commonlib.gettable("Director.MovieRender_Image");
NPL.load("(gl)script/ide/Director/MovieRender_Camera.lua");
local MovieRender_Camera = commonlib.gettable("Director.MovieRender_Camera");
NPL.load("(gl)script/ide/Director/MovieRender_Model.lua");
local MovieRender_Model = commonlib.gettable("Director.MovieRender_Model");
local MovieRender_Character = commonlib.gettable("Director.MovieRender_Character");
NPL.load("(gl)script/ide/Director/MovieRender_SpellCamera.lua");
local MovieRender_SpellCamera = commonlib.gettable("Director.MovieRender_SpellCamera");
NPL.load("(gl)script/ide/Director/Movie.lua");
local Movie = commonlib.gettable("Director.Movie");
local MovieClip = commonlib.inherit(commonlib.EventSystem, commonlib.gettable("Director.MovieClip"));  
MovieClip.motion_list = nil;
MovieClip.mini_scene_motion_name = "Movie_mini_scene_motion_name"
MovieClip.uid = nil;
MovieClip.end_to_clear = true;--播放完毕 自动清除资源
MovieClip.render_maps = {
	["Model"] = MovieRender_Model,
	["Character"] = MovieRender_Character,
	["Text"] = MovieRender_Text,
	["Camera"] = MovieRender_Camera,
	["Audio"] = MovieRender_Audio,
	["Mcml"] = MovieRender_Mcml,
	["Image"] = MovieRender_Image,
	["Arena"] = MovieRender_Arena,
	["Spell"] = MovieRender_Spell,
	["Script"] = MovieRender_Script,
	["SpellCamera"] = MovieRender_SpellCamera,
}

local last_id = 1;
-- constructor
function MovieClip:ctor()
	last_id = last_id + 1;
	local uid = self.uid or last_id 
	self.uid = tostring(uid);
	self.audio_pool = {};
end
function MovieClip:GetUID()
	return self.uid;
end
--[[
	MovieClip.motion_list = {
		[1] = { 
			Motion_Node = Motion_Node,--mcml node
			MotionLines = MotionLines,--mcml node
			MotionLines_Frames = {
				[1] = frames,--mcml node
				[2] = frames,--mcml node
			},
			MotionLines_Frames_State_list = {
				[1] = {
					{ frame = 0, next_frame = 100, frame_index = 1, next_frame_index = 2, is_created = nil, },
					{ frame = 100, next_frame = 200, frame_index = 2, next_frame_index = 3, is_created = nil, },
					{ frame = 200, next_frame = 300, frame_index = 3, next_frame_index = 4, is_created = nil, },
					{ frame = 300, next_frame = 300, frame_index = 4, next_frame_index = 4, is_created = nil, },
				},
				[2] = {...},
			},
		},
	}
--]]
function MovieClip:Play_File(movie_file)
	MovieClip:PrePlay_File(movie_file);
end
--通过文件路径 准备好所有的数据
function MovieClip:PrePlay_File(movie_file)
	local xmlRoot = ParaXML.LuaXML_ParseFile(movie_file);
	self:PrePlay_ByMcmlNode(xmlRoot);
end
--通过解析后的字符串 准备好所有的数据
function MovieClip:PrePlay_ByString(movie_mcmlNode_str)
	local mcmlNode = ParaXML.LuaXML_ParseString(movie_mcmlNode_str);
	self:PrePlay_ByMcmlNode(mcmlNode);
end
--准备好所有的数据
function MovieClip:PrePlay_ByMcmlNode(movie_mcmlNode)
	self.motion_list = {};
	if(not movie_mcmlNode)then return end
	local motion_index = 0;
	local motion_node;
	for motion_node in commonlib.XPath.eachNode(movie_mcmlNode, "//Motions/Motion") do
		motion_index = motion_index + 1;

		local motion = {};

		self.motion_list[motion_index] = motion;
		motion["Motion_Node"] = motion_node;

		local MotionLines = commonlib.XPath.selectNodes(motion_node, "/MotionLine");
		motion["MotionLines"] = MotionLines;

		local MotionLines_Frames = {};
		motion["MotionLines_Frames"] = MotionLines_Frames;

		local MotionLines_Frames_State_list = {};
		motion["MotionLines_Frames_State_list"] = MotionLines_Frames_State_list;

		local line_node;
		local line_index;
		local line_cnt = #MotionLines;
		for line_index = 1,line_cnt do
			line_node = MotionLines[line_index];

			local frame_state_list = {};
			--记录frame_state_list
			MotionLines_Frames_State_list[line_index] = frame_state_list;

			local frames = commonlib.XPath.selectNodes(line_node, "//Frame");
			--记录MotionLines_Frames
			MotionLines_Frames[line_index] = frames;

			local frame_node;
			local frame_index;
			local frame_cnt = #frames;
			for frame_index = 1,frame_cnt do
				next_frame_index = frame_index+1;
				local frame_node = frames[frame_index];
				local next_frame_node = frames[next_frame_index];

				if(frame_node)then
					local frame = Movie.GetNumber(frame_node,"Time") or 0;
					local next_frame = frame;
					if(next_frame_node)then
						next_frame = Movie.GetNumber(next_frame_node,"Time") or frame;
					else
						next_frame_index = frame_index;
					end
					table.insert(frame_state_list,{
						frame = frame,
						next_frame = next_frame,
						frame_index = frame_index,
						next_frame_index = next_frame_index,
						is_created = nil,
					});
				end
			end
		end

	end
end
function MovieClip:Reset_Frames_State_list()
	if(self.motion_list)then
		local k,v;
		for k,v in ipairs(self.motion_list) do
			local motion = v;
			local MotionLines_Frames_State_list = motion["MotionLines_Frames_State_list"];
			local kkk,frame_state;
			for kkk,frame_state in ipairs(MotionLines_Frames_State_list) do
				local kkkk,vvvv;
				for kkkk,vvvv in ipairs(frame_state) do
					vvvv.is_created = nil;
				end
			end
		end
	end	
end
function MovieClip:GotoFrame(motion_index,root_frame)
	if(not self.motion_list or not self.motion_list[motion_index] or not root_frame)then return end
	--如果是编辑模式
	if(Movie.is_edit_mode)then
		ExternalInterface.Call("motion_time_update",{
				index = motion_index,
				run_time = root_frame,
			});
	end
	--效率好像有问题
	self:DispatchEvent({type = "movie_update" , motion_index = motion_index, run_time = root_frame, });
	local motion = self.motion_list[motion_index];

	local Motion_Node = motion["Motion_Node"];
	local Duration = Movie.GetNumber(Motion_Node,"Duration");
	local MotionLines = motion["MotionLines"];
	local MotionLines_Frames = motion["MotionLines_Frames"];
	local MotionLines_Frames_State_list = motion["MotionLines_Frames_State_list"];

	local len = #MotionLines_Frames_State_list;
	
	local line_index;
	for line_index = 1,len do
		local can_update = true;
		--如果是编辑模式 忽略不可见的编辑
		if(Movie.is_edit_mode)then
			local motion_line = MotionLines[line_index];	
			can_update = Movie.GetBoolean(motion_line,"Debug_Visible");
		end
		local frame_state = MotionLines_Frames_State_list[line_index];
		--[[
		local frame_state = {
			{ frame = 0, next_frame = 100, frame_index = 1, next_frame_index = 2, is_created = nil, },
			{ frame = 100, next_frame = 200, frame_index = 2, next_frame_index = 3, is_created = nil, },
			{ frame = 200, next_frame = 300, frame_index = 3, next_frame_index = 4, is_created = nil, },
			{ frame = 300, next_frame = 300, frame_index = 4, next_frame_index = 4, is_created = nil, },
		}
		--]]
		if(frame_state and can_update)then
			local min_frame = 0;
			local cnt = #frame_state;
			local max_frame = Duration;
			if(root_frame >= min_frame and root_frame <= max_frame)then
				local k,v;
				for k,v in ipairs(frame_state) do
					local frame = v.frame;
					local next_frame = v.next_frame;
					local frame_index = v.frame_index;
					local next_frame_index = v.next_frame_index;

					local is_created = v.is_created;
					local need_created = false;
					local located_keyframe = false;
					if(root_frame >= frame and root_frame < next_frame)then
						if(not is_created)then
							v.is_created = true;
							need_created = true;
						end
						MovieClip.UpdateCallback(self,self.motion_list,root_frame,motion_index,line_index,frame,next_frame,frame_index,next_frame_index,need_created);
					--最后一帧
					elseif(root_frame >= next_frame and frame == next_frame)then
						if(not is_created)then
							v.is_created = true;
							need_created = true;
							MovieClip.UpdateCallback(self,self.motion_list,root_frame,motion_index,line_index,frame,next_frame,frame_index,next_frame_index,need_created);
						end
						
					end
				end
			end
		end
	end
end
function MovieClip.UpdateCallback(movieclip,motion_list,root_frame,motion_index,line_index,frame,next_frame,frame_index,next_frame_index,need_created,located_keyframe)
	if(not motion_list)then return end
	local motion = motion_list[motion_index];
	if(not motion)then
		return
	end
	local Motion_Node = motion["Motion_Node"];
	local MotionLines = motion["MotionLines"];
	local MotionLines_Frames = motion["MotionLines_Frames"];
	local MotionLines_Frames_State_list = motion["MotionLines_Frames_State_list"];

	local motion_line = MotionLines[line_index];
	if(motion_line)then
		local TargetType = Movie.GetString(motion_line,"TargetType");
		
		local render = MovieClip.render_maps[TargetType];
		if(render and render.Update)then
			local frames = MotionLines_Frames[line_index];
			render.Update(movieclip,frames,root_frame,motion_index,line_index,frame,next_frame,frame_index,next_frame_index,need_created,motion_line,located_keyframe);
		end
	end
end
--通过解析文件 播放电影
--@param movie_file: 电影文件路径
--@param motion_index:场景索引
--@param run_time:运行时间
function MovieClip:DoPlay_File(movie_file,force_load,motion_index,run_time)
	if(force_load or not self.last_DoPlayStringNode)then
		self.last_DoPlayStringNode = ParaXML.LuaXML_ParseFile(movie_file);
	end
	self:DoPlay_ByMcmlNode(self.last_DoPlayStringNode,motion_index,run_time);
end
--通过解析字符串 播放电影
function MovieClip:DoPlay_ByString(movie_mcmlNode_str,motion_index,run_time)
	local mcmlNode = ParaXML.LuaXML_ParseString(movie_mcmlNode_str);
	self:DoPlay_ByMcmlNode(mcmlNode,motion_index,run_time);
end
--播放电影
--@param movie_mcmlNode:数据源
--@param motion_index:场景索引
--@param run_time:运行时间
--@event {type = "before_play" , movie_mcmlNode = movie_mcmlNode, }
--@event {type = "movie_start" , motion_index = motion_index, run_time = run_time, }
--@event {type = "movie_update" , motion_index = motion_index, run_time = run_time, }
--@event {type = "movie_change_scene" , motion_index = motion_index, run_time = run_time, }
--@event {type = "movie_end" , motion_index = motion_index, run_time = run_time, }
function MovieClip:DoPlay_ByMcmlNode(movie_mcmlNode,motion_index,run_time)
	if(not movie_mcmlNode)then
		return;
	end
	self:Clear();
	self:DispatchEvent({type = "before_play" ,movie_mcmlNode = movie_mcmlNode,});
	self:PrePlay_ByMcmlNode(movie_mcmlNode);
	if(not self.motion_list)then
		return;
	end
	if(not self.timer)then
		self.timer = commonlib.Timer:new();
	end
	self:DoResume();
	run_time = run_time or 0;
	local motion_index = motion_index or 1;
	local motion_cnt = #self.motion_list;
	self.timer.callbackFunc = function(timer)
			if(self.is_pause)then
				return;
			end
			local delta = timer:GetDelta(200);
			local motion = self.motion_list[motion_index];
			if(not motion)then
				echo({self.uid,motion_index});
			end 
			local Motion_Node = motion["Motion_Node"];
			local duration = Movie.GetNumber(Motion_Node,"Duration") or 0;
			if(run_time > duration)then
				motion_index = motion_index + 1;
				if(motion_index > motion_cnt)then
					if(self.end_to_clear)then
						self:Clear();
					else
						self.timer:Change();
						self.is_pause = false;
					end
					self:DispatchEvent({type = "movie_end" ,motion_index = motion_index, run_time = run_time, });
					return;
				else
					run_time = 0;
					self:DispatchEvent({type = "movie_change_scene" ,motion_index = motion_index, run_time = run_time, });
				end
			else
				run_time = run_time + delta;
			end
			self:GotoFrame(motion_index,run_time)
		end
	self:DispatchEvent({type = "movie_start" , motion_index = motion_index, run_time = run_time, });
	self.timer:Change(0, 10);
end

function MovieClip:DoPause()
	self.is_pause = true;
end
function MovieClip:DoResume()
	self.is_pause = false;
end
function MovieClip:Clear()
	if(self.timer)then
		self.timer:Change();
	end
	self.is_pause = false;

	--销毁所有的资源
	if(self.motion_list)then
		local motion_index,v;
		for motion_index,v in ipairs(self.motion_list) do
			local motion = v;
			local MotionLines = motion["MotionLines"];
			local line_index,line_node;
			for line_index,line_node in ipairs(MotionLines) do
				local TargetType = line_node.attr.TargetType;
				local render = self.render_maps[TargetType];
				if(render and render.DestroyEntity)then
					render.DestroyEntity(self,motion_index, line_index);
				end
			end
		end
	end	
	self.audio_pool = {};
	self.motion_list = {};
end
function MovieClip:GetInstanceName(motion_index,line_index)
	local uid = self.uid or "";
	return string.format("MovieClip_%s_%d_%d",uid,motion_index or 0,line_index or 0);
end
function MovieClip:GetMotionLineNode(motion_index,line_index)
	motion_index = motion_index or 1;
	line_index = line_index or 1;
	local motion = self.motion_list[motion_index];
	if(motion)then
		local MotionLines = motion["MotionLines"];
		local MotionLines_Frames = motion["MotionLines_Frames"];
		local MotionLines_Frames_State_list = motion["MotionLines_Frames_State_list"];

		if(MotionLines )then
			local line_node = MotionLines[line_index];
			return line_node;
		end
	end
end


