--[[
Title: preload a movie
Author(s): Leio Zhang
Date: 2008/9/24
Desc:
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/PreLoader.lua");
------------------------------------------------------------
]]
NPL.load("(gl)script/ide/commonlib.lua");
local PreLoader = {
	name = "PerLoader_instance",
	
}
commonlib.setfield("CommonCtrl.Animation.Motion.PreLoader",PreLoader );
function PreLoader.DataBind(moviescript)
	if(not moviescript)then return; end
	local self = PreLoader;
	self.moviescript = moviescript;
	self.allObjects = self._GetAllObjects()
end
function PreLoader.CreateAllObjects()
	local self = PreLoader;
	local allObjects = self.allObjects;
	if(not allObjects)then return; end
		local k,param;	
		for k,param in ipairs(allObjects) do
			local name = param["name"];		
			local type = param["Type"];
			if(name)then
				if(type)then					
					local alignment,x,y,width,height = param["Alignment"],param["X"], param["Y"], param["Width"], param["Height"]
					local type = param["Type"];
					local bg = param["Bg"];
					local text = param["Text"];
					local visible = param["Visible"];
					local c = ParaUI.CreateUIObject(type,name,alignment,x,y,width,height);
					c.visible = visible;
					if(type == "container")then
						if(bg)then
							c.background = bg;
						end
					else
						if(text)then
							c.text = text;
						end
					end
					local root = ParaUI.GetUIObject("root");
					if(root:IsValid())then
						root:AddChild(c);
					end
				else
					local obj = ObjEditor.GetObjectByParams(param)
					if(not obj)then
						Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_CreateObject, obj_params=param});
					end	
				end
			end
		end
	self.FindAllInternalObj()
end
-------------------------------------------------
function PreLoader.FindAllInternalObj()
	local self = PreLoader;
	local allObjects = self.allObjects;
	if(not allObjects)then return; end
		local k,param;	
		for k,param in ipairs(allObjects) do
			local name = param["name"];		
			local type = param["Type"];
			if(name)then
				if(type)then					
					
				else
					local obj = ObjEditor.GetObjectByParams(param)
					if(not param.IsCharacter and obj)then
						CommonCtrl.Animation.Motion.TargetResourceManager[name] = obj;
					end
				end
			end
		end
end
-------------------------------------------------
function PreLoader.StopAllObjects()
	local self = PreLoader;
	self.StopAllSounds();
	local allObjects = self.allObjects;
	if(not allObjects)then return; end
		local k,param;	
		for k,param in ipairs(allObjects) do
			local name = param["name"];		
			local character = ParaScene.GetCharacter(name);
			if(character:IsValid())then
				character:ToCharacter():Stop();
			end		
		end
end
function PreLoader.DestoryAllObjects()
	local self = PreLoader;
	self.StopAllSounds()
	local allObjects = self.allObjects;
	if(not allObjects)then return; end
	local k,param;
	for k,param in ipairs(allObjects) do
		local type = param["Type"];
		if(type)then
			local name = param["name"];
			if(name)then
				ParaUI.Destroy(name);
			end
		else
			Map3DSystem.SendMessage_obj({type = Map3DSystem.msg.OBJ_DeleteObject, obj_params=param});
		end
	end
	self.ClearAllObjByViewBox();
end
function PreLoader.StopAllSounds()
	local self = PreLoader;
	if(not self.moviescript)then return; end	
	local sounds = self.moviescript.soundsNode;
	if(sounds)then
		local sound;
		for sound in sounds:next() do
			local frames = self.moviescript:GetNodeKeyFrams(sound)
			if(frames)then
				local keyframe;
				for __,keyframe in ipairs(frames.keyframes) do
					local target = keyframe:GetValue();
					if(target)then
						local path = target.Path;
						if(path)then
							local file = ParaIO.GetCurDirectory(0)..path;
							if(ParaIO.DoesFileExist(file, true))then
								ParaAudio.StopWaveFile(path, true);
							end	
						end
					end
				end
			end
		end	
	end
end
function PreLoader._GetAllObjects()
	local self = PreLoader;
	if(not self.moviescript)then return; end
	return self.moviescript:GetAllStaticObjects()
end
