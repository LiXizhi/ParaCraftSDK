--[[
Title: MotionRender
Author(s): Leio
Date: 2010/06/12
Desc: 
------------------------------------------------------------
NPL.load("(gl)script/ide/MotionEx/MotionRender.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Display3D/SceneManager.lua");
NPL.load("(gl)script/apps/Aries/Combat/CombatCameraView.lua");
local SceneManager = commonlib.gettable("CommonCtrl.Display3D.SceneManager");
local MotionRender = commonlib.gettable("MotionEx.MotionRender");
local CombatCameraView = commonlib.gettable("MotionEx.CombatCameraView");

function MotionRender.DoUpdate(renderType,renderTarget,renderScene,renderOrigin,renderNode,memory,state)
	if(not renderType)then return end;
	local runFunc = MotionRender.maps[renderType];
	if(runFunc)then
		runFunc(renderType,renderTarget,renderScene,renderOrigin,renderNode,memory,state);
	end
end
function MotionRender.audio_update(renderType,renderTarget,renderScene,renderOrigin,renderNode,memory,state)
	if(not renderNode)then return end
	local assetfile = renderNode[1];
	renderNode.state = state;
	if(assetfile and state)then
		local audio_src = AudioEngine.CreateGet(assetfile)
		audio_src.file = assetfile;
		if(state == "in")then
			audio_src:play();
		elseif(state == "out")then
			audio_src:stop();
		end
	end
end
--更新camera
--renderOrigin = { FollowTarget = nil, CameraObjectDistance = 0, CameraLiftupAngle = 0, CameraRotY = 0, };
function MotionRender.aries_camera_update(renderType,renderTarget,renderScene,renderOrigin,renderNode,memory)
	if(not renderNode)then return end
	renderOrigin = renderOrigin or { x = 0, y = 0, z = 0, CameraObjectDistance = 0, CameraLiftupAngle = 0, CameraRotY = 0,}
	local att = ParaCamera.GetAttributeObject();

	local x,y,z = ParaCamera.GetLookAtPos()
	local target;
	--如果有跟随的物体
	if(renderNode.FollowTarget)then
		target = renderNode.FollowTarget;
	else
		target = CombatCameraView.GetFollowObjID();
	end
	if(target and renderNode.AllowFollow)then
		local miniscenename = CombatCameraView.GetMinisceneName();
		if(miniscenename) then
			-- mini scene
			local effectGraph = ParaScene.GetMiniSceneGraph(miniscenename);
			if(effectGraph and effectGraph:IsValid() == true) then
				local entity = effectGraph:GetObject(target);
				if(entity and entity:IsValid() == true)then
					x, y, z = entity:GetPosition();
				end
			end
		else
			-- main scene
			local entity = ParaScene.GetObject(target);
			if(entity and entity:IsValid() == true)then
				x, y, z = entity:GetPosition();
			end
		end
	end
	if(renderNode.x)then
		x = renderNode.x + renderOrigin.x;
	end
	if(renderNode.y)then
		y = renderNode.y + renderOrigin.y;
	end
	if(renderNode.z)then
		z = renderNode.z + renderOrigin.z;
	end
	ParaCamera.SetLookAtPos(x, y, z)

	local CameraObjectDistance = renderNode.CameraObjectDistance;
	local CameraLiftupAngle = renderNode.CameraLiftupAngle;
	local CameraRotY = renderNode.CameraRotY;
	if(CameraObjectDistance)then
		CameraObjectDistance = CameraObjectDistance + renderOrigin.CameraObjectDistance;
		att:SetField("CameraObjectDistance", CameraObjectDistance);
	end
	if(CameraLiftupAngle)then
		CameraLiftupAngle = CameraLiftupAngle + renderOrigin.CameraLiftupAngle;
		att:SetField("CameraLiftupAngle", CameraLiftupAngle);
	end
	if(CameraRotY)then
		CameraRotY = CameraRotY + renderOrigin.CameraRotY;
		att:SetField("CameraRotY", CameraRotY);
	end
	
end
function MotionRender.movie_entity_update(renderType,renderTarget,renderScene,renderOrigin,renderNode,memory)
	NPL.load("(gl)script/ide/MotionEx/MovieController.lua");
	local MovieController = commonlib.gettable("MotionEx.MovieController")
	renderTarget = MovieController.updatenode_id_entityid_map[renderTarget];
	MotionRender.entity_update(renderType,renderTarget,renderScene,renderOrigin,renderNode,memory)
end
function MotionRender.entity_update(renderType,renderTarget,renderScene,renderOrigin,renderNode,memory)
	if(not renderTarget or not renderNode)then return end
	renderOrigin = renderOrigin or { x = 0, y = 0, z = 0, facing = 0,}

	local player;
	player = ParaScene.GetObject(renderTarget);
	if(not player or not player:IsValid())then return end
	local x,y,z = player:GetPosition();
	local facing = player:GetFacing();
	if(renderNode.x)then
		x = renderNode.x + renderOrigin.x;
	end
	if(renderNode.y)then
		y = renderNode.y + renderOrigin.y;
	end
	if(renderNode.z)then
		z = renderNode.z + renderOrigin.z;
	end
	if(renderNode.facing)then
		local facing = renderNode.facing + renderOrigin.facing;
	end
	--commonlib.echo({ renderTarget = renderTarget, x = x, y = y, z = z, facing = facing });
	player:SetPosition(x,y,z);
	player:SetFacing(facing);
end
function MotionRender.headontext_update(renderType,renderTarget,renderScene,renderOrigin,renderNode,memory)
	if(not renderNode)then return end
	local txt = renderNode[1];
	if(txt and memory.txt ~= txt)then
		memory.txt = txt;
		local player = ParaScene.GetPlayer();
		headon_speech.Speek(player.name, txt, 2);
	end
end
-----------------------------------------------
--aries_preloading_text
-----------------------------------------------
function MotionRender.aries_preloading_text_update_DoPlay()
	local _parent=ParaUI.GetUIObject("aries_preloading_text_container");
	local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
	if(_parent:IsValid() == false)then		
		local _this = ParaUI.CreateUIObject("container","aries_preloading_text_container", "_mb", 0, 0, 0, 80)
		_this.background="Texture/whitedot.png";
		_guihelper.SetUIColor(_this, "0 0 0");
		_this:AttachToRoot();
		_this.zorder = 1000;
		_parent = _this;
		
		_this = ParaUI.CreateUIObject("text", "aries_preloading_text_container_text", "_fi", 0,15,0,15)
		_this.text = "";
		_this.font="System;16";
		--_this.scalingx = 1.2;
		--_this.scalingy = 1.2;
		_guihelper.SetFontColor(_this, "255 255 255");
		_this.shadow = false;
		_guihelper.SetUIFontFormat(_this,5);
		_parent:AddChild(_this);
	else
		_parent.visible = true;
	end

	local _parent=ParaUI.GetUIObject("aries_preloading_text_container_top");
	if(_parent:IsValid() == false)then
		local _this = ParaUI.CreateUIObject("container","aries_preloading_text_container_top", "_mt", 0, 0, 0, 80)
		_this.background="Texture/whitedot.png";
		_guihelper.SetUIColor(_this, "0 0 0");
		_this:AttachToRoot();
	else
		_parent.visible = true;
	end
end
function MotionRender.aries_preloading_text_update_DoEnd()
	ParaUI.Destroy("aries_preloading_text_container_text");
	ParaUI.Destroy("aries_preloading_text_container");
	ParaUI.Destroy("aries_preloading_text_container_top");
	--local _this = ParaUI.GetUIObject("aries_preloading_text_container_text");
	--if(_this and _this:IsValid())then
		--_this.text = "";	
	--end
	--local _this = ParaUI.GetUIObject("aries_preloading_text_container");
	--if(_this and _this:IsValid())then
		--_this.visible = false;
	--end
	--local _this = ParaUI.GetUIObject("aries_preloading_text_container_top");
	--if(_this and _this:IsValid())then
		--_this.visible = false;
	--end
end
function MotionRender.aries_preloading_text_update(renderType,renderTarget,renderScene,renderOrigin,renderNode,memory,state)
	if(not renderNode or not memory)then return end
	if(memory.localtime and memory.local_max_time)then
		if(memory.localtime == 0)then
			MotionRender.aries_preloading_text_update_DoPlay();
		end
	end
	local txt = renderNode[1];
	if(txt and memory.txt ~= txt)then
		memory.txt = txt;
		local _this = ParaUI.GetUIObject("aries_preloading_text_container_text");
		if(_this:IsValid())then
			_this.text = txt;	
		end
	end
end
function MotionRender.ForceEnd()
	MotionRender.aries_preloading_text_update_DoEnd();
end
MotionRender.maps = {
	["audio"] = MotionRender.audio_update,
	["aries_camera"] = MotionRender.aries_camera_update,
	["entity"] = MotionRender.entity_update,
	["movie_entity"] = MotionRender.movie_entity_update,--see MovieController
	["headontext"] = MotionRender.headontext_update,
	["aries_preloading_text"] = MotionRender.aries_preloading_text_update,
}