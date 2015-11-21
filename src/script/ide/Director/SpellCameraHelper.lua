--[[
Title: SpellCameraHelper
Author(s): Leio
Date: 2012/07/03
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/Director/SpellCameraHelper.lua");
local SpellCameraHelper = commonlib.gettable("Director.SpellCameraHelper");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Director/MovieRender_Model.lua");
local MovieRender_Model = commonlib.gettable("Director.MovieRender_Model");
NPL.load("(gl)script/ide/ExternalInterface.lua");
NPL.load("(gl)script/ide/Director/Movie.lua");
local Movie = commonlib.gettable("Director.Movie");
local SpellCameraHelper = commonlib.gettable("Director.SpellCameraHelper");
SpellCameraHelper.player_name = "Aries_SpellCamera_Player";
SpellCameraHelper.cache= {};
SpellCameraHelper.spell_map= {
	--["spell 技能名称"] = "camera_path 摄影机文件路径"
};
SpellCameraHelper.refpoints_map= {
	--["ground"] = mcmlNode
}
SpellCameraHelper.camera_map= {
	--["id"] = mcmlNode 
}
function SpellCameraHelper.SetEditMode(b)
	local self = SpellCameraHelper;
	self.is_edit_mode = b;
end
function SpellCameraHelper.Stop()
	local self = SpellCameraHelper;
	local player = Movie.CreateOrGetPlayer(self.player_name);
	if(player)then
		player:Clear();
	end	
	if(self.is_edit_mode)then
		ExternalInterface.Call("Director.movie_end",{
			motion_index = 1,
			run_time = 0,
		});
	end
end
--[[
local args = {
	start_point_pos = start_point_pos, --开始位置
	end_point_pos = end_point_pos, -- 结束位置
	ground_pos = ground_pos, -- 圆盘位置
	miniscene_name = miniscene_name,--跟随物体的mini scene
	lookat_effect_force_name = force_name,-- 跟随物体的名称
	spell_config_file = spell_config_file,-- 特效的路径
	caster_slotid = caster_slotid,--开始的索引
	target_slotids = target_slotids,--结束的索引列表
	nomotion = false,--直接跳转到动画的结束点
}
--]]
function SpellCameraHelper.Play(args)
	local self = SpellCameraHelper;
	if(not args)then return end
	local player = Movie.CreateOrGetPlayer(self.player_name);
	if(player)then
		--如果是编辑模式
		if(self.is_edit_mode)then
			player:AddEventListener("movie_start",function(holder,event)
				ExternalInterface.Call("Director.movie_start",{
						motion_index = event.motion_index,
						run_time = event.run_time,
					});
			end,nil,"DirectorToolPage_movie_start");
			player:AddEventListener("movie_update",function(holder,event)
				ExternalInterface.Call("Director.movie_update",{
						motion_index = event.motion_index,
						run_time = event.run_time,
					});
			end,nil,"DirectorToolPage_movie_update");
			player:AddEventListener("movie_end",function(holder,event)
				ExternalInterface.Call("Director.movie_end",{
						motion_index = event.motion_index,
						run_time = event.run_time,
					});
			end,nil,"DirectorToolPage_movie_end");
		end
		local caster_slotid = args.caster_slotid;
		local target_slotids = args.target_slotids;
		local start_point_pos = args.start_point_pos;
		local end_point_pos = args.end_point_pos;
		local ground_pos = args.ground_pos;
		local spell_config_file = args.spell_config_file;

		local center_node,refpoints_map,camera_map,spell_map = self.GetConfig();
		local has,camera_file = SpellCameraHelper.HasCamera(spell_config_file);

		if(has)then
			local xmlRoot = self.cache[camera_file];
			--编辑模式下没有缓存
			if(not xmlRoot or self.is_edit_mode or (SystemInfo.GetField("name") == "Taurus"))then
				xmlRoot = ParaXML.LuaXML_ParseFile(camera_file);
				self.cache[camera_file] = xmlRoot;
			end
			--替换动态节点 carster target
			self.ReplaceDynamicNode(xmlRoot,caster_slotid,target_slotids,start_point_pos,end_point_pos,ground_pos);
			player:DoPlay_ByMcmlNode(xmlRoot);
		end
	end
end
function SpellCameraHelper.ReplaceDynamicNode(xmlRoot,caster_slotid,target_slotids,start_point_pos,end_point_pos,ground_pos)
	local self = SpellCameraHelper;
	if(not xmlRoot or not start_point_pos or not end_point_pos or not ground_pos)then return end
	local center_node,refpoints_map,camera_map,spell_map = self.GetConfig();
	local node;
	for node in commonlib.XPath.eachNode(xmlRoot, "//Motion/MotionLine/Frame") do
		local RefID = node.attr.RefID;
		if(RefID)then
			if(RefID == "dynamic")then
				local ref_node = refpoints_map[RefID];
				--获取摄影机目前坐标
				local X,Y,Z = ParaCamera.GetLookAtPos()
				local att = ParaCamera.GetAttributeObject();
				local CameraObjectDistance = att:GetField("CameraObjectDistance", 10);
				local CameraLiftupAngle = att:GetField("CameraLiftupAngle", 0);
				local CameraRotY = att:GetField("CameraRotY", 0);

				X = X + Movie.GetNumber(node,"X") + Movie.GetNumber(ref_node,"X");
				Y = Y + Movie.GetNumber(node,"Y") + Movie.GetNumber(ref_node,"Y");
				Z = Z + Movie.GetNumber(node,"Z") + Movie.GetNumber(ref_node,"Z");
				CameraObjectDistance = CameraObjectDistance + Movie.GetNumber(node,"CameraObjectDistance") + Movie.GetNumber(ref_node,"CameraObjectDistance");
				CameraLiftupAngle = CameraLiftupAngle + Movie.GetNumber(node,"CameraLiftupAngle") + Movie.GetNumber(ref_node,"CameraLiftupAngle");
				CameraRotY = CameraRotY + Movie.GetNumber(node,"CameraRotY") + Movie.GetNumber(ref_node,"CameraRotY");

				node.attr.Internal_X = tostring(X);
				node.attr.Internal_Y = tostring(Y);
				node.attr.Internal_Z = tostring(Z);
				node.attr.Internal_CameraObjectDistance = tostring(CameraObjectDistance);
				node.attr.Internal_CameraLiftupAngle = tostring(CameraLiftupAngle);
				node.attr.Internal_CameraRotY = tostring(CameraRotY);

			elseif(RefID == "carster")then
				local ref_node = refpoints_map[RefID];
				--进攻位置坐标
				local X = start_point_pos[1] + Movie.GetNumber(node,"X") + Movie.GetNumber(ref_node,"X");
				local Y = start_point_pos[2] + Movie.GetNumber(node,"Y") + Movie.GetNumber(ref_node,"Y");
				local Z = start_point_pos[3] + Movie.GetNumber(node,"Z") + Movie.GetNumber(ref_node,"Z");
				local CameraObjectDistance = Movie.GetNumber(node,"CameraObjectDistance") + Movie.GetNumber(ref_node,"CameraObjectDistance");
				local CameraLiftupAngle = Movie.GetNumber(node,"CameraLiftupAngle") + Movie.GetNumber(ref_node,"CameraLiftupAngle");
				local CameraRotY = Movie.GetNumber(node,"CameraRotY") + Movie.GetNumber(ref_node,"CameraRotY");

				
				local facing = math.atan2((start_point_pos[1] - ground_pos[1]), (start_point_pos[3] - ground_pos[3]));
				facing = facing + Movie.GetNumber(node,"CameraRotY");

				node.attr.Internal_X = tostring(X);
				node.attr.Internal_Y = tostring(Y);
				node.attr.Internal_Z = tostring(Z);
				node.attr.Internal_CameraObjectDistance = tostring(CameraObjectDistance);
				node.attr.Internal_CameraLiftupAngle = tostring(CameraLiftupAngle);
				node.attr.Internal_CameraRotY = tostring(facing);
			elseif(RefID == "target")then
				local ref_node = refpoints_map[RefID];
				--被进攻位置坐标
				local X = end_point_pos[1] + Movie.GetNumber(node,"X") + Movie.GetNumber(ref_node,"X");
				local Y = end_point_pos[2] + Movie.GetNumber(node,"Y") + Movie.GetNumber(ref_node,"Y");
				local Z = end_point_pos[3] + Movie.GetNumber(node,"Z") + Movie.GetNumber(ref_node,"Z");
				local CameraObjectDistance = Movie.GetNumber(node,"CameraObjectDistance") + Movie.GetNumber(ref_node,"CameraObjectDistance");
				local CameraLiftupAngle = Movie.GetNumber(node,"CameraLiftupAngle") + Movie.GetNumber(ref_node,"CameraLiftupAngle");
				local CameraRotY = Movie.GetNumber(node,"CameraRotY") + Movie.GetNumber(ref_node,"CameraRotY");

				local facing = math.atan2((end_point_pos[1] - ground_pos[1]), (end_point_pos[3] - ground_pos[3]));
				facing = facing + Movie.GetNumber(node,"CameraRotY");

				node.attr.Internal_X = tostring(X);
				node.attr.Internal_Y = tostring(Y);
				node.attr.Internal_Z = tostring(Z);
				node.attr.Internal_CameraObjectDistance = tostring(CameraObjectDistance);
				node.attr.Internal_CameraLiftupAngle = tostring(CameraLiftupAngle);
				node.attr.Internal_CameraRotY = tostring(facing);

			elseif(RefID == "ground")then
				local ref_node = refpoints_map[RefID];
				--法阵中心坐标
				local X = ground_pos[1] + Movie.GetNumber(node,"X") + Movie.GetNumber(ref_node,"X");
				local Y = ground_pos[2] + Movie.GetNumber(node,"Y") + Movie.GetNumber(ref_node,"Y");
				local Z = ground_pos[3] + Movie.GetNumber(node,"Z") + Movie.GetNumber(ref_node,"Z");
				local CameraObjectDistance = Movie.GetNumber(node,"CameraObjectDistance") + Movie.GetNumber(ref_node,"CameraObjectDistance");
				local CameraLiftupAngle = Movie.GetNumber(node,"CameraLiftupAngle") + Movie.GetNumber(ref_node,"CameraLiftupAngle");
				local CameraRotY = Movie.GetNumber(node,"CameraRotY") + Movie.GetNumber(ref_node,"CameraRotY");


				node.attr.Internal_X = tostring(X);
				node.attr.Internal_Y = tostring(Y);
				node.attr.Internal_Z = tostring(Z);
				node.attr.Internal_CameraObjectDistance = tostring(CameraObjectDistance);
				node.attr.Internal_CameraLiftupAngle = tostring(CameraLiftupAngle);
				node.attr.Internal_CameraRotY = tostring(CameraRotY);
			elseif(RefID == "ground2")then
				local ref_node = refpoints_map[RefID];
				--法阵中心坐标
				local X = ground_pos[1] + Movie.GetNumber(node,"X") + Movie.GetNumber(ref_node,"X");
				local Y = ground_pos[2] + Movie.GetNumber(node,"Y") + Movie.GetNumber(ref_node,"Y");
				local Z = ground_pos[3] + Movie.GetNumber(node,"Z") + Movie.GetNumber(ref_node,"Z");
				local CameraObjectDistance = Movie.GetNumber(node,"CameraObjectDistance") + Movie.GetNumber(ref_node,"CameraObjectDistance");
				local CameraLiftupAngle = Movie.GetNumber(node,"CameraLiftupAngle") + Movie.GetNumber(ref_node,"CameraLiftupAngle");
				local CameraRotY = Movie.GetNumber(node,"CameraRotY") + Movie.GetNumber(ref_node,"CameraRotY");
				if(caster_slotid > 4)then
					CameraRotY = CameraRotY + 3.14;
				end

				node.attr.Internal_X = tostring(X);
				node.attr.Internal_Y = tostring(Y);
				node.attr.Internal_Z = tostring(Z);
				node.attr.Internal_CameraObjectDistance = tostring(CameraObjectDistance);
				node.attr.Internal_CameraLiftupAngle = tostring(CameraLiftupAngle);
				node.attr.Internal_CameraRotY = tostring(CameraRotY);
			else
				local ref_node = refpoints_map[RefID];
				if(ref_node)then
					local iscustom = ref_node.attr.iscustom;
					--自定义参照点 以法阵中心为参照点
					if(iscustom and (iscustom == "True" or iscustom == "true"))then
						local X = ground_pos[1] + Movie.GetNumber(node,"X") + Movie.GetNumber(ref_node,"X");
						local Y = ground_pos[2] + Movie.GetNumber(node,"Y") + Movie.GetNumber(ref_node,"Y");
						local Z = ground_pos[3] + Movie.GetNumber(node,"Z") + Movie.GetNumber(ref_node,"Z");
						local CameraObjectDistance = Movie.GetNumber(node,"CameraObjectDistance") + Movie.GetNumber(ref_node,"CameraObjectDistance");
						local CameraLiftupAngle = Movie.GetNumber(node,"CameraLiftupAngle") + Movie.GetNumber(ref_node,"CameraLiftupAngle");
						local CameraRotY = Movie.GetNumber(node,"CameraRotY") + Movie.GetNumber(ref_node,"CameraRotY");

						local facing = math.atan2(Movie.GetNumber(node,"X")+ Movie.GetNumber(ref_node,"X"), Movie.GetNumber(node,"Z")+ Movie.GetNumber(ref_node,"Z"));
						facing = facing + CameraRotY;
						node.attr.Internal_X = tostring(X);
						node.attr.Internal_Y = tostring(Y);
						node.attr.Internal_Z = tostring(Z);
						node.attr.Internal_CameraObjectDistance = tostring(CameraObjectDistance);
						node.attr.Internal_CameraLiftupAngle = tostring(CameraLiftupAngle);
						node.attr.Internal_CameraRotY = tostring(facing);
					end
				end
			end
		end
	end
end
function SpellCameraHelper.HasCamera(spell_config_file)
	local self = SpellCameraHelper;
	if(not spell_config_file)then return end
	local center_node,refpoints_map,camera_map,spell_map = self.GetConfig();
	spell_config_file = string.lower(spell_config_file);
	local camera_file = spell_map[spell_config_file];
	if(camera_file)then
		return true,camera_file;
	end
end
--return center_node,refpoints_map,camera_map,spell_map
function SpellCameraHelper.GetConfig()
	local self = SpellCameraHelper;
	self.LoadConfig();
	return self.center_node,self.refpoints_map,self.camera_map,self.spell_map;
end
function SpellCameraHelper.LoadConfig()
	local self = SpellCameraHelper;
	local config_file = "config/Aries/Cameras/SpellCamera/CameraLinks.xml";
	if(not self.load_config)then
		self.load_config = true;
		local xmlRoot = ParaXML.LuaXML_ParseFile(config_file);
		--中心点
		local center_node;
		for center_node in commonlib.XPath.eachNode(xmlRoot, "//root/center") do
			self.center_node = center_node;
			break;
		end
		--常用参照点
		local node;
		for node in commonlib.XPath.eachNode(xmlRoot, "//root/refpoints/item") do
			local id = node.attr.id;
			if(id)then
				id = string.lower(id);
				self.refpoints_map[id] = node;
			end
		end
		--摄影机库
		for node in commonlib.XPath.eachNode(xmlRoot, "//root/cameras/item") do
			local id = node.attr.id;
			if(id)then
				id = string.lower(id);
				self.camera_map[id] = node;
			end
		end
		--links
		for node in commonlib.XPath.eachNode(xmlRoot, "//root/links/item") do
			local camera = node.attr.camera;
			local spell = node.attr.spell;

			if(camera and spell)then
				camera = string.lower(camera);
				spell = string.lower(spell);
				if(self.camera_map and self.camera_map[camera])then
					local camera_node = self.camera_map[camera];
					self.spell_map[spell] = camera_node.attr.path;
				end
			end
		end
	end
end
--X Y Z CameraRotY是相对坐标
function SpellCameraHelper.ShowFrameNode_InEditor(RefID,X,Y,Z,CameraRotY,carster_id,target_id)
	local self = SpellCameraHelper;
	if(not RefID or not self.is_edit_mode)then return end
	X = X or 0;
	Y = Y or 0;
	Z = Z or 0;
	CameraRotY = CameraRotY or 0;
	carster_id = carster_id or 1;
	target_id = target_id or 5;
	local center_node,refpoints_map,camera_map,spell_map = self.GetConfig();
	local custom_node = refpoints_map[RefID];
	if(custom_node)then
		local facing = math.atan2(Movie.GetNumber(custom_node,"X"), Movie.GetNumber(custom_node,"Z"));
		if(RefID == "carster")then
			--进攻位置坐标
			local pos = self.GetArenaPointPosition_InEditor(carster_id);
			if(pos)then
				X = pos[1];
				Z = pos[2];
				facing = math.atan2(X,Z);
				facing = facing + Movie.GetNumber(center_node,"CameraRotY");
			end
		elseif(RefID == "target")then
			local pos = self.GetArenaPointPosition_InEditor(target_id);
			if(pos)then
				X = pos[1];
				Z = pos[2];
				facing = math.atan2(X,Z);
				facing = facing + Movie.GetNumber(center_node,"CameraRotY");
			end
		elseif(RefID == "ground")then
			--法阵中心坐标
			facing = Movie.GetNumber(center_node,"CameraRotY");
		else
			local iscustom = custom_node.attr.iscustom;
			--自定义参照点 以法阵中心为参照点
			if(iscustom and (iscustom == "True" or iscustom == "true"))then
				facing = math.atan2(X+Movie.GetNumber(custom_node,"X"),Z+Movie.GetNumber(custom_node,"Z"));
			end
		end
		X = Movie.GetNumber(center_node,"X") + Movie.GetNumber(custom_node,"X") + X;
		Y = Movie.GetNumber(center_node,"Y") + Movie.GetNumber(custom_node,"Y") + Y;
		Z = Movie.GetNumber(center_node,"Z") + Movie.GetNumber(custom_node,"Z") + Z;
		facing = facing + CameraRotY;
		local obj_name = "ShowCustomNode";
		local props_param = {
			x = X,
			y = Y+4,
			z = Z,
			facing = facing,
			scale = 1,
			assetfile = "model/06props/v5/06combat/Common/SequenceArrow/sequence_arrow_teen.x",
			visible = true,
			ismodel = true,
		}
		MovieRender_Model.CreateEntity(obj_name,props_param)
	end
end
--返回法阵1-8号位相对位置坐标
function SpellCameraHelper.GetArenaPointPosition_InEditor(index)
	local self = SpellCameraHelper;
	if(not self.arena_pos)then
		self.arena_pos = {
			{-14.72629,10.43018,},
			{-5.66545,17.12558,},
			{5.61966,17.12299,},
			{14.68445,10.43259,},
			{14.68985,-10.40605,},
			{5.63028,-17.11443,},
			{-5.66262,-17.13002,},
			{-14.72411,-10.4321,},
		};
	end
	return self.arena_pos[index];
end
function SpellCameraHelper.ShowCustomNode_InEditor(RefID)
	local self = SpellCameraHelper;
	if(not RefID or not self.is_edit_mode)then return end
	local center_node,refpoints_map,camera_map,spell_map = self.GetConfig();
	local X,Y,Z,CameraRotY;
	local carster_id,target_id = 1,5;
	self.ShowFrameNode_InEditor(RefID,X,Y,Z,CameraRotY,carster_id,target_id);
end
function SpellCameraHelper.GetCameraParams()
	local self = SpellCameraHelper;
	local RefID = "ground";
	local center_node,refpoints_map,camera_map,spell_map = self.GetConfig();
	local ref_node = refpoints_map[RefID];
	if(not ref_node)then
		return
	end
	--获取摄影机目前坐标
	local X,Y,Z = ParaCamera.GetLookAtPos()
	local _X,_Y,_Z = ParaCamera.GetLookAtPos()
	local att = ParaCamera.GetAttributeObject();
	local CameraObjectDistance = att:GetField("CameraObjectDistance", 10);
	local CameraLiftupAngle = att:GetField("CameraLiftupAngle", 0);
	local CameraRotY = att:GetField("CameraRotY", 0);

	local X = X - Movie.GetNumber(ref_node,"X") - Movie.GetNumber(center_node,"X");
	local Y = Y - Movie.GetNumber(ref_node,"Y") - Movie.GetNumber(center_node,"Y");
	local Z = Z - Movie.GetNumber(ref_node,"Z") - Movie.GetNumber(center_node,"Z");
	local CameraObjectDistance = CameraObjectDistance - Movie.GetNumber(ref_node,"CameraObjectDistance") - Movie.GetNumber(center_node,"CameraObjectDistance");
	local CameraLiftupAngle = CameraLiftupAngle - Movie.GetNumber(ref_node,"CameraLiftupAngle") - Movie.GetNumber(center_node,"CameraLiftupAngle");
	local CameraRotY = CameraRotY - Movie.GetNumber(ref_node,"CameraRotY") - Movie.GetNumber(center_node,"CameraRotY");	
	CameraRotY = CameraRotY - 1.57;
	local params = {
		X = X,
		Y = Y,
		Z = Z,
		CameraObjectDistance = CameraObjectDistance,
		CameraLiftupAngle = CameraLiftupAngle,
		CameraRotY = CameraRotY,
	}
	return params;
end
