--[[
Title: StoryboardRecorder
Author(s): Leio Zhang
Date: 2008/8/5
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/StoryboardRecorder.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Animation/TimeSpan.lua");
NPL.load("(gl)script/ide/Animation/Storyboard.lua");
local StoryboardRecorder = {
	frames = {},
	curKeyTime = "00:00:00",
	curKeyFrame = nil,
	storyboard = nil,
	isRecording = false,
	outputpath = "ggggggggggggggggg.xml",
}
commonlib.setfield("CommonCtrl.Animation.StoryboardRecorder",StoryboardRecorder);
function StoryboardRecorder.gotoAndStopPreTime(args)
	local self = StoryboardRecorder;
	if(not self.storyboard)then return; end
	self.unRecorder()
	self.storyboard:gotoAndStopPreTime(args);
end
function StoryboardRecorder.gotoAndStopNextTime(args)
	local self = StoryboardRecorder;
	if(not self.storyboard)then return; end
	self.unRecorder()
	self.storyboard:gotoAndStopNextTime(args);
end
function StoryboardRecorder.speedPreTime(args)
	local self = StoryboardRecorder;
	if(not self.storyboard)then return; end
	self.unRecorder()
	self.storyboard:speedPreTime(args);
end
function StoryboardRecorder.speedNextTime(args)
	local self = StoryboardRecorder;
	if(not self.storyboard)then return; end
	self.unRecorder()
	self.storyboard:speedNextTime(args);
end
function StoryboardRecorder.doPlay()
	local self = StoryboardRecorder;
	if(not self.storyboard)then return; end
	self.unRecorder()
	self.storyboard:doPlay();
end
function StoryboardRecorder.doStop()
	local self = StoryboardRecorder;
	if(not self.storyboard)then return; end
	self.unRecorder()
	self.storyboard:doStop();
end
function StoryboardRecorder.doEnd()
	local self = StoryboardRecorder;
	if(not self.storyboard)then return; end
	self.unRecorder()
	self.storyboard:doEnd();
end
function StoryboardRecorder.doPause()
	local self = StoryboardRecorder;
	if(not self.storyboard)then return; end
	self.unRecorder()
	if(self.storyboard:isPlaying())then
		self.storyboard:doPause();
	else
		self.storyboard:doResume();
	end
end
function StoryboardRecorder.setHook(bool)
	local self = StoryboardRecorder;
	if(not self.storyboard)then return; end
	if(bool == true)then
		CommonCtrl.os.hook.SetWindowsHook({hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET, 
		callback = CommonCtrl.Animation.StoryboardRecorder.Hook_SceneObject, 
		hookName = "Record3DObject_Hook", appName = "scene", wndName = "object"});
	else
		CommonCtrl.os.hook.UnhookWindowsHook({hookName = "Record3DObject_Hook", hookType = CommonCtrl.os.hook.HookType.WH_CALLWNDPROCRET})
	end
end
function StoryboardRecorder.doRecorder()
	local self = StoryboardRecorder;
	if(not self.storyboard)then return; end
	self.isRecording = true;
	self.setHook(true)
end
function StoryboardRecorder.unRecorder()
	local self = StoryboardRecorder;
	if(not self.storyboard)then return; end
	self.isRecording = false;
	self.setHook(false)
end
function StoryboardRecorder.clear()
	local self = StoryboardRecorder;
	self.frames = {};
	self.curKeyTime = "00:00:00";
	self.curKeyFrame = nil;
	self.storyboard = nil;
	self.isRecording = false;
	self.setHook(false)
end
function StoryboardRecorder.init()
	local self = StoryboardRecorder;
	self.clear()
	-- create a new recorder
	self.storyboard = CommonCtrl.Animation.Storyboard:new();
	local storyboardManager = CommonCtrl.Animation.StoryboardManager:new();
	self.storyboard.animatorManager = storyboardManager;
end
-- when will be recorded,timer formats is "00:00:01"
function StoryboardRecorder.setCurKeyTime(v)
	local self = StoryboardRecorder;
	if(not v)then return; end
	self.curKeyTime = v;
end
function StoryboardRecorder.getCurKeyTime()
	local self = StoryboardRecorder;
	return self.curKeyTime;
end
function StoryboardRecorder.getCurKeyFrame()
	local self = StoryboardRecorder;
	local frame = CommonCtrl.Animation.TimeSpan.GetFrames(self.curKeyTime);
	return frame;
end
function StoryboardRecorder.getStoryboardManager()
	local self = StoryboardRecorder;
	if(not self.storyboard)then return; end
	return self.storyboard.animatorManager;
end
-- find out which keyframes and keyframe will be added or updated at KeyTime
function StoryboardRecorder.getKeyFrames(TargetName,TargetProperty,KeyTime,FramesType,FrameType)
	local self = StoryboardRecorder;
	local storyboardManager = self.getStoryboardManager();
	if(not self.frames or not storyboardManager)then return; end
	local keyframes,v,_keyframes;
	for _keyframes,v in pairs(self.frames) do
		if(_keyframes.TargetProperty == TargetProperty and _keyframes.TargetName ==  TargetName)then
			-- find keyframes
			keyframes = _keyframes;
			break;
		end
	end
	if(not keyframes)then
		keyframes = self.createKeyFrames(TargetName,TargetProperty,FramesType);
		if(keyframes)then
			self.frames[keyframes] = keyframes;
			
			storyboardManager:AddChild(keyframes);
		end
	end
	local keyframe = keyframes:hasKeyFrame(KeyTime);
	if(not keyframe)then	
		keyframe = self.createKeyFrame(KeyTime,FrameType);
		if(keyframe)then
			--commonlib.echo({"keyframe.KeyTime",keyframe.KeyTime});
			keyframes:addKeyframe(keyframe)
		end
	end
	self.storyboard:SetAnimatorManager(storyboardManager);
	
	return keyframes,keyframe
end
--create a keyFrame 
function StoryboardRecorder.createKeyFrame(KeyTime,FrameType)
	if(not FrameType)then return  end
	local frame;
	if(FrameType == "discreteObjectKeyFrame")then
		frame  = CommonCtrl.Animation.DiscreteObjectKeyFrame:new{
			KeyTime = KeyTime
		}
	end
	return frame;
end
-- create a animationUsingKeyFrames
function StoryboardRecorder.createKeyFrames(TargetName,TargetProperty,FramesType)
	if(not FramesType)then return end
	local frames;
	if(FramesType == "objectAnimationUsingKeyFrames")then
		frames = CommonCtrl.Animation.ObjectAnimationUsingKeyFrames:new{
			TargetName = TargetName,
			TargetProperty = TargetProperty,
		}
	end
	return frames;
end
-- a callback function of "whenUnRecord3DObject_Hook"
function StoryboardRecorder.Hook_SceneObject(nCode, appName, msg)
	local self = StoryboardRecorder;
	if(not self.storyboard)then return; end
	local keyframes,keyframe;
	local obj_params = msg.obj_params;
	local targetName = "object_editor";
	local targetProperty;
	local keytime = self.getCurKeyTime();
	local framesType,frameType;
	if(msg.type == Map3DSystem.msg.OBJ_ModifyObject) then
		targetProperty = "ModifyMeshPhysicsObject";
		framesType = "objectAnimationUsingKeyFrames";
		frameType = "discreteObjectKeyFrame";
		
		keyframes,keyframe = self.getKeyFrames(targetName,targetProperty,keytime,framesType,frameType)

		local value = keyframe:GetValue();
		if(not value)then
			value = {};
			table.insert(value,obj_params);
			keyframe:SetValue(value);
		else
			local k,v;
			for k,v in ipairs(value) do
				if(v.name == obj_params.name)then
					value[k] = obj_params;
					break;
				end
			end
		end
	elseif(msg.type == Map3DSystem.msg.OBJ_CreateObject) then

		targetProperty = "CreateMeshPhysicsObject";
		framesType = "objectAnimationUsingKeyFrames";
		frameType = "discreteObjectKeyFrame";
		
		keyframes,keyframe = self.getKeyFrames(targetName,targetProperty,keytime,framesType,frameType)

		local value = keyframe:GetValue();
		if(not value)then
			value = {};
		end
		table.insert(value,obj_params);
		keyframe:SetValue(value);
		--commonlib.echo(obj_params);
		local KeyFramesPool = CommonCtrl.Animation.KeyFramesPool;
		local hadobject = KeyFramesPool.getObject(keyframes,keyframe,obj_params.name);
		if(not hadobject)then
			KeyFramesPool.addObject(keyframes,keyframe,obj_params.name);
		end
	elseif(msg.type == Map3DSystem.msg.OBJ_DeleteObject) then
		targetProperty = "DeleteMeshPhysicsObject";
		framesType = "objectAnimationUsingKeyFrames";
		frameType = "discreteObjectKeyFrame";
		
		keyframes,keyframe = self.getKeyFrames(targetName,targetProperty,keytime,framesType,frameType)

		local value = keyframe:GetValue();
		if(not value)then
			value = {};
		end
		table.insert(value,obj_params);
		keyframe:SetValue(value);
	end
	return nCode
end
function StoryboardRecorder.SaveMotionFile()
	local self = StoryboardRecorder;
	if(not self.storyboard)then return; end
	--local lrc = [[
	 --[offset:1000]
--[00:03.13]歌曲名：安静
--[00:04.65]歌词：
--[00:05.63]    词曲：周杰伦
--
--
--[02:27.54][00:27.76]只剩下钢琴陪我谈了一天
--[02:32.83][00:33.19]睡着的大提琴 安静的旧旧的
--
--[02:40.55][00:41.06]我想你已表现的非常明白
--[02:46.03][00:46.48]我懂我也知道 你没有舍不得
--
--[02:53.77][00:54.88]你说你也会难过我不相信
--[03:00.61][01:00.82]牵着你陪着我 也只是曾经
--[03:06.43][01:06.99]希望他是真的比我还要爱你
--[03:13.08][01:14.95]我才会逼自己离开
--
--[03:21.04][01:21.31]你要我说多难堪 我根本不想分开
--[03:27.35][01:28.05]为什么还要我用微笑来带过
--[03:34.15][01:34.28]我没有这种天份 包容你也接受他
--[03:40.71][01:40.87]不用担心的太多 我会一直好好过
--[03:47.51][01:47.58]你已经远远离开 我也会慢慢走开
--[03:54.07][01:54.15]为什么我连分开都迁就着你
--[04:00.84][02:00.91]我真的没有天份 安静的没这么快
--[04:07.17][02:07.80]我会学着放弃你 是因为我太爱你
--]]
	--NPL.load("(gl)script/ide/Animation/Reverse.lua");
	--local keyframes = CommonCtrl.Animation.Reverse.LrcToMcml(lrc,nil)
	--local storyboardManager = self.getStoryboardManager();
	--storyboardManager:AddChild(keyframes)
	--self.storyboard:SetAnimatorManager(storyboardManager);
	local file = ParaIO.open(self.outputpath, "w");
	if(file ~= nil and file:IsValid()) then
		file:WriteString(self.storyboard:ReverseToMcml())
		file:close();
	end
end
function StoryboardRecorder.OpenMotionFile(path)
	local self = StoryboardRecorder;
	NPL.load("(gl)script/kids/3DMapSystemApp/mcml/PageCtrl.lua");
	if(self.MyPage)then
		self.MyPage:Close()
	end
	local MyPage = Map3DSystem.mcml.PageCtrl:new({url=path or self.outputpath});
	self.MyPage = MyPage;
	function MyPage:OnCreate()      
        StoryboardRecorder.storyboard =  MyPage:CallMethod("Storyboard1", "GetEngine", "");
    end
    local _, _, screenWidth, screenHeight = ParaUI.GetUIObject("root"):GetAbsPosition();
	--MyPage:Create("movie file", nil, "_lb", 0, 0, screenWidth, -64);
	MyPage:Create("movie file", nil, "_lt", 0, 0, screenWidth, 64);
end
