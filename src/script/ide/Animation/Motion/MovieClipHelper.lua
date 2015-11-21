--[[
Title: MovieClipHelper
Author(s): Leio Zhang
Date: 2009/1/10
use the lib:
------------------------------------------------------------
NPL.load("(gl)script/ide/Animation/Motion/MovieClipHelper.lua");
------------------------------------------------------------
--]]
NPL.load("(gl)script/ide/Animation/Motion/MovieClip.lua");
local MovieClipHelper = {
}
commonlib.setfield("CommonCtrl.Animation.Motion.MovieClipHelper",MovieClipHelper);
-- @param objName: the name of 2d object(button)
-- @param property: the property of 2d object(X,Y,Width,Height,Rot,ScaleX,ScaleY,Alpha,Visible)
-- @param duration: a timer string("hour:minute:second")
-- @param fromValue: a start value
-- @param toValue: a end value
-- @param simpleEase: default value is 0, -1 <= simpleEase <= 1
function MovieClipHelper.PlayControlTargetProperty(objName,property,duration,fromValue,toValue,simpleEase)
	if(not objName or not property or not duration or not fromValue or not toValue)then return end
	if(not simpleEase)then simpleEase = 0; end
	if(simpleEase < -1 )then simpleEase = -1; end
	if(simpleEase > 1 )then simpleEase = 1; end
	
	local root_mc = CommonCtrl.Animation.Motion.MovieClip:new();
	-------------layer_1
	local Name = objName;
	local layer_1 = CommonCtrl.Animation.Motion.LayerManager:new();
	local targetKeyFrames = CommonCtrl.Animation.Motion.TargetAnimationUsingKeyFrames:new{TargetName = Name,TargetProperty = Name};

	local t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = "00:00:00", SimpleEase = simpleEase,}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new();
	controlTarget[property] = fromValue;
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);

	local t_frame = CommonCtrl.Animation.Motion.LinearTargetKeyFrame:new{KeyTime = duration, SimpleEase = simpleEase,}
	local controlTarget = CommonCtrl.Animation.Motion.ControlTarget:new();
	controlTarget[property] = toValue;
	t_frame:SetValue(controlTarget);
	targetKeyFrames:addKeyframe(t_frame);
	
	-- add child
	layer_1:AddChild(targetKeyFrames);
	root_mc:AddLayer(layer_1);
		
	root_mc:UpdateDuration();
	
	local mcPlayer = CommonCtrl.Animation.Motion.McPlayer:new();
	mcPlayer:SetClip(root_mc);
	mcPlayer:Play();
end