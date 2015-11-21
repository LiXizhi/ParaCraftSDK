--[[
Title: MotionRender_Model
Author(s): Leio
Date: 2011/05/19
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/MotionEx/MotionRender_Model.lua");
local MotionRender_Model = commonlib.gettable("MotionEx.MotionRender_Model");
------------------------------------------------------------
--]]
NPL.load("(gl)script/kids/3DMapSystemUI/CCS/ccs.lua");
local CCS = commonlib.gettable("System.UI.CCS");
NPL.load("(gl)script/ide/MotionEx/MotionTypes.lua");
local MotionTypes = commonlib.gettable("MotionEx.MotionTypes");
NPL.load("(gl)script/ide/MotionEx/MotionXmlToTable.lua");
local MotionXmlToTable = commonlib.gettable("MotionEx.MotionXmlToTable");
local MotionRender_Model = commonlib.gettable("MotionEx.MotionRender_Model");
local ParaScene_GetMiniSceneGraph = ParaScene.GetMiniSceneGraph;
function MotionRender_Model.GetParamsByNode(mcmlNode,stage_params)
	local self = MotionRender_Model;
	if(mcmlNode)then
		local stage_x,stage_y,stage_z = 0,0,0;
		if(stage_params)then
			stage_x = stage_params.x or 0;
			stage_y = stage_params.y or 0;
			stage_z = stage_params.z or 0;
		end
		local params = {
			x = MotionXmlToTable.GetNumber(mcmlNode,"X") + stage_x,
			y = MotionXmlToTable.GetNumber(mcmlNode,"Y") + stage_y,
			z = MotionXmlToTable.GetNumber(mcmlNode,"Z") + stage_z,
			facing = MotionXmlToTable.GetNumber(mcmlNode,"Facing") or 0,
			scale = MotionXmlToTable.GetNumber(mcmlNode,"Scale") or 1,
			assetfile = MotionXmlToTable.GetString(mcmlNode,"AssetFile"),
			ccsinfo = MotionXmlToTable.GetString(mcmlNode,"CCS"),
			animation = MotionXmlToTable.GetString(mcmlNode,"Animation"),
			visible = MotionXmlToTable.GetBoolean(mcmlNode,"Visible"),
			ismodel = stage_params.ismodel,
		};
		return params;
	end
end
function MotionRender_Model.GetRunTimeParams(motion_handler,run_time,cur_play_node,next_play_node,stage_params)
	local self = MotionRender_Model;
	if(motion_handler and cur_play_node and next_play_node)then
		
		local start_time = MotionXmlToTable.GetNumber(cur_play_node,"Time");
		local end_time = MotionXmlToTable.GetNumber(next_play_node,"Time");
		local duration = end_time - start_time;
		local time = run_time - start_time;

		local stage_x,stage_y,stage_z = 0,0,0;
		if(stage_params)then
			stage_x = stage_params.x or 0;
			stage_y = stage_params.y or 0;
			stage_z = stage_params.z or 0;
		end
		local function get_value_number(p)
			local from = MotionXmlToTable.GetNumber(cur_play_node,p);
			local to = MotionXmlToTable.GetNumber(next_play_node,p);
			local begin = from;
			local change = to - from;
			local value = motion_handler( time , begin , change , duration );	
			return value;
		end
		local params = {
			x = get_value_number("X") + stage_x,
			y = get_value_number("Y") + stage_y,
			z = get_value_number("Z") + stage_z,
			facing = get_value_number("Facing"),
			scale = get_value_number("Scale"),
			visible = MotionXmlToTable.GetBoolean(cur_play_node,"Visible"),
			ismodel = stage_params.ismodel,
		};
		--commonlib.echo({
			--start_time = start_time,
			--run_time = run_time,
			--scale = params.scale,
		--});
		return params;
	end
end
function MotionRender_Model.DoUpdate(filename,instance_name,stage_params,run_time,pre_frame_node,frame_node,next_frame_node,state)
	local self = MotionRender_Model;
	--if(state == "jumpframe")then
			--local old_props_param = {};
			--if(pre_frame_node)then
				--old_props_param = MotionRender_Model.GetParamsByNode(pre_frame_node,stage_params);
			--end
			--local props_param = MotionRender_Model.GetParamsByNode(frame_node,stage_params);
			----commonlib.echo("=======run_time");
			----commonlib.echo(run_time);
			----commonlib.echo(props_param);
			--if(props_param.assetfile ~= old_props_param.assetfile)then
				--self.DestroyEntity(instance_name);
				--self.CreateEntity(instance_name,props_param);
			--else
				--local bUpdateAnimation;
				--if(not props_param.ismodel)then
					--bUpdateAnimation = true;
				--end
				--self.UpdateEntity(instance_name,props_param,bUpdateAnimation)
			--end
			--
	--elseif(state == "update")then
		--if(frame_node and next_frame_node)then
			--local cur_time = MotionXmlToTable.GetNumber(frame_node,"Time");
			--local frame_type = MotionXmlToTable.GetString(next_frame_node,"FrameType");
			--local motion_handler = MotionTypes[frame_type];
			--if(motion_handler)then
				--local props_param = self.GetRunTimeParams(motion_handler,run_time,frame_node,next_frame_node,stage_params);
				--self.UpdateEntity(instance_name,props_param)
			--end
--
		--elseif(frame_node and not next_frame_node)then
			----last frame
			--local props_param = MotionRender_Model.GetParamsByNode(frame_node,stage_params);
			--self.CreateEntity(instance_name,props_param);
		--end
	--end
	if(frame_node)then
		local props_param = self.GetParamsByNode(frame_node,stage_params);
		if(state == "jumpframe")then
			self.DestroyEntity(instance_name);
			self.CreateEntity(instance_name,props_param);
			local bUpdateAnimation;
			if(not props_param.ismodel)then
				bUpdateAnimation = true;
			end
			self.UpdateEntity(instance_name,props_param,bUpdateAnimation)
		elseif(state == "update")then
			if(not self.HasEntity(instance_name))then
				self.CreateEntity(instance_name,props_param);
				local bUpdateAnimation;
				if(not props_param.ismodel)then
					bUpdateAnimation = true;
				end
				self.UpdateEntity(instance_name,props_param,bUpdateAnimation)

				return;
			end
			local cur_time = MotionXmlToTable.GetNumber(frame_node,"Time");
			local frame_type = MotionXmlToTable.GetString(next_frame_node,"FrameType");
			local motion_handler = MotionTypes[frame_type];
			if(motion_handler)then
				local props_param = self.GetRunTimeParams(motion_handler,run_time,frame_node,next_frame_node,stage_params);
				self.UpdateEntity(instance_name,props_param)
			end
		end
	end
end
function MotionRender_Model.CreateEntity(effect_name,props_param)
	local self = MotionRender_Model;
	if(not effect_name or not props_param)then return end
	local effectGraph = ParaScene_GetMiniSceneGraph(MotionXmlToTable.mini_scene_motion_name);
	local asset_file =  props_param.assetfile;
	local x,y,z = props_param.x,props_param.y,props_param.z;
	local facing = props_param.facing;
	local scale = props_param.scale;
	local ismodel = props_param.ismodel;
	local animation = props_param.animation;
	local filename = props_param.filename;
	local visible = props_param.visible;
	if(not asset_file)then
		return
	end	
	if(effectGraph:IsValid()) then
		effectGraph:DestroyObject(effect_name);
		if(not visible)then
			return
		end
		local obj;
		if(ismodel) then
			asset = ParaAsset.LoadStaticMesh("", asset_file);
			obj = ParaScene.CreateMeshPhysicsObject(effect_name, asset, 1,1,1, false, "1,0,0,0,1,0,0,0,1,0,0,0");
			obj:SetField("progress", 1);
		else
			asset = ParaAsset.LoadParaX("", asset_file);
			obj = ParaScene.CreateCharacter(effect_name, asset , "", true, 1.0, 0, 1.0);
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

			local ccsinfo = props_param.ccsinfo;
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
	if(MotionXmlToTable.assetMap)then
		MotionXmlToTable.assetMap[effect_name] = effect_name;
	end
end
function MotionRender_Model.DestroyEntity(effect_name)
	local self = MotionRender_Model;
	if(not effect_name)then return end
	local effectGraph = ParaScene_GetMiniSceneGraph(MotionXmlToTable.mini_scene_motion_name);
	if(effectGraph:IsValid()) then
		effectGraph:DestroyObject(effect_name);
	end
end
function MotionRender_Model.UpdateEntity(effect_name,props_param,bUpdateAnimation)
	local self = MotionRender_Model;
	if(not effect_name or not props_param)then return end
	local x,y,z = props_param.x,props_param.y,props_param.z;
	local facing = props_param.facing;
	local scale = props_param.scale;
	local visible = props_param.visible;
	local ismodel = props_param.ismodel;
	local animation = props_param.animation;
	
	local effectGraph = ParaScene_GetMiniSceneGraph(MotionXmlToTable.mini_scene_motion_name);
	if(effectGraph:IsValid()) then
		local obj = effectGraph:GetObject(effect_name);
		
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
function MotionRender_Model.HasEntity(effect_name)
	local self = MotionRender_Model;
	local effectGraph = ParaScene_GetMiniSceneGraph(MotionXmlToTable.mini_scene_motion_name);
	if(effectGraph:IsValid()) then
		local obj = effectGraph:GetObject(effect_name);
		if(obj and obj:IsValid())then
			return true;
		end
	end
end