--[[
Title: Storyboard
Author(s): Leio Zhang
Date: 2008/7/21
Desc: 

use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Storyboard.lua");
local Storyboard = CommonCtrl.Animation.Storyboard:new();
local StoryboardManager = CommonCtrl.Animation.StoryboardManager:new();
local DoubleAnimationUsingKeyFrames = CommonCtrl.Animation.DoubleAnimationUsingKeyFrames:new();
local LinearDoubleKeyFrame = CommonCtrl.Animation.LinearDoubleKeyFrame:new{
	KeyTime = "00:00:00",
	Value = 10,
}
DoubleAnimationUsingKeyFrames:addKeyframe(LinearDoubleKeyFrame)
local LinearDoubleKeyFrame = CommonCtrl.Animation.LinearDoubleKeyFrame:new{
	KeyTime = "00:00:01",
	Value = 100,
	SimpleEase = 1,
}
DoubleAnimationUsingKeyFrames:addKeyframe(LinearDoubleKeyFrame)
DoubleAnimationUsingKeyFrames:addKeyframe(LinearDoubleKeyFrame)
local DiscreteDoubleKeyFrame = CommonCtrl.Animation.DiscreteDoubleKeyFrame:new{
	KeyTime = "00:00:03",
	Value = 300,
}
DoubleAnimationUsingKeyFrames:addKeyframe(DiscreteDoubleKeyFrame)

local StringAnimationUsingKeyFrames = CommonCtrl.Animation.StringAnimationUsingKeyFrames:new();

local DiscreteStringKeyFrame = CommonCtrl.Animation.DiscreteStringKeyFrame:new{
	KeyTime = "00:00:00",
	Value = "哈哈0",
}
StringAnimationUsingKeyFrames:addKeyframe(DiscreteStringKeyFrame)
local DiscreteStringKeyFrame = CommonCtrl.Animation.DiscreteStringKeyFrame:new{
	KeyTime = "00:00:04",
	Value = "哈哈1",
}
StringAnimationUsingKeyFrames:addKeyframe(DiscreteStringKeyFrame)

local DiscreteStringKeyFrame = CommonCtrl.Animation.DiscreteStringKeyFrame:new{
	KeyTime = "00:00:05",
	Value = "哈哈2",
}
StringAnimationUsingKeyFrames:addKeyframe(DiscreteStringKeyFrame)

StoryboardManager:AddChild(DoubleAnimationUsingKeyFrames);
StoryboardManager:AddChild(StringAnimationUsingKeyFrames);
Storyboard:SetAnimatorManager(StoryboardManager);
Storyboard:doPlay();
------------------------------------------------------------
--]]

NPL.load("(gl)script/ide/Motion/AnimatorEngine.lua");
NPL.load("(gl)script/ide/Animation/CurtainLib.lua");
NPL.load("(gl)script/ide/Animation/TimeSpan.lua");
NPL.load("(gl)script/ide/Animation/Reverse.lua");
NPL.load("(gl)script/ide/Animation/KeyFrame.lua");
NPL.load("(gl)script/ide/Animation/AnimationUsingKeyFrames.lua");
NPL.load("(gl)script/ide/Animation/DoubleAnimationUsingKeyFrames.lua");
NPL.load("(gl)script/ide/Animation/StringAnimationUsingKeyFrames.lua");
NPL.load("(gl)script/ide/Animation/Point3DAnimationUsingKeyFrames.lua");
NPL.load("(gl)script/ide/Animation/ObjectAnimationUsingKeyFrames.lua");
NPL.load("(gl)script/ide/Animation/Point3DAnimationUsingPath.lua");
local Storyboard  = commonlib.inherit(CommonCtrl.Motion.AnimatorEngine, {
	name = "Storyboard_instance",
	mcmlTitle = "pe:storyboard",
	framerate = CommonCtrl.Animation.TimeSpan.framerate,
});
commonlib.setfield("CommonCtrl.Animation.Storyboard",Storyboard );

-- speedPreTime
-- @param steptime: "00:00:01"
function Storyboard:speedPreTime(steptime)
	if(not steptime) then 
		steptime = "00:00:01";
	end
	local stepframe = CommonCtrl.Animation.TimeSpan.GetFrames(steptime);
	local frame = self:GetTime();
	frame = frame - stepframe;
	self:gotoAndPlay(frame);
end
-- speedNextTime
-- @param steptime: "00:00:01"
function Storyboard:speedNextTime(steptime)
	if(not steptime) then 
		steptime = "00:00:01";
	end
	local stepframe = CommonCtrl.Animation.TimeSpan.GetFrames(steptime);
	local frame = self:GetTime();
	frame = frame + stepframe;
	self:gotoAndPlay(frame);
end
-- speedPreFrame
-- @param stepframe: 1
function Storyboard:speedPreFrame(stepframe)
	if(not stepframe) then 
		stepframe = 1; 
	end
	local frame = self:GetTime();
	frame = frame - stepframe;
	self:gotoAndPlay(frame);
end
-- speedNextFrame
-- @param stepframe: 1
function Storyboard:speedNextFrame(stepframe)
	if(not stepframe) then 
		stepframe = 1; 
	end
	local frame = self:GetTime();
	frame = frame + stepframe;
	self:gotoAndPlay(frame);
end
-- gotoAndStopPreFrame
function Storyboard:gotoAndStopPreFrame()
	self:speedPreFrame();
	self:_doPause();
end
-- gotoAndStopNextFrame
function Storyboard:gotoAndStopNextFrame()
	self:speedNextFrame();
	self:_doPause();
end
-- gotoAndStopPreTime
function Storyboard:gotoAndStopPreTime()
	self:speedPreTime()
	self:_doPause();
end
-- gotoAndStopNextTime
function Storyboard:gotoAndStopNextTime()
	self:speedNextTime()
	self:_doPause();
end

function Storyboard:ReverseToMcml()
	if(not self.animatorManager)then return "" end
	local node_value = "";
	local k,frame;
	for k,frame in ipairs(self.animatorManager.levelList) do
		node_value = node_value..frame:ReverseToMcml();
	end
	local p_node = "\r\n";
	local str = string.format([[<%s name="%s" repeatCount = "%s">%s</%s>%s]],self.mcmlTitle,self.name,self.repeatCount,"\r\n"..node_value,self.mcmlTitle,p_node);
	return str;
end
---------------------------------------------------------
-- StoryboardManager control
---------------------------------------------------------
local StoryboardManager  = commonlib.inherit(CommonCtrl.Motion.AnimatorManager, {
	name = "StoryboardManager_instance",
});
commonlib.setfield("CommonCtrl.Animation.StoryboardManager",StoryboardManager );


--DoPlay
function StoryboardManager:DoPlay()
	local k , v;
	for k,v in ipairs(self.levelList) do
		local animationKeyFrames = v;
		animationKeyFrames:ClearTempValue();
	end
end
--DoPause
function StoryboardManager:DoPause()
	
end
--DoResume
function StoryboardManager:DoResume()
	
end
--DoStop
function StoryboardManager:DoStop()
	
end
--DoEnd
function StoryboardManager:DoEnd()
	
end
--OnTimeChange
function StoryboardManager:OnTimeChange()
	local k , v;
	local storyboard = self.parent;
	if(not storyboard)then return; end
	local time = storyboard:GetTime();
	for k,v in ipairs(self.levelList) do
		local animationKeyFrames = v;
		local result,curKeyframe,frame = animationKeyFrames:getValue(time)
		CommonCtrl.Animation.Util.SetDisplayObjProperty(result,animationKeyFrames,curKeyframe,frame)
		--commonlib.echo({time,result});
	end
end

function StoryboardManager:Destroy()
	
end

function StoryboardManager:gotoAndPlay(frame)
	local k , v;
	local storyboard = self.parent;
	if(not storyboard or not frame)then return; end
	for k,v in ipairs(self.levelList) do
		local animationKeyFrames = v;
		--local result = animationKeyFrames:getValue(frame)
		--CommonCtrl.Animation.Util.SetDisplayObjProperty(result,animationKeyFrames)
		local result,curKeyframe,frame = animationKeyFrames:getValue(frame)
		CommonCtrl.Animation.Util.SetDisplayObjProperty(result,animationKeyFrames,curKeyframe,frame)
	end
end

