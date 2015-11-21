--[[
Title: MovieRender_Model
Author(s): Leio
Date: 2012/05/10
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/Director/MovieRender_Model.lua");
local MovieRender_Model = commonlib.gettable("Director.MovieRender_Model");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/MotionEx/MotionTypes.lua");
local MotionTypes = commonlib.gettable("MotionEx.MotionTypes");
NPL.load("(gl)script/ide/Director/Movie.lua");
local Movie = commonlib.gettable("Director.Movie");
local MovieRender_Model = commonlib.gettable("Director.MovieRender_Model");
local MovieRender_Character = commonlib.gettable("Director.MovieRender_Character");
NPL.load("(gl)script/apps/Aries/Quest/NPC.lua");
local NPC = commonlib.gettable("MyCompany.Aries.Quest.NPC");
function MovieRender_Character.Update(movieclip,frames,root_frame,motion_index,line_index,frame,next_frame,frame_index,next_frame_index,need_created)
	MovieRender_Model._Update(movieclip,frames,root_frame,motion_index,line_index,frame,next_frame,frame_index,next_frame_index,need_created,false);
end
function MovieRender_Character.DestroyEntity(movieclip,motion_index,line_index)
	MovieRender_Model.DestroyEntity(movieclip,motion_index,line_index);
end
function MovieRender_Character.GetEntity(obj_name)
	return MovieRender_Model.GetEntity(obj_name);
end
function MovieRender_Model.Update(movieclip,frames,root_frame,motion_index,line_index,frame,next_frame,frame_index,next_frame_index,need_created)
	MovieRender_Model._Update(movieclip,frames,root_frame,motion_index,line_index,frame,next_frame,frame_index,next_frame_index,need_created,true);
end
MovieRender_Model.delay_timer = nil;
function MovieRender_Model._Update(movieclip,frames,root_frame,motion_index,line_index,frame,next_frame,frame_index,next_frame_index,need_created,ismodel)
	local obj_name = movieclip:GetInstanceName(motion_index,line_index);
	local frame_node = frames[frame_index];
	local next_frame_node = frames[next_frame_index];
	if(frame_node)then
		local x = Movie.GetNumber(frame_node,"X");
		local y = Movie.GetNumber(frame_node,"Y");
		local z = Movie.GetNumber(frame_node,"Z");
		local facing = Movie.GetNumber(frame_node,"Facing") or 0;
		local scale = Movie.GetNumber(frame_node,"Scale") or 1;
		local assetfile = Movie.GetString(frame_node,"AssetFile");
		local ccsinfo = Movie.GetString(frame_node,"CCS");
		local animation = Movie.GetString(frame_node,"Animation");
		local visible = Movie.GetBoolean(frame_node,"Visible");
		local props_param;
		props_param = {
			x = x,y = y,z = z,facing = facing,scale = scale,assetfile = assetfile,animation = animation,visible = visible,ismodel =ismodel,
		};
		--是否
		local Action = Movie.GetNumber(frame_node,"Action") or 0; --0 fly 1 walk 2 run
		if(need_created)then
			MovieRender_Model.DestroyEntity(movieclip,motion_index,line_index);
			MovieRender_Model.CreateEntity(obj_name,props_param);
			if(not ismodel)then
				if(Action > 0)then
					if(not MovieRender_Model.delay_timer)then
						MovieRender_Model.delay_timer = commonlib.Timer:new(); 
					end

					MovieRender_Model.delay_timer.callbackFunc = function(timer)
						local obj = NPC.GetNpcCharacterFromIDAndInstance(obj_name)
						if(obj and next_frame_node)then
							obj:ToCharacter():Stop();
							local s = obj:ToCharacter():GetSeqController();
							local _x = Movie.GetNumber(next_frame_node,"X");
							local _y = Movie.GetNumber(next_frame_node,"Y");
							local _z = Movie.GetNumber(next_frame_node,"Z");
							if(Action == 1)then
								s:WalkTo(_x - x,_y - y,_z - z);
							elseif(Action == 2)then
								s:RunTo(_x - x,_y - y,_z - z);
							end
						end
					end
					MovieRender_Model.delay_timer:Change(200, nil)
				end
			end
		end
		if(next_frame_node)then
			local FrameType = Movie.GetString(next_frame_node,"FrameType");
		
			local motion_handler = MotionTypes[FrameType];
			if(motion_handler and frame_node ~= next_frame_node)then
				local _x = Movie.GetNumber(next_frame_node,"X");
				local _y = Movie.GetNumber(next_frame_node,"Y");
				local _z = Movie.GetNumber(next_frame_node,"Z");
				local _facing = Movie.GetNumber(next_frame_node,"Facing") or 0;
				local _scale = Movie.GetNumber(next_frame_node,"Scale") or 1;

				local time = root_frame - frame;
				local duration = next_frame - frame;
				x = Movie.GetMotionValue(motion_handler,time,duration,x,_x);
				y = Movie.GetMotionValue(motion_handler,time,duration,y,_y);
				z = Movie.GetMotionValue(motion_handler,time,duration,z,_z);
				facing = Movie.GetMotionValue(motion_handler,time,duration,facing,_facing);
				scale = Movie.GetMotionValue(motion_handler,time,duration,scale,_scale);

				props_param = {
					x = x,y = y,z = z,facing = facing,scale = scale,assetfile = assetfile,animation = animation,visible = visible,ismodel =ismodel,
				};
			end
			if(Action == 0)then
				MovieRender_Model.UpdateEntity(obj_name,props_param,bUpdateAnimation);
			end
		end
	end
end
function MovieRender_Model.GetEntity(obj_name)
	local obj = NPC.GetNpcCharacterFromIDAndInstance(obj_name)
	if(obj)then
		return obj;
	end
	local effectGraph = ParaScene.GetMiniSceneGraph(Movie.mini_scene_motion_name);
	local obj = effectGraph:GetObject(obj_name);
	return obj;
end
function MovieRender_Model.CreateEntity(obj_name,props_param)
	local self = MovieRender_Model;
	
	if(not obj_name or not props_param)then return end
	local effectGraph = ParaScene.GetMiniSceneGraph(Movie.mini_scene_motion_name);
	local asset_file =  props_param.assetfile;
	local x,y,z = props_param.x,props_param.y,props_param.z;
	local facing = props_param.facing;
	local scale = props_param.scale;
	local ismodel = props_param.ismodel;
	local animation = props_param.animation;
	local filename = props_param.filename;
	local visible = props_param.visible;
	local ccsinfo = props_param.ccsinfo;

	if(not asset_file)then
		return
	end	
	if(not ismodel)then
		if(ccsinfo)then
			ccsinfo = commonlib.LoadTableFromString(ccsinfo);
		end
		local params = {
			position = {x,y,z},
			assetfile_char = asset_file,
			facing = facing,
			scaling = scale,
			ccsinfo = ccsinfo,
		}
		--用NPC创建人物
		NPC.CreateNPCCharacter(obj_name, params)
		local obj = NPC.GetNpcCharacterFromIDAndInstance(obj_name)
		if(obj and animation and animation ~= "")then
			Map3DSystem.Animation.PlayAnimationFile(animation, obj);
		end
		return
	end
	if(effectGraph:IsValid()) then
		effectGraph:DestroyObject(obj_name);
		if(not visible)then
			return
		end
		local obj;
		if(ismodel) then
			asset = ParaAsset.LoadStaticMesh("", asset_file);
			obj = ParaScene.CreateMeshPhysicsObject(obj_name, asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
			obj:SetField("progress", 1);
		else
			asset = ParaAsset.LoadParaX("", asset_file);
			obj = ParaScene.CreateCharacter(obj_name, asset , "", true, 1.0, 0, 1.0);
			if(animation and animation ~= "")then
				Map3DSystem.Animation.PlayAnimationFile(animation, obj);
			end
		end
		if(obj and obj:IsValid() == true) then
			obj:SetPosition(x, y, z);
			if(scale) then
				obj:SetScale(scale);
			end
			if(facing) then
				obj:SetFacing(facing);
			end
			effectGraph:AddChild(obj);

			if(ccsinfo and not ismodel)then
				ccsinfo = commonlib.LoadTableFromString(ccsinfo);
				if(ccsinfo)then
					CCS.DB.ApplyCartoonfaceInfoString(obj, ccsinfo.cartoonface_info);
					CCS.Predefined.ApplyFacialInfoString(obj, ccsinfo.facial_info);
					local npcCharChar = obj:ToCharacter();
					local i;
					for i = 0, 45 do
						npcCharChar:SetCharacterSlot(i, ccsinfo.equips[i] or 0);
					end
				end
			end
		end
	end
end
function MovieRender_Model.UpdateEntity(obj_name,props_param,bUpdateAnimation)
	if(not obj_name or not props_param)then return end
	local x,y,z = props_param.x,props_param.y,props_param.z;
	local facing = props_param.facing;
	local scale = props_param.scale;
	local visible = props_param.visible;
	local ismodel = props_param.ismodel;
	local animation = props_param.animation;
	if(not ismodel)then
		local obj = NPC.GetNpcCharacterFromIDAndInstance(obj_name)
		if(obj)then
			obj:SetVisible(visible);
			if(not visible)then
				return
			end
			if(x and y and z)then
				obj:SetPosition(x,y,z);
			end
			if(facing)then
				obj:SetFacing(facing);
			end
			if(scale)then
				obj:SetScale(scale);
			end
		end
		return
	end
	local effectGraph = ParaScene.GetMiniSceneGraph(Movie.mini_scene_motion_name);
	if(effectGraph:IsValid()) then
		local obj = effectGraph:GetObject(obj_name);
		
		if(obj and obj:IsValid())then
			
			obj:SetVisible(visible);
			if(not visible)then
				return
			end
			if(x and y and z)then
				obj:SetPosition(x,y,z);
			end
			if(facing)then
				obj:SetFacing(facing);
			end
			if(scale)then
				obj:SetScale(scale);
			end
		end
		if(bUpdateAnimation and not ismodel and animation and animation ~= "")then
			Map3DSystem.Animation.PlayAnimationFile(animation, obj);
		end
	end
end
function MovieRender_Model.DestroyEntity(movieclip,motion_index,line_index)
	local obj_name = movieclip:GetInstanceName(motion_index,line_index);
	local effectGraph = ParaScene.GetMiniSceneGraph(Movie.mini_scene_motion_name);
	local obj = effectGraph:GetObject(obj_name);
	if(obj and obj:IsValid())then
		effectGraph:DestroyObject(obj_name);
	end
	NPC.DeleteNPCCharacter(obj_name);
end